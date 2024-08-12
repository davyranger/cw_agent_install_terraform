module "cd_agent_lin" {
  source = "./modules/cw_age_lin"
}
  
module "cd_agent_win" {
  source = "./modules/cw_age_win"
}

resource "aws_iam_role" "event_change_role_runcommand" {
  name = "linux_inevoke_run_command"

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

resource "aws_iam_policy" "linux_inevoke_run_command_policy" {
  name        = "linux_inevoke_run_command_policy"
  description = "Policy for linux run command execution"

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Action": "ssm:SendCommand",
        "Effect": "Allow",
        "Resource": [
          "arn:aws:ec2:ap-southeast-2:117134819170:instance/*"
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
          "arn:aws:ssm:ap-southeast-2:*:document/install_or_update_cw_agent_lin"
        ]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attachment" {
  policy_arn = aws_iam_policy.linux_inevoke_run_command_policy.arn
  role       = aws_iam_role.event_change_role_runcommand.name
}

resource "aws_cloudwatch_event_rule" "runcommand_event_rule" {
  name        = "trigger_config_lin"
  description = "Trigger run command for linux instances"

  event_pattern = jsonencode({
    "source": ["aws.ssm"],
    "detail-type": ["Parameter Store Change"],
    "resources": ["arn:aws:ssm:ap-southeast-2:117134819170:parameter/cloudwatch-agent-lin/config"]
  })
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule      = aws_cloudwatch_event_rule.runcommand_event_rule.name
  target_id = "install_or_update_cw_agent_lin"
  arn       = module.cd_agent_lin.arn
  role_arn  = aws_iam_role.event_change_role_runcommand.arn

  run_command_targets {
    key = "tag:Name"
    values = ["lin_cwagent"]  # Replace with the tag value of your target EC2 instances
  }
}
