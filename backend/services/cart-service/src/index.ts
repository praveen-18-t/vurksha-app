/**
 * Cart Service
 * Redis-backed shopping cart with product validation
 * 
 * Features:
 * - Ephemeral cart storage in Redis
 * - Real-time stock validation
 * - Automatic expiry for abandoned carts
 * - Cart merging for guest → authenticated user
 */

import Fastify, { FastifyInstance, FastifyPluginCallback, FastifyRequest, FastifyReply } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import jwt from '@fastify/jwt';
import Redis from 'ioredis';
import amqp, { Channel } from 'amqplib';
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
  CartUpdatedEvent,
  Exchanges,
  executeWithCircuitBreaker,
  createCircuitBreaker,
} from '@vurksha/shared';

// Configuration
const config = {
  port: parseInt(process.env.PORT || '3004'),
  host: process.env.HOST || '0.0.0.0',
  jwtSecret: process.env.JWT_SECRET || 'development-secret',
  redisUrl: process.env.REDIS_URL!,
  rabbitmqUrl: process.env.RABBITMQ_URL!,
  productServiceUrl: process.env.PRODUCT_SERVICE_URL || 'http://product-service:3002',
  cartTtlSeconds: 7 * 24 * 60 * 60, // 7 days
};

// Types
interface CartItem {
  productId: string;
  productName: string;
  productImage?: string;
  unitPrice: number;
  quantity: number;
  unit: string;
  maxQuantity?: number;
}

interface Cart {
  userId: string;
  items: CartItem[];
  updatedAt: string;
}

// Clients
const redis = new Redis(config.redisUrl);
let rabbitChannel: Channel | null = null;

const log = logger.child({ service: 'cart-service' });

// Circuit breaker for product service
const productServiceBreaker = createCircuitBreaker('product-service');

// Redis keys
const cartKey = (userId: string) => `cart:${userId}`;

// RabbitMQ setup
async function setupRabbitMQ(): Promise<void> {
  try {
    const connection = await amqp.connect(config.rabbitmqUrl);
    rabbitChannel = await connection.createChannel();
    await rabbitChannel.assertExchange(Exchanges.DOMAIN_EVENTS, 'topic', { durable: true });

    connection.on('close', () => {
      log.warn('RabbitMQ connection closed, reconnecting...');
      setTimeout(setupRabbitMQ, 5000);
    });

    log.info('RabbitMQ connected');
  } catch (error) {
    log.warn({ error }, 'RabbitMQ not available');
  }
}

async function publishEvent<T>(event: DomainEvent<T>, routingKey: string): Promise<void> {
  if (!rabbitChannel) return;

  rabbitChannel.publish(
    Exchanges.DOMAIN_EVENTS,
    routingKey,
    Buffer.from(JSON.stringify(event)),
    { persistent: true, contentType: 'application/json' }
  );
}

// Cart service functions
async function getCart(userId: string): Promise<Cart> {
  const data = await redis.get(cartKey(userId));
  if (!data) {
    return { userId, items: [], updatedAt: new Date().toISOString() };
  }
  return JSON.parse(data);
}

async function saveCart(cart: Cart): Promise<void> {
  cart.updatedAt = new Date().toISOString();
  await redis.setex(cartKey(cart.userId), config.cartTtlSeconds, JSON.stringify(cart));
}

async function validateProduct(productId: string): Promise<{ valid: boolean; product?: CartItem }> {
  try {
    const response = await executeWithCircuitBreaker(
      productServiceBreaker,
      async () => {
        const res = await fetch(`${config.productServiceUrl}/api/v1/products/${productId}`);
        if (!res.ok) throw new Error('Product not found');
        return res.json();
      }
    );

    const product = response.data?.product;
    if (!product || !product.isActive) {
      return { valid: false };
    }

    return {
      valid: true,
      product: {
        productId: product.id,
        productName: product.name,
        productImage: product.images?.[0]?.url,
        unitPrice: product.price,
        quantity: 0,
        unit: product.unit,
        maxQuantity: product.stockQuantity,
      },
    };
  } catch (error) {
    log.warn({ error, productId }, 'Failed to validate product');
    // On circuit breaker open, allow adding (optimistic)
    return { valid: true };
  }
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
    dependencies: [HealthChecks.redis(redis)],
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
  await server.register(cartRoutes, { prefix: '/api/v1/cart' });

  return server;
}

// Validation schemas
const addItemSchema = z.object({
  productId: z.string().uuid(),
  productName: z.string(),
  productImage: z.string().optional(),
  unitPrice: z.number().positive(),
  quantity: z.number().int().positive(),
  unit: z.string().default('kg'),
});

const updateQuantitySchema = z.object({
  quantity: z.number().int().min(0),
});

