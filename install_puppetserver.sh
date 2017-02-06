#!/bin/bash -xe

# Ensure pip is installed
if ! which pip; then
	curl "https://bootstrap.pypa.io/get-pip.py" -o "get-pip.py"
	python get-pip.py
fi

# Upgrade pip 
/bin/pip install --upgrade pip

# Upgrade awscli tools (They are installed in the AMI)
/bin/pip install --upgrade awscli

# Get hostname from AWS Name Tag (requires the EC2 instance to have an IAM role that allows DescribeTags)
AWS_INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | grep region | cut -d\" -f4)
AWSHOSTNAME=$(aws ec2 describe-tags --region ${AWS_REGION} --filters "Name=resource-id,Values=${AWS_INSTANCE_ID}" --query "Tags[?Key=='Name'].Value[] | [0]" | cut -d\" -f2)

# Set hostname
hostnamectl set-hostname ${AWSHOSTNAME}.cpg.org

# Update system and install wget, git
yum update -y
yum install wget git -y

# Set puppet.cpg.org as hostname in hosts file
echo "$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4) puppet puppet.cpg.org" >> /etc/hosts

# Download puppet 
wget "https://pm.puppetlabs.com/cgi-bin/download.cgi?dist=el&rel=7&arch=x86_64&ver=2016.4.0" -O puppet.2016.4.0.tar.gz
tar -xvzf puppet.2016.4.0.tar.gz
cd puppet-enterprise*

# Create pe.conf file
touch pe.conf
echo '{' >> pe.conf
echo '"console_admin_password": "puppet"' >> pe.conf
echo '"puppet_enterprise::puppet_master_host": "%{::trusted.certname}"' >> pe.conf
echo '}'  >> pe.conf

echo "Install Puppetserver"
./puppet-enterprise-installer -c pe.conf

echo "Adding * to autosign.conf"
cat >> /etc/puppetlabs/puppet/autosign.conf <<'AUTOSIGN'
*
AUTOSIGN

# Run puppet agent
/usr/local/bin/puppet agent -t
