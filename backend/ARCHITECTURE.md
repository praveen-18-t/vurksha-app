# Vurksha Farm Delivery - Production Backend Architecture

## Executive Summary

This document describes the production-grade, highly available, fault-tolerant backend architecture for the Vurksha Farm Delivery mobile application. The system is designed with the philosophy that **everything will fail**, and recovery must be so fast and seamless that end users never notice.

---

## 1. System Architecture Overview

```
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              FLUTTER MOBILE APP                                      │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                           CLOUDFLARE / AWS CLOUDFRONT                                │
│                          (Global CDN + DDoS Protection)                              │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                              AWS APPLICATION LOAD BALANCER                           │
│                          (Health Checks + SSL Termination)                           │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
┌─────────────────────────────────────────────────────────────────────────────────────┐
│                                  API GATEWAY                                         │
│                     (Kong / AWS API Gateway / Custom)                                │
│   ┌──────────────┬──────────────┬──────────────┬──────────────┬──────────────┐      │
│   │    Auth      │ Rate Limit   │   Caching    │  Validation  │   Routing    │      │
│   └──────────────┴──────────────┴──────────────┴──────────────┴──────────────┘      │
└─────────────────────────────────────────────────────────────────────────────────────┘
                                        │
                    ┌───────────────────┼───────────────────┐
                    ▼                   ▼                   ▼
    ┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────────────┐
    │   USER SERVICE        │ │   PRODUCT SERVICE     │ │   ORDER SERVICE       │
    │   (Kubernetes Pod)    │ │   (Kubernetes Pod)    │ │   (Kubernetes Pod)    │
    │   [3+ replicas]       │ │   [3+ replicas]       │ │   [3+ replicas]       │
    └───────────────────────┘ └───────────────────────┘ └───────────────────────┘
                    │                   │                   │
                    ▼                   ▼                   ▼
    ┌───────────────────────┐ ┌───────────────────────┐ ┌───────────────────────┐
    │   PostgreSQL          │ │   PostgreSQL          │ │   PostgreSQL          │
    │   (Primary + Replica) │ │   (Primary + Replica) │ │   (Primary + Replica) │
    └───────────────────────┘ └───────────────────────┘ └───────────────────────┘
                    │                   │                   │
                    └───────────────────┼───────────────────┘
                                        ▼
            ┌─────────────────────────────────────────────────────────────┐
            │                    SHARED INFRASTRUCTURE                     │
            │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
            │  │   Redis     │  │  RabbitMQ   │  │  Elasticsearch      │  │
            │  │   Cluster   │  │   Cluster   │  │     Cluster         │  │
            │  └─────────────┘  └─────────────┘  └─────────────────────┘  │
            └─────────────────────────────────────────────────────────────┘
                                        │
                                        ▼
            ┌─────────────────────────────────────────────────────────────┐
            │                     OBSERVABILITY STACK                      │
            │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
            │  │  Prometheus │  │   Grafana   │  │  Jaeger/Zipkin      │  │
            │  │   + Thanos  │  │             │  │  (Tracing)          │  │
            │  └─────────────┘  └─────────────┘  └─────────────────────┘  │
            └─────────────────────────────────────────────────────────────┘
```

---

## 2. Microservices Architecture

### Service Decomposition by Business Capability

| Service | Responsibility | Database | Cache TTL |
|---------|---------------|----------|-----------|
| **User Service** | Authentication, profiles, addresses | PostgreSQL | 5 min |
| **Product Service** | Catalog, categories, inventory | PostgreSQL | 1 min |
| **Order Service** | Orders, order lifecycle | PostgreSQL | None |
| **Cart Service** | Shopping cart management | Redis | Session |
| **Payment Service** | Payment processing, transactions | PostgreSQL | None |
| **Notification Service** | Push, SMS, Email notifications | PostgreSQL | None |
| **Delivery Service** | Delivery tracking, assignments | PostgreSQL | 30 sec |
| **Search Service** | Full-text search, recommendations | Elasticsearch | 5 min |
| **Admin Service** | Admin operations, reports | Read replicas | None |
| **File Service** | Image uploads, CDN management | S3 | CDN |

### Service Communication Patterns

```
┌─────────────────────────────────────────────────────────────────┐
│                    SYNCHRONOUS (REST/gRPC)                       │
│  ┌─────────────┐         ┌─────────────┐         ┌───────────┐  │
│  │   Client    │ ─────▶  │   Gateway   │ ─────▶  │  Service  │  │
│  └─────────────┘         └─────────────┘         └───────────┘  │
│                                                                  │
│  Use for: Read operations, user-facing requests, < 200ms SLA    │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                 ASYNCHRONOUS (Event-Driven)                      │
│  ┌─────────────┐         ┌─────────────┐         ┌───────────┐  │
│  │  Producer   │ ─────▶  │  RabbitMQ   │ ─────▶  │  Consumer │  │
│  └─────────────┘         └─────────────┘         └───────────┘  │
│                                                                  │
│  Use for: Order processing, notifications, inventory updates    │
└─────────────────────────────────────────────────────────────────┘
```

