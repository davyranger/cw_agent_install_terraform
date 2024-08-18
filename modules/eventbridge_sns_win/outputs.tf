output "eventbridge_rule_arn_win" {
  value = aws_cloudwatch_event_rule.ssm_command_failed_win.arn
}
