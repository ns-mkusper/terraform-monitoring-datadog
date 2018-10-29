#############################################################################
# Variables
# https://www.terraform.io/docs/configuration/variables.html
#############################################################################
variable "aws_region" {
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
variable "aws_public_key_material" {
  description = "The public SSH key material to load onto the instances."
}
# For example purposes
variable "monitor_suffix" {
  default = "Kelner Example from Terraform"
  description = "A suffic that gets applied to end of monitor names"
}
