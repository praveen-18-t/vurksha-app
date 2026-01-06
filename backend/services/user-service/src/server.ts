/**
 * Fastify Server Setup
 * Configures all plugins, middleware, and routes
 */

import Fastify, { FastifyInstance } from 'fastify';
import cors from '@fastify/cors';
import helmet from '@fastify/helmet';
import jwt from '@fastify/jwt';
import {
  requestIdMiddleware,
  errorHandler,
  healthCheckPlugin,
  HealthChecks,
  logger,
} from '@vurksha/shared';
import { config } from './config';
import { prisma } from './lib/prisma';
import { redis } from './lib/redis';

// Route imports
import { authRoutes } from './routes/auth.routes';
import { userRoutes } from './routes/user.routes';
import { addressRoutes } from './routes/address.routes';

export async function createServer(): Promise<FastifyInstance> {
  const server = Fastify({
    logger: false, // We use our own logger
    requestIdHeader: 'x-request-id',
    trustProxy: true,
    bodyLimit: 1048576, // 1MB
  });

  // Security headers
  await server.register(helmet, {
    contentSecurityPolicy: false, // API doesn't serve HTML
  });

  // CORS
  await server.register(cors, {
    origin: true, // Configure properly for production
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: [
      'Content-Type',
      'Authorization',
      'X-Request-Id',
      'X-Correlation-Id',
      'X-Idempotency-Key',
    ],
  });

  // JWT authentication
  await server.register(jwt, {
    secret: config.jwtSecret,
    sign: {
      expiresIn: config.jwtAccessExpiry,
    },
  });

  // Custom middleware
  await server.register(requestIdMiddleware);
  await server.register(errorHandler);

  // Health checks
  await server.register(healthCheckPlugin, {
    dependencies: [
      HealthChecks.postgres(prisma),
      HealthChecks.redis(redis),
    ],
  });

  // API routes (versioned)
  await server.register(
    async (instance) => {
      await instance.register(authRoutes, { prefix: '/auth' });
      await instance.register(userRoutes, { prefix: '/users' });
      await instance.register(addressRoutes, { prefix: '/addresses' });
    },
    { prefix: '/api/v1' }
  );

  // Request logging
  server.addHook('onRequest', async (request) => {
    logger.info({
      requestId: request.requestId,
      method: request.method,
      url: request.url,
      ip: request.ip,
    }, 'Incoming request');
  });

  return server;
}
