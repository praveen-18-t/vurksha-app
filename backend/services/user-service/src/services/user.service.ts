/**
 * User Service
 * Handles user profile operations
 */

import { prisma, withDbTimeout } from '../lib/prisma';
import { redis } from '../lib/redis';
import { publishEvent } from '../lib/rabbitmq';
import { v4 as uuidv4 } from 'uuid';
import {
  logger,
  CacheKeys,
  EventTypes,
  DomainEvent,
  UserUpdatedEvent,
} from '@vurksha/shared';
import { NotFoundError } from '@vurksha/shared';
import { UpdateUserInput } from '../schemas/user.schema';

const log = logger.child({ service: 'user' });
const CACHE_TTL = 300; // 5 minutes

export interface UserDto {
  id: string;
  phoneNumber: string;
  email: string | null;
  name: string | null;
  profileImageUrl: string | null;
  isVerified: boolean;
  createdAt: string;
}

export class UserService {
  /**
   * Get user by ID
   */
  async getById(userId: string): Promise<UserDto> {
    // Try cache first
    const cacheKey = CacheKeys.user(userId);
    const cached = await redis.get(cacheKey);

    if (cached) {
      log.debug({ userId }, 'User cache hit');
      return JSON.parse(cached);
    }

    // Cache miss - fetch from database
    const user = await withDbTimeout(() =>
      prisma.user.findUnique({
        where: { id: userId },
        select: {
          id: true,
          phoneNumber: true,
          email: true,
          name: true,
          profileImageUrl: true,
          isVerified: true,
          createdAt: true,
        },
      })
    );

    if (!user) {
      throw new NotFoundError('User', userId);
    }

    const dto = this.toDto(user);

    // Cache the result
    await redis.setex(cacheKey, CACHE_TTL, JSON.stringify(dto));

    return dto;
  }

  /**
   * Update user profile
   */
  async update(
    userId: string,
    input: UpdateUserInput,
    requestId: string
  ): Promise<UserDto> {
    // Verify user exists
    const existing = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!existing) {
      throw new NotFoundError('User', userId);
    }

    // Update user
    const user = await withDbTimeout(() =>
      prisma.user.update({
        where: { id: userId },
        data: input,
        select: {
          id: true,
          phoneNumber: true,
          email: true,
          name: true,
          profileImageUrl: true,
          isVerified: true,
          createdAt: true,
        },
      })
    );

    const dto = this.toDto(user);

    // Invalidate cache
    await redis.del(CacheKeys.user(userId));

    // Publish event
    const event: DomainEvent<UserUpdatedEvent> = {
      eventId: uuidv4(),
      eventType: EventTypes.USER_UPDATED,
      aggregateId: userId,
      aggregateType: 'User',
      timestamp: new Date().toISOString(),
      version: 1,
      payload: {
        userId,
        changes: input,
        updatedAt: new Date().toISOString(),
      },
      metadata: {
        correlationId: requestId,
        userId,
        source: 'user-service',
      },
    };
    await publishEvent(event, EventTypes.USER_UPDATED);

    log.info({ userId, requestId }, 'User updated');

    return dto;
  }

  /**
   * Delete user account
   */
  async delete(userId: string, requestId: string): Promise<void> {
    const user = await prisma.user.findUnique({
      where: { id: userId },
    });

    if (!user) {
      throw new NotFoundError('User', userId);
    }

    // Soft delete - mark as inactive
    await prisma.user.update({
      where: { id: userId },
      data: { isActive: false },
    });

    // Revoke all sessions
    await prisma.session.updateMany({
      where: { userId, isRevoked: false },
      data: { isRevoked: true, revokedAt: new Date() },
    });

    // Invalidate cache
    await redis.del(CacheKeys.user(userId));

    // Publish event
    const event: DomainEvent<{ userId: string; deletedAt: string }> = {
      eventId: uuidv4(),
      eventType: EventTypes.USER_DELETED,
      aggregateId: userId,
      aggregateType: 'User',
      timestamp: new Date().toISOString(),
      version: 1,
      payload: {
        userId,
        deletedAt: new Date().toISOString(),
      },
      metadata: {
        correlationId: requestId,
        userId,
        source: 'user-service',
      },
    };
    await publishEvent(event, EventTypes.USER_DELETED);

    log.info({ userId, requestId }, 'User deleted');
  }

  private toDto(user: {
    id: string;
    phoneNumber: string;
    email: string | null;
    name: string | null;
    profileImageUrl: string | null;
    isVerified: boolean;
    createdAt: Date;
  }): UserDto {
    return {
      id: user.id,
      phoneNumber: user.phoneNumber,
      email: user.email,
      name: user.name,
      profileImageUrl: user.profileImageUrl,
      isVerified: user.isVerified,
      createdAt: user.createdAt.toISOString(),
    };
  }
}

export const userService = new UserService();
