#!/bin/bash -xe

echo 'Add ssh key to pull puppet code'
mkdir /root/.ssh && chmod 700 /root/.ssh
cp /root/git_id_rsa /root/.ssh/id_rsa
chmod 400 /root/.ssh/id_rsa

# "Add Git server to known_hosts"
echo "Add Git server to known_hosts"
ssh-keyscan -H git.example.com >> /root/.ssh/known_hosts

# Empty Puppet directory (to be populated with Git code)
rm -rf /etc/puppetlabs/code/environments/production/* &&

# Clone code
git clone git@git.example.com:devops/puppet.git /etc/puppetlabs/code/environments/production/

# Create api user
# curl -H "Content-Type: application/json" \
#   --cert   $CERT \
#   --key    $KEY \
#   --cacert $CACERT \
#   https://${CERTNAME}:4433/rbac-api/v1/users \
#   -X POST -d @/vagrant/create-user.json &&

# Authenticate with the created user
#TOKEN=$(curl -sk -X POST -H 'Content-Type: application/json' -d '{"login": "api_caller", "password": "puppet"}' https://${CERTNAME}:4433/rbac-api/v1/auth/token | python -c 'import sys, json; print json.load(sys.stdin)["token"]')

CERT=$(/usr/local/bin/puppet config print hostcert)
KEY=$(/usr/local/bin/puppet config print hostprivkey)
CACERT=$(/usr/local/bin/puppet config print localcacert)
CERTNAME=$(/usr/local/bin/puppet config print certname)

# Refresh classes
curl -H "Content-Type: application/json" \
  --cert   $CERT \
  --key    $KEY \
  --cacert $CACERT \
  https://${CERTNAME}:4433/classifier-api/v1/update-classes \
  -X POST &&

# Create classification
for group in `python -c 'from __future__ import print_function; import sys,json; [ print(json.dumps(x).replace(" ","")) for x in json.load(open("./classification.json")) ]'`
do
	curl -H "Content-Type: application/json"  \
	 --cert   $CERT  \
	 --key    $KEY  \
	 --cacert $CACERT \
	 https://${CERTNAME}:4433/classifier-api/v1/groups \
	 -X POST -d "${group}"
done

# Get Puppet Hiera group ID
PUPPET_HIERA_ID=$(curl -H "Content-Type: application/json" \
  --cert   $CERT \
  --key    $KEY \
  --cacert $CACERT \
  https://${CERTNAME}:4433/classifier-api/v1/groups |  python -c 'from __future__ import print_function; import sys, json;  print( [ x["id"] for x in json.load(sys.stdin) if ("name" in x and x["name"] == "puppet_hiera" ) ][0] )') &&

# Pin puppetmaster to puppet_hiera group
curl -H "Content-Type: application/json" \
  --cert   $CERT \
  --key    $KEY \
  --cacert $CACERT \
  -d '{"nodes": ["puppet.example.com"]}' \
  https://${CERTNAME}:4433/classifier-api/v1/groups/${PUPPET_HIERA_ID}/pin

# Run puppet agent
/usr/local/bin/puppet agent -t || true