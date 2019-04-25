[![Codacy Badge](https://api.codacy.com/project/badge/Grade/0f6953cf7f1d462d9d0b7f7fc9b25dcc)](https://www.codacy.com/app/ns-mkusper/terraform-monitoring-datadog?utm_source=github.com&amp;utm_medium=referral&amp;utm_content=ns-mkusper/terraform-monitoring-datadog&amp;utm_campaign=Badge_Grade)

# Terraform Monitoring Datadog module
_Build and deploy Monitoring Host (Datadog) with Terraform and Ansible_

This repo contains code to deploy a monitoring host running Datadog and nginx deployed by Terraform and Ansible.

## Prerequisites

Valid `profile` must exist in `~/.aws/config` and must be useable by aws-vault. Working versions of `ansible`, `terraform`, `terrform-inventory` and `aws-vault` must be installed.

The following environment variables must be set as well:

VAULT_ADDR
VAULT_TOKEN

## Usage

`make all`, `make destroy`, etc.
