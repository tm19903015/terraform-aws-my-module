# ----------------------------
# 共通タグ
# ----------------------------
variable "common_tags" {
  type = map(string)
}
# ----------------------------
# デフォルトルート
# ----------------------------
variable "default_route_cidr" {
  type = string
}

# ----------------------------
# VPCID
# ----------------------------
variable "vpc_id" {
  type = string
}
# ----------------------------
# ALB関連のSG作成フラグ
# ----------------------------
variable "create_alb_sg" {
  type = bool
}

# ----------------------------
# PrivateEC2関連のSG作成フラグ
# ----------------------------
variable "create_private_ec2_sg" {
  type = bool
}

# ----------------------------
# PrivateRDS関連のSG作成フラグ
# ----------------------------
variable "create_private_rds_sg" {
  type = bool
}

# ----------------------------
# repo環境用EC2のSG作成フラグ
# ----------------------------
variable "create_repo_ec2_sg" {
  type = bool
}

# ----------------------------
# SSM　Interface Endopoint作成フラグ
# ----------------------------
variable "create_ssm_endpoint" {
  type = bool
}


