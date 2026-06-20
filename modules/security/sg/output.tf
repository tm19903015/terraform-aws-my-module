# ----------------------------
# EC2セキュリティグループID出力
# ----------------------------
output "vpc_security_group_ids_ec2" {
  value = aws_security_group.private_ec2_sg[*].id
}

# ----------------------------
# ALBセキュリティグループID出力
# ----------------------------
output "vpc_security_group_ids_alb" {
  value = aws_security_group.alb_sg[*].id
}

# ----------------------------
# repo環境のEC2セキュリティグループID出力
# ----------------------------
output "vpc_security_group_ids_repo_ec2" {
  value = aws_security_group.repo_ec2_sg[*].id
}

# ----------------------------
# SSM Interface EndopointセキュリティグループID出力
# ----------------------------
output "ssm_vpce_sg_id" {
  value = var.create_ssm_endpoint ? aws_security_group.ssm_vpce_sg[0].id : null
}

# ----------------------------
# RDSセキュリティグループID出力
# ----------------------------
output "vpc_security_group_ids_rds" {
  value = aws_security_group.private_rds_sg[*].id
}
