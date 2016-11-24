# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'

config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))


ucpip=config['environment']['ucpip']
ucpuser=config['environment']['ucpuser']
ucppasswd=config['environment']['ucppasswd']
ucpurl=config['environment']['ucpurl']
dtrurl=config['environment']['dtrurl']
ucpfqdn=config['environment']['ucpfqdn']
dtrfqdn=config['environment']['dtrfqdn']


boxes = config['boxes']



Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.synced_folder "tmp_deploying_stage/", "/tmp_deploying_stage",create:true
  config.vm.synced_folder "licenses/", "/licenses",create:true


  boxes.each do |node|
    config.vm.define node['name'] do |config|
      config.vm.hostname = node['name']
      config.vm.provider "virtualbox" do |v|
        v.name = node['name']
        v.customize ["modifyvm", :id, "--memory", node['mem']]
        v.customize ["modifyvm", :id, "--cpus", node['cpu']]
        if node['ucprole'] == "client"
         v.gui = true
       end
      end

      # config.vm.network "public_network",
      # bridge: "wlan0" ,
      # use_dhcp_assigned_default_route: true

      config.vm.network "private_network",
      ip: node['managementip'],
      virtualbox__intnet: "DOCKER_PUBLIC"

      config.vm.network "private_network",
      ip: node['storageip'],
      virtualbox__intnet: "DOCKER_STORAGE"


      if node['ucprole'] == "master"
        puts '--------------------------------'
        puts 'UCPFQDN: ['+ucpfqdn+']'
        puts 'UCPIP: ['+ucpip+']'
        puts 'UCPUSER: ['+ucpuser+']'
        puts 'UCPPASSWD: ['+ucppasswd+']'
        puts '--------------------------------'

    	  config.vm.network "forwarded_port", guest: 8443, host: 8443, auto_correct: true
        ucpcontrollerip=node['managementip']
      end

      config.vm.network "forwarded_port", guest: 6080, host: 6080, auto_correct: true
      config.vm.network "forwarded_port", guest: 7080, host: 7080, auto_correct: true
      config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true

      config.vm.provision "shell", inline: <<-SHELL
        sudo apt-get update -qq && apt-get install -qq chrony && timedatectl set-timezone Europe/Madrid
      SHELL

      ## INSTALL DOCKER ENGINE
      config.vm.provision "shell", inline: <<-SHELL
        sudo apt-get install -qq curl
        curl -s 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | sudo apt-key add --import
        sudo apt-get update -qq && sudo apt-get -qq install apt-transport-https
        sudo apt-get install -qq linux-image-extra-virtual
        echo "deb https://packages.docker.com/1.12/apt/repo ubuntu-trusty main" | sudo tee /etc/apt/sources.list.d/docker.list
        sudo apt-get update -qq && sudo apt-get install -qq docker-engine
	      echo "DOCKER_OPTS='-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock'" >> /etc/default/docker
	      sudo service docker restart
        sudo usermod -aG docker vagrant
      SHELL

      ## ADD HOSTS
      config.vm.provision "shell", inline: <<-SHELL
        echo "10.0.100.10 ucp ucp.dockerlab.local" >>/etc/hosts
        echo "10.0.100.13 dtr dtr.dockerlab.local" >>/etc/hosts
        echo "10.0.100.10 ucp-manager ucp-manager.dockerlab.local" >>/etc/hosts
        echo "10.0.100.11 ucp-replica1 ucp-replica1.dockerlab.local" >>/etc/hosts
        echo "10.0.100.12 ucp-replica2 ucp-replica2.dockerlab.local" >>/etc/hosts
        echo "10.0.100.13 ucp-node1 ucp-node1.dockerlab.local" >>/etc/hosts
        echo "10.0.100.14 ucp-node2 ucp-node2.dockerlab.local" >>/etc/hosts
      SHELL


      puts '--------------------------------'
      puts 'NODENAME: ['+node['name']+']'
      puts 'UCPROLE: ['+node['ucprole']+']'
      puts 'NODEIP: ['+node['managementip']+']'
      puts 'FQDN: ['+node['fqdn']+']'
      puts '--------------------------------'


      config.vm.provision :shell,
                          :path => 'ucp_install.sh',
                          :args => [
                            node['name'],
                            node['ucprole'],
                            node['managementip'],
                            node['fqdn'],
                            ucpfqdn,
                            ucpip,
                            ucpuser,
                            ucppasswd,
                            ucpurl
                          ]

      if node['dtr'] == true
        config.vm.network "forwarded_port", guest: 7443, host: 7443, auto_correct: true
        config.vm.provision :shell,
                            :path => 'dtr_install.sh',
                            :args => [
                              node['name'],
                              ucpip,
                              ucpuser,
                              ucppasswd,
                              ucpurl,
                              dtrurl
                            ]
      end

    end
  end
end
