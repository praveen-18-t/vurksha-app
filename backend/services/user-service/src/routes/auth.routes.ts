/**
 * Authentication Routes
 * Public endpoints for user authentication
 */

import { FastifyInstance, FastifyPluginCallback } from 'fastify';
import { validate, successResponse } from '@vurksha/shared';
import { authService } from '../services/auth.service';
import {
  sendOtpSchema,
  verifyOtpSchema,
  refreshTokenSchema,
  logoutSchema,
  SendOtpInput,
  VerifyOtpInput,
  RefreshTokenInput,
  LogoutInput,
} from '../schemas/auth.schema';

export const authRoutes: FastifyPluginCallback = (
  fastify: FastifyInstance,
  _opts,
  done
) => {
  /**
   * POST /auth/otp/send
   * Send OTP to phone number
   */
  fastify.post(
    '/otp/send',
    validate<SendOtpInput, unknown, unknown>(
      { body: sendOtpSchema },
      async (request, reply) => {
        const result = await authService.sendOtp(
          request.body,
          request.requestId
        );

        const response = successResponse(
          {
            message: 'OTP sent successfully',
            expiresIn: result.expiresIn,
          },
          request.requestId
        );

        return reply.status(200).send(response);
      }
    )
  );

  /**
   * POST /auth/otp/verify
   * Verify OTP and authenticate user
   */
  fastify.post(
    '/otp/verify',
    validate<VerifyOtpInput, unknown, unknown>(
      { body: verifyOtpSchema },
      async (request, reply) => {
        const result = await authService.verifyOtp(
          request.body,
          request.requestId,
          (payload, options) => fastify.jwt.sign(payload, options)
        );

        const response = successResponse(
          {
            user: result.user,
            tokens: result.tokens,
          },
          request.requestId
        );

        return reply.status(200).send(response);
      }
    )
  );

  /**
   * POST /auth/token/refresh
   * Refresh access token
   */
  fastify.post(
    '/token/refresh',
    validate<RefreshTokenInput, unknown, unknown>(
      { body: refreshTokenSchema },
      async (request, reply) => {
        const tokens = await authService.refreshToken(
          request.body.refreshToken,
          (payload, options) => fastify.jwt.sign(payload, options)
        );

        const response = successResponse({ tokens }, request.requestId);

        return reply.status(200).send(response);
      }
    )
  );

  /**
   * POST /auth/logout
   * Logout user (requires authentication)
   */
  fastify.post(
    '/logout',
    {
      preHandler: [fastify.authenticate],
    },
    validate<LogoutInput, unknown, unknown>(
      { body: logoutSchema },
      async (request, reply) => {
        const userId = (request.user as { sub: string }).sub;

        await authService.logout(
          userId,
          request.body.refreshToken,
          request.body.allDevices
        );

        const response = successResponse(
          { message: 'Logged out successfully' },
          request.requestId
        );

        return reply.status(200).send(response);
      }
    )
  );

  done();
};

// Add authenticate decorator type
declare module 'fastify' {
  interface FastifyInstance {
    authenticate: (
      request: FastifyRequest,
      reply: FastifyReply
    ) => Promise<void>;
  }
}

import { FastifyRequest, FastifyReply } from 'fastify';
