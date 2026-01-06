/**
 * Authentication Service
 * Handles OTP generation, verification, and token management
 */

import bcrypt from 'bcrypt';
import { v4 as uuidv4 } from 'uuid';
import { prisma, withDbTimeout } from '../lib/prisma';
import { redis } from '../lib/redis';
import { publishEvent } from '../lib/rabbitmq';
import { config } from '../config';
import {
  logger,
  ErrorCodes,
  EventTypes,
  DomainEvent,
  UserCreatedEvent,
} from '@vurksha/shared';
import {
  UnauthorizedError,
  NotFoundError,
  BadRequestError,
} from '@vurksha/shared';
import { SendOtpInput, VerifyOtpInput } from '../schemas/auth.schema';
import { OTPPurpose } from '@prisma/client';

const log = logger.child({ service: 'auth' });

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  expiresIn: number;
}

export interface AuthResult {
  user: {
    id: string;
    phoneNumber: string;
    name: string | null;
    email: string | null;
    isNew: boolean;
  };
  tokens: TokenPair;
}

export class AuthService {
  private readonly OTP_RATE_LIMIT_KEY = 'otp:rate:';
  private readonly OTP_RATE_LIMIT_MAX = 5;
  private readonly OTP_RATE_LIMIT_WINDOW = 3600; // 1 hour

  /**
   * Send OTP to phone number
   */
  async sendOtp(
    input: SendOtpInput,
    requestId: string
  ): Promise<{ success: boolean; expiresIn: number }> {
    const { phoneNumber } = input;

    // Rate limiting
    await this.checkOtpRateLimit(phoneNumber);

    // Generate OTP
    const otp = this.generateOtp();
    const hashedOtp = await bcrypt.hash(otp, 10);

    // Find existing user
    const user = await withDbTimeout(() =>
      prisma.user.findUnique({
        where: { phoneNumber },
        select: { id: true },
      })
    );

    // Create OTP record
    await withDbTimeout(() =>
      prisma.oTPCode.create({
        data: {
          userId: user?.id,
          phoneNumber,
          code: hashedOtp,
          purpose: user ? OTPPurpose.LOGIN : OTPPurpose.REGISTRATION,
          expiresAt: new Date(Date.now() + config.otpExpiry * 1000),
          maxAttempts: config.otpMaxAttempts,
        },
      })
    );

    // Send OTP via SMS (mock in development)
    await this.sendOtpSms(phoneNumber, otp);

    // Increment rate limit counter
    await this.incrementOtpRateLimit(phoneNumber);

    log.info({ phoneNumber, requestId }, 'OTP sent');

    return {
      success: true,
      expiresIn: config.otpExpiry,
    };
  }

  /**
   * Verify OTP and authenticate user
   */
  async verifyOtp(
    input: VerifyOtpInput,
    requestId: string,
    signToken: (payload: object, options?: object) => string
  ): Promise<AuthResult> {
    const { phoneNumber, otp, deviceId, deviceName, deviceType } = input;

    // Find valid OTP
    const otpRecord = await withDbTimeout(() =>
      prisma.oTPCode.findFirst({
        where: {
          phoneNumber,
          isUsed: false,
          expiresAt: { gt: new Date() },
        },
        orderBy: { createdAt: 'desc' },
      })
    );

    if (!otpRecord) {
      throw new UnauthorizedError('OTP expired or not found', ErrorCodes.OTP_EXPIRED);
    }

    // Check attempts
    if (otpRecord.attempts >= otpRecord.maxAttempts) {
      throw new UnauthorizedError('Maximum OTP attempts exceeded', ErrorCodes.OTP_INVALID);
    }

    // Verify OTP
    const isValid = await bcrypt.compare(otp, otpRecord.code);

    if (!isValid) {
      // Increment attempts
      await prisma.oTPCode.update({
        where: { id: otpRecord.id },
        data: { attempts: { increment: 1 } },
      });
      throw new UnauthorizedError('Invalid OTP', ErrorCodes.OTP_INVALID);
    }

    // Mark OTP as used
    await prisma.oTPCode.update({
      where: { id: otpRecord.id },
      data: { isUsed: true, usedAt: new Date() },
    });

    // Find or create user
    let user = await prisma.user.findUnique({
      where: { phoneNumber },
    });

    let isNewUser = false;

    if (!user) {
      isNewUser = true;
      user = await prisma.user.create({
        data: {
          phoneNumber,
          isVerified: true,
        },
      });

      // Publish user created event
      const event: DomainEvent<UserCreatedEvent> = {
        eventId: uuidv4(),
        eventType: EventTypes.USER_CREATED,
        aggregateId: user.id,
        aggregateType: 'User',
        timestamp: new Date().toISOString(),
        version: 1,
        payload: {
          userId: user.id,
          phoneNumber: user.phoneNumber,
          createdAt: user.createdAt.toISOString(),
        },
        metadata: {
          correlationId: requestId,
          source: 'user-service',
        },
      };
      await publishEvent(event, EventTypes.USER_CREATED);
    }

    // Update last login
    await prisma.user.update({
      where: { id: user.id },
      data: { lastLoginAt: new Date() },
    });

    // Generate tokens
    const tokens = await this.generateTokens(
      user.id,
      user.role,
      signToken,
      {
        deviceId,
        deviceName,
        deviceType,
      }
    );

    log.info({ userId: user.id, isNewUser, requestId }, 'User authenticated');

    return {
      user: {
        id: user.id,
        phoneNumber: user.phoneNumber,
        name: user.name,
        email: user.email,
        isNew: isNewUser,
      },
      tokens,
    };
  }

