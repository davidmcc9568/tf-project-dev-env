# AWS Developer Environment with Terraform and VS Code

This repository contains Terraform code to create a developer environment in AWS that can be accessed using Visual Studio Code. The environment includes a VPC, subnet, Internet Gateway, route table, security group, and an EC2 instance with Docker installed. Using the Terraform provisioner 'local-exec', along with a ssh-config file, this project allows the user to open a VS Code interface inside the EC2 instance directly. 

**Resources**<br>

The following resources are created in this infrastructure:<br>
VPC with a CIDR block of 10.95.0.0/16 <br>
Public subnet within the VPC with a CIDR block of 10.95.1.0/24<br>
Internet Gateway attached to the VPC<br>
Route table associated with the VPC<br>
Security group allowing all ingress and egress traffic (See Note blow)<br>
Imported key pair for SSH authentication<br>
EC2 instance with Docker installed<br>

**Prerequisites**<br>

Terraform installed<br>
An AWS account with the necessary permissions to create resources<br>
AWS CLI installed and configured with your AWS credentials<br>
An existing SSH key pair for EC2 instance authentication<br>

**Usage**<br>

Clone this repository.<br>
Run 'terraform init' in the root directory of the repository to initialize Terraform.<br>
Update the variables in 'variables.tf' as needed.<br>
Run 'terraform apply' to create the infrastructure. Confirm the changes by typing yes when prompted.<br>
To connect to the created EC2 instance using Visual Studio Code, install the Remote - SSH extension and configure your SSH config file based on the output from the terraform apply command.<br>
To destroy the created infrastructure, run 'terraform destroy'. Confirm the changes by typing 'yes' when prompted.<br>

**Note**<br>
Make sure to replace the ingress CIDR block with your IP address in the 'aws_security_group' resource to follow best practices.

**Files**<br>
'main.tf': Main Terraform configuration file with resource definitions<br>
'datasources.tf': Data source configuration for the AWS AMI used to create the EC2 instance<br>
'providers.tf': Provider configuration for AWS<br>
'userdata.tpl': User data script to bootstrap the EC2 instance with Docker installation<br>
'variables.tf': Variables used in the Terraform configuration<br>
'windows-ssh-config.tpl': SSH configuration template for connecting to the EC2 instance with Visual Studio Code. I am using a windows machine, change file based on your system<br>
'outputs.tf;: Outputs the public IP address of the EC2 instance<br>
