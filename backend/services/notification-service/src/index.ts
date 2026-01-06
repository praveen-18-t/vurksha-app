/**
 * Notification Service
 * Event-driven notification delivery (Push, SMS, Email)
 * 
 * Consumes events from RabbitMQ and delivers notifications
 * via Firebase Cloud Messaging for push notifications
 */

import Fastify, { FastifyInstance, FastifyPluginCallback, FastifyRequest, FastifyReply } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import jwt from '@fastify/jwt';
import { PrismaClient, NotificationType, NotificationStatus } from '@prisma/client';
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
  Exchanges,
  Queues,
  withRetry,
  RetryPredicates,
} from '@vurksha/shared';

// Configuration
const config = {
  port: parseInt(process.env.PORT || '3005'),
  host: process.env.HOST || '0.0.0.0',
  jwtSecret: process.env.JWT_SECRET || 'development-secret',
  databaseUrl: process.env.DATABASE_URL!,
  redisUrl: process.env.REDIS_URL!,
  rabbitmqUrl: process.env.RABBITMQ_URL!,
  firebaseCredentials: process.env.FIREBASE_CREDENTIALS,
};

// Clients
const prisma = new PrismaClient();
const redis = new Redis(config.redisUrl);
let rabbitChannel: Channel | null = null;

const log = logger.child({ service: 'notification-service' });

// Firebase setup (mock for now)
interface FirebaseMessage {
  token: string;
  notification: {
    title: string;
    body: string;
    imageUrl?: string;
  };
  data?: Record<string, string>;
}

async function sendFirebasePush(message: FirebaseMessage): Promise<string> {
  // In production, use firebase-admin:
  // const response = await admin.messaging().send(message);
  // return response;
  
  log.info({ token: message.token.slice(0, 20) }, 'Sending FCM push notification');
  
  // Simulate some network delay
  await new Promise((r) => setTimeout(r, 100));
  
  // Mock response
  return `projects/vurksha/messages/${uuidv4()}`;
}

// Notification templates
const templates: Record<string, { title: string; body: string }> = {
  ORDER_CONFIRMED: {
    title: 'Order Confirmed!',
    body: 'Your order #{{orderNumber}} has been confirmed. We\'re preparing it for delivery.',
  },
  ORDER_SHIPPED: {
    title: 'Order Shipped!',
    body: 'Your order #{{orderNumber}} is out for delivery. Track your delivery in the app.',
  },
  ORDER_DELIVERED: {
    title: 'Order Delivered!',
    body: 'Your order #{{orderNumber}} has been delivered. Enjoy your fresh produce!',
  },
  ORDER_CANCELLED: {
    title: 'Order Cancelled',
    body: 'Your order #{{orderNumber}} has been cancelled. Refund will be processed if applicable.',
  },
  PAYMENT_SUCCESS: {
    title: 'Payment Successful',
    body: 'Payment of ₹{{amount}} for order #{{orderNumber}} was successful.',
  },
};

function interpolate(template: string, variables: Record<string, string>): string {
  return template.replace(/\{\{(\w+)\}\}/g, (match, key) => variables[key] || match);
}

// Event handlers
async function handleOrderConfirmed(event: DomainEvent<{ orderId: string; orderNumber: string }>): Promise<void> {
  const { orderId, orderNumber } = event.payload;
  const userId = event.metadata.userId;

  if (!userId) return;

  await createAndSendNotification(userId, {
    type: NotificationType.ORDER_UPDATE,
    templateKey: 'ORDER_CONFIRMED',
    variables: { orderNumber },
    actionType: 'order_details',
    actionData: { orderId },
  });
}

async function handleOrderShipped(event: DomainEvent<{ orderId: string; orderNumber: string }>): Promise<void> {
  const { orderId, orderNumber } = event.payload;
  const userId = event.metadata.userId;

  if (!userId) return;

  await createAndSendNotification(userId, {
    type: NotificationType.DELIVERY_UPDATE,
    templateKey: 'ORDER_SHIPPED',
    variables: { orderNumber },
    actionType: 'track_order',
    actionData: { orderId },
  });
}

