/**
 * RabbitMQ Connection
 * Configured for reliable messaging with automatic reconnection
 */

import amqp, { Channel, Connection } from 'amqplib';
import { config } from '../config';
import { logger, Exchanges, DomainEvent } from '@vurksha/shared';

const log = logger.child({ component: 'rabbitmq' });

let connection: Connection | null = null;
let channel: Channel | null = null;
let isConnecting = false;

/**
 * Connect to RabbitMQ with retry logic
 */
export async function connectRabbitMQ(): Promise<void> {
  if (connection && channel) return;
  if (isConnecting) return;

  isConnecting = true;

  try {
    connection = await amqp.connect(config.rabbitmqUrl);
    channel = await connection.createChannel();

    // Set up exchanges
    await channel.assertExchange(Exchanges.DOMAIN_EVENTS, 'topic', {
      durable: true,
    });

    await channel.assertExchange(Exchanges.DEAD_LETTER, 'topic', {
      durable: true,
    });

    // Handle connection events
    connection.on('error', (err) => {
      log.error({ error: err.message }, 'RabbitMQ connection error');
    });

    connection.on('close', () => {
      log.warn('RabbitMQ connection closed, attempting reconnect...');
      connection = null;
      channel = null;
      setTimeout(() => connectRabbitMQ(), 5000);
    });

    log.info('RabbitMQ connected');
    isConnecting = false;
  } catch (error) {
    log.error({ error }, 'Failed to connect to RabbitMQ');
    isConnecting = false;
    setTimeout(() => connectRabbitMQ(), 5000);
    throw error;
  }
}

/**
 * Publish an event to the domain events exchange
 */
export async function publishEvent<T>(
  event: DomainEvent<T>,
  routingKey: string
): Promise<boolean> {
  if (!channel) {
    log.warn('RabbitMQ channel not available, buffering event');
    // In production, you'd buffer this and retry
    return false;
  }

  try {
    const message = Buffer.from(JSON.stringify(event));
    
    channel.publish(Exchanges.DOMAIN_EVENTS, routingKey, message, {
      persistent: true,
      contentType: 'application/json',
      messageId: event.eventId,
      timestamp: Date.now(),
      headers: {
        'x-correlation-id': event.metadata.correlationId,
      },
    });

    log.debug({
      eventId: event.eventId,
      eventType: event.eventType,
      routingKey,
    }, 'Event published');

    return true;
  } catch (error) {
    log.error({ error, event }, 'Failed to publish event');
    return false;
  }
}

/**
 * Get RabbitMQ channel
 */
export function getChannel(): Channel | null {
  return channel;
}

/**
 * Check if RabbitMQ is connected
 */
export function isConnected(): boolean {
  return connection !== null && channel !== null;
}

/**
 * Close RabbitMQ connection
 */
export async function closeRabbitMQ(): Promise<void> {
  try {
    if (channel) {
      await channel.close();
    }
    if (connection) {
      await connection.close();
    }
    log.info('RabbitMQ connection closed');
  } catch (error) {
    log.error({ error }, 'Error closing RabbitMQ connection');
  }
}