  /**
   * Refresh access token
   */
  async refreshToken(
    refreshToken: string,
    signToken: (payload: object, options?: object) => string
  ): Promise<TokenPair> {
    // Find session
    const session = await prisma.session.findUnique({
      where: { refreshToken },
      include: { user: true },
    });

    if (!session || session.isRevoked || session.expiresAt < new Date()) {
      throw new UnauthorizedError('Invalid refresh token', ErrorCodes.TOKEN_INVALID);
    }

    // Generate new tokens
    const tokens = await this.generateTokens(
      session.userId,
      session.user.role,
      signToken,
      {
        deviceId: session.deviceId || undefined,
        deviceName: session.deviceName || undefined,
        deviceType: session.deviceType || undefined,
      }
    );

    // Revoke old session
    await prisma.session.update({
      where: { id: session.id },
      data: { isRevoked: true, revokedAt: new Date() },
    });

    return tokens;
  }

  /**
   * Logout user (revoke session)
   */
  async logout(
    userId: string,
    refreshToken?: string,
    allDevices = false
  ): Promise<void> {
    if (allDevices) {
      // Revoke all sessions
      await prisma.session.updateMany({
        where: { userId, isRevoked: false },
        data: { isRevoked: true, revokedAt: new Date() },
      });
    } else if (refreshToken) {
      // Revoke specific session
      await prisma.session.updateMany({
        where: { refreshToken, userId, isRevoked: false },
        data: { isRevoked: true, revokedAt: new Date() },
      });
    }

    log.info({ userId, allDevices }, 'User logged out');
  }

  // Private methods

  private generateOtp(): string {
    const digits = '0123456789';
    let otp = '';
    for (let i = 0; i < config.otpLength; i++) {
      otp += digits[Math.floor(Math.random() * 10)];
    }
    return otp;
  }

  private async sendOtpSms(phoneNumber: string, otp: string): Promise<void> {
    if (config.nodeEnv === 'development') {
      // Log OTP in development
      log.info({ phoneNumber, otp }, 'OTP (development mode)');
      return;
    }

    // Production: Use Twilio
    // const twilio = require('twilio')(config.twilioAccountSid, config.twilioAuthToken);
    // await twilio.messages.create({
    //   body: `Your Vurksha verification code is: ${otp}. Valid for ${config.otpExpiry / 60} minutes.`,
    //   from: config.twilioPhoneNumber,
    //   to: phoneNumber,
    // });
  }

  private async generateTokens(
    userId: string,
    role: string,
    signToken: (payload: object, options?: object) => string,
    deviceInfo: {
      deviceId?: string;
      deviceName?: string;
      deviceType?: string;
    }
  ): Promise<TokenPair> {
    // Generate refresh token
    const refreshToken = uuidv4();

    // Calculate expiry (7 days for refresh token)
    const expiresAt = new Date();
    expiresAt.setDate(expiresAt.getDate() + 7);

    // Create session
    await prisma.session.create({
      data: {
        userId,
        refreshToken,
        expiresAt,
        deviceId: deviceInfo.deviceId,
        deviceName: deviceInfo.deviceName,
        deviceType: deviceInfo.deviceType,
      },
    });

    // Generate access token
    const accessToken = signToken(
      {
        sub: userId,
        role,
        type: 'access',
      },
      { expiresIn: config.jwtAccessExpiry }
    );

    return {
      accessToken,
      refreshToken,
      expiresIn: 900, // 15 minutes in seconds
    };
  }

  private async checkOtpRateLimit(phoneNumber: string): Promise<void> {
    const key = `${this.OTP_RATE_LIMIT_KEY}${phoneNumber}`;
    const count = await redis.get(key);

    if (count && parseInt(count) >= this.OTP_RATE_LIMIT_MAX) {
      throw new BadRequestError(
        'Too many OTP requests. Please try again later.'
      );
    }
  }

  private async incrementOtpRateLimit(phoneNumber: string): Promise<void> {
    const key = `${this.OTP_RATE_LIMIT_KEY}${phoneNumber}`;
    const pipeline = redis.pipeline();
    pipeline.incr(key);
    pipeline.expire(key, this.OTP_RATE_LIMIT_WINDOW);
    await pipeline.exec();
  }
}

export const authService = new AuthService();
