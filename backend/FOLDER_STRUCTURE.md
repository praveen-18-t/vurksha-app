# Backend Folder Structure

```
backend/
├── ARCHITECTURE.md                    # System architecture documentation
├── docker-compose.yml                 # Local development environment
├── docker-compose.prod.yml            # Production-like local environment
├── Makefile                           # Development commands
├── .env.example                       # Environment variables template
├── .gitignore                         # Git ignore rules
│
├── api-gateway/                       # Kong API Gateway configuration
│   ├── kong.yml                       # Gateway declarative config
│   ├── plugins/                       # Custom plugins
│   └── Dockerfile                     # Gateway container
│
├── services/                          # Microservices
│   ├── shared/                        # Shared libraries
│   │   ├── package.json
│   │   └── src/
│   │       ├── types/                 # Shared TypeScript types
│   │       ├── middleware/            # Common middleware
│   │       ├── utils/                 # Utility functions
│   │       ├── errors/                # Error classes
│   │       └── resilience/            # Circuit breaker, retry logic
│   │
│   ├── user-service/                  # User management
│   │   ├── package.json
│   │   ├── Dockerfile
│   │   ├── tsconfig.json
│   │   ├── prisma/
│   │   │   └── schema.prisma
│   │   └── src/
│   │       ├── index.ts
│   │       ├── server.ts
│   │       ├── config/
│   │       ├── routes/
│   │       ├── controllers/
│   │       ├── services/
│   │       ├── repositories/
│   │       └── schemas/
│   │
│   ├── product-service/               # Product catalog
│   │   └── (same structure)
│   │
│   ├── order-service/                 # Order management
│   │   └── (same structure)
│   │
│   ├── cart-service/                  # Shopping cart
│   │   └── (same structure)
│   │
│   ├── payment-service/               # Payment processing
│   │   └── (same structure)
│   │
│   ├── notification-service/          # Notifications
│   │   └── (same structure)
│   │
│   ├── delivery-service/              # Delivery tracking
│   │   └── (same structure)
│   │
│   └── search-service/                # Search & recommendations
│       └── (same structure)
│
├── infrastructure/                    # Infrastructure as Code
│   ├── kubernetes/                    # K8s manifests
│   │   ├── base/                      # Base configurations
│   │   │   ├── namespace.yaml
│   │   │   ├── configmap.yaml
│   │   │   └── secrets.yaml
│   │   ├── services/                  # Service deployments
│   │   │   ├── user-service/
│   │   │   ├── product-service/
│   │   │   └── ...
│   │   ├── databases/                 # Database StatefulSets
│   │   ├── monitoring/                # Prometheus, Grafana
│   │   └── ingress/                   # Ingress controllers
│   │
│   ├── terraform/                     # Cloud infrastructure
│   │   ├── modules/
│   │   │   ├── eks/
│   │   │   ├── rds/
│   │   │   ├── elasticache/
│   │   │   └── vpc/
│   │   ├── environments/
│   │   │   ├── dev/
│   │   │   ├── staging/
│   │   │   └── production/
│   │   └── main.tf
│   │
│   └── helm/                          # Helm charts
│       └── vurksha/
│           ├── Chart.yaml
│           ├── values.yaml
│           └── templates/
│
├── scripts/                           # Utility scripts
│   ├── setup-local.sh
│   ├── run-migrations.sh
│   ├── seed-data.sh
│   └── health-check.sh
│
└── tests/                             # Integration & E2E tests
    ├── integration/
    ├── e2e/
    └── load/
        └── k6/
```

## Service Responsibilities

### User Service
- Phone authentication (OTP)
- User profile management
- Delivery address CRUD
- Session management
- JWT token issuance

### Product Service
- Product catalog management
- Category management
- Inventory tracking
- Product search (delegates to Search Service)
- Reviews and ratings

### Order Service
- Order creation and management
- Order lifecycle (placed → confirmed → shipped → delivered)
- Order history
- Refunds and cancellations

### Cart Service
- Shopping cart operations (add, remove, update)
- Cart persistence (Redis-backed)
- Price calculation
- Stock validation

### Payment Service
- Payment gateway integration
- Transaction management
- Refund processing
- Payment status webhooks

### Notification Service
- Push notifications (FCM)
- SMS notifications
- Email notifications
- Notification preferences

### Delivery Service
- Delivery partner assignment
- Real-time tracking
- Delivery status updates
- Route optimization

### Search Service
- Full-text product search
- Autocomplete suggestions
- Category filtering
- Personalized recommendations
