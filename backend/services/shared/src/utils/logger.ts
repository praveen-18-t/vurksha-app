/**
 * Structured Logger
 * Production-grade logging with JSON output for observability
 */

import pino, { Logger, LoggerOptions } from 'pino';

const isDevelopment = process.env.NODE_ENV !== 'production';

const baseConfig: LoggerOptions = {
  level: process.env.LOG_LEVEL || (isDevelopment ? 'debug' : 'info'),
  
  // Add timestamp and service info
  base: {
    service: process.env.SERVICE_NAME || 'unknown',
    version: process.env.SERVICE_VERSION || '1.0.0',
    environment: process.env.NODE_ENV || 'development',
  },
  
  // Customize timestamp format
  timestamp: pino.stdTimeFunctions.isoTime,
  
  // Redact sensitive fields
  redact: {
    paths: [
      'password',
      'token',
      'accessToken',
      'refreshToken',
      'authorization',
      'cookie',
      'otp',
      'secret',
      '*.password',
      '*.token',
      'headers.authorization',
      'headers.cookie',
    ],
    censor: '[REDACTED]',
  },

  // Format stack traces
  formatters: {
    level: (label) => ({ level: label }),
    bindings: (bindings) => ({
      pid: bindings.pid,
      host: bindings.hostname,
    }),
  },
};

// Pretty print for development
const devConfig: LoggerOptions = {
  ...baseConfig,
  transport: {
    target: 'pino-pretty',
    options: {
      colorize: true,
      translateTime: 'SYS:standard',
      ignore: 'pid,hostname',
    },
  },
};

// JSON output for production
const prodConfig: LoggerOptions = {
  ...baseConfig,
};

export const logger: Logger = pino(isDevelopment ? devConfig : prodConfig);

/**
 * Create a child logger with additional context
 */
export function createLogger(context: Record<string, unknown>): Logger {
  return logger.child(context);
}

/**
 * Request-scoped logger factory
 */
export function createRequestLogger(
  requestId: string,
  correlationId: string,
  additionalContext?: Record<string, unknown>
): Logger {
  return logger.child({
    requestId,
    correlationId,
    ...additionalContext,
  });
}

/**
 * Standard log formats for common events
 */
export const LogFormats = {
  httpRequest: (method: string, url: string, statusCode: number, durationMs: number) => ({
    type: 'http_request',
    method,
    url,
    statusCode,
    durationMs,
  }),

  dbQuery: (operation: string, table: string, durationMs: number) => ({
    type: 'db_query',
    operation,
    table,
    durationMs,
  }),

  cacheHit: (key: string) => ({
    type: 'cache_hit',
    key,
  }),

  cacheMiss: (key: string) => ({
    type: 'cache_miss',
    key,
  }),

  externalCall: (service: string, operation: string, durationMs: number, success: boolean) => ({
    type: 'external_call',
    service,
    operation,
    durationMs,
    success,
  }),

  businessEvent: (event: string, data: Record<string, unknown>) => ({
    type: 'business_event',
    event,
    ...data,
  }),
};
