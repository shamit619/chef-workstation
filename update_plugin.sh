#!/bin/bash
rm -rf IAC-terraform-scripts
git clone https://github.com/shamit619/IAC-terraform-scripts.git


cp -R IAC-terraform-scripts/chef-update-jenkins-plugins /mnt/recovery/root/
cd /mnt/recovery/root/chef-update-jenkins-plugins
terraform init
export TF_LOG="TRACE"
export TF_LOG_PATH="terraform.txt"

terraform apply -auto-approve
