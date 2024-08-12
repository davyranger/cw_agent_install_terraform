output "name" {
  value = aws_ssm_document.install_or_update_cw_agent.name  # Replace aws_resource_name with the actual resource
}

output "arn" {
  value = aws_ssm_document.install_or_update_cw_agent.arn   # Replace aws_resource_name with the actual resource
}
