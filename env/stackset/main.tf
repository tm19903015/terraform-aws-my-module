# ============================================================
# Terraform Configuration: Environment Root
# ============================================================

# ------------------------------------------------------------
# 1. Terraform Settings & Backend
# ------------------------------------------------------------
terraform {
  required_version = ">= 1.5"

  # ブロックの枠組みだけを残し、中身を「空っぽ」にする
  backend "s3" {}
}

# ------------------------------------------------------------
# 2. Provider Settings
# ------------------------------------------------------------
provider "aws" {
  region = var.region
  assume_role {
    # アカウントIDを変数にして、外（tfvars）から注入できるようにする
    role_arn = "arn:aws:iam::${var.account_id}:role/OrganizationAccountAccessRole"
  }
}

# ------------------------------------------------------------
# 3. Resource Modules
# ------------------------------------------------------------

# --- Network: VPC, Subnets, RouteTables ---
module "network" {
  source = "../../modules/network"

  # サブネット数・CIDR設定
  public_subnet_count      = var.public_subnet_count
  private_subnet_count     = var.private_subnet_count
  rds_private_subnet_count = var.rds_private_subnet_count
  vpc_cidr                 = var.vpc_cidr
  public_subnets           = var.public_subnets
  #private_subnets          = var.private_subnets
  private_subnets     = var.private_subnet_count > 0 ? var.private_subnets : {}
  rds_private_subnets = var.rds_private_subnets
  default_route_cidr  = var.default_route_cidr

  # DNS設定
  enable_dns_support   = var.vpc_dns_config.support
  enable_dns_hostnames = var.vpc_dns_config.hostnames
  common_tags          = var.common_tags
}

# --- Gateways: VPC Endpoints (S3, SSM) ---
module "gateways" {
  source = "../../modules/gateways"

  # エンドポイント作成制御
  ssm_endpoint_services = var.create_ssm_endpoint ? ["ssm", "ssmmessages", "ec2messages"] : []
  private_dns_enabled   = var.vpc_dns_config.private_dns
  create_s3_endpoint    = var.create_s3_endpoint

  # ネットワーク・セキュリティ連携
  vpc_id          = module.network.vpc_id
  private_subnets = module.network.private_subnets
  ssm_vpce_sg_id  = module.sg.ssm_vpce_sg_id
  s3_route_table_ids = concat(
    var.create_gateway_routing["s3"].create_public_route ? module.network.public_route_table_id : [],
    var.create_gateway_routing["s3"].create_private_route ? module.network.private_route_table_id : []
  )
  common_tags = var.common_tags
}

# --- IAM: Instance Profiles and Roles ---
module "iam" {
  source = "../../modules/security/iam"

  # 作成制御フラグ
  create_ec2_iam_role = var.create_ec2_iam_role
  create_s3_bucket    = var.create_s3_bucket
  common_tags         = var.common_tags
}

# --- SG: Security Groups ---
module "sg" {
  source = "../../modules/security/sg"

  # 各コンポーネントのSG作成制御フラグ
  create_alb_sg         = var.create_alb_sg
  create_private_ec2_sg = var.create_private_ec2_sg
  create_private_rds_sg = var.create_private_rds_sg
  create_repo_ec2_sg    = var.create_repo_ec2_sg
  create_ssm_endpoint   = var.create_ssm_endpoint

  # ネットワーク設定連携
  vpc_id             = module.network.vpc_id
  default_route_cidr = var.default_route_cidr
  common_tags        = var.common_tags
}

# --- Compute: Auto Scaling Group ---
module "asg" {
  source = "../../modules/compute/asg"

  # モジュール全体の作成制御
  count = var.create_asg ? 1 : 0

  # 権限・セキュリティ連携
  iam_instance_profile   = var.create_ec2_iam_role ? module.iam.iam_instance_profile[0] : null
  vpc_security_group_ids = module.sg.vpc_security_group_ids_ec2
  private_subnets        = module.network.private_subnets

  # ターゲットグループ・スケーリング設定
  aws_lb_target_group   = var.create_alb_sg ? [module.load_balancer[0].aws_lb_target_group.arn] : []
  ec2_instance_define   = var.ec2_instance_define
  asg_capacity_settings = var.asg_capacity_settings
  scaling_rule          = var.scaling_rule
  s3_bucket_name        = var.s3_bucket_name
  common_tags           = var.common_tags
}

# --- Compute: Single EC2 Instance (for Repo/Bastion) ---
module "ec2_single" {
  source = "../../modules/compute/ec2_single"

  # ★repo環境でのみ作成されるよう制御
  count = var.create_repo_ec2_sg ? 1 : 0

  # 権限・ネットワーク連携
  iam_instance_profile   = var.create_ec2_iam_role ? module.iam.iam_instance_profile[0] : null
  public_subnets         = module.network.public_subnets[0]
  vpc_security_group_ids = module.sg.vpc_security_group_ids_repo_ec2

  # インスタンス設定
  ec2_instance_define = var.ec2_instance_define
  s3_bucket_name      = var.s3_bucket_name
  common_tags         = var.common_tags
}

# --- Database: RDS Instance ---
module "database" {
  source = "../../modules/database"
  # RDS本体のフラグで制御
  count = var.create_rds ? 1 : 0

  vpc_security_group_ids = module.sg.vpc_security_group_ids_rds
  rds_private_subnets    = module.network.rds_private_subnets
  rds_instance_define    = var.rds_instance_define
  rds_connect_define     = var.rds_connect_define
  common_tags            = var.common_tags
}

# --- Load Balancer: Application Load Balancer ---
module "load_balancer" {
  source = "../../modules/load_balancer"
  # ALB本体のフラグで制御
  count = var.create_alb ? 1 : 0

  vpc_id                 = module.network.vpc_id
  public_subnets         = module.network.public_subnets
  vpc_security_group_ids = module.sg.vpc_security_group_ids_alb
  common_tags            = var.common_tags
}

# --- Monitoring: CloudWatch Alarms ---
module "monitoring" {
  source = "../../modules/monitoring"

  # ASG作成有無と連動
  count = var.create_asg ? 1 : 0

  endpoint                   = var.endpoint
  aws_autoscaling_group_name = var.create_asg ? module.asg[0].aws_autoscaling_group_name : null
  aws_autoscaling_policy     = var.create_asg ? module.asg[0].aws_autoscaling_policy : null
  cpu_alarm                  = var.cpu_alarm
  common_tags                = var.common_tags
}

# --- Storage: S3 Buckets ---
module "s3" {
  source = "../../modules/storage/s3"

  # ★バケット作成フラグそのものでモジュールごと制御
  count = var.create_s3_bucket ? 1 : 0

  s3_bucket_name         = var.s3_bucket_name
  allowed_principal_arns = var.allowed_principal_arns
  vpc_endpoint_id        = module.gateways.s3_vpc_endpoint_id
  common_tags            = var.common_tags
}
