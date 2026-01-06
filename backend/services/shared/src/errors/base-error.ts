/**
 * Base Error Class
 * All application errors should extend this
 */

import { ErrorCode } from '../types/errors';

export class BaseError extends Error {
  public readonly code: ErrorCode;
  public readonly isOperational: boolean;
  public readonly details?: Record<string, unknown>;

  constructor(
    code: ErrorCode,
    message: string,
    options: {
      isOperational?: boolean;
      details?: Record<string, unknown>;
      cause?: Error;
    } = {}
  ) {
    super(message);
    this.name = this.constructor.name;
    this.code = code;
    this.isOperational = options.isOperational ?? true;
    this.details = options.details;
    
    // Capture stack trace
    Error.captureStackTrace(this, this.constructor);
    
    // Preserve cause if provided (for error chaining)
    if (options.cause) {
      this.cause = options.cause;
    }
  }

  /**
   * Convert to JSON for logging
   */
  toJSON(): Record<string, unknown> {
    return {
      name: this.name,
      code: this.code,
      message: this.message,
      isOperational: this.isOperational,
      details: this.details,
      stack: this.stack,
    };
  }
}
