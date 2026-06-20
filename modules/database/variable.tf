# ----------------------------
# 共通タグ
# ----------------------------
variable "common_tags" {
  type = map(string)
}

# ----------------------------
# RDS用PrivateサブネットID
# ----------------------------
variable "rds_private_subnets" {
  type = list(string)
}

# ----------------------------
# RDS のインスタンス定義
# ----------------------------
variable "rds_instance_define" {
  type = object({
    engine            = string
    instance_class    = string
    allocated_storage = number
    #port              = number
  })
}

# ----------------------------
# # RDSの接続先情報
# ----------------------------
variable "rds_connect_define" {
  type = object({
    db_user     = string
    db_password = string
    db_name     = string
  })
}

# ----------------------------
# RDSのセキュリティグループ
# ----------------------------
variable "vpc_security_group_ids" {
  type = list(string)
}
