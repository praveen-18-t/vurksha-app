/**
 * User Service Configuration
 * Centralized configuration with environment validation
 */

import { z } from 'zod';

const configSchema = z.object({
  // Service
  serviceName: z.string().default('user-service'),
  serviceVersion: z.string().default('1.0.0'),
  nodeEnv: z.enum(['development', 'staging', 'production']).default('development'),
  
  // Server
  port: z.coerce.number().default(3001),
  host: z.string().default('0.0.0.0'),
  
  // Database
  databaseUrl: z.string(),
  dbPoolMin: z.coerce.number().default(2),
  dbPoolMax: z.coerce.number().default(10),
  dbConnectionTimeout: z.coerce.number().default(10000),
  
  // Redis
  redisUrl: z.string(),
  
  // RabbitMQ
  rabbitmqUrl: z.string(),
  
  // JWT
  jwtSecret: z.string().min(32),
  jwtAccessExpiry: z.string().default('15m'),
  jwtRefreshExpiry: z.string().default('7d'),
  
  // OTP
  otpLength: z.coerce.number().default(6),
  otpExpiry: z.coerce.number().default(300), // 5 minutes
  otpMaxAttempts: z.coerce.number().default(3),
  
  // Twilio (SMS)
  twilioAccountSid: z.string().optional(),
  twilioAuthToken: z.string().optional(),
  twilioPhoneNumber: z.string().optional(),
  
  // Rate Limiting
  rateLimitMax: z.coerce.number().default(100),
  rateLimitWindow: z.coerce.number().default(60),
  
  // Timeouts
  defaultTimeout: z.coerce.number().default(5000),
  dbTimeout: z.coerce.number().default(10000),
});

export type Config = z.infer<typeof configSchema>;

function loadConfig(): Config {
  const result = configSchema.safeParse({
    serviceName: process.env.SERVICE_NAME,
    serviceVersion: process.env.SERVICE_VERSION,
    nodeEnv: process.env.NODE_ENV,
    port: process.env.PORT,
    host: process.env.HOST,
    databaseUrl: process.env.DATABASE_URL,
    dbPoolMin: process.env.DB_POOL_MIN,
    dbPoolMax: process.env.DB_POOL_MAX,
    dbConnectionTimeout: process.env.DB_CONNECTION_TIMEOUT,
    redisUrl: process.env.REDIS_URL,
    rabbitmqUrl: process.env.RABBITMQ_URL,
    jwtSecret: process.env.JWT_SECRET,
    jwtAccessExpiry: process.env.JWT_ACCESS_EXPIRY,
    jwtRefreshExpiry: process.env.JWT_REFRESH_EXPIRY,
    otpLength: process.env.OTP_LENGTH,
    otpExpiry: process.env.OTP_EXPIRY,
    otpMaxAttempts: process.env.OTP_MAX_ATTEMPTS,
    twilioAccountSid: process.env.TWILIO_ACCOUNT_SID,
    twilioAuthToken: process.env.TWILIO_AUTH_TOKEN,
    twilioPhoneNumber: process.env.TWILIO_PHONE_NUMBER,
    rateLimitMax: process.env.RATE_LIMIT_MAX,
    rateLimitWindow: process.env.RATE_LIMIT_WINDOW,
    defaultTimeout: process.env.DEFAULT_TIMEOUT,
    dbTimeout: process.env.DB_TIMEOUT,
  });

  if (!result.success) {
    console.error('Configuration validation failed:');
    console.error(result.error.format());
    process.exit(1);
  }

  return result.data;
}

export const config = loadConfig();
