# ----------------------------
# S3エンドポイントID出力
# ----------------------------
output "s3_vpc_endpoint_id" {
  value = var.create_s3_endpoint ? aws_vpc_endpoint.this[0].id : null
}
