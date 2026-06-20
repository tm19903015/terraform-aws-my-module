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
  type = string
}

#=====================================
# EC2 のインスタンス定義
#=====================================
variable "ec2_instance_define" {
  type = object({
    ami           = string
    instance_type = string
  })
}

#variable "ec2_instances" {
#  type = map(object({
#    az = string
#  }))
#}

# ----------------------------
# EC2セキュリティグループID
# ----------------------------
variable "vpc_security_group_ids" {
  type = list(string)
}

# ----------------------------
# EC2インスタンスプロファイル名
# ----------------------------
variable "iam_instance_profile" {
  type = string
}

# ----------------------------
# S3バケット名
# ----------------------------
variable "s3_bucket_name" {
  type = string
}
