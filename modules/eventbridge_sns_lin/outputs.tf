output "eventbridge_rule_arn_lin" {
  value = aws_cloudwatch_event_rule.ssm_command_failed_lin.arn
}
