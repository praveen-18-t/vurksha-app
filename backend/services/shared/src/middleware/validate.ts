/**
 * Request Validation Middleware
 * Uses Zod schemas for type-safe request validation
 */

import { FastifyRequest, FastifyReply, RouteHandlerMethod } from 'fastify';
import { z, ZodSchema, ZodError } from 'zod';
import { errorResponse } from '../types/api-response';
import { ErrorCodes } from '../types/errors';

export interface ValidationSchemas {
  body?: ZodSchema;
  params?: ZodSchema;
  query?: ZodSchema;
  headers?: ZodSchema;
}

/**
 * Create a validated route handler
 */
export function validate<
  TBody = unknown,
  TParams = unknown,
  TQuery = unknown,
>(
  schemas: ValidationSchemas,
  handler: (
    request: FastifyRequest<{
      Body: TBody;
      Params: TParams;
      Querystring: TQuery;
    }>,
    reply: FastifyReply
  ) => Promise<void>
): RouteHandlerMethod {
  return async (request: FastifyRequest, reply: FastifyReply) => {
    try {
      // Validate body
      if (schemas.body) {
        request.body = schemas.body.parse(request.body);
      }

      // Validate params
      if (schemas.params) {
        (request.params as unknown) = schemas.params.parse(request.params);
      }

      // Validate query
      if (schemas.query) {
        (request.query as unknown) = schemas.query.parse(request.query);
      }

      // Validate headers
      if (schemas.headers) {
        const validatedHeaders = schemas.headers.parse(request.headers);
        Object.assign(request.headers, validatedHeaders);
      }

      // Call the actual handler
      await handler(
        request as FastifyRequest<{
          Body: TBody;
          Params: TParams;
          Querystring: TQuery;
        }>,
        reply
      );
    } catch (error) {
      if (error instanceof ZodError) {
        const response = errorResponse(
          ErrorCodes.VALIDATION_ERROR,
          'Request validation failed',
          request.requestId,
          {
            retryable: false,
            details: formatZodError(error),
          }
        );
        return reply.status(400).send(response);
      }
      throw error;
    }
  };
}

/**
 * Format Zod errors into a user-friendly structure
 */
function formatZodError(error: ZodError): Record<string, unknown> {
  const errors = error.errors.map((err) => ({
    field: err.path.join('.'),
    message: err.message,
    code: err.code,
  }));

  return { validationErrors: errors };
}

// Common validation schemas
export const CommonSchemas = {
  /**
   * UUID parameter validation
   */
  uuidParam: z.object({
    id: z.string().uuid('Invalid ID format'),
  }),

  /**
   * Phone number validation (Indian format)
   */
  phoneNumber: z.string().regex(
    /^\+91[6-9]\d{9}$/,
    'Invalid phone number. Must be in format +91XXXXXXXXXX'
  ),

  /**
   * Email validation
   */
  email: z.string().email('Invalid email format'),

  /**
   * Pagination query params
   */
  pagination: z.object({
    page: z.coerce.number().int().min(1).default(1),
    limit: z.coerce.number().int().min(1).max(100).default(20),
    sortBy: z.string().optional(),
    sortOrder: z.enum(['asc', 'desc']).default('desc'),
  }),

  /**
   * Date range query params
   */
  dateRange: z.object({
    startDate: z.coerce.date().optional(),
    endDate: z.coerce.date().optional(),
  }).refine(
    (data) => {
      if (data.startDate && data.endDate) {
        return data.startDate <= data.endDate;
      }
      return true;
    },
    { message: 'Start date must be before end date' }
  ),

  /**
   * Non-empty string
   */
  nonEmptyString: z.string().min(1, 'This field cannot be empty'),

  /**
   * Positive number
   */
  positiveNumber: z.number().positive('Must be a positive number'),

  /**
   * Positive integer
   */
  positiveInt: z.number().int().positive('Must be a positive integer'),
};
