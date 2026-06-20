# ----------------------------
# 共通タグ
# ----------------------------
variable "common_tags" {
  type = map(string)
}

# ----------------------------
# S3バケット名
# ----------------------------
variable "s3_bucket_name" {
  type    = string
  default = ""
}

# ----------------------------
# s3アクセスユーザ
# ----------------------------
variable "allowed_principal_arns" {
  type    = list(string)
  default = []
}

variable "vpc_endpoint_id" {
  type    = string
  default = null
}
