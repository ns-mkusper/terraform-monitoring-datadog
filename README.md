# Terraform Monitoring Datadog module
_Build and deploy Monitoring Host (Datadog) with Terraform and Ansible_

This repo contains code to deploy a monitoring host running Datadog and nginx deployed by Terraform and Ansible.

## Prerequisites

Valid `profile` must exist in `~/.aws/config` and must be useable by aws-vault. Working versions of `ansible`, `terraform`, `terrform-inventory` and `aws-vault` must be installed.

The following environment variables must be set as well:

VAULT_ADDR
VAULT_TOKEN
VAULT_ROOT_TOKEN

## Usage

`make all`, `make destroy`, etc.
