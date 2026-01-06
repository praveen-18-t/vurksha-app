/**
 * Order Service
 * Handles order creation, lifecycle management, and payment coordination
 */

import Fastify, { FastifyInstance, FastifyPluginCallback, FastifyRequest, FastifyReply } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import jwt from '@fastify/jwt';
import { PrismaClient, OrderStatus, PaymentStatus, PaymentMethod } from '@prisma/client';
import Redis from 'ioredis';
import amqp, { Channel, Connection } from 'amqplib';
import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';
import {
  requestIdMiddleware,
  errorHandler,
  healthCheckPlugin,
  HealthChecks,
  logger,
  successResponse,
  errorResponse,
  ErrorCodes,
  EventTypes,
  DomainEvent,
  OrderCreatedEvent,
  OrderConfirmedEvent,
  Exchanges,
  Queues,
} from '@vurksha/shared';

// Configuration
const config = {
  port: parseInt(process.env.PORT || '3003'),
  host: process.env.HOST || '0.0.0.0',
  jwtSecret: process.env.JWT_SECRET || 'development-secret',
  databaseUrl: process.env.DATABASE_URL!,
  redisUrl: process.env.REDIS_URL!,
  rabbitmqUrl: process.env.RABBITMQ_URL!,
  deliveryFee: 40, // Default delivery fee
  minOrderAmount: 199,
  freeDeliveryThreshold: 499,
};

// Clients
const prisma = new PrismaClient();
const redis = new Redis(config.redisUrl);
let rabbitChannel: Channel | null = null;

const log = logger.child({ service: 'order-service' });

// RabbitMQ setup
async function setupRabbitMQ(): Promise<void> {
  const connection = await amqp.connect(config.rabbitmqUrl);
  rabbitChannel = await connection.createChannel();

  await rabbitChannel.assertExchange(Exchanges.DOMAIN_EVENTS, 'topic', { durable: true });

  // Set up consumers
  await setupEventConsumers();

  connection.on('close', () => {
    log.warn('RabbitMQ connection closed, reconnecting...');
    setTimeout(setupRabbitMQ, 5000);
  });

  log.info('RabbitMQ connected');
}

async function setupEventConsumers(): Promise<void> {
  if (!rabbitChannel) return;

  // Listen for payment completed events
  const paymentQueue = 'order.payment_completed';
  await rabbitChannel.assertQueue(paymentQueue, { durable: true });
  await rabbitChannel.bindQueue(paymentQueue, Exchanges.DOMAIN_EVENTS, EventTypes.PAYMENT_COMPLETED);

  rabbitChannel.consume(paymentQueue, async (msg) => {
    if (!msg) return;

    try {
      const event = JSON.parse(msg.content.toString());
      await handlePaymentCompleted(event);
      rabbitChannel!.ack(msg);
    } catch (error) {
      log.error({ error }, 'Failed to process payment event');
      rabbitChannel!.nack(msg, false, true); // Requeue
    }
  });
}

async function handlePaymentCompleted(event: DomainEvent<{ orderId: string; transactionId: string }>): Promise<void> {
  const { orderId, transactionId } = event.payload;

  await prisma.$transaction(async (tx) => {
    const order = await tx.order.findUnique({ where: { id: orderId } });
    if (!order || order.status !== OrderStatus.PENDING) return;

    await tx.order.update({
      where: { id: orderId },
      data: {
        status: OrderStatus.CONFIRMED,
        paymentStatus: PaymentStatus.COMPLETED,
        confirmedAt: new Date(),
      },
    });

    await tx.orderEvent.create({
      data: {
        orderId,
        eventType: 'payment_confirmed',
        previousStatus: OrderStatus.PENDING,
        newStatus: OrderStatus.CONFIRMED,
        actorType: 'system',
        metadata: { transactionId },
      },
    });
  });

  // Publish order confirmed event
  const confirmEvent: DomainEvent<OrderConfirmedEvent> = {
    eventId: uuidv4(),
    eventType: EventTypes.ORDER_CONFIRMED,
    aggregateId: orderId,
    aggregateType: 'Order',
    timestamp: new Date().toISOString(),
    version: 1,
    payload: {
      orderId,
      confirmedAt: new Date().toISOString(),
      estimatedDelivery: new Date(Date.now() + 24 * 60 * 60 * 1000).toISOString(),
    },
    metadata: {
      correlationId: event.metadata.correlationId,
      source: 'order-service',
    },
  };

  await publishEvent(confirmEvent, EventTypes.ORDER_CONFIRMED);
}

