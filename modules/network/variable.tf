# ----------------------------
# VPCのCIDR作成
# ----------------------------
variable "vpc_cidr" {
  type = string
}

# ----------------------------
# 共通タグ
# ----------------------------
variable "common_tags" {
  type = map(string)
}

# ----------------------------
# Publicサブネット
# ----------------------------
variable "public_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

# ----------------------------
# Privateサブネット
# ----------------------------
variable "private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}

# ----------------------------
# デフォルトルート
# ----------------------------
variable "default_route_cidr" {
  type = string
}

# ----------------------------
# サブネットの作成個数 の定義
# ----------------------------
variable "public_subnet_count" {
  type = number
}
variable "private_subnet_count" {
  type = number
}
variable "rds_private_subnet_count" {
  type = number
}


# ----------------------------
# プライベート名前解決設定
# ----------------------------
variable "enable_dns_support" {
  type = bool
}
variable "enable_dns_hostnames" {
  type = bool
}

# ----------------------------
# RDS用Privateサブネット
# ----------------------------
variable "rds_private_subnets" {
  type = map(object({
    cidr = string
    az   = string
  }))
}
