output "lin_ssm_doc_name" {
  value = aws_ssm_document.install_or_update_cw_agent_lin.name  # Replace aws_resource_name with the actual resource
}

output "lin_ssm_doc_arn" {
  value = aws_ssm_document.install_or_update_cw_agent_lin.arn   # Replace aws_resource_name with the actual resource
}
