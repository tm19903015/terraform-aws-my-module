# ----------------------------
# VPCID出力
# ----------------------------
output "vpc_id" {
  value = aws_vpc.main.id
}

# ----------------------------
# PublicサブネットID出力
# ----------------------------
output "public_subnets" {
  value = [for s in aws_subnet.public : s.id]
}

# ----------------------------
# PrivateサブネットID出力
# ----------------------------
output "private_subnets" {
  value = [for s in aws_subnet.private : s.id]
}

# ----------------------------
# RDS用PrivateサブネットID出力
# ----------------------------
output "rds_private_subnets" {
  value = [for s in aws_subnet.rds_private : s.id]
}


# ----------------------------
# Publicルートテーブル出力
# ----------------------------
output "public_route_table_id" {
  value = [aws_route_table.public.id]
}

# ----------------------------
# Privateルートテーブル出力
# ----------------------------
output "private_route_table_id" {
  value = [for rt in aws_route_table.private : rt.id]
}