async function handleOrderDelivered(event: DomainEvent<{ orderId: string; orderNumber: string }>): Promise<void> {
  const { orderId, orderNumber } = event.payload;
  const userId = event.metadata.userId;

  if (!userId) return;

  await createAndSendNotification(userId, {
    type: NotificationType.ORDER_UPDATE,
    templateKey: 'ORDER_DELIVERED',
    variables: { orderNumber },
    actionType: 'rate_order',
    actionData: { orderId },
  });
}

async function handlePaymentCompleted(event: DomainEvent<{ orderId: string; amount: number }>): Promise<void> {
  const { orderId, amount } = event.payload;
  const userId = event.metadata.userId;

  if (!userId) return;

  // Fetch order number
  const orderNumber = await redis.get(`order:number:${orderId}`) || orderId.slice(0, 8);

  await createAndSendNotification(userId, {
    type: NotificationType.PAYMENT_CONFIRMATION,
    templateKey: 'PAYMENT_SUCCESS',
    variables: { orderNumber, amount: amount.toString() },
    actionType: 'order_details',
    actionData: { orderId },
  });
}

interface NotificationInput {
  type: NotificationType;
  templateKey: string;
  variables: Record<string, string>;
  actionType?: string;
  actionData?: Record<string, string>;
}

async function createAndSendNotification(userId: string, input: NotificationInput): Promise<void> {
  const template = templates[input.templateKey];
  if (!template) {
    log.warn({ templateKey: input.templateKey }, 'Template not found');
    return;
  }

  const title = interpolate(template.title, input.variables);
  const body = interpolate(template.body, input.variables);

  // Check user preferences
  const preferences = await prisma.notificationPreference.findUnique({
    where: { userId },
  });

  if (preferences && !preferences.pushEnabled) {
    log.info({ userId }, 'User has disabled push notifications');
    return;
  }

  // Create notification record
  const notification = await prisma.notification.create({
    data: {
      userId,
      type: input.type,
      title,
      body,
      actionType: input.actionType,
      actionData: input.actionData,
      status: NotificationStatus.PENDING,
    },
  });

  // Get device tokens
  const deviceTokens = await prisma.deviceToken.findMany({
    where: { userId, isActive: true },
  });

  if (deviceTokens.length === 0) {
    log.info({ userId }, 'No device tokens found');
    await prisma.notification.update({
      where: { id: notification.id },
      data: { status: NotificationStatus.FAILED, failureReason: 'No device tokens' },
    });
    return;
  }

  // Send to all devices with retry
  let success = false;
  for (const device of deviceTokens) {
    try {
      await withRetry(
        async () => {
          await sendFirebasePush({
            token: device.token,
            notification: { title, body },
            data: {
              actionType: input.actionType || '',
              actionData: JSON.stringify(input.actionData || {}),
              notificationId: notification.id,
            },
          });
        },
        {
          maxAttempts: 3,
          initialDelay: 500,
          predicate: RetryPredicates.network,
        }
      );
      success = true;
    } catch (error) {
      log.warn({ error, deviceToken: device.id }, 'Failed to send push notification');
      
      // Deactivate invalid token
      if ((error as Error).message?.includes('Unregistered') ||
          (error as Error).message?.includes('InvalidRegistration')) {
        await prisma.deviceToken.update({
          where: { id: device.id },
          data: { isActive: false },
        });
      }
    }
  }

  // Update notification status
  await prisma.notification.update({
    where: { id: notification.id },
    data: {
      status: success ? NotificationStatus.SENT : NotificationStatus.FAILED,
      sentAt: success ? new Date() : undefined,
      failedAt: !success ? new Date() : undefined,
      failureReason: !success ? 'All delivery attempts failed' : undefined,
    },
  });
}

