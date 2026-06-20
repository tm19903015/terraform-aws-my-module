# ----------------------------
# RDS作成
# → EC2からRDSへ通信するためのRDS本体の作成を作成する。
# ----------------------------
resource "aws_db_instance" "main" {
  identifier              = "${var.common_tags["Env"]}-rds"
  engine                  = var.rds_instance_define.engine
  instance_class          = var.rds_instance_define.instance_class
  allocated_storage       = var.rds_instance_define.allocated_storage
  username                = var.rds_connect_define.db_user
  password                = var.rds_connect_define.db_password
  db_name                 = var.rds_connect_define.db_name
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = var.vpc_security_group_ids
  publicly_accessible     = false
  skip_final_snapshot     = true
  backup_retention_period = 1
}