async function publishEvent<T>(event: DomainEvent<T>, routingKey: string): Promise<void> {
  if (!rabbitChannel) {
    log.warn('RabbitMQ not connected, event not published');
    return;
  }

  rabbitChannel.publish(
    Exchanges.DOMAIN_EVENTS,
    routingKey,
    Buffer.from(JSON.stringify(event)),
    { persistent: true, contentType: 'application/json' }
  );
}

// Order number generator
async function generateOrderNumber(): Promise<string> {
  const year = new Date().getFullYear();
  const key = `order:counter:${year}`;
  const count = await redis.incr(key);
  await redis.expire(key, 366 * 24 * 60 * 60); // 1 year
  return `VRK-${year}-${count.toString().padStart(6, '0')}`;
}

// Server setup
async function createServer(): Promise<FastifyInstance> {
  const server = Fastify({
    logger: false,
    requestIdHeader: 'x-request-id',
    trustProxy: true,
  });

  await server.register(helmet, { contentSecurityPolicy: false });
  await server.register(cors, { origin: true, credentials: true });
  await server.register(jwt, { secret: config.jwtSecret });
  await server.register(requestIdMiddleware);
  await server.register(errorHandler);
  await server.register(healthCheckPlugin, {
    dependencies: [
      HealthChecks.postgres(prisma),
      HealthChecks.redis(redis),
    ],
  });

  // Authentication decorator
  server.decorate('authenticate', async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      await request.jwtVerify();
    } catch (err) {
      reply.status(401).send(errorResponse(ErrorCodes.UNAUTHORIZED, 'Authentication required', request.requestId));
    }
  });

  // Routes
  await server.register(orderRoutes, { prefix: '/api/v1/orders' });

  return server;
}

// Validation schemas
const createOrderSchema = z.object({
  items: z.array(z.object({
    productId: z.string().uuid(),
    productName: z.string(),
    productImage: z.string().optional(),
    unitPrice: z.number().positive(),
    quantity: z.number().int().positive(),
    unit: z.string().default('kg'),
  })).min(1),
  deliveryAddress: z.object({
    id: z.string().uuid(),
    fullName: z.string(),
    phoneNumber: z.string(),
    addressLine1: z.string(),
    addressLine2: z.string().optional(),
    landmark: z.string().optional(),
    city: z.string(),
    state: z.string(),
    pincode: z.string(),
  }),
  paymentMethod: z.enum(['COD', 'UPI', 'CARD', 'NET_BANKING', 'WALLET']),
  scheduledDeliveryDate: z.string().datetime().optional(),
  deliverySlot: z.string().optional(),
  customerNote: z.string().max(500).optional(),
  couponCode: z.string().optional(),
});

type CreateOrderInput = z.infer<typeof createOrderSchema>;

