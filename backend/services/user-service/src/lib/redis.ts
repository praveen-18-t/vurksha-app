/**
 * Redis Client Instance
 * Configured for high availability with proper error handling
 */

import Redis from 'ioredis';
import { config } from '../config';
import { logger } from '@vurksha/shared';

const log = logger.child({ component: 'redis' });

export const redis = new Redis(config.redisUrl, {
  maxRetriesPerRequest: 3,
  retryStrategy: (times) => {
    if (times > 10) {
      log.error({ retries: times }, 'Redis max retries reached');
      return null; // Stop retrying
    }
    const delay = Math.min(times * 100, 3000);
    log.warn({ retries: times, delay }, 'Retrying Redis connection');
    return delay;
  },
  reconnectOnError: (err) => {
    const targetErrors = ['READONLY', 'ECONNRESET', 'ETIMEDOUT'];
    if (targetErrors.some((e) => err.message.includes(e))) {
      return true;
    }
    return false;
  },
  enableReadyCheck: true,
  lazyConnect: false,
});

redis.on('connect', () => {
  log.info('Redis connected');
});

redis.on('ready', () => {
  log.info('Redis ready');
});

redis.on('error', (err) => {
  log.error({ error: err.message }, 'Redis error');
});

redis.on('close', () => {
  log.warn('Redis connection closed');
});

redis.on('reconnecting', () => {
  log.info('Redis reconnecting');
});

/**
 * Check if Redis is healthy
 */
export async function isRedisHealthy(): Promise<boolean> {
  try {
    const result = await redis.ping();
    return result === 'PONG';
  } catch {
    return false;
  }
}
