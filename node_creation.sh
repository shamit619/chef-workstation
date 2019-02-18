i#!/bin/bash
count=$1
node_name=$2
rm -rf IAC-terraform-scripts
git clone https://github.com/shamit619/IAC-terraform-scripts.git


cp -R IAC-terraform-scripts/chef-node-create /mnt/recovery/root/
cd /mnt/recovery/root/chef-node-create
Chef_Node_Count=$(knife node list | sed '/^\s*$/d' | wc -l)
echo "chef:$Chef_Node_Count" >> /home/ec2-user/node.txt
node_count=$(( $Chef_Node_Count + $count ))
echo $node_count
echo "node:$node_count" >> /home/ec2-user/node.txt
chef_private_ip=$(aws ec2 describe-instances --filter "Name=tag:Name,Values=chef server" | grep "PrivateDnsName" | sed -n "1p" | awk -F':' '{print $2}' | tr -d ['",'] | tr -d [:space:])
echo "chef-ip:$chef_private_ip" >> /home/ec2-user/node.txt
if [ "$Chef_Node_Count" == "0" ];
then
echo "Inside main terraform node creation folder" >> /home/ec2-user/node.txt
cd /mnt/recovery/root/chef-node-create
#chmod 755 /mnt/recovery/root/chef-node-create/chef-node.sh
terraform init
export TF_LOG="TRACE"
export TF_LOG_PATH="terraform.txt"
sed -e "s#chefip#$chef_private_ip#" -e "s#nodecount#$node_count#" -e "s#nodename#$node_name#" general_terraform.tfvars > terraform.tfvars
terraform apply -auto-approve
#terraform plan
else
if [ -s /mnt/recovery/root/chef-node-create/chef-node-reattempt/terraform.tfstate ];
then
echo "Inside subfolder of terraform node creation" >> /home/ec2-user/node.txt
cd /mnt/recovery/root/chef-node-create
sg_id=$(terraform output node-sg-id)
echo $sg_id >> /home/ec2-user/node.txt
cd /mnt/recovery/root/chef-node-create/chef-node-reattempt
#chmod 755 /mnt/recovery/root/chef-node-create/chef-node-reattempt/chef-node.sh
terraform init
export TF_LOG="TRACE"
export TF_LOG_PATH="terraform.txt"
sed -e "s#chefip#$chef_private_ip#" -e "s#nodecount#$node_count#" -e "s#nodename#$node_name#" -e "s#securitygroup#$sg_id#" general_terraform.tfvars > terraform.tfvars
terraform apply -auto-approve
#terraform plan
else
echo "Inside else block of submodule of terraform node creation" >> /home/ec2-user/node.txt
cd /mnt/recovery/root/chef-node-create
sg_id=$(terraform output node-sg-id)
echo $sg_id >> /home/ec2-user/node.txt
cd /mnt/recovery/root/chef-node-create/chef-node-reattempt
#chmod 755 /mnt/recovery/root/chef-node-create/chef-node-reattempt/chef-node.sh
terraform init
export TF_LOG="TRACE"
export TF_LOG_PATH="terraform.txt"
sed -e "s#chefip#$chef_private_ip#" -e "s#nodecount#$Chef_Node_Count#" -e "s#nodename#$node_name#" -e "s#securitygroup#$sg_id#" general_terraform.tfvars > terraform.tfvars
terraform apply -auto-approve
#terraform plan
fi
fi
rm -rf /home/ec2-user/node.txt
