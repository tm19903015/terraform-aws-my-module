# ----------------------------
# AmazonSNSトピック作成
# → アラーム検知後にAmazonSNSでアラームを通知する用のトピック
# ----------------------------
resource "aws_sns_topic" "alert_to_mail_topic" {
  name = "${var.common_tags["Env"]}-cloudwatch-alarm-alert-to-mail"
  tags = merge(var.common_tags, {
    Name = "${var.common_tags["Env"]}-cloudwatch-alarm-alert-to-mail"
  })
}

# ----------------------------
# AmazonSNSトピック サブスクリプション作成
# → アラーム検知後にAmazonSNSでアラームを通知する用のトピックのサブスクリプション作成
# ----------------------------
resource "aws_sns_topic_subscription" "alert_to_email_topic_subscription" {
  topic_arn = aws_sns_topic.alert_to_mail_topic.arn
  protocol  = "email"
  endpoint  = var.endpoint
}


