# ----------------------------
# 循環参照回避：EC2 ⇔ SSM 間の相互許可ルール
# ----------------------------
# EC2からSSM VPCEへの「出口」
resource "aws_security_group_rule" "ec2_to_ssm_egress" {
  count                    = (var.create_ssm_endpoint ? 1 : 0) * (var.create_private_ec2_sg ? 1 : 0)
  type                     = "egress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.private_ec2_sg[0].id
  source_security_group_id = aws_security_group.ssm_vpce_sg[0].id
}

# SSM VPCEがEC2から受ける「入口」
resource "aws_security_group_rule" "ssm_vpce_from_ec2_ingress" {
  count                    = (var.create_ssm_endpoint ? 1 : 0) * (var.create_private_ec2_sg ? 1 : 0)
  type                     = "ingress"
  from_port                = 443
  to_port                  = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.ssm_vpce_sg[0].id
  source_security_group_id = aws_security_group.private_ec2_sg[0].id
}
