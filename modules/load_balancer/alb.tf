# ----------------------------
# ALB本体作成
# → 可用性の観点よりマルチAZ構成を実現するためのALb本体の作成
# ----------------------------
resource "aws_lb" "alb" {
  name               = "${var.common_tags["Env"]}-alb"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.public_subnets
  security_groups    = var.vpc_security_group_ids
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-alb"
  })
}
# ----------------------------
# Target Group作成
# → インターネットからALBへHTTP経由で通信した際に配下のEC2にどう振り分けるかを決めるためのグループ本体の作成
# ----------------------------
resource "aws_lb_target_group" "tg" {
  name        = "${var.common_tags["Env"]}-alb-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    path = "/"
  }
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-alb-tg"
  })
}
# ----------------------------
# Listner作成
# → ALBからHTTP経由で配下のEC2に通信するための受付係としてListnerの作成
# ----------------------------
resource "aws_lb_listener" "listner" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg.arn
  }
}
