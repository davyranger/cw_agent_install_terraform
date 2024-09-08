module "cd_agent_lin" {
  source = "./modules/cw_age_lin"
}

module "cd_agent_win" {
  source = "./modules/cw_age_win"
}

module "cw_event_lin" {
  source = "./modules/cw_events_lin"
  arn    = module.cd_agent_lin.lin_ssm_doc_arn
}

module "cw_event_win" {
  source = "./modules/cw_events_win"
  arn    = module.cd_agent_win.win_ssm_doc_arn
}

module "eventbridge_sns_lin" {
  source               = "./modules/eventbridge_sns_lin"
  sns_topic_arn        = aws_sns_topic.ssm_alerts.arn
}

module "eventbridge_sns_win" {
  source               = "./modules/eventbridge_sns_win"
  sns_topic_arn        = aws_sns_topic.ssm_alerts.arn
}

resource "aws_sns_topic" "ssm_alerts" {
  name = "ssm-alerts1"
}

resource "aws_sns_topic_policy" "sns_policy_win" {
  arn    = aws_sns_topic.ssm_alerts.arn
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = {
          Service = "events.amazonaws.com"
        }
        Action    = "sns:Publish"
        Resource  = aws_sns_topic.ssm_alerts.arn
        Condition = {
          ArnLike = {
            "aws:SourceArn" = [
              module.eventbridge_sns_win.eventbridge_rule_arn_win,
              module.eventbridge_sns_lin.eventbridge_rule_arn_lin
            ]
          }
        }
      }
    ]
  })
}
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.ssm_alerts.arn
  protocol  = "email"
  endpoint  = "davy.strain@hotmail.com"
}

# module "sns_win" {
#   source = "./modules/sns_win"
#   name   = module.cd_agent_win.win_ssm_doc_name
# }

