#!/bin/bash
count=$1
node_name=$2
rm -rf IAC-terraform-scripts
git clone https://github.com/shamit619/IAC-terraform-scripts.git


cp -R IAC-terraform-scripts/chef-node-create /mnt/recovery/root/
cd /mnt/recovery/root/chef-node-create
Chef_Node_Count=$(knife node list | wc -l)
node_count=$(( $Chef_Node_Count + $count ))
echo $node_count
chef_private_ip=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=chef server" | grep "PrivateDnsName" | sed -n "1p" | awk -F':' '{print $2}' | tr -d ['",'] | tr -d [:space:])
chmod 755 /mnt/recovery/root/chef-node-create/chef-node.sh
terraform init
export TF_LOG="TRACE"
export TF_LOG_PATH="terraform.txt"
sed -e "s#chefip#$chef_private_ip#" -e "s#nodecount#$node_count#" -e "s#nodename#$node_name#" general_terraform.tfvars > terraform.tfvars

terraform apply -auto-approve