// RabbitMQ setup
async function setupRabbitMQ(): Promise<void> {
  const connection = await amqp.connect(config.rabbitmqUrl);
  rabbitChannel = await connection.createChannel();

  await rabbitChannel.assertExchange(Exchanges.DOMAIN_EVENTS, 'topic', { durable: true });

  // Set up queue for notifications
  const queue = Queues.NOTIFICATIONS;
  await rabbitChannel.assertQueue(queue, {
    durable: true,
    deadLetterExchange: Exchanges.DEAD_LETTER,
  });

  // Bind to relevant events
  const bindings = [
    EventTypes.ORDER_CONFIRMED,
    EventTypes.ORDER_SHIPPED,
    EventTypes.ORDER_DELIVERED,
    EventTypes.PAYMENT_COMPLETED,
  ];

  for (const routingKey of bindings) {
    await rabbitChannel.bindQueue(queue, Exchanges.DOMAIN_EVENTS, routingKey);
  }

  // Set prefetch to process one at a time
  await rabbitChannel.prefetch(10);

  // Consume messages
  rabbitChannel.consume(queue, async (msg) => {
    if (!msg) return;

    try {
      const event = JSON.parse(msg.content.toString()) as DomainEvent<unknown>;
      log.info({ eventType: event.eventType }, 'Processing notification event');

      switch (event.eventType) {
        case EventTypes.ORDER_CONFIRMED:
          await handleOrderConfirmed(event as DomainEvent<{ orderId: string; orderNumber: string }>);
          break;
        case EventTypes.ORDER_SHIPPED:
          await handleOrderShipped(event as DomainEvent<{ orderId: string; orderNumber: string }>);
          break;
        case EventTypes.ORDER_DELIVERED:
          await handleOrderDelivered(event as DomainEvent<{ orderId: string; orderNumber: string }>);
          break;
        case EventTypes.PAYMENT_COMPLETED:
          await handlePaymentCompleted(event as DomainEvent<{ orderId: string; amount: number }>);
          break;
      }

      rabbitChannel!.ack(msg);
    } catch (error) {
      log.error({ error }, 'Failed to process notification event');
      rabbitChannel!.nack(msg, false, false); // Send to DLQ
    }
  });

  connection.on('close', () => {
    log.warn('RabbitMQ connection closed, reconnecting...');
    setTimeout(setupRabbitMQ, 5000);
  });

  log.info('RabbitMQ connected and consumers set up');
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
  await server.register(notificationRoutes, { prefix: '/api/v1/notifications' });

  return server;
}

// Validation schemas
const registerDeviceSchema = z.object({
  token: z.string().min(1),
  platform: z.enum(['ios', 'android', 'web']),
});

const updatePreferencesSchema = z.object({
  pushEnabled: z.boolean().optional(),
  emailEnabled: z.boolean().optional(),
  smsEnabled: z.boolean().optional(),
  orderUpdates: z.boolean().optional(),
  promotionalOffers: z.boolean().optional(),
  deliveryAlerts: z.boolean().optional(),
});

