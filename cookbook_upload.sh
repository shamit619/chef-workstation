#!/bin/bash
cookbookname=$1
#echo $cookbookname > /home/ec2-user/akhil.txt
#echo $cookbookname
rm -rf IAC-terraform-scripts
git clone https://github.com/shamit619/IAC-terraform-scripts.git


cp -R IAC-terraform-scripts/chef-cookbooks /mnt/recovery/root/
cd /mnt/recovery/root/chef-cookbooks
terraform init
export TF_LOG="TRACE"
export TF_LOG_PATH="terraform.txt"
sed -e "s#cookbookname#$cookbookname#" general_terraform.tfvars > terraform.tfvars
terraform apply -auto-approve

