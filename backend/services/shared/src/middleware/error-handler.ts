/**
 * Global Error Handler
 * Converts all errors to standardized API responses
 */

import { FastifyError, FastifyPluginCallback, FastifyReply, FastifyRequest } from 'fastify';
import fp from 'fastify-plugin';
import { ZodError } from 'zod';
import { BaseError } from '../errors/base-error';
import { errorResponse } from '../types/api-response';
import { ErrorCodes, ErrorCodeToHttpStatus, RetryableErrors } from '../types/errors';
import { logger } from '../utils/logger';

interface ErrorHandlerOptions {
  /** Whether to include stack traces in development */
  includeStackTrace?: boolean;
}

const errorHandlerPlugin: FastifyPluginCallback<ErrorHandlerOptions> = (
  fastify,
  opts,
  done
) => {
  const includeStack = opts.includeStackTrace ?? process.env.NODE_ENV !== 'production';

  fastify.setErrorHandler((error: FastifyError | Error, request: FastifyRequest, reply: FastifyReply) => {
    const requestId = request.requestId || 'unknown';
    
    // Log the error
    logger.error({
      requestId,
      error: error.message,
      stack: error.stack,
      url: request.url,
      method: request.method,
    }, 'Request error');

    // Handle Zod validation errors
    if (error instanceof ZodError) {
      const response = errorResponse(
        ErrorCodes.VALIDATION_ERROR,
        'Validation failed',
        requestId,
        {
          retryable: false,
          details: { errors: error.errors },
        }
      );
      return reply.status(400).send(response);
    }

    // Handle custom application errors
    if (error instanceof BaseError) {
      const httpStatus = ErrorCodeToHttpStatus[error.code] || 500;
      const isRetryable = RetryableErrors.has(error.code);
      
      const response = errorResponse(
        error.code,
        error.message,
        requestId,
        {
          retryable: isRetryable,
          retryAfter: isRetryable ? 5 : undefined,
          details: includeStack ? { stack: error.stack } : undefined,
        }
      );
      
      return reply.status(httpStatus).send(response);
    }

    // Handle Fastify errors (validation, etc.)
    if ('statusCode' in error) {
      const fastifyError = error as FastifyError;
      const code = getErrorCodeFromStatus(fastifyError.statusCode || 500);
      
      const response = errorResponse(
        code,
        fastifyError.message,
        requestId,
        {
          retryable: fastifyError.statusCode === 503 || fastifyError.statusCode === 429,
          details: includeStack ? { stack: fastifyError.stack } : undefined,
        }
      );
      
      return reply.status(fastifyError.statusCode || 500).send(response);
    }

    // Handle unknown errors
    const response = errorResponse(
      ErrorCodes.INTERNAL_ERROR,
      process.env.NODE_ENV === 'production'
        ? 'An unexpected error occurred'
        : error.message,
      requestId,
      {
        retryable: true,
        retryAfter: 5,
        details: includeStack ? { stack: error.stack } : undefined,
      }
    );

    return reply.status(500).send(response);
  });

  // Handle 404 errors
  fastify.setNotFoundHandler((request: FastifyRequest, reply: FastifyReply) => {
    const requestId = request.requestId || 'unknown';
    
    const response = errorResponse(
      ErrorCodes.NOT_FOUND,
      `Route ${request.method} ${request.url} not found`,
      requestId,
      { retryable: false }
    );
    
    return reply.status(404).send(response);
  });

  done();
};

function getErrorCodeFromStatus(status: number): string {
  switch (status) {
    case 400:
      return ErrorCodes.VALIDATION_ERROR;
    case 401:
      return ErrorCodes.UNAUTHORIZED;
    case 404:
      return ErrorCodes.NOT_FOUND;
    case 409:
      return ErrorCodes.CONFLICT;
    case 429:
      return ErrorCodes.RATE_LIMITED;
    case 503:
      return ErrorCodes.SERVICE_UNAVAILABLE;
    default:
      return ErrorCodes.INTERNAL_ERROR;
  }
}

export const errorHandler = fp(errorHandlerPlugin, {
  name: 'error-handler',
  fastify: '4.x',
});
