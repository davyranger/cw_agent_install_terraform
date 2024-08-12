data "aws_instances" "test" {
  filter {
    name   = "platform-details"
    values = ["Windows"]
  }

  instance_state_names = ["running"]
}

resource "aws_ssm_parameter" "cw_agent" {
  description = "Cloudwatch agent config to configure custom log"
  name        = "/cloudwatch-agent-win/config"
  type        = "String"
  value       = file("./modules/cw_age_win/cw_agent_config.json")
}

resource "aws_ssm_association" "install_or_update_cloudwatch_agent" {
  name = "${aws_ssm_document.install_or_update_cw_agent.name}"
  
  targets {
    key    = "InstanceIds"
    values = data.aws_instances.test.ids
  }
}

resource "aws_ssm_document" "install_or_update_cw_agent" {
  name          = "install_or_update_cw_agent_win"
  document_type = "Command"

  content = <<DOC
  {
    "schemaVersion": "2.2",
    "description": "Install or update CloudWatch agent on Windows EC2 instances.",
    "mainSteps": [
      {
        "action": "aws:runPowerShellScript",
        "name": "install_or_update_cw_agent",
        "inputs": {
          "runCommand": [
            "Write-Output 'Downloading CloudWatch agent installer...'",
            "New-Item -Path 'C:\\Temp\\' -ItemType Directory",
            "Invoke-WebRequest -Uri 'https://amazoncloudwatch-agent.s3.amazonaws.com/windows/amd64/latest/amazon-cloudwatch-agent.msi' -OutFile 'C:\\Temp\\amazon-cloudwatch-agent.msi'",
            "Write-Output 'Installing CloudWatch agent...'",
            "Start-Process -FilePath 'msiexec.exe' -ArgumentList '/i C:\\Temp\\amazon-cloudwatch-agent.msi /quiet /qn /norestart' -Wait",
            "Write-Output 'Configuring CloudWatch agent...'",
            "& 'C:\\Program Files\\Amazon\\AmazonCloudWatchAgent\\amazon-cloudwatch-agent-ctl.ps1' -a fetch-config -m ec2 -s -c ssm:/cloudwatch-agent-win/config",
            "Write-Output 'Starting CloudWatch agent...'",
            "Start-Service -Name 'AmazonCloudWatchAgent'",
            "Write-Output 'Done initialization'"
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
