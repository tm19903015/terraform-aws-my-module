# ----------------------------
# VPC作成
# → AWS上のネットワーク全体の土台
# ----------------------------
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = var.enable_dns_support
  enable_dns_hostnames = var.enable_dns_hostnames
  tags = merge(var.common_tags,
    {
      Name = "${var.common_tags["Env"]}-vpc"
  })
}



