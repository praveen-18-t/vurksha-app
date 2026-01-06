# Vurksha Backend - Production-Grade Microservices

A highly available, fault-tolerant, self-healing backend system for the Vurksha Farm Delivery mobile application.

## 🏗️ Architecture Overview

This backend follows a **microservices architecture** with the following key principles:

- **No Single Point of Failure** - Every component is redundant
- **Horizontal Scalability** - Services scale independently based on load
- **Circuit Breakers** - Graceful degradation when dependencies fail
- **Event-Driven Communication** - Loose coupling via RabbitMQ
- **Self-Healing** - Kubernetes auto-restart and health checks

### Services

| Service | Port | Description |
|---------|------|-------------|
| **user-service** | 3001 | Authentication, profiles, addresses |
| **product-service** | 3002 | Product catalog, categories, banners |
| **order-service** | 3003 | Order lifecycle, payment coordination |
| **cart-service** | 3004 | Redis-backed shopping cart |
| **notification-service** | 3005 | Push notifications (FCM), SMS, Email |

### Tech Stack

- **Runtime**: Node.js 20 LTS + TypeScript 5.x
- **Framework**: Fastify (2x faster than Express)
- **ORM**: Prisma with PostgreSQL
- **Cache**: Redis with cache-aside pattern
- **Message Queue**: RabbitMQ with dead-letter queues
- **API Gateway**: Kong
- **Container Orchestration**: Kubernetes (EKS)
- **Infrastructure**: Terraform on AWS

## 🚀 Quick Start

### Prerequisites

- Docker & Docker Compose
- Node.js 20+
- pnpm (recommended) or npm

### Local Development

```bash
# Start infrastructure (PostgreSQL, Redis, RabbitMQ)
docker-compose up -d postgres redis rabbitmq

# Install dependencies
cd services/user-service
pnpm install

# Run database migrations
pnpm prisma migrate dev

# Start development server
pnpm dev
```

### Full Stack (Docker Compose)

```bash
# Start everything
docker-compose up -d

# View logs
docker-compose logs -f

# Access services
# API Gateway: http://localhost:8000
# RabbitMQ UI: http://localhost:15672
# Grafana: http://localhost:3000
# Prometheus: http://localhost:9090
# Jaeger: http://localhost:16686
```

## 📁 Project Structure

```
backend/
├── services/
│   ├── shared/              # Shared library (@vurksha/shared)
│   │   ├── src/
│   │   │   ├── types/       # API responses, errors, events
│   │   │   ├── resilience/  # Circuit breaker, retry, timeout
│   │   │   ├── middleware/  # Request ID, error handler, validation
│   │   │   └── utils/       # Logger, cache, idempotency
│   │   └── package.json
│   │
│   ├── user-service/        # User microservice
│   ├── product-service/     # Product microservice
│   ├── order-service/       # Order microservice
│   ├── cart-service/        # Cart microservice (Redis)
│   └── notification-service/# Notification microservice
│
├── infra/
│   ├── kong/               # API Gateway config
│   ├── prometheus/         # Metrics collection
│   └── grafana/            # Dashboards
│
├── k8s/
│   ├── base/              # Kubernetes base configs
│   ├── services/          # Service deployments
│   └── ingress/           # Ingress controllers
│
├── terraform/             # AWS infrastructure as code
│   ├── main.tf
│   ├── vpc.tf
│   ├── eks.tf
│   ├── rds.tf
│   └── elasticache.tf
│
├── docker-compose.yml     # Local development
├── ARCHITECTURE.md        # Detailed architecture docs
└── README.md
```

## 🔧 Configuration

### Environment Variables

Each service uses environment variables for configuration:

```bash
# Required
DATABASE_URL=postgresql://user:pass@host:5432/db
REDIS_URL=redis://host:6379
RABBITMQ_URL=amqp://user:pass@host:5672
JWT_SECRET=your-secret-key

# Optional
PORT=3001
LOG_LEVEL=info
```

### Secrets Management

In production, secrets are stored in AWS Secrets Manager and injected via Kubernetes secrets.

## 🛡️ Resilience Patterns

### Circuit Breaker

```typescript
import { executeWithCircuitBreaker } from '@vurksha/shared';

const result = await executeWithCircuitBreaker(
  'external-api',
  async () => fetch('https://api.example.com/data')
);
```

### Retry with Exponential Backoff

```typescript
import { withRetry, RetryPredicates } from '@vurksha/shared';

const result = await withRetry(
  () => riskyOperation(),
  { maxAttempts: 3, predicate: RetryPredicates.database }
);
```

### Idempotency

```bash
# Include idempotency key in request headers
curl -X POST /api/v1/orders \
  -H "X-Idempotency-Key: unique-request-id-123" \
  -d '{"items": [...]}'
```

## 📊 Observability

### Health Checks

Every service exposes:

- `GET /health/live` - Liveness probe (is the process alive?)
- `GET /health/ready` - Readiness probe (can it accept traffic?)
- `GET /health` - Full health with dependency status

### Metrics (Prometheus)

- Request latency histograms
- Error rates by endpoint
- Circuit breaker states
- Cache hit/miss ratios

### Tracing (Jaeger)

Distributed tracing via `X-Request-ID` header propagation.

### Logging (Loki)

Structured JSON logs with:
- Request ID
- User ID
- Latency
- Error stack traces

## 🚢 Deployment

### Blue-Green Deployment

```bash
# Deploy new version to green environment
kubectl apply -f k8s/services/ --namespace=vurksha-green

# Run smoke tests
./scripts/smoke-test.sh vurksha-green

# Switch traffic
kubectl patch service kong-proxy -p '{"spec":{"selector":{"version":"green"}}}'
```

### Terraform (AWS)

```bash
cd terraform

# Initialize
terraform init

# Plan
terraform plan -var="environment=production"

# Apply
terraform apply -var="environment=production"
```

## 🔐 Security

- **JWT Authentication** with refresh token rotation
- **Rate Limiting** at API Gateway level (100 req/sec per user)
- **Input Validation** with Zod schemas
- **SQL Injection Prevention** via Prisma parameterized queries
- **Encryption at Rest** for all data stores (KMS)
- **Encryption in Transit** (TLS 1.3)
- **Security Headers** (HSTS, CSP, X-Frame-Options)

## 📝 API Documentation

### Authentication

```bash
# Request OTP
POST /api/v1/auth/otp/send
{"phoneNumber": "+919876543210"}

# Verify OTP
POST /api/v1/auth/otp/verify
{"phoneNumber": "+919876543210", "otp": "123456"}

# Response: { accessToken, refreshToken }
```

### Orders

```bash
# Create order (idempotent)
POST /api/v1/orders
X-Idempotency-Key: uuid-here
Authorization: Bearer <token>

# Response includes order number: VRK-2026-000001
```

## 🧪 Testing

```bash
# Unit tests
pnpm test

# Integration tests
pnpm test:integration

# Load tests
k6 run tests/load/orders.js
```

## 📈 Performance Targets

| Metric | Target |
|--------|--------|
| API Latency (p99) | < 200ms |
| Availability | 99.9% |
| Throughput | 10,000 req/sec |
| Recovery Time | < 30 seconds |

## 🤝 Contributing

1. Create feature branch from `main`
2. Write tests for new functionality
3. Ensure all tests pass
4. Create pull request with description

## 📄 License

Proprietary - Vurksha Farms Pvt. Ltd.
