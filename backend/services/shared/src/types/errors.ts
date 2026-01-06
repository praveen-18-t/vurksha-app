/**
 * Standard Error Codes
 * These codes are used by Flutter for proper error handling
 */

export const ErrorCodes = {
  // Authentication errors (1xxx)
  UNAUTHORIZED: 'AUTH_001',
  TOKEN_EXPIRED: 'AUTH_002',
  TOKEN_INVALID: 'AUTH_003',
  SESSION_EXPIRED: 'AUTH_004',
  OTP_INVALID: 'AUTH_005',
  OTP_EXPIRED: 'AUTH_006',
  PHONE_NOT_REGISTERED: 'AUTH_007',

  // Validation errors (2xxx)
  VALIDATION_ERROR: 'VAL_001',
  INVALID_INPUT: 'VAL_002',
  MISSING_REQUIRED_FIELD: 'VAL_003',
  INVALID_FORMAT: 'VAL_004',

  // Resource errors (3xxx)
  NOT_FOUND: 'RES_001',
  ALREADY_EXISTS: 'RES_002',
  CONFLICT: 'RES_003',
  GONE: 'RES_004',

  // Business logic errors (4xxx)
  INSUFFICIENT_STOCK: 'BIZ_001',
  ORDER_CANNOT_CANCEL: 'BIZ_002',
  CART_EMPTY: 'BIZ_003',
  PAYMENT_FAILED: 'BIZ_004',
  DELIVERY_UNAVAILABLE: 'BIZ_005',
  MINIMUM_ORDER_NOT_MET: 'BIZ_006',
  COUPON_INVALID: 'BIZ_007',
  COUPON_EXPIRED: 'BIZ_008',

  // Rate limiting (5xxx)
  RATE_LIMITED: 'RATE_001',
  TOO_MANY_REQUESTS: 'RATE_002',

  // System errors (9xxx)
  INTERNAL_ERROR: 'SYS_001',
  SERVICE_UNAVAILABLE: 'SYS_002',
  TIMEOUT: 'SYS_003',
  DEPENDENCY_FAILED: 'SYS_004',
  MAINTENANCE: 'SYS_005',
} as const;

export type ErrorCode = (typeof ErrorCodes)[keyof typeof ErrorCodes];

/**
 * Map of retryable error codes
 * Flutter uses this to determine if automatic retry should be attempted
 */
export const RetryableErrors: Set<ErrorCode> = new Set([
  ErrorCodes.SERVICE_UNAVAILABLE,
  ErrorCodes.TIMEOUT,
  ErrorCodes.DEPENDENCY_FAILED,
  ErrorCodes.RATE_LIMITED,
]);

/**
 * HTTP status code mapping
 */
export const ErrorCodeToHttpStatus: Record<ErrorCode, number> = {
  [ErrorCodes.UNAUTHORIZED]: 401,
  [ErrorCodes.TOKEN_EXPIRED]: 401,
  [ErrorCodes.TOKEN_INVALID]: 401,
  [ErrorCodes.SESSION_EXPIRED]: 401,
  [ErrorCodes.OTP_INVALID]: 400,
  [ErrorCodes.OTP_EXPIRED]: 400,
  [ErrorCodes.PHONE_NOT_REGISTERED]: 404,
  
  [ErrorCodes.VALIDATION_ERROR]: 400,
  [ErrorCodes.INVALID_INPUT]: 400,
  [ErrorCodes.MISSING_REQUIRED_FIELD]: 400,
  [ErrorCodes.INVALID_FORMAT]: 400,
  
  [ErrorCodes.NOT_FOUND]: 404,
  [ErrorCodes.ALREADY_EXISTS]: 409,
  [ErrorCodes.CONFLICT]: 409,
  [ErrorCodes.GONE]: 410,
  
  [ErrorCodes.INSUFFICIENT_STOCK]: 422,
  [ErrorCodes.ORDER_CANNOT_CANCEL]: 422,
  [ErrorCodes.CART_EMPTY]: 422,
  [ErrorCodes.PAYMENT_FAILED]: 422,
  [ErrorCodes.DELIVERY_UNAVAILABLE]: 422,
  [ErrorCodes.MINIMUM_ORDER_NOT_MET]: 422,
  [ErrorCodes.COUPON_INVALID]: 422,
  [ErrorCodes.COUPON_EXPIRED]: 422,
  
  [ErrorCodes.RATE_LIMITED]: 429,
  [ErrorCodes.TOO_MANY_REQUESTS]: 429,
  
  [ErrorCodes.INTERNAL_ERROR]: 500,
  [ErrorCodes.SERVICE_UNAVAILABLE]: 503,
  [ErrorCodes.TIMEOUT]: 504,
  [ErrorCodes.DEPENDENCY_FAILED]: 502,
  [ErrorCodes.MAINTENANCE]: 503,
};
