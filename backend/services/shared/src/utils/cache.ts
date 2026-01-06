/**
 * Redis Cache Utilities
 * Cache-aside pattern with proper error handling and TTL management
 */

import Redis from 'ioredis';
import { logger } from './logger';

export interface CacheConfig {
  redis: Redis;
  defaultTTL?: number; // seconds
  keyPrefix?: string;
}

export interface CacheOptions {
  ttl?: number; // seconds
  refreshAhead?: number; // percentage of TTL to trigger refresh (0-1)
}

const log = logger.child({ component: 'cache' });

export class CacheService {
  private redis: Redis;
  private defaultTTL: number;
  private keyPrefix: string;

  constructor(config: CacheConfig) {
    this.redis = config.redis;
    this.defaultTTL = config.defaultTTL || 300; // 5 minutes
    this.keyPrefix = config.keyPrefix || 'cache:';
  }

  private formatKey(key: string): string {
    return `${this.keyPrefix}${key}`;
  }

  /**
   * Get a value from cache
   */
  async get<T>(key: string): Promise<T | null> {
    try {
      const value = await this.redis.get(this.formatKey(key));
      if (value) {
        log.debug({ key }, 'Cache hit');
        return JSON.parse(value) as T;
      }
      log.debug({ key }, 'Cache miss');
      return null;
    } catch (error) {
      log.warn({ error, key }, 'Cache get failed');
      return null; // Fail gracefully
    }
  }

  /**
   * Set a value in cache
   */
  async set<T>(key: string, value: T, options: CacheOptions = {}): Promise<void> {
    try {
      const ttl = options.ttl || this.defaultTTL;
      await this.redis.setex(
        this.formatKey(key),
        ttl,
        JSON.stringify(value)
      );
      log.debug({ key, ttl }, 'Cache set');
    } catch (error) {
      log.warn({ error, key }, 'Cache set failed');
      // Don't throw - cache failure shouldn't break the app
    }
  }

  /**
   * Delete a value from cache
   */
  async delete(key: string): Promise<void> {
    try {
      await this.redis.del(this.formatKey(key));
      log.debug({ key }, 'Cache delete');
    } catch (error) {
      log.warn({ error, key }, 'Cache delete failed');
    }
  }

  /**
   * Delete multiple keys by pattern
   */
  async deletePattern(pattern: string): Promise<void> {
    try {
      const keys = await this.redis.keys(this.formatKey(pattern));
      if (keys.length > 0) {
        await this.redis.del(...keys);
        log.debug({ pattern, count: keys.length }, 'Cache pattern delete');
      }
    } catch (error) {
      log.warn({ error, pattern }, 'Cache pattern delete failed');
    }
  }

  /**
   * Get or set pattern (cache-aside)
   */
  async getOrSet<T>(
    key: string,
    factory: () => Promise<T>,
    options: CacheOptions = {}
  ): Promise<T> {
    // Try to get from cache first
    const cached = await this.get<T>(key);
    if (cached !== null) {
      return cached;
    }

    // Cache miss - fetch from source
    const value = await factory();
    
    // Store in cache (don't await to not block response)
    this.set(key, value, options).catch((error) => {
      log.warn({ error, key }, 'Failed to cache value');
    });

    return value;
  }

  /**
   * Increment a counter
   */
  async increment(key: string, amount = 1): Promise<number> {
    try {
      return await this.redis.incrby(this.formatKey(key), amount);
    } catch (error) {
      log.warn({ error, key }, 'Cache increment failed');
      return 0;
    }
  }

  /**
   * Add to a set
   */
  async addToSet(key: string, ...members: string[]): Promise<void> {
    try {
      await this.redis.sadd(this.formatKey(key), ...members);
    } catch (error) {
      log.warn({ error, key }, 'Cache addToSet failed');
    }
  }

  /**
   * Get set members
   */
  async getSetMembers(key: string): Promise<string[]> {
    try {
      return await this.redis.smembers(this.formatKey(key));
    } catch (error) {
      log.warn({ error, key }, 'Cache getSetMembers failed');
      return [];
    }
  }

  /**
   * Check if member exists in set
   */
  async isMemberOfSet(key: string, member: string): Promise<boolean> {
    try {
      const result = await this.redis.sismember(this.formatKey(key), member);
      return result === 1;
    } catch (error) {
      log.warn({ error, key }, 'Cache isMemberOfSet failed');
      return false;
    }
  }

  /**
   * Hash operations for complex objects
   */
  async hset(key: string, field: string, value: unknown): Promise<void> {
    try {
      await this.redis.hset(this.formatKey(key), field, JSON.stringify(value));
    } catch (error) {
      log.warn({ error, key, field }, 'Cache hset failed');
    }
  }

  async hget<T>(key: string, field: string): Promise<T | null> {
    try {
      const value = await this.redis.hget(this.formatKey(key), field);
      return value ? (JSON.parse(value) as T) : null;
    } catch (error) {
      log.warn({ error, key, field }, 'Cache hget failed');
      return null;
    }
  }

  async hgetall<T>(key: string): Promise<Record<string, T>> {
    try {
      const data = await this.redis.hgetall(this.formatKey(key));
      const result: Record<string, T> = {};
      for (const [field, value] of Object.entries(data)) {
        result[field] = JSON.parse(value) as T;
      }
      return result;
    } catch (error) {
      log.warn({ error, key }, 'Cache hgetall failed');
      return {};
    }
  }

  /**
   * Lock for distributed operations
   */
  async acquireLock(
    key: string,
    ttlSeconds = 30
  ): Promise<{ acquired: boolean; release: () => Promise<void> }> {
    const lockKey = `lock:${key}`;
    const lockValue = `${Date.now()}-${Math.random()}`;

    try {
      const result = await this.redis.set(
        this.formatKey(lockKey),
        lockValue,
        'EX',
        ttlSeconds,
        'NX'
      );

      if (result === 'OK') {
        return {
          acquired: true,
          release: async () => {
            // Only release if we still own the lock
            const current = await this.redis.get(this.formatKey(lockKey));
            if (current === lockValue) {
              await this.redis.del(this.formatKey(lockKey));
            }
          },
        };
      }

      return {
        acquired: false,
        release: async () => {},
      };
    } catch (error) {
      log.warn({ error, key }, 'Lock acquisition failed');
      return {
        acquired: false,
        release: async () => {},
      };
    }
  }
}

/**
 * Create cache keys with consistent formatting
 */
export const CacheKeys = {
  user: (userId: string) => `user:${userId}`,
  userSession: (sessionId: string) => `session:${sessionId}`,
  product: (productId: string) => `product:${productId}`,
  productList: (category: string, page: number) => `products:${category}:${page}`,
  cart: (userId: string) => `cart:${userId}`,
  order: (orderId: string) => `order:${orderId}`,
  userOrders: (userId: string) => `orders:user:${userId}`,
  category: (categoryId: string) => `category:${categoryId}`,
  categories: () => 'categories:all',
};
