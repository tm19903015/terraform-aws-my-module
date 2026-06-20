# ----------------------------
# 外部公開用のセキュリティグループ作成
# → インターネットからALBへの通信するため、HTTPのみ許可
# ----------------------------
resource "aws_security_group" "alb_sg" {
  #ALB関連のSG作成フラグがtrueなら作成、falseなら作成しない。
  count = var.create_alb_sg ? 1 : 0

  name        = "${var.common_tags["Env"]}-alb-sg"
  description = "Internet to ALB"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-alb-sg"
  })

  #インバウンド設定（80番ポートのみ許可）
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.default_route_cidr]
  }

  #アウトバウンド設定（全許可）
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default_route_cidr]
  }

}
