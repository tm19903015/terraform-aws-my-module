# ----------------------------
# SSM VPCE用SG
# ----------------------------
resource "aws_security_group" "ssm_vpce_sg" {
  #フラグが1なら作成、0なら作成しない。
  count = var.create_ssm_endpoint ? 1 : 0

  name        = "${var.common_tags["Env"]}-ssm-vpce-sg"
  description = "SSM,Internet,S3 Access"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-ssm-vpce-sg"
  })
}
