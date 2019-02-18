#!/bin/bash -xev
chef_ip=$1
node_name=$2
# Do some chef pre-work
/bin/mkdir -p /etc/chef
/bin/mkdir -p /var/lib/chef
/bin/mkdir -p /var/log/chef

# Setup hosts file correctly
cat > "/etc/hosts" << EOF
10.0.0.5    compliance-server compliance-server.automate.com
10.0.0.6    chef-server chef-server.automate.com
10.0.0.7    automate-server automate-server.automate.com
EOF

cd /etc/chef/

# Install chef
curl -L https://omnitruck.chef.io/install.sh | bash || error_exit 'could not install chef'

#NODE_NAME=node-$(cat /dev/urandom | tr -dc 'a-zA-Z0-9' | fold -w 4 | head -n 1)
NODE_NAME=node-$(shuf -i 1-100 -n 1)-$node_name
#NODE_NAME="demo"
sudo aws s3 cp s3://shamit619/infosys.pem --region "ap-south-1" .
mv infosys.pem infosys-validator.pem

# Create client.rb
/bin/echo 'log_location     STDOUT' >> /etc/chef/client.rb
/bin/echo -e "chef_server_url  \"https://$chef_ip/organizations/infosys\"" >> /etc/chef/client.rb
/bin/echo -e "validation_client_name \"infosys-validator\"" >> /etc/chef/client.rb
/bin/echo -e "validation_key \"/etc/chef/infosys-validator.pem\"" >> /etc/chef/client.rb
/bin/echo -e "node_name  \"${NODE_NAME}\"" >> /etc/chef/client.rb

# Create knife.rb
/bin/echo 'current_dir = File.dirname(__FILE__)' >> /etc/chef/knife.rb
/bin/echo -e "log_level                \":info\"" >> /etc/chef/knife.rb
/bin/echo -e "log_location             \"STDOUT\"" >> /etc/chef/knife.rb
/bin/echo -e "node_name                \"admin\"" >> /etc/chef/knife.rb
/bin/echo -e "client_key               \"#{current_dir}/admin.pem\"" >> /etc/chef/knife.rb
/bin/echo -e "chef_server_url          \"https://$chef_ip/organizations/infosys\"" >> /etc/chef/knife.rb
#cookbook_path            ["#{current_dir}/../cookbooks

knife ssl fetch
knife ssl check
sudo chef-client