---

## 3. Failure Scenarios & Recovery Strategies

### Scenario 1: Database Primary Failure
```
Problem: PostgreSQL primary becomes unavailable
Detection: Connection failures, health check fails
Recovery:
  1. PgBouncer detects failure (< 5 seconds)
  2. Patroni promotes replica to primary
  3. Applications reconnect to new primary
  4. Failed node recovered and rejoins as replica
User Impact: 0-5 seconds of write failures, reads continue
```

### Scenario 2: Service Pod Crash
```
Problem: Product Service pod crashes
Detection: Liveness probe fails
Recovery:
  1. Kubernetes terminates unhealthy pod
  2. Traffic routed to remaining healthy pods
  3. New pod scheduled and started
  4. Readiness probe passes, traffic restored
User Impact: Zero - other pods handle requests
```

### Scenario 3: Downstream Service Unavailable
```
Problem: Notification Service is down
Detection: Circuit breaker opens after 5 failures
Recovery:
  1. Circuit breaker prevents cascading failure
  2. Order Service continues processing
  3. Notifications queued in RabbitMQ
  4. When service recovers, queue is processed
User Impact: Delayed notifications only
```

### Scenario 4: Redis Cache Failure
```
Problem: Redis cluster unavailable
Detection: Connection timeout
Recovery:
  1. Cache-aside pattern falls back to database
  2. Service continues with degraded performance
  3. Redis cluster auto-heals
  4. Cache rebuilds lazily on requests
User Impact: Slightly higher latency
```

### Scenario 5: Message Queue Failure
```
Problem: RabbitMQ cluster unavailable
Detection: Connection refused
Recovery:
  1. Publishers use local buffer + retry
  2. Critical operations use sync fallback
  3. RabbitMQ cluster recovers
  4. Buffered messages published
User Impact: Delayed async operations
```

---

## 4. Technology Stack

### Core Services (Node.js/TypeScript)
| Component | Technology | Justification |
|-----------|------------|---------------|
| Runtime | Node.js 20 LTS | Event-driven, high concurrency |
| Language | TypeScript 5.x | Type safety, maintainability |
| Framework | Fastify | 2x faster than Express, schema validation |
| ORM | Prisma | Type-safe, migrations, connection pooling |
| Validation | Zod | Runtime type validation |

### Databases
| Component | Technology | Justification |
|-----------|------------|---------------|
| Primary DB | PostgreSQL 16 | ACID, JSON support, mature |
| Connection Pool | PgBouncer | Connection management |
| HA Management | Patroni | Automatic failover |
| Cache | Redis Cluster | Sub-ms latency, pub/sub |
| Search | Elasticsearch | Full-text, faceted search |

### Infrastructure
| Component | Technology | Justification |
|-----------|------------|---------------|
| Orchestration | Kubernetes (EKS) | Auto-scaling, self-healing |
| Service Mesh | Istio | mTLS, traffic management |
| API Gateway | Kong | Plugin ecosystem, performance |
| Message Queue | RabbitMQ | Reliable, clustering |
| CDN | CloudFront | Global edge caching |

### Observability
| Component | Technology | Justification |
|-----------|------------|---------------|
| Metrics | Prometheus + Thanos | Long-term storage, HA |
| Logs | Loki + Promtail | Native Grafana integration |
| Tracing | Jaeger | Distributed tracing |
| Dashboards | Grafana | Unified observability |
| Alerting | AlertManager + PagerDuty | On-call escalation |

---

## 5. API Design Principles

### Versioning Strategy
```
/api/v1/products         ← Current stable
/api/v2/products         ← New version (parallel)
/api/v1/products         ← Deprecated (6 months notice)
```

### Response Format (Mobile-Optimized)
```json
{
  "success": true,
  "data": { ... },
  "meta": {
    "requestId": "req_abc123",
    "timestamp": "2026-01-03T10:00:00Z",
    "version": "1.0.0"
  },
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "hasMore": true
  }
}
```

### Error Response Format
```json
{
  "success": false,
  "error": {
    "code": "PRODUCT_NOT_FOUND",
    "message": "Product with ID xyz not found",
    "retryable": false,
    "retryAfter": null
  },
  "meta": {
    "requestId": "req_abc123",
    "timestamp": "2026-01-03T10:00:00Z"
  }
}
```

