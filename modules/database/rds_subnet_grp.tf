# ----------------------------
# RDS向けサブネットグループ作成
# → RDSに紐づけるサブネットグループを作成
# ----------------------------
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.common_tags["Env"]}-rds-private-subnet-group"
  subnet_ids = var.rds_private_subnets
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-rds-private-subnet-group"
  })
}
