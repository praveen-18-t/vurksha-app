/**
 * Timeout Utilities
 * Prevent operations from hanging indefinitely
 */

import { logger } from '../utils/logger';

export class TimeoutError extends Error {
  constructor(
    message: string,
    public readonly operation: string,
    public readonly timeoutMs: number
  ) {
    super(message);
    this.name = 'TimeoutError';
  }
}

/**
 * Wrap a promise with a timeout
 */
export async function withTimeout<T>(
  promise: Promise<T>,
  timeoutMs: number,
  operation: string = 'operation'
): Promise<T> {
  let timeoutId: NodeJS.Timeout | undefined;

  const timeoutPromise = new Promise<never>((_, reject) => {
    timeoutId = setTimeout(() => {
      const error = new TimeoutError(
        `${operation} timed out after ${timeoutMs}ms`,
        operation,
        timeoutMs
      );
      logger.warn({ operation, timeoutMs }, error.message);
      reject(error);
    }, timeoutMs);
  });

  try {
    const result = await Promise.race([promise, timeoutPromise]);
    clearTimeout(timeoutId);
    return result;
  } catch (error) {
    clearTimeout(timeoutId);
    throw error;
  }
}

/**
 * Standard timeout values for different operation types
 */
export const Timeouts = {
  /** Fast operations (cache lookups, etc.) */
  FAST: 1000,
  /** Standard API calls */
  STANDARD: 5000,
  /** Database operations */
  DATABASE: 10000,
  /** External service calls */
  EXTERNAL: 15000,
  /** File uploads */
  UPLOAD: 60000,
  /** Long-running operations */
  LONG: 120000,
} as const;

/**
 * Timeout decorator for class methods
 */
export function Timeout(timeoutMs: number, operation?: string) {
  return function (
    _target: unknown,
    propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: unknown[]) {
      return withTimeout(
        originalMethod.apply(this, args),
        timeoutMs,
        operation || propertyKey
      );
    };

    return descriptor;
  };
}

/**
 * Create a timeout-wrapped version of a function
 */
export function withTimeoutWrapper<
  T extends (...args: unknown[]) => Promise<unknown>
>(fn: T, timeoutMs: number, operation?: string): T {
  return (async (...args: Parameters<T>) => {
    return withTimeout(fn(...args), timeoutMs, operation || fn.name);
  }) as T;
}

/**
 * Deadline-based timeout (absolute time limit)
 */
export async function withDeadline<T>(
  promise: Promise<T>,
  deadline: Date,
  operation: string = 'operation'
): Promise<T> {
  const remaining = deadline.getTime() - Date.now();
  
  if (remaining <= 0) {
    throw new TimeoutError(
      `${operation} deadline already passed`,
      operation,
      0
    );
  }
  
  return withTimeout(promise, remaining, operation);
}

/**
 * Abort controller-based timeout for HTTP requests
 */
export function createTimeoutController(
  timeoutMs: number
): { controller: AbortController; cleanup: () => void } {
  const controller = new AbortController();
  
  const timeoutId = setTimeout(() => {
    controller.abort();
  }, timeoutMs);
  
  return {
    controller,
    cleanup: () => clearTimeout(timeoutId),
  };
}