### Idempotency Keys
```
POST /api/v1/orders
Headers:
  X-Idempotency-Key: order_123_user_456_1704279600

Server stores: { key, response, expires_at }
Duplicate request returns cached response
```

---

## 6. Database Strategy

### Per-Service Database Isolation
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│  user_service   │    │ product_service │    │  order_service  │
│    _db          │    │      _db        │    │      _db        │
├─────────────────┤    ├─────────────────┤    ├─────────────────┤
│ users           │    │ products        │    │ orders          │
│ addresses       │    │ categories      │    │ order_items     │
│ auth_tokens     │    │ inventory       │    │ order_events    │
│ sessions        │    │ reviews         │    │ payments        │
└─────────────────┘    └─────────────────┘    └─────────────────┘
```

### Zero-Downtime Migration Strategy
```
1. Add new column (nullable or with default)
2. Deploy code that writes to both columns
3. Backfill existing data
4. Deploy code that reads from new column
5. Remove old column (after deprecation period)
```

---

## 7. Caching Strategy

### Cache Layers
```
┌──────────────────────────────────────────────────────────────┐
│ Layer 1: CDN (CloudFront)                                    │
│ - Static assets, public API responses                        │
│ - TTL: 1 hour for assets, 1 min for API                     │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ Layer 2: API Gateway (Kong)                                  │
│ - Authenticated user responses                               │
│ - TTL: 30 seconds                                           │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ Layer 3: Redis Cluster                                       │
│ - Session data, computed values                              │
│ - TTL: Varies by data type                                  │
└──────────────────────────────────────────────────────────────┘
                            │
                            ▼
┌──────────────────────────────────────────────────────────────┐
│ Layer 4: Application Cache (in-memory)                       │
│ - Configuration, feature flags                               │
│ - TTL: 5 minutes                                            │
└──────────────────────────────────────────────────────────────┘
```

### Cache-Aside Implementation
```typescript
async function getProduct(id: string): Promise<Product> {
  // 1. Check cache first
  const cached = await redis.get(`product:${id}`);
  if (cached) {
    return JSON.parse(cached);
  }
  
  // 2. Cache miss - fetch from database
  const product = await db.product.findUnique({ where: { id } });
  
  // 3. Store in cache with TTL
  if (product) {
    await redis.setex(`product:${id}`, 60, JSON.stringify(product));
  }
  
  return product;
}
```

---

## 8. Security Model

### Defense in Depth
```
┌─────────────────────────────────────────────────────────────┐
│ Layer 1: Network Security                                    │
│ - VPC isolation, security groups, NACLs                     │
│ - Private subnets for databases                             │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│ Layer 2: Edge Security                                       │
│ - Cloudflare DDoS protection, WAF                           │
│ - Rate limiting at CDN level                                │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│ Layer 3: API Gateway Security                                │
│ - JWT validation, API key verification                       │
│ - Request validation, rate limiting per user                │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│ Layer 4: Service Security                                    │
│ - mTLS between services (Istio)                             │
│ - Input validation (Zod schemas)                            │
│ - SQL injection prevention (Prisma)                         │
└─────────────────────────────────────────────────────────────┘
                            │
┌─────────────────────────────────────────────────────────────┐
│ Layer 5: Data Security                                       │
│ - Encryption at rest (AWS KMS)                              │
│ - Encryption in transit (TLS 1.3)                           │
│ - Secrets management (AWS Secrets Manager)                  │
└─────────────────────────────────────────────────────────────┘
```

### Authentication Flow
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Mobile    │────▶│   Gateway   │────▶│   User      │
│   App       │     │             │     │   Service   │
└─────────────┘     └─────────────┘     └─────────────┘
      │                   │                    │
      │ 1. Phone + OTP    │                    │
      │──────────────────▶│                    │
      │                   │ 2. Validate OTP    │
      │                   │───────────────────▶│
      │                   │ 3. Generate Tokens │
      │                   │◀───────────────────│
      │ 4. Access + Refresh Token              │
      │◀──────────────────│                    │
```

---

## 9. Deployment Strategy

### Blue-Green Deployment
```
┌────────────────────────────────────────────────────────────┐
│                    Production Traffic                       │
│                          100%                               │
│                           │                                 │
│                           ▼                                 │
│    ┌─────────────────────────────────────────┐             │
│    │           Load Balancer                  │             │
│    └─────────────────────────────────────────┘             │
│                     │         │                             │
│                     ▼         ▼                             │
│    ┌─────────────────┐   ┌─────────────────┐               │
│    │  BLUE (v1.2.0)  │   │ GREEN (v1.3.0)  │               │
│    │   [Active]      │   │   [Standby]     │               │
│    │   3 pods        │   │   3 pods        │               │
│    └─────────────────┘   └─────────────────┘               │
│                                                             │
│    After validation, swap: GREEN becomes Active             │
└────────────────────────────────────────────────────────────┘
```

