resource "aws_cloudwatch_log_metric_filter" "ssm_specific_command_failed" {
  name           = "SSMSpecificCommandFailed"
  log_group_name = aws_cloudwatch_log_group.ssm_lin.name
  
  pattern        = <<PATTERN
  {
    $.status = "Failed"
    && $.documentName = "${var.name}"
  }
PATTERN

  metric_transformation {
    name      = "SSMSpecificCommandFailed"
    namespace = "SSM"
    value     = "1"
  }
}


resource "aws_cloudwatch_log_group" "ssm_lin" {
  name = "/aws/ssm/AWS-RunShellScript"
}

# CloudWatch Metric Alarm
resource "aws_cloudwatch_metric_alarm" "ssm_command_failed" {
  alarm_name          = "SSMCommandFailed"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "1"
  metric_name         = aws_cloudwatch_log_metric_filter.ssm_specific_command_failed.metric_transformation[0].name
  namespace           = aws_cloudwatch_log_metric_filter.ssm_specific_command_failed.metric_transformation[0].namespace
  period              = "60"
  statistic           = "Sum"
  threshold           = "1"

  alarm_actions = [aws_sns_topic.ssm_alerts.arn]
}

# SNS Topic and Subscription
resource "aws_sns_topic" "ssm_alerts" {
  name = "ssm-alerts"
}

resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.ssm_alerts.arn
  protocol  = "email"
  endpoint  = "davy.strain@hotmail.com"
}
