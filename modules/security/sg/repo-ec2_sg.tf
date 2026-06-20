# ----------------------------
# repo環境のEC2向けのセキュリティグループ作成
# → SSM、インターネット、S3 Gatewayへのアクセス許可設定
# ----------------------------
resource "aws_security_group" "repo_ec2_sg" {
  #フラグがtrueなら作成、falseなら作成しない
  count       = var.create_repo_ec2_sg ? 1 : 0
  name        = "${var.common_tags["Env"]}-ec2-sg"
  description = "SSM,Internet,S3 Access"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-ec2-sg"
  })

  # ① インターネット(HTTPS)へのアウトバウンド：SSMや外部Repo用アウトバウンド設定（全許可）
  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.default_route_cidr]
    description = "Allow HTTPS for SSM and Internet"
  }
}
