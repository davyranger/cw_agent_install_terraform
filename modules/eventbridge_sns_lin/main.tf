resource "aws_cloudwatch_event_rule" "ssm_command_failed_lin" {
  name        = "SSMCommandFailedRulelin"
  description = "EventBridge rule for SSM command failures on linux instances"
  event_pattern = jsonencode({
    "detail-type": ["EC2 Command Status-change Notification"],
    "source": ["aws.ssm"],
    "detail": {
      "status": ["Failed"],
      "document-name": ["install_or_update_cw_agent_lin"]
    }
  })
}

# CloudWatch Event Target with Input Transformer
resource "aws_cloudwatch_event_target" "sns_target_lin" {
  rule      = aws_cloudwatch_event_rule.ssm_command_failed_lin.name
  target_id = "SendToSNSlin"
  arn       = var.sns_topic_arn  # Your SNS Topic ARN

  input_transformer {
    input_paths = {
      "command-id"   = "$.detail.command-id"
      "document-name" = "$.detail.document-name"
      "status"        = "$.detail.status"
    }
    input_template = "{\"message\": \"SSM command <document-name> with Command ID <command-id> has <status> on Linux instance(s).\"}"
  }
}