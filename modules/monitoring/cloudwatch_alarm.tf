# ----------------------------
# CloudWatchアラーム作成
# → CPU使用率が50%をオーバーした際に発動するアラームを作成
# ----------------------------
resource "aws_cloudwatch_metric_alarm" "cpu_up_alarm" {
  #共通
  evaluation_periods  = var.cpu_alarm.common.evaluation_periods
  datapoints_to_alarm = var.cpu_alarm.common.datapoints_to_alarm
  metric_name         = var.cpu_alarm.common.metric_name
  namespace           = var.cpu_alarm.common.namespace
  period              = var.cpu_alarm.common.period
  statistic           = var.cpu_alarm.common.statistic
  alarm_description   = var.cpu_alarm.common.alarm_description
  dimensions = {
    AutoScalingGroupName = var.aws_autoscaling_group_name
  }
  treat_missing_data        = var.cpu_alarm.common.treat_missing_data # 欠落データの処理方法 （今回はlocal変数ないで定義）
  insufficient_data_actions = [aws_sns_topic.alert_to_mail_topic.arn] # データ不足の時に実行するアクション（SNSトピックに送信）
  actions_enabled           = var.cpu_alarm.common.actions_enabled    # アラームのアクションを有効化する

  #個別
  for_each            = var.cpu_alarm.rules
  comparison_operator = each.value.comparison_operator
  alarm_name          = each.value.alarm_name
  threshold           = each.value.threshold
  alarm_actions = concat(
    each.value.notify ? [aws_sns_topic.alert_to_mail_topic.arn] : [],
    each.value.type == "scale_out" ? [var.aws_autoscaling_policy.scale_out] : [var.aws_autoscaling_policy.scale_in]
  )
  ok_actions = lookup(each.value, "ok_actions", null)
}
