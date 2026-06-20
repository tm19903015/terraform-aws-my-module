# ----------------------------
# ASG名出力
# ----------------------------
output "aws_autoscaling_group_name" {
  value = aws_autoscaling_group.main.name
}

# ----------------------------
# ASGポリシー出力
# ----------------------------
output "aws_autoscaling_policy" {
  value = {
    scale_out = aws_autoscaling_policy.scale_out.arn
    scale_in  = aws_autoscaling_policy.scale_in.arn
  }
}

