# ----------------------------
# 共通タグ
# ----------------------------
variable "common_tags" {
  type = map(string)
}
# ----------------------------
# EC2インスタンスプロファイル名
# ----------------------------
variable "iam_instance_profile" {
  type = string
}

# ----------------------------
# EC2セキュリティグループID
# ----------------------------
variable "vpc_security_group_ids" {
  type = list(string)
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

#=====================================
# ASG キャパシティ構成
#=====================================
variable "asg_capacity_settings" {
  type = object({
    desired_capacity          = number #通常稼働数
    max_size                  = number #最大稼働数
    min_size                  = number #最低稼働数
    health_check_grace_period = number #初期猶予期間
  })
}

# ----------------------------
# PrivateサブネットID
# ----------------------------
variable "private_subnets" {
  type = list(string)
}

# ----------------------------
# ALBターゲットグループ
# ----------------------------
variable "aws_lb_target_group" {
  type = list(string)
}

#=====================================
# ASG スケーリングルール
#=====================================
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

# ----------------------------
# S3バケット名
# ----------------------------
variable "s3_bucket_name" {
  type = string
}
