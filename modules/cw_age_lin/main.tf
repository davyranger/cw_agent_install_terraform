data "aws_instances" "test" {
  filter {
    name   = "platform-details"
    values = ["Linux/UNIX"]
  }

  instance_state_names = ["running"]
}

resource "aws_ssm_parameter" "cw_agent" {
  #depends_on  = [aws_cloudwatch_log_metric_filter.ssm_specific_command_failed]
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent-lin/config"
  type        = "String"
  value       = file("./modules/cw_age_lin/cw_agent_config.json")
}

resource "aws_ssm_association" "install_or_update_cloudwatch_agent" {

  name = "${aws_ssm_document.install_or_update_cw_agent_lin.name}"
  
  targets {
    key    = "InstanceIds"
    values = data.aws_instances.test.ids
  }
}

resource "aws_ssm_document" "install_or_update_cw_agent_lin" {
  name          = "install_or_update_cw_agent_lin"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Check ip configuration of a Linux instance.",
    "mainSteps": [
      {
        "action": "aws:runShellScript",
        "name": "install_or_update_cw_agent",
        "inputs": {
          "runCommand": [
            "sudo yum update -y",
            "sudo yum upgrade -y",
            "sudo wget https://s3.amazonaws.com/amazoncloudwatch-agent/amazon_linux/amd64/latest/amazon-cloudwatch-agent.rpm",
            "sudo rpm -U ./amazon-cloudwatch-agent.rpm",
            "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c ssm:/cloudwatch-agent-lin/config -s",
            "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start",
            "echo 'Done initialization'"
          ]
        }
      }
    ]
  }
DOC
}

output "instance_ids" {
  value = data.aws_instances.test.ids
}
