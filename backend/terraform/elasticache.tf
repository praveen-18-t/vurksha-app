# ElastiCache Redis - Clustered with Multi-AZ

# Security group for ElastiCache
resource "aws_security_group" "elasticache" {
  name_prefix = "${local.cluster_name}-elasticache-"
  description = "Security group for ElastiCache Redis"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "Redis from EKS"
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-elasticache-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# ElastiCache Parameter Group
resource "aws_elasticache_parameter_group" "redis" {
  name_prefix = "${local.cluster_name}-redis-"
  family      = "redis7"
  description = "Custom Redis parameter group"

  parameter {
    name  = "maxmemory-policy"
    value = "allkeys-lru"
  }

  parameter {
    name  = "notify-keyspace-events"
    value = "Ex"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

# ElastiCache Replication Group (Cluster Mode Disabled)
resource "aws_elasticache_replication_group" "redis" {
  replication_group_id       = "${local.cluster_name}-redis"
  description                = "Redis cluster for Vurksha"
  
  engine               = "redis"
  engine_version       = "7.0"
  node_type            = var.redis_node_type
  port                 = 6379
  parameter_group_name = aws_elasticache_parameter_group.redis.name

  # Multi-AZ with automatic failover
  automatic_failover_enabled = true
  multi_az_enabled          = true
  
  # Number of cache clusters (1 primary + replicas)
  num_cache_clusters = 3

  # Subnet and security
  subnet_group_name  = module.vpc.elasticache_subnet_group_name
  security_group_ids = [aws_security_group.elasticache.id]

  # Encryption
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true
  kms_key_id                = aws_kms_key.elasticache.arn
  
  # Auth
  auth_token = random_password.redis_auth.result

  # Maintenance
  maintenance_window       = "sun:04:00-sun:05:00"
  snapshot_window          = "03:00-04:00"
  snapshot_retention_limit = 7
  auto_minor_version_upgrade = true

  # Notifications
  notification_topic_arn = aws_sns_topic.alerts.arn

  tags = local.tags
}

# KMS key for ElastiCache encryption
resource "aws_kms_key" "elasticache" {
  description             = "KMS key for ElastiCache encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-elasticache-key"
  })
}

# Random password for Redis auth
resource "random_password" "redis_auth" {
  length  = 32
  special = false
}

# Store Redis auth token in Secrets Manager
resource "aws_secretsmanager_secret" "redis_auth" {
  name_prefix = "${local.cluster_name}-redis-auth-"
  description = "Redis AUTH token"

  tags = local.tags
}

resource "aws_secretsmanager_secret_version" "redis_auth" {
  secret_id = aws_secretsmanager_secret.redis_auth.id
  secret_string = jsonencode({
    auth_token = random_password.redis_auth.result
    endpoint   = aws_elasticache_replication_group.redis.primary_endpoint_address
    port       = 6379
  })
}

# SNS Topic for alerts
resource "aws_sns_topic" "alerts" {
  name_prefix = "${local.cluster_name}-alerts-"
  
  tags = local.tags
}

resource "aws_sns_topic_subscription" "alerts_email" {
  topic_arn = aws_sns_topic.alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}
