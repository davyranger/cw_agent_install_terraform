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

module "sns_lin" {
  source = "./modules/sns_lin"
  name   = module.cd_agent_lin.lin_ssm_doc_name
}

# module "sns_win" {
#   source = "./modules/sns_win"
#   name   = module.cd_agent_win.win_ssm_doc_name
# }

