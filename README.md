# 📘 CloudWatch Agent & Terraform Quick Reference

This document outlines essential commands and steps for:

* Installing Terraform
* Checking CloudWatch Agent status on Windows and Linux
* Using the CloudWatch Agent config wizard
* Simulating agent failures for testing

---

## 🚀 Installing Terraform (Linux)

Use the following steps to install Terraform (v1.7.4) on a Linux system:

```bash
# Download Terraform binary
wget https://releases.hashicorp.com/terraform/1.7.4/terraform_1.7.4_linux_amd64.zip

# Unzip the Terraform binary
unzip terraform_1.7.4_linux_amd64.zip

# Move it to a location in your PATH
sudo mv terraform /usr/local/bin

# Clean up zip file
rm terraform_1.7.4_linux_amd64.zip
```

---

## 🪟 CloudWatch Agent (Windows)

### ✅ Check Agent Status

Run the following in PowerShell:

```powershell
& $Env:ProgramFiles\Amazon\AmazonCloudWatchAgent\amazon-cloudwatch-agent-ctl.ps1 -m ec2 -a status
```

### 📄 View Current Configuration

```powershell
cat C:\ProgramData\Amazon\AmazonCloudWatchAgent\Configs\ssm__cloudwatch-agent-win_config
```

### 🛠️ Run Configuration Wizard

Launch the wizard to interactively create a new config:

```powershell
amazon-cloudwatch-agent-config-wizard.exe
```

---

## 🐧 CloudWatch Agent (Linux)

### ✅ Check Agent Status

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -m ec2 -a status
```

### 📄 View Agent Logs

```bash
cat /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

### 🛠️ Run Configuration Wizard

```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-config-wizard
```

---

## ❌ Simulating a Failed Agent Install

To intentionally trigger a failure in CloudWatch agent installation (for test scenarios), insert the following into the **Run Command** payload (SSM or similar):

```json
"runCommand": [
  "Write-Host 'Failing intentionally'",
  "exit 1"
]
```

---
