# ----------------------------
# Private Subnet作成
# → インターネットからアクセス不可なサブネット
# → EC2を配置する場所
# ----------------------------

resource "aws_subnet" "private" {
  # マップのキーをリスト化し、指定した個数分だけ「切り取る（slice）」
  for_each = {
    for k in slice(keys(var.private_subnets), 0, var.private_subnet_count) :
    k => var.private_subnets[k]
  }
  vpc_id = aws_vpc.main.id

  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-private-subnet-${each.key}"
  })
}
