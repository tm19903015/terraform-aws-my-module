# ============================================================
# Terraform Variables: Definitions
# ============================================================

# ------------------------------------------------------------
# 1. Basic Settings
# ------------------------------------------------------------
variable "account_id" {
  description = "ターゲットとなるAWSアカウントID（prod または repo）"
  type        = string
}

variable "region" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "common_tags" {
  type = map(string)
}

# ------------------------------------------------------------
# 2. Network Layout
# ------------------------------------------------------------

# --- Subnet Definitions ---
variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "rds_private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

variable "default_route_cidr" {
  type = string
}

# --- VPC DNS Settings ---
variable "vpc_dns_config" {
  description = "VPCのDNS設定とエンドポイントのPrivate DNS有効化フラグ"
  type = object({
    support     = bool
    hostnames   = bool
    private_dns = bool
  })
}

# ------------------------------------------------------------
# 3. Compute & Auto Scaling Settings
# ------------------------------------------------------------
variable "ec2_instance_define" {
  type = object({
    ami           = string
    instance_type = string
  })
}

variable "asg_capacity_settings" {
  type = object({
    desired_capacity          = number # 通常稼働数
    max_size                  = number # 最大稼働数
    min_size                  = number # 最低稼働数
    health_check_grace_period = number # 初期猶予期間
  })
}

variable "scaling_rule" {
  type = object({
    scale_out = object({
      name               = string
      policy_type        = string
      adjustment_type    = string
      scaling_adjustment = number
    })
    scale_in = object({
      name               = string
      policy_type        = string
      adjustment_type    = string
      scaling_adjustment = number
    })
  })
}

# ------------------------------------------------------------
# 4. Database Settings
# ------------------------------------------------------------
variable "rds_instance_define" {
  type = object({
    engine            = string
    instance_class    = string
    allocated_storage = number
  })
}

variable "rds_connect_define" {
  type = object({
    db_user     = string
    db_password = string
    db_name     = string
  })
}

# ------------------------------------------------------------
# 5. Storage Settings
# ------------------------------------------------------------
variable "s3_bucket_name" {
  type = string
}
variable "allowed_principal_arns" {
  type = list(string)
}

# ------------------------------------------------------------
# 6. Monitoring & Notification
# ------------------------------------------------------------
variable "endpoint" {
  type = string
}

variable "cpu_alarm" {
  description = "CloudWatch CPUアラームの共通設定と個別ルール"
  type = object({
    # 共通設定ブロック
    common = object({
      evaluation_periods  = number
      datapoints_to_alarm = number
      metric_name         = string
      namespace           = string
      period              = number
      statistic           = string
      treat_missing_data  = string
      alarm_description   = string
      actions_enabled     = bool
    })

    # 個別ルールブロック（up / low）
    rules = object({
      up = object({
        type                = string
        comparison_operator = string
        alarm_name          = string
        threshold           = number
        notify              = bool
      })
      low = object({
        type                = string
        comparison_operator = string
        alarm_name          = string
        threshold           = number
        notify              = bool
      })
    })
  })
}

# ------------------------------------------------------------
# 7. Resource Creation Control (Feature Flags)
# ------------------------------------------------------------

# --- Resource Counts ---
variable "public_subnet_count" {
  type = number
}
variable "private_subnet_count" {
  type = number
}
variable "rds_private_subnet_count" {
  type = number
}

# --- Component Flags (bool) ---
variable "create_asg" {
  type = bool
}

variable "create_alb" {
  type = bool
}

variable "create_rds" {
  type = bool
}

variable "create_alb_sg" {
  type = bool
}

variable "create_private_ec2_sg" {
  type = bool
}

variable "create_private_rds_sg" {
  type = bool
}

variable "create_ec2_iam_role" {
  type = bool
}

variable "create_repo_ec2_sg" {
  type = bool
}

variable "create_ssm_endpoint" {
  type = bool
}

variable "create_s3_endpoint" {
  type = bool
}

variable "create_s3_bucket" {
  type = bool
}

variable "create_gateway_routing" {
  type = map(object({
    create_public_route  = bool
    create_private_route = bool
  }))
  description = "Gateway型エンドポイントの各ルートテーブルへのアタッチ制御"
}