// Cart routes
const cartRoutes: FastifyPluginCallback = (fastify, _opts, done) => {
  fastify.addHook('preHandler', (fastify as any).authenticate);

  /**
   * GET /cart
   * Get current user's cart
   */
  fastify.get('/', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const cart = await getCart(userId);

    const subtotal = cart.items.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);

    const response = successResponse(
      {
        cart: {
          items: cart.items,
          itemCount: cart.items.reduce((sum, item) => sum + item.quantity, 0),
          subtotal,
          updatedAt: cart.updatedAt,
        },
      },
      request.requestId
    );

    return reply.send(response);
  });

  /**
   * POST /cart/items
   * Add item to cart
   */
  fastify.post('/items', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const input = addItemSchema.parse(request.body);

    // Validate product
    const validation = await validateProduct(input.productId);
    if (!validation.valid) {
      return reply.status(422).send(
        errorResponse(
          ErrorCodes.PRODUCT_NOT_FOUND,
          'Product not available',
          request.requestId
        )
      );
    }

    const cart = await getCart(userId);
    const existingIndex = cart.items.findIndex((i) => i.productId === input.productId);

    if (existingIndex >= 0) {
      // Update quantity
      cart.items[existingIndex].quantity += input.quantity;
    } else {
      // Add new item
      cart.items.push({
        productId: input.productId,
        productName: input.productName,
        productImage: input.productImage,
        unitPrice: input.unitPrice,
        quantity: input.quantity,
        unit: input.unit,
      });
    }

    await saveCart(cart);

    // Publish event
    const event: DomainEvent<CartUpdatedEvent> = {
      eventId: uuidv4(),
      eventType: EventTypes.CART_UPDATED,
      aggregateId: userId,
      aggregateType: 'Cart',
      timestamp: new Date().toISOString(),
      version: 1,
      payload: {
        userId,
        items: cart.items.map((i) => ({
          productId: i.productId,
          quantity: i.quantity,
        })),
        action: 'add',
      },
      metadata: {
        correlationId: request.requestId,
        userId,
        source: 'cart-service',
      },
    };

    await publishEvent(event, EventTypes.CART_UPDATED);

    const subtotal = cart.items.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);

    const response = successResponse(
      {
        cart: {
          items: cart.items,
          itemCount: cart.items.reduce((sum, item) => sum + item.quantity, 0),
          subtotal,
          updatedAt: cart.updatedAt,
        },
      },
      request.requestId
    );

    return reply.send(response);
  });

  /**
   * PUT /cart/items/:productId
   * Update item quantity
   */
  fastify.put('/items/:productId', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const { productId } = request.params as { productId: string };
    const { quantity } = updateQuantitySchema.parse(request.body);

    const cart = await getCart(userId);
    const index = cart.items.findIndex((i) => i.productId === productId);

    if (index < 0) {
      return reply.status(404).send(
        errorResponse(ErrorCodes.NOT_FOUND, 'Item not in cart', request.requestId)
      );
    }

    if (quantity === 0) {
      // Remove item
      cart.items.splice(index, 1);
    } else {
      cart.items[index].quantity = quantity;
    }

    await saveCart(cart);

    const subtotal = cart.items.reduce((sum, item) => sum + item.unitPrice * item.quantity, 0);

    const response = successResponse(
      {
        cart: {
          items: cart.items,
          itemCount: cart.items.reduce((sum, item) => sum + item.quantity, 0),
          subtotal,
          updatedAt: cart.updatedAt,
        },
      },
      request.requestId
    );

    return reply.send(response);
  });

  /**
   * DELETE /cart/items/:productId
   * Remove item from cart
   */
  fastify.delete('/items/:productId', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const { productId } = request.params as { productId: string };

    const cart = await getCart(userId);
    const index = cart.items.findIndex((i) => i.productId === productId);

    if (index >= 0) {
      cart.items.splice(index, 1);
      await saveCart(cart);
    }

    const response = successResponse(
      { message: 'Item removed from cart' },
      request.requestId
    );

    return reply.send(response);
  });

  /**
   * DELETE /cart
   * Clear entire cart
   */
  fastify.delete('/', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    await redis.del(cartKey(userId));

    const response = successResponse(
      { message: 'Cart cleared' },
      request.requestId
    );

    return reply.send(response);
  });

  /**
   * POST /cart/validate
   * Validate all items in cart (stock availability)
   */
  fastify.post('/validate', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const cart = await getCart(userId);

    const validationResults = await Promise.all(
      cart.items.map(async (item) => {
        const result = await validateProduct(item.productId);
        return {
          productId: item.productId,
          valid: result.valid,
          available: result.product?.maxQuantity ?? 0,
          requested: item.quantity,
        };
      })
    );

    const invalidItems = validationResults.filter((r) => !r.valid || r.requested > r.available);

    const response = successResponse(
      {
        valid: invalidItems.length === 0,
        items: validationResults,
        invalidItems,
      },
      request.requestId
    );

    return reply.send(response);
  });

  done();
};

// Start server
async function main() {
  await setupRabbitMQ();

  const server = await createServer();

  const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM'];
  for (const signal of signals) {
    process.on(signal, async () => {
      log.info({ signal }, 'Shutdown signal received');
      await server.close();
      await redis.quit();
      process.exit(0);
    });
  }

  try {
    await server.listen({ port: config.port, host: config.host });
    log.info({ port: config.port }, 'Cart service started');
  } catch (error) {
    log.fatal({ error }, 'Failed to start server');
    process.exit(1);
  }
}

main();
