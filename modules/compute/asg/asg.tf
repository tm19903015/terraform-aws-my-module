# ----------------------------
# AutoScaling作成
# → AutoScalingでスケールするための定義を作成
# ----------------------------
resource "aws_autoscaling_group" "main" {
  name             = "${var.common_tags["Env"]}-asg"
  desired_capacity = var.asg_capacity_settings.desired_capacity
  max_size         = var.asg_capacity_settings.max_size
  min_size         = var.asg_capacity_settings.min_size

  vpc_zone_identifier = var.private_subnets

  launch_template {
    id      = aws_launch_template.ec2_template.id
    version = "$Latest"
  }
  target_group_arns         = var.aws_lb_target_group
  health_check_type         = "ELB"
  health_check_grace_period = var.asg_capacity_settings.health_check_grace_period

  tag {
    key                 = "Name"
    value               = "${var.common_tags["Env"]}-asg"
    propagate_at_launch = true
  }
}

# ----------------------------
# AutoScalingポリシー作成
# → AutoScalingでリソース増加時のスケールアウト、スケールインするためのポリシーを作成
# ----------------------------
resource "aws_autoscaling_policy" "scale_out" {
  name                   = "${var.common_tags["Env"]}-${var.scaling_rule.scale_out.name}"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = var.scaling_rule.scale_out.policy_type
  adjustment_type        = var.scaling_rule.scale_out.adjustment_type
  step_adjustment {
    scaling_adjustment          = var.scaling_rule.scale_out.scaling_adjustment
    metric_interval_lower_bound = 0
  }

}
resource "aws_autoscaling_policy" "scale_in" {
  name                   = "${var.common_tags["Env"]}-${var.scaling_rule.scale_in.name}"
  autoscaling_group_name = aws_autoscaling_group.main.name
  policy_type            = var.scaling_rule.scale_in.policy_type
  adjustment_type        = var.scaling_rule.scale_in.adjustment_type
  step_adjustment {
    scaling_adjustment          = var.scaling_rule.scale_in.scaling_adjustment
    metric_interval_upper_bound = 0
  }

}
