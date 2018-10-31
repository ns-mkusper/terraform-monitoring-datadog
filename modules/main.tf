#
# NETWORKING
#
# Hashicorp AWS VPC Module: https://registry.terraform.io/modules/terraform-aws-modules/vpc/aws/1.17.0
#

data "aws_caller_identity" "current" {}

# TODO: Add to DevOps VPC instead of creating a new one.
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name = "vpc-monitoring"
  cidr = "10.0.0.0/16"
  azs             = ["${data.aws_availability_zones.available.names}"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
  enable_nat_gateway = true
  enable_vpn_gateway = true

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}
#
# Security Group for HTTP
#
resource "aws_security_group" "web_sg" {
  name_prefix = "${var.common_name}-${terraform.workspace}"
  description = "Security Group for monitoring host HTTP"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = {
    "Terraform" = "true"
    "Environment" = "${terraform.workspace}"
  }
}
#
# Security Group for SSH
# https://www.terraform.io/docs/providers/aws/r/security_group.html
#
resource "aws_security_group" "ssh_sg" {
  name_prefix = "${var.common_name}-${terraform.workspace}"
  description = "Security Group for monitoring host SSH"
  vpc_id      = "${module.vpc.vpc_id}"
  tags        = {
    "Terraform" = "true"
    "Environment" = "${terraform.workspace}"
  }
}
#
# Security Group Rules
# https://www.terraform.io/docs/providers/aws/r/security_group_rule.html
#
resource "aws_security_group_rule" "inbound_https_from_anywhere" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web_sg.id}"
}

resource "aws_security_group_rule" "inbound_http_from_anywhere" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web_sg.id}"
}

resource "aws_security_group_rule" "inbound_ssh_from_anywhere" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web_sg.id}"
}
resource "aws_security_group_rule" "outbound_to_anywhere" {
  type            = "egress"
  from_port       = 0
  to_port         = 0
  protocol        = "-1"
  cidr_blocks     = ["0.0.0.0/0"]
  security_group_id = "${aws_security_group.web_sg.id}"
}
#
# EC2 Instances
#
# Currenty get AWS SSH Key Pair for SSH into the Instance
# TODO: Use Vault to store/rotate the SSH key.
# https://www.terraform.io/docs/providers/aws/r/key_pair.html
#
resource "aws_key_pair" "aws_ssh_key" {
  key_name   = "${var.common_name}-${terraform.workspace}"
  public_key = "${file("${var.aws_ec2_public_key}")}"
}
#
# Randomize subnet selection
# https://www.terraform.io/docs/providers/random/r/shuffle.html
#
resource "random_shuffle" "subnet" {
  input = ["${module.vpc.public_subnets}"]
  result_count = 1
}
#
# Latest CIS CentOS Hardened AMI
# https://www.terraform.io/docs/providers/aws/d/ami.html
#
data "aws_ami" "hardened_centos" {
  owners      = ["679593333241"]
  most_recent = true

  filter {
    name   = "name"
    values = ["CIS Centos Linux 7 Benchmark *"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

#
# AWS EC2 Instance
# https://www.terraform.io/docs/providers/aws/r/instance.html
#
resource "aws_instance" "monitor_host" {
  ami = "${data.aws_ami.hardened_centos.id}"
  instance_type = "${var.aws_instance_type}"
  vpc_security_group_ids = [
    "${aws_security_group.web_sg.id}",
    "${aws_security_group.ssh_sg.id}"
  ]
  # sticks this instance in a random subnet
  subnet_id = "${random_shuffle.subnet.result[0]}"
  # Instance userdata to install dd and setup nginx/ansible
  user_data = <<-EOF
              #!/bin/bash
              DD_API_KEY="${data.vault_generic_secret.dd-secrets.data["api-key"]}" bash -c "$(curl -L https://raw.githubusercontent.com/DataDog/dd-agent/master/packaging/datadog-agent/source/install_agent.sh)"
              EOF
  key_name = "${aws_key_pair.aws_ssh_key.key_name}"
  associate_public_ip_address = true
  tags {
    "name" = "${var.common_name}-${terraform.workspace}"
    "terraform" = "true"
    "environment" = "${terraform.workspace}"
    "role" = "nginx"
    "creator" = "${data.aws_caller_identity.current.user_id}"
  }
}

resource "ansible_host" "monitor_host" {
  inventory_hostname = "${aws_instance.monitor_host.public_dns}"
  groups = ["web"]
  vars
  {
    ansible_user = "centos"
    ansible_ssh_private_key_file="~/.ssh/id_rsa"
    ansible_python_interpreter="/usr/bin/python3"
  }
}

