# ----------------------------
# Route Table作成
# → 通信の行き先を決めるテーブル
# ----------------------------
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-public-route"
  })
}

# ----------------------------
# デフォルトルート作成
# → 0.0.0.0/0 宛の通信をInternet Gatewayへ流す
# ----------------------------
resource "aws_route" "public_route" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = var.default_route_cidr
  gateway_id             = aws_internet_gateway.igw.id
}

# ----------------------------
# Route TableをPublic Subnetに関連付け
# → Public Subnetがインターネットへ出られるようにする
# ----------------------------
resource "aws_route_table_association" "public" {
  for_each       = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# ----------------------------
# Private用のルート作成
# ----------------------------
resource "aws_route_table" "private" {
  # Privateサブネットが存在する場合のみ、"main" というキーを持つMapを作成してループを回す
  for_each = length(aws_subnet.private) > 0 ? { "main" = true } : {}
  vpc_id   = aws_vpc.main.id
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-private-route-${each.key}"
  })
}

# ----------------------------
# 各Private Subnetにこのルートテーブルを適用
# ----------------------------
resource "aws_route_table_association" "private" {
  # サブネットごとに回すが、紐付けるテーブルは上記で定義した "main" を参照
  for_each       = aws_subnet.private
  subnet_id      = each.value.id
  route_table_id = aws_route_table.private["main"].id

}
