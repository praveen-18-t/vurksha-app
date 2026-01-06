/**
 * Health Check Utilities
 * Liveness and Readiness probes for Kubernetes
 */

import { FastifyInstance, FastifyPluginCallback } from 'fastify';
import fp from 'fastify-plugin';
import { logger } from './logger';

export interface HealthCheckDependency {
  name: string;
  check: () => Promise<boolean>;
  critical?: boolean; // If true, failure means service is not ready
}

export interface HealthStatus {
  status: 'healthy' | 'degraded' | 'unhealthy';
  timestamp: string;
  uptime: number;
  version: string;
  dependencies: Record<
    string,
    {
      status: 'up' | 'down';
      latencyMs: number;
    }
  >;
}

const startTime = Date.now();
const log = logger.child({ component: 'health' });

const healthPlugin: FastifyPluginCallback<{
  dependencies?: HealthCheckDependency[];
}> = (fastify: FastifyInstance, opts, done) => {
  const dependencies = opts.dependencies || [];

  /**
   * Liveness probe - is the service running?
   * Used by Kubernetes to determine if pod should be restarted
   */
  fastify.get('/health/live', async (_request, reply) => {
    return reply.status(200).send({
      status: 'ok',
      timestamp: new Date().toISOString(),
    });
  });

  /**
   * Readiness probe - is the service ready to accept traffic?
   * Used by Kubernetes to determine if pod should receive traffic
   */
  fastify.get('/health/ready', async (_request, reply) => {
    const results = await checkDependencies(dependencies);
    
    // Check if any critical dependency is down
    const criticalDown = dependencies.some(
      (dep) => dep.critical && results[dep.name]?.status === 'down'
    );

    if (criticalDown) {
      return reply.status(503).send({
        status: 'not_ready',
        timestamp: new Date().toISOString(),
        dependencies: results,
      });
    }

    return reply.status(200).send({
      status: 'ready',
      timestamp: new Date().toISOString(),
      dependencies: results,
    });
  });

  /**
   * Detailed health status - for monitoring dashboards
   */
  fastify.get('/health', async (_request, reply) => {
    const results = await checkDependencies(dependencies);
    
    const allUp = Object.values(results).every((r) => r.status === 'up');
    const anyDown = Object.values(results).some((r) => r.status === 'down');

    const status: HealthStatus = {
      status: allUp ? 'healthy' : anyDown ? 'degraded' : 'healthy',
      timestamp: new Date().toISOString(),
      uptime: Math.floor((Date.now() - startTime) / 1000),
      version: process.env.SERVICE_VERSION || '1.0.0',
      dependencies: results,
    };

    const statusCode = status.status === 'unhealthy' ? 503 : 200;
    return reply.status(statusCode).send(status);
  });

  done();
};

/**
 * Check all dependencies and return their status
 */
async function checkDependencies(
  dependencies: HealthCheckDependency[]
): Promise<Record<string, { status: 'up' | 'down'; latencyMs: number }>> {
  const results: Record<string, { status: 'up' | 'down'; latencyMs: number }> =
    {};

  await Promise.all(
    dependencies.map(async (dep) => {
      const start = Date.now();
      try {
        const isHealthy = await Promise.race([
          dep.check(),
          new Promise<boolean>((_, reject) =>
            setTimeout(() => reject(new Error('Timeout')), 5000)
          ),
        ]);
        results[dep.name] = {
          status: isHealthy ? 'up' : 'down',
          latencyMs: Date.now() - start,
        };
      } catch (error) {
        log.warn({ dependency: dep.name, error }, 'Health check failed');
        results[dep.name] = {
          status: 'down',
          latencyMs: Date.now() - start,
        };
      }
    })
  );

  return results;
}

export const healthCheckPlugin = fp(healthPlugin, {
  name: 'health-check',
  fastify: '4.x',
});

/**
 * Common health check factories
 */
export const HealthChecks = {
  /**
   * PostgreSQL health check
   */
  postgres: (prisma: { $queryRaw: (query: unknown) => Promise<unknown> }) => ({
    name: 'postgres',
    critical: true,
    check: async () => {
      try {
        await prisma.$queryRaw`SELECT 1`;
        return true;
      } catch {
        return false;
      }
    },
  }),

  /**
   * Redis health check
   */
  redis: (redis: { ping: () => Promise<string> }) => ({
    name: 'redis',
    critical: false, // Service can operate without cache
    check: async () => {
      try {
        const result = await redis.ping();
        return result === 'PONG';
      } catch {
        return false;
      }
    },
  }),

  /**
   * RabbitMQ health check
   */
  rabbitmq: (connection: { isConnected: () => boolean }) => ({
    name: 'rabbitmq',
    critical: false, // Service can buffer messages
    check: async () => {
      return connection.isConnected();
    },
  }),

  /**
   * Elasticsearch health check
   */
  elasticsearch: (client: { ping: () => Promise<boolean> }) => ({
    name: 'elasticsearch',
    critical: false,
    check: async () => {
      try {
        return await client.ping();
      } catch {
        return false;
      }
    },
  }),

  /**
   * External service health check
   */
  externalService: (
    name: string,
    healthUrl: string,
    fetch: typeof globalThis.fetch
  ) => ({
    name,
    critical: false,
    check: async () => {
      try {
        const response = await fetch(healthUrl, {
          method: 'GET',
          signal: AbortSignal.timeout(3000),
        });
        return response.ok;
      } catch {
        return false;
      }
    },
  }),
};
