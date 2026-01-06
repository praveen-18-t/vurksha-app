/**
 * HTTP Error Classes
 * Typed errors for common HTTP scenarios
 */

import { BaseError } from './base-error';
import { ErrorCodes, ErrorCode } from '../types/errors';

/**
 * 400 Bad Request
 */
export class BadRequestError extends BaseError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(ErrorCodes.VALIDATION_ERROR, message, { details });
  }
}

/**
 * 401 Unauthorized
 */
export class UnauthorizedError extends BaseError {
  constructor(message = 'Authentication required', code?: ErrorCode) {
    super(code || ErrorCodes.UNAUTHORIZED, message);
  }
}

/**
 * 403 Forbidden
 */
export class ForbiddenError extends BaseError {
  constructor(message = 'Access denied') {
    super(ErrorCodes.UNAUTHORIZED, message);
  }
}

/**
 * 404 Not Found
 */
export class NotFoundError extends BaseError {
  constructor(resource: string, id?: string) {
    const message = id
      ? `${resource} with ID '${id}' not found`
      : `${resource} not found`;
    super(ErrorCodes.NOT_FOUND, message, { details: { resource, id } });
  }
}

/**
 * 409 Conflict
 */
export class ConflictError extends BaseError {
  constructor(message: string, details?: Record<string, unknown>) {
    super(ErrorCodes.CONFLICT, message, { details });
  }
}

/**
 * 422 Unprocessable Entity (Business Logic Error)
 */
export class BusinessError extends BaseError {
  constructor(code: ErrorCode, message: string, details?: Record<string, unknown>) {
    super(code, message, { details });
  }
}

/**
 * 429 Rate Limited
 */
export class RateLimitError extends BaseError {
  public readonly retryAfter: number;

  constructor(retryAfter: number) {
    super(ErrorCodes.RATE_LIMITED, 'Too many requests, please try again later');
    this.retryAfter = retryAfter;
  }
}

/**
 * 500 Internal Server Error
 */
export class InternalError extends BaseError {
  constructor(message = 'An unexpected error occurred', cause?: Error) {
    super(ErrorCodes.INTERNAL_ERROR, message, { 
      isOperational: false,
      cause,
    });
  }
}

/**
 * 502 Bad Gateway (Downstream Service Error)
 */
export class DependencyError extends BaseError {
  constructor(service: string, cause?: Error) {
    super(ErrorCodes.DEPENDENCY_FAILED, `${service} is currently unavailable`, {
      details: { service },
      cause,
    });
  }
}

/**
 * 503 Service Unavailable
 */
export class ServiceUnavailableError extends BaseError {
  constructor(message = 'Service temporarily unavailable') {
    super(ErrorCodes.SERVICE_UNAVAILABLE, message);
  }
}

/**
 * 504 Gateway Timeout
 */
export class TimeoutError extends BaseError {
  constructor(operation: string, timeoutMs: number) {
    super(ErrorCodes.TIMEOUT, `${operation} timed out after ${timeoutMs}ms`, {
      details: { operation, timeoutMs },
    });
  }
}

// Business-specific errors
export class InsufficientStockError extends BusinessError {
  constructor(productId: string, requested: number, available: number) {
    super(
      ErrorCodes.INSUFFICIENT_STOCK,
      `Insufficient stock for product. Requested: ${requested}, Available: ${available}`,
      { productId, requested, available }
    );
  }
}

export class OrderCannotCancelError extends BusinessError {
  constructor(orderId: string, status: string) {
    super(
      ErrorCodes.ORDER_CANNOT_CANCEL,
      `Order cannot be cancelled in '${status}' status`,
      { orderId, status }
    );
  }
}

export class CartEmptyError extends BusinessError {
  constructor() {
    super(ErrorCodes.CART_EMPTY, 'Cannot checkout with an empty cart');
  }
}

export class PaymentFailedError extends BusinessError {
  constructor(reason: string, transactionId?: string) {
    super(
      ErrorCodes.PAYMENT_FAILED,
      `Payment failed: ${reason}`,
      { reason, transactionId }
    );
  }
}

export class DeliveryUnavailableError extends BusinessError {
  constructor(pincode: string) {
    super(
      ErrorCodes.DELIVERY_UNAVAILABLE,
      `Delivery is not available for pincode ${pincode}`,
      { pincode }
    );
  }
}

export class MinimumOrderNotMetError extends BusinessError {
  constructor(minimumAmount: number, currentAmount: number) {
    super(
      ErrorCodes.MINIMUM_ORDER_NOT_MET,
      `Minimum order amount is ₹${minimumAmount}. Current: ₹${currentAmount}`,
      { minimumAmount, currentAmount }
    );
  }
}

export class CouponError extends BusinessError {
  constructor(
    code: typeof ErrorCodes.COUPON_INVALID | typeof ErrorCodes.COUPON_EXPIRED,
    couponCode: string
  ) {
    const message = code === ErrorCodes.COUPON_EXPIRED
      ? `Coupon '${couponCode}' has expired`
      : `Coupon '${couponCode}' is invalid`;
    super(code, message, { couponCode });
  }
}
