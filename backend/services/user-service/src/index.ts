/**
 * User Service Entry Point
 * Initializes and starts the Fastify server with proper graceful shutdown
 */

import { createServer } from './server';
import { config } from './config';
import { logger } from '@vurksha/shared';
import { prisma } from './lib/prisma';
import { redis } from './lib/redis';
import { closeRabbitMQ } from './lib/rabbitmq';

const log = logger.child({ service: config.serviceName });

async function main() {
  const server = await createServer();

  // Graceful shutdown handlers
  const signals: NodeJS.Signals[] = ['SIGINT', 'SIGTERM'];
  
  for (const signal of signals) {
    process.on(signal, async () => {
      log.info({ signal }, 'Received shutdown signal');
      
      try {
        // Stop accepting new connections
        await server.close();
        log.info('HTTP server closed');

        // Close database connections
        await prisma.$disconnect();
        log.info('Database connections closed');

        // Close Redis
        await redis.quit();
        log.info('Redis connection closed');

        // Close RabbitMQ
        await closeRabbitMQ();
        log.info('RabbitMQ connection closed');

        log.info('Graceful shutdown completed');
        process.exit(0);
      } catch (error) {
        log.error({ error }, 'Error during shutdown');
        process.exit(1);
      }
    });
  }

  // Handle uncaught exceptions
  process.on('uncaughtException', (error) => {
    log.fatal({ error }, 'Uncaught exception');
    process.exit(1);
  });

  process.on('unhandledRejection', (reason) => {
    log.fatal({ reason }, 'Unhandled rejection');
    process.exit(1);
  });

  // Start server
  try {
    await server.listen({
      port: config.port,
      host: config.host,
    });
    
    log.info(
      {
        port: config.port,
        host: config.host,
        environment: config.nodeEnv,
      },
      `${config.serviceName} started`
    );
  } catch (error) {
    log.fatal({ error }, 'Failed to start server');
    process.exit(1);
  }
}

main();
