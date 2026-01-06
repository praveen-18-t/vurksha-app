/**
 * Request ID Middleware
 * Ensures every request has a unique identifier for tracing
 */

import { FastifyPluginCallback, FastifyRequest, FastifyReply } from 'fastify';
import { v4 as uuidv4 } from 'uuid';
import fp from 'fastify-plugin';

declare module 'fastify' {
  interface FastifyRequest {
    requestId: string;
    correlationId: string;
    startTime: number;
  }
}

const REQUEST_ID_HEADER = 'x-request-id';
const CORRELATION_ID_HEADER = 'x-correlation-id';

const requestIdPlugin: FastifyPluginCallback = (fastify, _opts, done) => {
  fastify.addHook('onRequest', async (request: FastifyRequest, reply: FastifyReply) => {
    // Capture start time for latency calculation
    request.startTime = Date.now();

    // Use existing request ID from gateway or generate new one
    request.requestId =
      (request.headers[REQUEST_ID_HEADER] as string) || uuidv4();

    // Correlation ID for distributed tracing (passed between services)
    request.correlationId =
      (request.headers[CORRELATION_ID_HEADER] as string) || request.requestId;

    // Set headers in response for client reference
    reply.header(REQUEST_ID_HEADER, request.requestId);
    reply.header(CORRELATION_ID_HEADER, request.correlationId);
  });

  fastify.addHook('onResponse', async (request: FastifyRequest, reply: FastifyReply) => {
    const duration = Date.now() - request.startTime;
    
    request.log.info({
      requestId: request.requestId,
      correlationId: request.correlationId,
      method: request.method,
      url: request.url,
      statusCode: reply.statusCode,
      durationMs: duration,
    });
  });

  done();
};

export const requestIdMiddleware = fp(requestIdPlugin, {
  name: 'request-id',
  fastify: '4.x',
});

/**
 * Get request ID from current context (for use in services)
 */
export function getRequestId(request: FastifyRequest): string {
  return request.requestId;
}

/**
 * Get correlation ID from current context (for inter-service calls)
 */
export function getCorrelationId(request: FastifyRequest): string {
  return request.correlationId;
}
