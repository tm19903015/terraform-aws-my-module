# ----------------------------
# 共通タグ
# ----------------------------
variable "common_tags" {
  type = map(string)
}

# ----------------------------
# EC2IAMロール作成フラグ
# ----------------------------
variable "create_ec2_iam_role" {
  type = bool
}

# ----------------------------
# S3バケット作成フラグ
# ----------------------------
variable "create_s3_bucket" {
  type = bool
}
