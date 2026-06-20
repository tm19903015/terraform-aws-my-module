# ----------------------------
# 共通タグ
# ----------------------------
variable "common_tags" {
  type = map(string)
}

# ----------------------------
# VPCID
# ----------------------------
variable "vpc_id" {
  type = string
}

# ----------------------------
# PrivateサブネットID
# ----------------------------
variable "private_subnets" {
  type = list(string)
}

# ----------------------------
# SSM　Interface Endopointサービス
# ----------------------------
variable "ssm_endpoint_services" {
  type    = list(string)
  default = []
}


# ----------------------------
# SSM Interface EndopointのセキュリティグループID
# ----------------------------
variable "ssm_vpce_sg_id" {
  type = string
}

# ----------------------------
# プライベート名前解決設定
# ----------------------------
variable "private_dns_enabled" {
  type = bool
}

# ----------------------------
# S3ゲートウェイエンドポイント用のルートテーブル
# ----------------------------
variable "s3_route_table_ids" {
  type = list(string)
}

# ----------------------------
# S3 Gateway Endpoint作成フラグ
# ----------------------------
variable "create_s3_endpoint" {
  type = bool
}
