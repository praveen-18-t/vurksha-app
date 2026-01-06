/**
 * User Routes
 * Endpoints for user profile management
 */

import { FastifyInstance, FastifyPluginCallback, FastifyRequest, FastifyReply } from 'fastify';
import { validate, successResponse } from '@vurksha/shared';
import { userService } from '../services/user.service';
import {
  updateUserSchema,
  userParamsSchema,
  UpdateUserInput,
  UserParams,
} from '../schemas/user.schema';

// Authentication decorator
const authenticate = async (request: FastifyRequest, _reply: FastifyReply) => {
  await request.jwtVerify();
};

export const userRoutes: FastifyPluginCallback = (
  fastify: FastifyInstance,
  _opts,
  done
) => {
  // All routes require authentication
  fastify.addHook('preHandler', authenticate);

  /**
   * GET /users/me
   * Get current user profile
   */
  fastify.get('/me', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;
    const user = await userService.getById(userId);

    const response = successResponse({ user }, request.requestId);
    return reply.status(200).send(response);
  });

  /**
   * PUT /users/me
   * Update current user profile
   */
  fastify.put(
    '/me',
    validate<UpdateUserInput, unknown, unknown>(
      { body: updateUserSchema },
      async (request, reply) => {
        const userId = (request.user as { sub: string }).sub;

        const user = await userService.update(
          userId,
          request.body,
          request.requestId
        );

        const response = successResponse({ user }, request.requestId);
        return reply.status(200).send(response);
      }
    )
  );

  /**
   * DELETE /users/me
   * Delete current user account
   */
  fastify.delete('/me', async (request, reply) => {
    const userId = (request.user as { sub: string }).sub;

    await userService.delete(userId, request.requestId);

    const response = successResponse(
      { message: 'Account deleted successfully' },
      request.requestId
    );
    return reply.status(200).send(response);
  });

  /**
   * GET /users/:id (Admin only)
   * Get user by ID
   */
  fastify.get(
    '/:id',
    validate<unknown, UserParams, unknown>(
      { params: userParamsSchema },
      async (request, reply) => {
        const userRole = (request.user as { role: string }).role;

        if (userRole !== 'ADMIN') {
          return reply.status(403).send({
            success: false,
            error: {
              code: 'FORBIDDEN',
              message: 'Admin access required',
              retryable: false,
            },
            meta: {
              requestId: request.requestId,
              timestamp: new Date().toISOString(),
              version: '1.0.0',
            },
          });
        }

        const user = await userService.getById(request.params.id);
        const response = successResponse({ user }, request.requestId);
        return reply.status(200).send(response);
      }
    )
  );

  done();
};