// Order routes
const orderRoutes: FastifyPluginCallback = (fastify, _opts, done) => {
  // All routes require authentication
  fastify.addHook('preHandler', (fastify as any).authenticate);

  /**
   * POST /orders
   * Create a new order
   */
  fastify.post('/', async (request, reply) => {
    const idempotencyKey = request.headers['x-idempotency-key'] as string;
    const userId = (request.user as { sub: string }).sub;

    // Check idempotency
    if (idempotencyKey) {
      const existing = await prisma.idempotencyKey.findUnique({
        where: { key: idempotencyKey },
      });
      if (existing && existing.expiresAt > new Date()) {
        reply.header('X-Idempotent-Replayed', 'true');
        return reply.status(existing.statusCode).send(existing.responseBody);
      }
    }

    // Validate input
    const input = createOrderSchema.parse(request.body);

    // Calculate totals
    const subtotal = input.items.reduce(
      (sum, item) => sum + item.unitPrice * item.quantity,
      0
    );

    if (subtotal < config.minOrderAmount) {
      return reply.status(422).send(
        errorResponse(
          ErrorCodes.MINIMUM_ORDER_NOT_MET,
          `Minimum order amount is ₹${config.minOrderAmount}`,
          request.requestId,
          { retryable: false, details: { minimumAmount: config.minOrderAmount, currentAmount: subtotal } }
        )
      );
    }

    const deliveryFee = subtotal >= config.freeDeliveryThreshold ? 0 : config.deliveryFee;
    const total = subtotal + deliveryFee;

    // Create order
    const orderNumber = await generateOrderNumber();

    const order = await prisma.$transaction(async (tx) => {
      const newOrder = await tx.order.create({
        data: {
          orderNumber,
          userId,
          deliveryAddress: input.deliveryAddress,
          status: OrderStatus.PENDING,
          subtotal,
          deliveryFee,
          total,
          paymentMethod: input.paymentMethod,
          paymentStatus: input.paymentMethod === 'COD' ? PaymentStatus.PENDING : PaymentStatus.PROCESSING,
          scheduledDeliveryDate: input.scheduledDeliveryDate ? new Date(input.scheduledDeliveryDate) : null,
          deliverySlot: input.deliverySlot,
          customerNote: input.customerNote,
          couponCode: input.couponCode,
          items: {
            create: input.items.map((item) => ({
              productId: item.productId,
              productName: item.productName,
              productImage: item.productImage,
              unitPrice: item.unitPrice,
              quantity: item.quantity,
              unit: item.unit,
              total: item.unitPrice * item.quantity,
            })),
          },
        },
        include: { items: true },
      });

      // Create order event
      await tx.orderEvent.create({
        data: {
          orderId: newOrder.id,
          eventType: 'order_created',
          newStatus: OrderStatus.PENDING,
          actorType: 'user',
          actorId: userId,
        },
      });

      // Create payment record
      if (input.paymentMethod !== 'COD') {
        await tx.payment.create({
          data: {
            orderId: newOrder.id,
            amount: total,
            method: input.paymentMethod as PaymentMethod,
            status: PaymentStatus.PENDING,
          },
        });
      }

      return newOrder;
    });

    // Publish order created event
    const event: DomainEvent<OrderCreatedEvent> = {
      eventId: uuidv4(),
      eventType: EventTypes.ORDER_CREATED,
      aggregateId: order.id,
      aggregateType: 'Order',
      timestamp: new Date().toISOString(),
      version: 1,
      payload: {
        orderId: order.id,
        userId,
        items: input.items.map((item) => ({
          productId: item.productId,
          quantity: item.quantity,
          price: item.unitPrice,
        })),
        totalAmount: total,
        deliveryAddress: JSON.stringify(input.deliveryAddress),
      },
      metadata: {
        correlationId: request.requestId,
        userId,
        source: 'order-service',
      },
    };

    await publishEvent(event, EventTypes.ORDER_CREATED);

    const responseData = {
      order: {
        id: order.id,
        orderNumber: order.orderNumber,
        status: order.status,
        subtotal: Number(order.subtotal),
        deliveryFee: Number(order.deliveryFee),
        total: Number(order.total),
        paymentMethod: order.paymentMethod,
        paymentStatus: order.paymentStatus,
        items: order.items.map((item) => ({
          productId: item.productId,
          productName: item.productName,
          quantity: item.quantity,
          unit: item.unit,
          unitPrice: Number(item.unitPrice),
          total: Number(item.total),
        })),
        createdAt: order.createdAt.toISOString(),
      },
    };

    // Store idempotency result
    if (idempotencyKey) {
      await prisma.idempotencyKey.create({
        data: {
          key: idempotencyKey,
          statusCode: 201,
          responseBody: successResponse(responseData, request.requestId) as object,
          expiresAt: new Date(Date.now() + 24 * 60 * 60 * 1000),
        },
      });
    }

    const response = successResponse(responseData, request.requestId);
    return reply.status(201).send(response);
  });

  /**
   * GET /orders
   * List user's orders
   */
  fastify.get('/', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const { page = 1, limit = 20, status } = request.query as { page?: number; limit?: number; status?: OrderStatus };

    const where: Record<string, unknown> = { userId };
    if (status) where.status = status;

    const [orders, total] = await Promise.all([
      prisma.order.findMany({
        where,
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
        include: {
          items: true,
        },
      }),
      prisma.order.count({ where }),
    ]);

    const response = successResponse(
      {
        orders: orders.map((o) => ({
          id: o.id,
          orderNumber: o.orderNumber,
          status: o.status,
          total: Number(o.total),
          paymentStatus: o.paymentStatus,
          itemCount: o.items.length,
          createdAt: o.createdAt.toISOString(),
          deliveredAt: o.deliveredAt?.toISOString(),
        })),
      },
      request.requestId,
      { page, limit, total }
    );

    return reply.send(response);
  });

  /**
   * GET /orders/:id
   * Get order details
   */
  fastify.get('/:id', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const { id } = request.params as { id: string };

    const order = await prisma.order.findFirst({
      where: { id, userId },
      include: {
        items: true,
        events: { orderBy: { createdAt: 'desc' }, take: 10 },
        payment: true,
      },
    });

    if (!order) {
      return reply.status(404).send(
        errorResponse(ErrorCodes.NOT_FOUND, 'Order not found', request.requestId)
      );
    }

    const response = successResponse(
      {
        order: {
          id: order.id,
          orderNumber: order.orderNumber,
          status: order.status,
          deliveryAddress: order.deliveryAddress,
          subtotal: Number(order.subtotal),
          deliveryFee: Number(order.deliveryFee),
          discount: Number(order.discount),
          total: Number(order.total),
          paymentMethod: order.paymentMethod,
          paymentStatus: order.paymentStatus,
          scheduledDeliveryDate: order.scheduledDeliveryDate?.toISOString(),
          deliverySlot: order.deliverySlot,
          customerNote: order.customerNote,
          items: order.items.map((item) => ({
            productId: item.productId,
            productName: item.productName,
            productImage: item.productImage,
            quantity: item.quantity,
            unit: item.unit,
            unitPrice: Number(item.unitPrice),
            total: Number(item.total),
          })),
          timeline: order.events.map((e) => ({
            event: e.eventType,
            status: e.newStatus,
            timestamp: e.createdAt.toISOString(),
            notes: e.notes,
          })),
          createdAt: order.createdAt.toISOString(),
          confirmedAt: order.confirmedAt?.toISOString(),
          shippedAt: order.shippedAt?.toISOString(),
          deliveredAt: order.deliveredAt?.toISOString(),
        },
      },
      request.requestId
    );

    return reply.send(response);
  });

  /**
   * POST /orders/:id/cancel
   * Cancel an order
   */
  fastify.post('/:id/cancel', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const { id } = request.params as { id: string };
    const { reason } = request.body as { reason?: string };

    const order = await prisma.order.findFirst({
      where: { id, userId },
    });

    if (!order) {
      return reply.status(404).send(
        errorResponse(ErrorCodes.NOT_FOUND, 'Order not found', request.requestId)
      );
    }

    const cancellableStatuses = [OrderStatus.PENDING, OrderStatus.CONFIRMED];
    if (!cancellableStatuses.includes(order.status)) {
      return reply.status(422).send(
        errorResponse(
          ErrorCodes.ORDER_CANNOT_CANCEL,
          `Order cannot be cancelled in ${order.status} status`,
          request.requestId
        )
      );
    }

    await prisma.$transaction(async (tx) => {
      await tx.order.update({
        where: { id },
        data: {
          status: OrderStatus.CANCELLED,
          cancelledAt: new Date(),
        },
      });

      await tx.orderEvent.create({
        data: {
          orderId: id,
          eventType: 'order_cancelled',
          previousStatus: order.status,
          newStatus: OrderStatus.CANCELLED,
          actorType: 'user',
          actorId: userId,
          notes: reason,
        },
      });
    });

    // Publish cancellation event
    const event: DomainEvent<{ orderId: string; cancelledAt: string; reason: string; refundInitiated: boolean }> = {
      eventId: uuidv4(),
      eventType: EventTypes.ORDER_CANCELLED,
      aggregateId: id,
      aggregateType: 'Order',
      timestamp: new Date().toISOString(),
      version: 1,
      payload: {
        orderId: id,
        cancelledAt: new Date().toISOString(),
        reason: reason || 'Cancelled by customer',
        refundInitiated: order.paymentStatus === PaymentStatus.COMPLETED,
      },
      metadata: {
        correlationId: request.requestId,
        userId,
        source: 'order-service',
      },
    };

    await publishEvent(event, EventTypes.ORDER_CANCELLED);

    const response = successResponse(
      { message: 'Order cancelled successfully' },
      request.requestId
    );

    return reply.send(response);
  });

  done();
};

// Start server
async function main() {
  try {
    await setupRabbitMQ();
  } catch (error) {
    log.warn({ error }, 'RabbitMQ not available, continuing without it');
  }

  const server = await createServer();

  const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM'];
  for (const signal of signals) {
    process.on(signal, async () => {
      log.info({ signal }, 'Shutdown signal received');
      await server.close();
      await prisma.$disconnect();
      await redis.quit();
      process.exit(0);
    });
  }

  try {
    await server.listen({ port: config.port, host: config.host });
    log.info({ port: config.port }, 'Order service started');
  } catch (error) {
    log.fatal({ error }, 'Failed to start server');
    process.exit(1);
  }
}

main();
