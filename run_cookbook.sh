#!/bin/bash
recipename=$1
servername=$2
rm -rf IAC-terraform-scripts
git clone https://github.com/shamit619/IAC-terraform-scripts.git


cp -R IAC-terraform-scripts/chef-add-run-list /mnt/recovery/root/
export TF_LOG="TRACE"
export TF_LOG_PATH="terraform.txt"
cd /mnt/recovery/root/chef-add-run-list
sed -e "s#recipename#$recipename#" -e "s#servername#$servername#" general_terraform.tfvars > terraform.tfvars
terraform apply -auto-approve
