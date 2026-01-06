/**
 * Retry Logic with Exponential Backoff and Jitter
 * Handles transient failures gracefully
 */

import { logger } from '../utils/logger';

export interface RetryConfig {
  /** Maximum number of retry attempts */
  maxAttempts?: number;
  /** Initial delay in milliseconds */
  initialDelay?: number;
  /** Maximum delay in milliseconds */
  maxDelay?: number;
  /** Multiplier for exponential backoff */
  multiplier?: number;
  /** Whether to add jitter to delays */
  jitter?: boolean;
  /** Predicate to determine if error is retryable */
  isRetryable?: (error: Error) => boolean;
  /** Callback before each retry */
  onRetry?: (error: Error, attempt: number, delay: number) => void;
}

const DEFAULT_RETRY_CONFIG: Required<Omit<RetryConfig, 'onRetry'>> = {
  maxAttempts: 3,
  initialDelay: 100,
  maxDelay: 10000,
  multiplier: 2,
  jitter: true,
  isRetryable: () => true,
};

/**
 * Calculate delay with exponential backoff and optional jitter
 */
function calculateDelay(
  attempt: number,
  config: Required<Omit<RetryConfig, 'onRetry'>>
): number {
  const exponentialDelay = Math.min(
    config.initialDelay * Math.pow(config.multiplier, attempt - 1),
    config.maxDelay
  );

  if (config.jitter) {
    // Add random jitter: 50-100% of calculated delay
    const jitterFactor = 0.5 + Math.random() * 0.5;
    return Math.floor(exponentialDelay * jitterFactor);
  }

  return exponentialDelay;
}

/**
 * Sleep for specified milliseconds
 */
function sleep(ms: number): Promise<void> {
  return new Promise((resolve) => setTimeout(resolve, ms));
}

/**
 * Execute function with retry logic
 */
export async function withRetry<T>(
  fn: () => Promise<T>,
  config: RetryConfig = {}
): Promise<T> {
  const opts = { ...DEFAULT_RETRY_CONFIG, ...config };
  const log = logger.child({ component: 'retry' });

  let lastError: Error | undefined;

  for (let attempt = 1; attempt <= opts.maxAttempts; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error as Error;

      // Check if we should retry
      if (attempt >= opts.maxAttempts) {
        log.error(
          { error: lastError, attempt },
          `All ${opts.maxAttempts} attempts failed`
        );
        throw lastError;
      }

      if (!opts.isRetryable(lastError)) {
        log.warn({ error: lastError }, 'Error is not retryable');
        throw lastError;
      }

      const delay = calculateDelay(attempt, opts);

      log.warn(
        { error: lastError.message, attempt, delay, maxAttempts: opts.maxAttempts },
        `Attempt ${attempt} failed, retrying in ${delay}ms`
      );

      if (config.onRetry) {
        config.onRetry(lastError, attempt, delay);
      }

      await sleep(delay);
    }
  }

  throw lastError;
}

/**
 * Common retryable error predicates
 */
export const RetryPredicates = {
  /**
   * Retry on network errors
   */
  isNetworkError: (error: Error): boolean => {
    const networkErrors = [
      'ECONNRESET',
      'ECONNREFUSED',
      'ETIMEDOUT',
      'ENOTFOUND',
      'EAI_AGAIN',
      'EPIPE',
      'EHOSTUNREACH',
    ];
    return networkErrors.some((code) => error.message.includes(code));
  },

  /**
   * Retry on HTTP 5xx errors
   */
  isServerError: (error: Error & { statusCode?: number }): boolean => {
    return error.statusCode !== undefined && error.statusCode >= 500;
  },

  /**
   * Retry on 429 Too Many Requests
   */
  isRateLimited: (error: Error & { statusCode?: number }): boolean => {
    return error.statusCode === 429;
  },

  /**
   * Retry on transient errors (network + server)
   */
  isTransient: (error: Error & { statusCode?: number }): boolean => {
    return (
      RetryPredicates.isNetworkError(error) ||
      RetryPredicates.isServerError(error) ||
      RetryPredicates.isRateLimited(error)
    );
  },

  /**
   * Never retry (for idempotency testing)
   */
  never: (): boolean => false,

  /**
   * Always retry
   */
  always: (): boolean => true,
};

/**
 * Retry decorator for class methods
 */
export function Retry(config?: RetryConfig) {
  return function (
    _target: unknown,
    _propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;

    descriptor.value = async function (...args: unknown[]) {
      return withRetry(() => originalMethod.apply(this, args), config);
    };

    return descriptor;
  };
}

/**
 * Create a retryable version of a function
 */
export function makeRetryable<T extends (...args: unknown[]) => Promise<unknown>>(
  fn: T,
  config?: RetryConfig
): T {
  return (async (...args: Parameters<T>) => {
    return withRetry(() => fn(...args), config);
  }) as T;
}
