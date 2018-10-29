#
# Require version of terraform
# https://www.terraform.io/docs/configuration/terraform.html
#
terraform {
  required_version = ">= 0.11.2"
}
#
# Monitor host secrets stored in vault 
#
data "vault_generic_secret" "dd-secrets"{
 path = "secret/dd-demo"
}
#
# DD Provider: https://www.terraform.io/docs/providers/datadog/index.html
#
provider "datadog" {
  # Define DATADOG_API_KEY and DATADOG_APP_KEY in environment variables
  api_key = "${data.vault_generic_secret.dd-secrets.data["api-key"]}"
  app_key = "${data.vault_generic_secret.dd-secrets.data["app-key"]}"
}
#
# AWS Provider: https://www.terraform.io/docs/providers/aws/index.html
#
provider "aws" {
  region = "${var.aws_region}"
  # Define Auth via Environment, Shared Creds file, etc as documented in
  # https://www.terraform.io/docs/providers/aws/index.html#environment-variables
}
#
# Get the availability zones for our given region
# https://www.terraform.io/docs/providers/aws/d/availability_zones.html
#
data "aws_availability_zones" "available" {}

# #
# #  Setup the Consul provisioner to use the demo cluster 
# #
# provider "consul" {
#   # Define CONSUL_HTTP_ADDR in environment variables  
#   datacenter = "${var.aws_regoin}"
# }
#
#  Setup the vault provisioner to use the demo cluster 
#
provider "vault" {
  # Define VAULT_ADDR in environment variables  
}
provider "ansible" {
  # Define VAULT_ADDR in environment variables  
}


