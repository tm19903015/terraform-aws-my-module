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
# publicサブネットID
# ----------------------------
variable "public_subnets" {
  type = list(string)
}

# ----------------------------
# セキュリティグループ
# ----------------------------
variable "vpc_security_group_ids" {
  type = list(string)
}
