# ----------------------------
# EC2インスタンスプロファイル名出力
# ----------------------------
output "iam_instance_profile" {
  value = aws_iam_instance_profile.ec2_profile[*].name
}