// Notification routes
const notificationRoutes: FastifyPluginCallback = (fastify, _opts, done) => {
  fastify.addHook('preHandler', (fastify as any).authenticate);

  /**
   * GET /notifications
   * Get user's notifications
   */
  fastify.get('/', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const { page = 1, limit = 20 } = request.query as { page?: number; limit?: number };

    const [notifications, total] = await Promise.all([
      prisma.notification.findMany({
        where: { userId },
        skip: (page - 1) * limit,
        take: limit,
        orderBy: { createdAt: 'desc' },
      }),
      prisma.notification.count({ where: { userId } }),
    ]);

    const response = successResponse(
      {
        notifications: notifications.map((n) => ({
          id: n.id,
          type: n.type,
          title: n.title,
          body: n.body,
          imageUrl: n.imageUrl,
          actionType: n.actionType,
          actionData: n.actionData,
          isRead: n.readAt !== null,
          createdAt: n.createdAt.toISOString(),
        })),
      },
      request.requestId,
      { page, limit, total }
    );

    return reply.send(response);
  });

  /**
   * POST /notifications/:id/read
   * Mark notification as read
   */
  fastify.post('/:id/read', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const { id } = request.params as { id: string };

    const notification = await prisma.notification.updateMany({
      where: { id, userId, readAt: null },
      data: { readAt: new Date(), status: NotificationStatus.READ },
    });

    if (notification.count === 0) {
      return reply.status(404).send(
        errorResponse(ErrorCodes.NOT_FOUND, 'Notification not found', request.requestId)
      );
    }

    const response = successResponse({ message: 'Marked as read' }, request.requestId);
    return reply.send(response);
  });

  /**
   * POST /notifications/read-all
   * Mark all notifications as read
   */
  fastify.post('/read-all', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;

    await prisma.notification.updateMany({
      where: { userId, readAt: null },
      data: { readAt: new Date(), status: NotificationStatus.READ },
    });

    const response = successResponse({ message: 'All notifications marked as read' }, request.requestId);
    return reply.send(response);
  });

  /**
   * POST /notifications/devices
   * Register device for push notifications
   */
  fastify.post('/devices', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const input = registerDeviceSchema.parse(request.body);

    await prisma.deviceToken.upsert({
      where: { userId_token: { userId, token: input.token } },
      create: {
        userId,
        token: input.token,
        platform: input.platform,
      },
      update: {
        isActive: true,
        platform: input.platform,
      },
    });

    const response = successResponse({ message: 'Device registered' }, request.requestId);
    return reply.status(201).send(response);
  });

  /**
   * DELETE /notifications/devices/:token
   * Unregister device
   */
  fastify.delete('/devices/:token', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const { token } = request.params as { token: string };

    await prisma.deviceToken.updateMany({
      where: { userId, token },
      data: { isActive: false },
    });

    const response = successResponse({ message: 'Device unregistered' }, request.requestId);
    return reply.send(response);
  });

  /**
   * GET /notifications/preferences
   * Get notification preferences
   */
  fastify.get('/preferences', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;

    let preferences = await prisma.notificationPreference.findUnique({
      where: { userId },
    });

    if (!preferences) {
      preferences = await prisma.notificationPreference.create({
        data: { userId },
      });
    }

    const response = successResponse(
      {
        preferences: {
          pushEnabled: preferences.pushEnabled,
          emailEnabled: preferences.emailEnabled,
          smsEnabled: preferences.smsEnabled,
          orderUpdates: preferences.orderUpdates,
          promotionalOffers: preferences.promotionalOffers,
          deliveryAlerts: preferences.deliveryAlerts,
        },
      },
      request.requestId
    );

    return reply.send(response);
  });

  /**
   * PUT /notifications/preferences
   * Update notification preferences
   */
  fastify.put('/preferences', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const input = updatePreferencesSchema.parse(request.body);

    const preferences = await prisma.notificationPreference.upsert({
      where: { userId },
      create: { userId, ...input },
      update: input,
    });

    const response = successResponse(
      {
        preferences: {
          pushEnabled: preferences.pushEnabled,
          emailEnabled: preferences.emailEnabled,
          smsEnabled: preferences.smsEnabled,
          orderUpdates: preferences.orderUpdates,
          promotionalOffers: preferences.promotionalOffers,
          deliveryAlerts: preferences.deliveryAlerts,
        },
      },
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
    log.warn({ error }, 'RabbitMQ not available, continuing without consumers');
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
    log.info({ port: config.port }, 'Notification service started');
  } catch (error) {
    log.fatal({ error }, 'Failed to start server');
    process.exit(1);
  }
}

main();
