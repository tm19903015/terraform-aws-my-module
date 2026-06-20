# ----------------------------
# Internet Gateway作成
# → VPCをインターネットと接続する出口
# ----------------------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-igw"
  })
}

