/**
 * Standardized API Response Types
 * All services MUST use these types for consistent Flutter integration
 */

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: ApiError;
  meta: ResponseMeta;
  pagination?: PaginationMeta;
}

export interface ApiError {
  code: string;
  message: string;
  details?: Record<string, unknown>;
  retryable: boolean;
  retryAfter?: number; // seconds
}

export interface ResponseMeta {
  requestId: string;
  timestamp: string;
  version: string;
  processingTimeMs?: number;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasMore: boolean;
}

/**
 * Success response builder
 */
export function successResponse<T>(
  data: T,
  requestId: string,
  pagination?: Omit<PaginationMeta, 'totalPages' | 'hasMore'>
): ApiResponse<T> {
  const paginationMeta = pagination
    ? {
        ...pagination,
        totalPages: Math.ceil(pagination.total / pagination.limit),
        hasMore: pagination.page * pagination.limit < pagination.total,
      }
    : undefined;

  return {
    success: true,
    data,
    meta: {
      requestId,
      timestamp: new Date().toISOString(),
      version: process.env.API_VERSION || '1.0.0',
    },
    pagination: paginationMeta,
  };
}

/**
 * Error response builder
 */
export function errorResponse(
  code: string,
  message: string,
  requestId: string,
  options: {
    retryable?: boolean;
    retryAfter?: number;
    details?: Record<string, unknown>;
  } = {}
): ApiResponse<never> {
  return {
    success: false,
    error: {
      code,
      message,
      retryable: options.retryable ?? false,
      retryAfter: options.retryAfter,
      details: options.details,
    },
    meta: {
      requestId,
      timestamp: new Date().toISOString(),
      version: process.env.API_VERSION || '1.0.0',
    },
  };
}
