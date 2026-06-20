# ----------------------------
# 共通タグ
# ----------------------------
variable "common_tags" {
  type = map(string)
}
#=====================================
# SNSトピック通知先のメールアドレス
#=====================================
variable "endpoint" {
  type = string
}

# ----------------------------
# ASG名
# ----------------------------
variable "aws_autoscaling_group_name" {
  type = string
}

#=====================================
# CloudWacthアラーム の定義
#=====================================
variable "cpu_alarm" {
  description = "CloudWatch CPUアラームの共通設定と個別ルール"
  type = object({
    # 共通設定ブロック
    common = object({
      evaluation_periods  = number
      datapoints_to_alarm = number
      metric_name         = string
      namespace           = string
      period              = number
      statistic           = string
      treat_missing_data  = string
      alarm_description   = string
      actions_enabled     = bool
    })

    # 個別ルールブロック（up / low）
    rules = object({
      up = object({
        type                = string
        comparison_operator = string
        alarm_name          = string
        threshold           = number
        notify              = bool
      })
      low = object({
        type                = string
        comparison_operator = string
        alarm_name          = string
        threshold           = number
        notify              = bool
      })
    })
  })
}

# ----------------------------
# CloudWacthアラーム のスケールアクション
# ----------------------------
variable "aws_autoscaling_policy" {
  type = object({
    scale_out = string
    scale_in  = string
  })
}


