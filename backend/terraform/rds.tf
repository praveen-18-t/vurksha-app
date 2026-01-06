# RDS PostgreSQL - Multi-AZ with Read Replicas

# Security group for RDS
resource "aws_security_group" "rds" {
  name_prefix = "${local.cluster_name}-rds-"
  description = "Security group for RDS PostgreSQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "PostgreSQL from EKS"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-rds-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}

# RDS Parameter Group
resource "aws_db_parameter_group" "postgres" {
  name_prefix = "${local.cluster_name}-postgres-"
  family      = "postgres16"
  description = "Custom parameter group for Vurksha"

  parameter {
    name  = "log_statement"
    value = "ddl"
  }

  parameter {
    name  = "log_min_duration_statement"
    value = "1000" # Log queries > 1 second
  }

  parameter {
    name  = "max_connections"
    value = "500"
  }

  parameter {
    name  = "shared_preload_libraries"
    value = "pg_stat_statements"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = local.tags
}

# RDS Primary Instance (Multi-AZ)
module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "6.3.0"

  identifier = "${local.cluster_name}-postgres"

  engine               = "postgres"
  engine_version       = "16.1"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = var.db_instance_class

  allocated_storage     = 100
  max_allocated_storage = 500
  storage_type          = "gp3"
  storage_encrypted     = true
  kms_key_id           = aws_kms_key.rds.arn

  db_name  = "vurksha"
  username = "vurksha_admin"
  port     = 5432

  # Multi-AZ for High Availability
  multi_az = true

  # Subnet group
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [aws_security_group.rds.id]

  # Maintenance & Backup
  maintenance_window          = "Sun:03:00-Sun:04:00"
  backup_window              = "02:00-03:00"
  backup_retention_period    = 30
  delete_automated_backups   = false
  copy_tags_to_snapshot      = true
  skip_final_snapshot        = false
  final_snapshot_identifier_prefix = "${local.cluster_name}-final"

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  performance_insights_kms_key_id      = aws_kms_key.rds.arn

  # Enhanced Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  # Parameter group
  parameter_group_name = aws_db_parameter_group.postgres.name

  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]

  # Auto minor version upgrade
  auto_minor_version_upgrade = true

  # Deletion protection
  deletion_protection = true

  tags = local.tags
}

# Read Replica for read scaling
resource "aws_db_instance" "read_replica" {
  count = var.environment == "production" ? 1 : 0

  identifier = "${local.cluster_name}-postgres-read"

  instance_class    = var.db_instance_class
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  replicate_source_db = module.rds.db_instance_identifier

  vpc_security_group_ids = [aws_security_group.rds.id]

  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 7

  # Monitoring
  monitoring_interval = 60
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn

  auto_minor_version_upgrade = true

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-postgres-read"
  })
}

# KMS key for RDS encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS encryption"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-rds-key"
  })
}

# IAM role for RDS enhanced monitoring
resource "aws_iam_role" "rds_monitoring" {
  name_prefix = "${local.cluster_name}-rds-monitoring-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "monitoring.rds.amazonaws.com"
      }
    }]
  })

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "rds_monitoring" {
  role       = aws_iam_role.rds_monitoring.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
