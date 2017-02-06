# vagrant-aws-puppetserver

This Vagrant project allows you to spin up a AWS EC2 instance and provision a puppetserver using Vagrant provisioning scripts

# Pre-requisites:
* Vagrant

* vagrant-aws plug-in 

## AWS pre-requisites:
While you can add your AWS credentials to the Vagrantfile, it is not recommended. A better way is to have the AWS CLI tools installed and configured
```
$ aws configure
AWS Access Key ID [****************XYYY]: XXXXXXXXYYY
AWS Secret Access Key [****************ZOOO]:ZZZZZZZOOO
Default region name [us-east-1]:us-east-1
Default output format [None]: json
```

# Usage
Clone this repository
Add your specific data to servers.yaml
finally...
```
$ vagrant up
```
