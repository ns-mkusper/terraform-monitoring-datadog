#
# Variables
# https://www.terraform.io/docs/configuration/variables.html
#
variable "aws_region" {
  default = "us-east-1"
  description = "The region to provision AWS resources in."
}
variable "common_name" {
  description = "The common environment name to use for most resources."
  default = "datadog-demo"
}
variable "aws_vpc_cidr_block" {
  description = "The CIDR block to use for the AWS VPC."
  default = "10.0.0.0/16"
}
variable "aws_vpc_cidr_public_subnets" {
  description = "The public subnet CIDR blocks"
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}
variable "aws_instance_type" {
  default = "t2.nano"
  description = "The AWS instance type to launch."
}
variable "aws_ec2_public_key" {
  default = "~/.ssh/id_rsa.pub"
  description = "Public SSH key to load onto the monitor host."
}
