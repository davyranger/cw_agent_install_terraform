data "aws_instances" "test" {
  filter {
    name   = "platform-details"
    values = ["Linux/UNIX"]
  }

  instance_state_names = ["running"]
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent/config"
  type        = "String"
  value       = file("../../modules/cw_age_all/cw_agent_config.json")
}

resource "aws_ssm_association" "install_or_update_cloudwatch_agent" {

  name = "${aws_ssm_document.install_or_update_cw_agent.name}"
  
  targets {
    key    = "InstanceIds"
    values = data.aws_instances.test.ids
  }
}

resource "aws_ssm_document" "install_or_update_cw_agent" {
  name          = "test_document"
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
            "sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 ssm:/cloudwatch-agent/config -s",
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
