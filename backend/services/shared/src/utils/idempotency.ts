/**
 * Idempotency Handler
 * Ensures safe retry of operations without duplicate side effects
 */

import Redis from 'ioredis';
import { logger } from './logger';
import { FastifyRequest, FastifyReply } from 'fastify';
import { ApiResponse } from '../types/api-response';

const IDEMPOTENCY_HEADER = 'x-idempotency-key';
const DEFAULT_TTL = 24 * 60 * 60; // 24 hours

const log = logger.child({ component: 'idempotency' });

export interface IdempotencyConfig {
  redis: Redis;
  keyPrefix?: string;
  ttlSeconds?: number;
}

export interface StoredIdempotencyResult {
  statusCode: number;
  body: ApiResponse<unknown>;
  timestamp: string;
}

export class IdempotencyService {
  private redis: Redis;
  private keyPrefix: string;
  private ttl: number;

  constructor(config: IdempotencyConfig) {
    this.redis = config.redis;
    this.keyPrefix = config.keyPrefix || 'idempotency:';
    this.ttl = config.ttlSeconds || DEFAULT_TTL;
  }

  private formatKey(key: string): string {
    return `${this.keyPrefix}${key}`;
  }

  /**
   * Check if an idempotency key exists and return cached result
   */
  async get(key: string): Promise<StoredIdempotencyResult | null> {
    try {
      const value = await this.redis.get(this.formatKey(key));
      if (value) {
        log.debug({ key }, 'Idempotency key found');
        return JSON.parse(value);
      }
      return null;
    } catch (error) {
      log.warn({ error, key }, 'Failed to check idempotency key');
      return null;
    }
  }

  /**
   * Store result for an idempotency key
   */
  async set(
    key: string,
    statusCode: number,
    body: ApiResponse<unknown>
  ): Promise<void> {
    try {
      const result: StoredIdempotencyResult = {
        statusCode,
        body,
        timestamp: new Date().toISOString(),
      };
      await this.redis.setex(
        this.formatKey(key),
        this.ttl,
        JSON.stringify(result)
      );
      log.debug({ key }, 'Idempotency result stored');
    } catch (error) {
      log.warn({ error, key }, 'Failed to store idempotency result');
    }
  }

  /**
   * Mark an operation as in progress
   */
  async markInProgress(key: string): Promise<boolean> {
    try {
      const result = await this.redis.set(
        this.formatKey(`${key}:lock`),
        'processing',
        'EX',
        60, // 1 minute lock
        'NX'
      );
      return result === 'OK';
    } catch (error) {
      log.warn({ error, key }, 'Failed to mark as in progress');
      return true; // Allow operation if Redis fails
    }
  }

  /**
   * Release the in-progress lock
   */
  async releaseProgress(key: string): Promise<void> {
    try {
      await this.redis.del(this.formatKey(`${key}:lock`));
    } catch (error) {
      log.warn({ error, key }, 'Failed to release progress lock');
    }
  }
}

/**
 * Get idempotency key from request
 */
export function getIdempotencyKey(request: FastifyRequest): string | null {
  return (request.headers[IDEMPOTENCY_HEADER] as string) || null;
}

/**
 * Create Fastify hook for idempotency handling
 */
export function createIdempotencyHook(idempotencyService: IdempotencyService) {
  return async function idempotencyPreHandler(
    request: FastifyRequest,
    reply: FastifyReply
  ) {
    // Only apply to POST, PUT, PATCH methods
    if (!['POST', 'PUT', 'PATCH'].includes(request.method)) {
      return;
    }

    const key = getIdempotencyKey(request);
    if (!key) {
      return; // No idempotency key provided
    }

    // Check for existing result
    const existing = await idempotencyService.get(key);
    if (existing) {
      log.info({ key }, 'Returning cached idempotent response');
      reply.header('X-Idempotent-Replayed', 'true');
      return reply.status(existing.statusCode).send(existing.body);
    }

    // Check if operation is in progress
    const acquired = await idempotencyService.markInProgress(key);
    if (!acquired) {
      return reply.status(409).send({
        success: false,
        error: {
          code: 'OPERATION_IN_PROGRESS',
          message: 'A request with this idempotency key is already being processed',
          retryable: true,
          retryAfter: 5,
        },
        meta: {
          requestId: request.requestId,
          timestamp: new Date().toISOString(),
          version: process.env.API_VERSION || '1.0.0',
        },
      });
    }

    // Store key and service in request for later use
    (request as { idempotencyKey?: string }).idempotencyKey = key;
    (request as { idempotencyService?: IdempotencyService }).idempotencyService =
      idempotencyService;
  };
}

/**
 * Store idempotent response after successful operation
 */
export async function storeIdempotentResponse(
  request: FastifyRequest,
  statusCode: number,
  body: ApiResponse<unknown>
): Promise<void> {
  const key = (request as { idempotencyKey?: string }).idempotencyKey;
  const service = (request as { idempotencyService?: IdempotencyService })
    .idempotencyService;

  if (key && service) {
    await service.set(key, statusCode, body);
    await service.releaseProgress(key);
  }
}

/**
 * Generate idempotency key for client use
 */
export function generateIdempotencyKey(
  userId: string,
  operation: string,
  ...params: string[]
): string {
  const components = [userId, operation, ...params, Date.now().toString()];
  return components.join('_');
}
