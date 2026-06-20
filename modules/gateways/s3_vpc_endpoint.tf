# ----------------------------
# S3VPCエンドポイント作成
# → EC2からS3へパッケージを参照・更新するためのS3への専用回線を作成
# ----------------------------
resource "aws_vpc_endpoint" "this" {
  count             = var.create_s3_endpoint ? 1 : 0
  vpc_id            = var.vpc_id
  service_name      = "com.amazonaws.ap-northeast-1.s3"
  vpc_endpoint_type = "Gateway"
  # 既存のルートテーブルにS3VPCエンドポイントの経路を追加
  route_table_ids = var.s3_route_table_ids
  # ---------------------------------------------------------------------------
  # AWS公式リポジトリ(S3)への通信を許可するため、対象バケットを限定しない設定
  # ※特定の自前バケットに絞ると、dnf等によるAWS公式S3への通信が403エラーになるため
  # ---------------------------------------------------------------------------
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:*"
        Resource  = "*"
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-s3-vpc-endpoint"
  })
}
