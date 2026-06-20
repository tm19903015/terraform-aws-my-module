# ----------------------------
# PROD環境：ALB-EC2間 ＆ EC2-S3/RDS間 接続設定
# ----------------------------
#プライベート用のセキュリティグループ作成（器のみ）
resource "aws_security_group" "private_ec2_sg" {
  #ALB関連のSGが1なら作成、0なら作成しない。
  count = var.create_private_ec2_sg ? 1 : 0

  name        = "${var.common_tags["Env"]}-ec2-private-sg"
  description = "ALB TO EC2 instances AND EC2 instances TO NAT GateWay"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-ec2-private-sg"
  })
}

# インバウンド：ALBからのみHTTP許可
resource "aws_security_group_rule" "ec2_from_alb_ingress" {
  count                    = var.create_private_ec2_sg ? 1 : 0
  type                     = "ingress"
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg[0].id
  source_security_group_id = aws_security_group.alb_sg[0].id
}

# アウトバウンド：S3 Gateway Endpoint向け
resource "aws_security_group_rule" "ec2_to_s3_egress" {
  count             = var.create_private_ec2_sg ? 1 : 0
  type              = "egress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  prefix_list_ids   = [data.aws_prefix_list.s3.id]
  security_group_id = aws_security_group.private_ec2_sg[0].id
  description       = "Allow HTTPS to S3 via Gateway Endpoint"
}

# アウトバウンド：RDS向け
resource "aws_security_group_rule" "ec2_to_rds_egress" {
  count                    = var.create_private_ec2_sg ? 1 : 0
  type                     = "egress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg[0].id
  source_security_group_id = aws_security_group.private_rds_sg[0].id
  description              = "Allow EC2 to RDS"
}
