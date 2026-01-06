/**
 * Rate Limiting Middleware
 * Protects services from abuse and ensures fair usage
 */

import { FastifyPluginCallback, FastifyRequest, FastifyReply } from 'fastify';
import fp from 'fastify-plugin';
import Redis from 'ioredis';
import { errorResponse } from '../types/api-response';
import { ErrorCodes } from '../types/errors';
import { logger } from '../utils/logger';

export interface RateLimitConfig {
  /** Redis client instance */
  redis: Redis;
  /** Maximum requests per window */
  max: number;
  /** Time window in seconds */
  windowSeconds: number;
  /** Key prefix for Redis */
  keyPrefix?: string;
  /** Function to generate rate limit key (default: IP + userId) */
  keyGenerator?: (request: FastifyRequest) => string;
  /** Skip rate limiting for certain requests */
  skip?: (request: FastifyRequest) => boolean;
  /** Custom error message */
  errorMessage?: string;
}

const DEFAULT_CONFIG = {
  max: 100,
  windowSeconds: 60,
  keyPrefix: 'rl:',
};

declare module 'fastify' {
  interface FastifyRequest {
    rateLimit?: {
      limit: number;
      remaining: number;
      reset: number;
    };
  }
}

const rateLimitPlugin: FastifyPluginCallback<RateLimitConfig> = (
  fastify,
  opts,
  done
) => {
  const config = { ...DEFAULT_CONFIG, ...opts };
  const log = logger.child({ component: 'rate-limit' });

  const keyGenerator = config.keyGenerator || defaultKeyGenerator;

  fastify.addHook('onRequest', async (request: FastifyRequest, reply: FastifyReply) => {
    // Check if we should skip rate limiting
    if (config.skip?.(request)) {
      return;
    }

    const key = config.keyPrefix + keyGenerator(request);
    const now = Math.floor(Date.now() / 1000);
    const windowStart = now - (now % config.windowSeconds);
    const windowKey = `${key}:${windowStart}`;

    try {
      // Increment counter with atomic operation
      const pipeline = config.redis.pipeline();
      pipeline.incr(windowKey);
      pipeline.expire(windowKey, config.windowSeconds + 1);
      const results = await pipeline.exec();

      const count = results?.[0]?.[1] as number || 0;
      const remaining = Math.max(0, config.max - count);
      const reset = windowStart + config.windowSeconds;

      // Set rate limit headers
      reply.header('X-RateLimit-Limit', config.max.toString());
      reply.header('X-RateLimit-Remaining', remaining.toString());
      reply.header('X-RateLimit-Reset', reset.toString());

      // Store for potential use in handlers
      request.rateLimit = {
        limit: config.max,
        remaining,
        reset,
      };

      // Check if rate limit exceeded
      if (count > config.max) {
        log.warn({
          key,
          count,
          max: config.max,
          ip: request.ip,
          url: request.url,
        }, 'Rate limit exceeded');

        const response = errorResponse(
          ErrorCodes.RATE_LIMITED,
          config.errorMessage || 'Too many requests, please try again later',
          request.requestId,
          {
            retryable: true,
            retryAfter: reset - now,
          }
        );

        reply.header('Retry-After', (reset - now).toString());
        return reply.status(429).send(response);
      }
    } catch (error) {
      // If Redis fails, allow the request but log the error
      log.error({ error }, 'Rate limit check failed, allowing request');
    }
  });

  done();
};

/**
 * Default key generator: combines IP and user ID if available
 */
function defaultKeyGenerator(request: FastifyRequest): string {
  const userId = (request as { userId?: string }).userId;
  if (userId) {
    return `user:${userId}`;
  }
  return `ip:${request.ip}`;
}

export const rateLimitMiddleware = fp(rateLimitPlugin, {
  name: 'rate-limit',
  fastify: '4.x',
});

/**
 * Create a rate limiter for specific routes
 */
export function createRouteRateLimiter(
  redis: Redis,
  config: Omit<RateLimitConfig, 'redis'>
) {
  return async function routeRateLimiter(
    request: FastifyRequest,
    reply: FastifyReply
  ) {
    const fullConfig: RateLimitConfig = { redis, ...config };
    const key = fullConfig.keyPrefix + (config.keyGenerator || defaultKeyGenerator)(request);
    const now = Math.floor(Date.now() / 1000);
    const windowStart = now - (now % fullConfig.windowSeconds);
    const windowKey = `${key}:${windowStart}`;

    const count = await redis.incr(windowKey);
    await redis.expire(windowKey, fullConfig.windowSeconds + 1);

    if (count > fullConfig.max) {
      const reset = windowStart + fullConfig.windowSeconds;
      const response = errorResponse(
        ErrorCodes.RATE_LIMITED,
        fullConfig.errorMessage || 'Too many requests',
        request.requestId,
        {
          retryable: true,
          retryAfter: reset - now,
        }
      );
      reply.header('Retry-After', (reset - now).toString());
      return reply.status(429).send(response);
    }
  };
}

/**
 * Sliding window rate limiter (more accurate but more Redis operations)
 */
export async function slidingWindowRateLimit(
  redis: Redis,
  key: string,
  max: number,
  windowSeconds: number
): Promise<{ allowed: boolean; remaining: number; reset: number }> {
  const now = Date.now();
  const windowMs = windowSeconds * 1000;
  const windowStart = now - windowMs;

  const pipeline = redis.pipeline();
  
  // Remove old entries
  pipeline.zremrangebyscore(key, 0, windowStart);
  
  // Add current request
  pipeline.zadd(key, now.toString(), `${now}-${Math.random()}`);
  
  // Count requests in window
  pipeline.zcard(key);
  
  // Set expiry
  pipeline.expire(key, windowSeconds);

  const results = await pipeline.exec();
  const count = results?.[2]?.[1] as number || 0;

  return {
    allowed: count <= max,
    remaining: Math.max(0, max - count),
    reset: Math.floor((now + windowMs) / 1000),
  };
}
