# ----------------------------
# RDS向けPrivate Subnet作成
# → RDSを配置するPrivate Subnetを2つ作成
# ----------------------------
resource "aws_subnet" "rds_private" {
  # マップのキーをリスト化し、指定した個数分だけ「切り取る（slice）」
  for_each = {
    for k in slice(keys(var.rds_private_subnets), 0, var.rds_private_subnet_count) :
    k => var.rds_private_subnets[k]
  }
  vpc_id = aws_vpc.main.id

  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-rds-private-subnet-${each.key}"
  })
}
