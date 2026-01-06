/**
 * Circuit Breaker Pattern Implementation
 * Prevents cascading failures by failing fast when downstream services are unhealthy
 */

import {
  CircuitBreakerPolicy,
  ConsecutiveBreaker,
  ExponentialBackoff,
  retry,
  circuitBreaker,
  handleAll,
  wrap,
  IPolicy,
} from 'cockatiel';
import { logger } from '../utils/logger';

export interface CircuitBreakerConfig {
  /** Name for logging and metrics */
  name: string;
  /** Number of consecutive failures before opening circuit */
  failureThreshold?: number;
  /** Time to wait before attempting recovery (ms) */
  resetTimeout?: number;
  /** Maximum retries before giving up */
  maxRetries?: number;
  /** Initial retry delay (ms) */
  initialRetryDelay?: number;
  /** Maximum retry delay (ms) */
  maxRetryDelay?: number;
}

const DEFAULT_CONFIG: Required<Omit<CircuitBreakerConfig, 'name'>> = {
  failureThreshold: 5,
  resetTimeout: 30000,
  maxRetries: 3,
  initialRetryDelay: 100,
  maxRetryDelay: 5000,
};

/**
 * Creates a circuit breaker with retry policy
 */
export function createCircuitBreaker(config: CircuitBreakerConfig): IPolicy {
  const opts = { ...DEFAULT_CONFIG, ...config };
  const log = logger.child({ circuitBreaker: config.name });

  // Retry policy with exponential backoff + jitter
  const retryPolicy = retry(handleAll, {
    maxAttempts: opts.maxRetries,
    backoff: new ExponentialBackoff({
      initialDelay: opts.initialRetryDelay,
      maxDelay: opts.maxRetryDelay,
    }),
  });

  retryPolicy.onRetry((event) => {
    log.warn(
      { attempt: event.attempt, delay: event.delay },
      `Retrying operation after failure`
    );
  });

  retryPolicy.onGiveUp((event) => {
    log.error(
      { error: event.reason },
      `Giving up after ${opts.maxRetries} retries`
    );
  });

  // Circuit breaker policy
  const breakerPolicy = circuitBreaker(handleAll, {
    halfOpenAfter: opts.resetTimeout,
    breaker: new ConsecutiveBreaker(opts.failureThreshold),
  });

  breakerPolicy.onBreak((event) => {
    log.error(
      { error: event.reason },
      `Circuit breaker OPEN - ${config.name} is unhealthy`
    );
    // Emit metric for monitoring
    emitCircuitBreakerMetric(config.name, 'open');
  });

  breakerPolicy.onReset(() => {
    log.info(`Circuit breaker CLOSED - ${config.name} recovered`);
    emitCircuitBreakerMetric(config.name, 'closed');
  });

  breakerPolicy.onHalfOpen(() => {
    log.info(`Circuit breaker HALF-OPEN - testing ${config.name}`);
    emitCircuitBreakerMetric(config.name, 'half-open');
  });

  // Combine policies: retry first, then circuit breaker
  return wrap(retryPolicy, breakerPolicy);
}

/**
 * Circuit breaker registry for managing multiple breakers
 */
class CircuitBreakerRegistry {
  private breakers: Map<string, IPolicy> = new Map();

  get(name: string, config?: Omit<CircuitBreakerConfig, 'name'>): IPolicy {
    if (!this.breakers.has(name)) {
      this.breakers.set(name, createCircuitBreaker({ name, ...config }));
    }
    return this.breakers.get(name)!;
  }

  getState(name: string): 'open' | 'closed' | 'half-open' | 'unknown' {
    const breaker = this.breakers.get(name);
    if (!breaker) return 'unknown';
    // State inspection would require additional tracking
    return 'unknown';
  }
}

export const circuitBreakerRegistry = new CircuitBreakerRegistry();

/**
 * Decorator for wrapping async functions with circuit breaker
 */
export function withCircuitBreaker(name: string) {
  return function (
    _target: unknown,
    _propertyKey: string,
    descriptor: PropertyDescriptor
  ) {
    const originalMethod = descriptor.value;
    const breaker = circuitBreakerRegistry.get(name);

    descriptor.value = async function (...args: unknown[]) {
      return breaker.execute(() => originalMethod.apply(this, args));
    };

    return descriptor;
  };
}

/**
 * Emit circuit breaker metrics (integrate with Prometheus)
 */
function emitCircuitBreakerMetric(
  name: string,
  state: 'open' | 'closed' | 'half-open'
) {
  // This would integrate with your metrics system
  // For now, we just log it
  logger.info({ metric: 'circuit_breaker_state', name, state });
}

/**
 * Execute function with circuit breaker protection
 */
export async function executeWithCircuitBreaker<T>(
  name: string,
  fn: () => Promise<T>,
  config?: Omit<CircuitBreakerConfig, 'name'>
): Promise<T> {
  const breaker = circuitBreakerRegistry.get(name, config);
  return breaker.execute(fn);
}