### Canary Deployment for Critical Changes
```
Phase 1: 5% traffic to new version (1 hour)
Phase 2: 25% traffic (2 hours)  
Phase 3: 50% traffic (4 hours)
Phase 4: 100% traffic

Automatic rollback if:
- Error rate > 1%
- P99 latency > 500ms
- Health check failures
```

---

## 10. Observability Stack

### The Four Pillars
```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│   METRICS   │    LOGS     │   TRACES    │   EVENTS    │
├─────────────┼─────────────┼─────────────┼─────────────┤
│ Prometheus  │    Loki     │   Jaeger    │  RabbitMQ   │
│   Thanos    │  Promtail   │   Zipkin    │   Events    │
└─────────────┴─────────────┴─────────────┴─────────────┘
              │             │             │
              └─────────────┼─────────────┘
                            ▼
                   ┌─────────────────┐
                   │     GRAFANA     │
                   │   Unified UI    │
                   └─────────────────┘
                            │
                            ▼
                   ┌─────────────────┐
                   │  ALERTMANAGER   │
                   │   + PagerDuty   │
                   └─────────────────┘
```

### Key Metrics (SLIs)
| Metric | Target | Alert Threshold |
|--------|--------|-----------------|
| API Availability | 99.9% | < 99.5% |
| P50 Latency | < 100ms | > 150ms |
| P99 Latency | < 500ms | > 800ms |
| Error Rate | < 0.1% | > 0.5% |
| Database Connection Pool | < 80% | > 90% |

---

## 11. Disaster Recovery

### Backup Strategy
| Data Type | Frequency | Retention | Location |
|-----------|-----------|-----------|----------|
| PostgreSQL | Continuous (WAL) | 30 days | S3 Cross-Region |
| Redis Snapshots | Every 6 hours | 7 days | S3 |
| Elasticsearch | Daily | 14 days | S3 |
| Secrets | On change | Versioned | Secrets Manager |

### Multi-Region Architecture
```
┌─────────────────────────────────────────────────────────────┐
│                    Primary Region (us-east-1)                │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   EKS       │  │  RDS Multi  │  │  ElastiCache│         │
│  │   Cluster   │  │     AZ      │  │   Cluster   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
│                          │                                   │
│                          │ Async Replication                 │
│                          ▼                                   │
└─────────────────────────────────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                  DR Region (us-west-2)                       │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐         │
│  │   EKS       │  │  RDS Read   │  │  ElastiCache│         │
│  │   Cluster   │  │   Replica   │  │   Cluster   │         │
│  └─────────────┘  └─────────────┘  └─────────────┘         │
└─────────────────────────────────────────────────────────────┘
```

### Recovery Time Objectives
| Scenario | RTO | RPO |
|----------|-----|-----|
| Single Pod Failure | 0 seconds | 0 |
| AZ Failure | < 30 seconds | 0 |
| Region Failure | < 15 minutes | < 1 minute |
| Data Corruption | < 1 hour | < 5 minutes |

---

## 12. Flutter Integration Guidelines

### Retry-Safe Endpoints
All mutating operations use idempotency keys:
```dart
final response = await api.post('/orders', {
  'items': cartItems,
}, headers: {
  'X-Idempotency-Key': '${userId}_${cartHash}_${timestamp}',
});
```

### Graceful Degradation
```dart
// Product images with fallback
Image.network(
  product.imageUrl,
  loadingBuilder: (context, child, progress) => Shimmer(),
  errorBuilder: (context, error, stack) => PlaceholderImage(),
)

// Offline-first with sync
final products = await localDb.getProducts();
if (await connectivity.hasConnection) {
  final fresh = await api.getProducts();
  await localDb.saveProducts(fresh);
}
```

### Error Handling
```dart
try {
  await api.placeOrder(order);
} on NetworkException catch (e) {
  if (e.isRetryable) {
    // Show retry button
    showRetryDialog(onRetry: () => placeOrder(order));
  } else {
    showErrorSnackbar(e.userMessage);
  }
}
```

---

## Next Steps

1. Review [services/](./services/) for microservice implementations
2. Review [infrastructure/](./infrastructure/) for Kubernetes configs
3. Review [docker-compose.yml](./docker-compose.yml) for local development
4. Run `make dev` to start local environment
