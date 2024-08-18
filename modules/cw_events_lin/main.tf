resource "aws_iam_role" "event_change_role_runcommand_lin" {
  name = "linux_invoke_run_command"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "events.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "linux_invoke_run_command_policy_lin" {
  name        = "linux_invoke_run_command_policy"
  description = "Policy for linux run command execution"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "ssm:SendCommand",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:instance/*"
        ],
        "Condition": {
          "StringEquals": {
            "ec2:ResourceTag/*": [
              "lin_cwagent"
            ]
          }
        }
      },
      {
        "Action": "ssm:SendCommand",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:document/install_or_update_cw_agent_lin"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment_lin" {
  policy_arn = aws_iam_policy.linux_invoke_run_command_policy_lin.arn
  role       = aws_iam_role.event_change_role_runcommand_lin.name
}

resource "aws_cloudwatch_event_rule" "runcommand_event_rule_lin" {
  name        = "trigger_config_lin"
  description = "Trigger run command for linux instances"

  event_pattern = jsonencode({
    "source": ["aws.ssm"],
    "detail-type": ["Parameter Store Change"],
    "resources": ["arn:aws:ssm:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:parameter/cloudwatch-agent-lin/config"]
  })
}

resource "aws_cloudwatch_event_target" "event_target_lin" {
  rule      = aws_cloudwatch_event_rule.runcommand_event_rule_lin.name
  target_id = "install_or_update_cw_agent_lin"
  arn       = var.arn
  role_arn  = aws_iam_role.event_change_role_runcommand_lin.arn

  run_command_targets {
    key = "tag:Name"
    values = ["lin_cwagent"]  # Replace with the tag value of your target EC2 instances
  }
}