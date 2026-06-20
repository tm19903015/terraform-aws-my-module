# ----------------------------
# Public Subnet作成
# → インターネットに出られるサブネット
# ----------------------------
resource "aws_subnet" "public" {
  # マップのキーをリスト化し、指定した個数分だけ「切り取る（slice）」
  for_each = {
    for k in slice(keys(var.public_subnets), 0, var.public_subnet_count) :
    k => var.public_subnets[k]
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = true
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-public-subnet-${each.key}"
  })
}
