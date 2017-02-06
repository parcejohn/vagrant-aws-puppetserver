# -*- mode: ruby -*-
# vi: set ft=ruby :

# Specify minimum Vagrant version and Vagrant API version
Vagrant.require_version ">= 1.6.0"
VAGRANTFILE_API_VERSION = "2"

# Require YAML module
require 'yaml'

# Read YAML file with box details
servers = YAML.load_file('servers.yaml')

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

    # Iterate through entries in YAML file
    servers.each do |server|
    
        config.vm.define server['name'] do |srv|

            srv.vm.box = server['box']
            srv.vm.box_url = server['box_url']

            srv.vm.provider :aws do |aws, override|

                ### Dont do these here, better to use awscli with a profile
                #aws.access_key_id = "YOUR KEY"
                #aws.secret_access_key = "YOUR SECRET KEY"
                #aws.session_token = "SESSION TOKEN"

                aws.region = server["aws_region"] if server["aws_region"]
                aws.keypair_name = server["aws_keypair_name"] if server["aws_keypair_name"]
                aws.subnet_id = server["aws_subnet_id"] if server["aws_subnet_id"]
                aws.associate_public_ip = server["aws_associate_public_ip"] if server["aws_associate_public_ip"]
                aws.security_groups = server["aws_security_groups"] if server["aws_security_groups"]
                aws.iam_instance_profile_name = server['aws_iam_role'] if server['aws_iam_role']
                aws.ami = server["aws_ami"] if server["aws_ami"]
                aws.instance_type = server["aws_instance_type"] if server["aws_instance_type"]
                aws.tags = server["aws_tags"] if server["aws_tags"]
                aws.user_data = server["aws_user_data"] if server["aws_user_data"]

                override.ssh.username = server["aws_ssh_username"] if server["aws_ssh_username"]
                override.ssh.private_key_path = server["aws_ssh_private_key_path"] if server["aws_ssh_private_key_path"]           

                config.vm.synced_folder ".", "/vagrant", type: "rsync"

                config.vm.provision :shell, path: server["provision"] if server["provision"]

            end  
        end
    end
end