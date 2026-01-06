# VPC Module - Multi-AZ with Public/Private Subnets

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.4.0"

  name = "${local.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs             = local.azs
  private_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i)]
  public_subnets  = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i + 4)]
  database_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i + 8)]
  elasticache_subnets = [for i, az in local.azs : cidrsubnet(var.vpc_cidr, 4, i + 12)]

  # NAT Gateway for private subnet internet access
  enable_nat_gateway     = true
  single_nat_gateway     = false # One NAT per AZ for HA
  one_nat_gateway_per_az = true

  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true

  # Database subnet group
  create_database_subnet_group       = true
  create_database_subnet_route_table = true

  # ElastiCache subnet group
  create_elasticache_subnet_group = true

  # Tags for EKS
  public_subnet_tags = {
    "kubernetes.io/role/elb"                      = 1
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb"             = 1
    "kubernetes.io/cluster/${local.cluster_name}" = "owned"
  }

  tags = local.tags
}

# VPC Endpoints for AWS services (cost optimization + security)
module "vpc_endpoints" {
  source  = "terraform-aws-modules/vpc/aws//modules/vpc-endpoints"
  version = "5.4.0"

  vpc_id = module.vpc.vpc_id

  endpoints = {
    s3 = {
      service         = "s3"
      service_type    = "Gateway"
      route_table_ids = module.vpc.private_route_table_ids
      tags            = { Name = "${local.cluster_name}-s3-endpoint" }
    }
    ecr_api = {
      service             = "ecr.api"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
      tags                = { Name = "${local.cluster_name}-ecr-api-endpoint" }
    }
    ecr_dkr = {
      service             = "ecr.dkr"
      private_dns_enabled = true
      subnet_ids          = module.vpc.private_subnets
      security_group_ids  = [aws_security_group.vpc_endpoints.id]
      tags                = { Name = "${local.cluster_name}-ecr-dkr-endpoint" }
    }
  }

  tags = local.tags
}

# Security group for VPC endpoints
resource "aws_security_group" "vpc_endpoints" {
  name_prefix = "${local.cluster_name}-vpc-endpoints-"
  description = "Security group for VPC endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  tags = merge(local.tags, {
    Name = "${local.cluster_name}-vpc-endpoints-sg"
  })

  lifecycle {
    create_before_destroy = true
  }
}
