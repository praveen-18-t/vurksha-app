/**
 * Prisma Client Instance
 * Configured with connection pooling and proper logging
 */

import { PrismaClient } from '@prisma/client';
import { config } from '../config';
import { logger } from '@vurksha/shared';

const log = logger.child({ component: 'prisma' });

export const prisma = new PrismaClient({
  log: [
    { emit: 'event', level: 'query' },
    { emit: 'event', level: 'error' },
    { emit: 'event', level: 'warn' },
  ],
  datasources: {
    db: {
      url: config.databaseUrl,
    },
  },
});

// Log queries in development
if (config.nodeEnv === 'development') {
  prisma.$on('query', (e) => {
    log.debug({
      query: e.query,
      params: e.params,
      duration: e.duration,
    }, 'Database query');
  });
}

// Log errors
prisma.$on('error', (e) => {
  log.error({ error: e.message }, 'Database error');
});

// Log warnings
prisma.$on('warn', (e) => {
  log.warn({ warning: e.message }, 'Database warning');
});

/**
 * Execute with timeout
 */
export async function withDbTimeout<T>(
  operation: () => Promise<T>,
  timeoutMs = config.dbTimeout
): Promise<T> {
  return Promise.race([
    operation(),
    new Promise<never>((_, reject) =>
      setTimeout(
        () => reject(new Error(`Database operation timed out after ${timeoutMs}ms`)),
        timeoutMs
      )
    ),
  ]);
}
