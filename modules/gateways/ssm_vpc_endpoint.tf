# ----------------------------
# SSM Interface Endopoint作成
# → EC2からSSMへアクセスするためのEndpointを作成
# ----------------------------
resource "aws_vpc_endpoint" "ssm" {
  for_each = toset(var.ssm_endpoint_services)

  vpc_id              = var.vpc_id
  service_name        = "com.amazonaws.ap-northeast-1.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = var.private_subnets
  security_group_ids  = [var.ssm_vpce_sg_id]
  private_dns_enabled = var.private_dns_enabled
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-vpce-${each.value}"
  })
}
