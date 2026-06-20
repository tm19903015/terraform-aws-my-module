# ----------------------------
# rds向けのPrivate Subnet 用のセキュリティグループ作成
# → EC2からRDSへの通信するため、DBのポート番号のみ許可
# → アウトバウンドの通信は全許可
resource "aws_security_group" "private_rds_sg" {
  count = var.create_private_rds_sg ? 1 : 0

  name        = "${var.common_tags["Env"]}-rds-private-sg"
  description = "EC2 instances TO RDS"
  vpc_id      = var.vpc_id
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-rds-private-sg"
  })

  #インバウンド設定(EC2からのみDBポート番号で許可)
  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.private_ec2_sg[0].id]
  }

  #アウトバウンド設定(全許可)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [var.default_route_cidr]
  }

}
