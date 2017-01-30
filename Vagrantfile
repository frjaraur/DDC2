# -*- mode: ruby -*-
# vi: set ft=ruby :

# Require YAML module
require 'yaml'

config = YAML.load_file(File.join(File.dirname(__FILE__), 'config.yml'))

base_box=config['environment']['base_box']

ucpip=config['environment']['ucpip']
dtrip=config['environment']['dtrip']
ucpuser=config['environment']['ucpuser']
ucppasswd=config['environment']['ucppasswd']
ucpurl=config['environment']['ucpurl']
dtrurl=config['environment']['dtrurl']
ucpfqdn=config['environment']['ucpfqdn']
dtrfqdn=config['environment']['dtrfqdn']


boxes = config['boxes']

proxy = config['environment']['proxy']

domain = config['environment']['domain']

boxes_hostsfile_entries=""

boxes.each do |box|
    boxes_hostsfile_entries=boxes_hostsfile_entries + box['managementip'] + ' ' +  box['name'] + ' ' + box['name']+'.'+domain+'\n'
end

boxes_hostsfile_entries=boxes_hostsfile_entries + ucpip + ' ' +  ucpfqdn + '\n'
boxes_hostsfile_entries=boxes_hostsfile_entries + dtrip + ' ' +  dtrfqdn + '\n'


update_hosts = <<SCRIPT
    echo "127.0.0.1 localhost" >/etc/hosts
    echo -e "#{boxes_hostsfile_entries}" |tee -a /etc/hosts
SCRIPT


Vagrant.configure(2) do |config|
  # config.ssh.username = "ubuntu"
  # config.ssh.password = ""
  # config.ssh.insert_key = true
  # config.ssh.forward_agent = true
  #config.ssh.private_key_path = "~/.ssh/id_rsa"
  #config.ssh.forward_agent = true

  if Vagrant.has_plugin?("vagrant-proxyconf")
    if proxy
      config.proxy.http = proxy
      config.proxy.https = proxy
      config.proxy.no_proxy = "localhost,127.0.0.1,"+ucpip+","+ucpfqdn+","+ucpfqdn
    end
  end

  config.vm.box = base_box
  config.vm.synced_folder "tmp_deploying_stage/", "/tmp_deploying_stage",create:true
  config.vm.synced_folder "licenses/", "/licenses",create:true
  config.vm.synced_folder "src/", "/src",create:true



  boxes.each do |node|
    config.vm.define node['name'] do |config|
      config.vm.hostname = node['name']
      config.vm.provider "virtualbox" do |v|
        v.name = node['name']
        v.customize ["modifyvm", :id, "--memory", node['mem']]
        v.customize ["modifyvm", :id, "--cpus", node['cpu']]
        v.customize ["modifyvm", :id, "--nictype1", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype2", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype3", "Am79C973"]
        v.customize ["modifyvm", :id, "--nictype4", "Am79C973"]
        v.customize ["modifyvm", :id, "--nicpromisc1", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc2", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc3", "allow-all"]
        v.customize ["modifyvm", :id, "--nicpromisc4", "allow-all"]
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

      config.vm.network "public_network",
      bridge: ["enp4s0","wlp3s0","enp3s0f1","wlp2s0"],
      auto_config: true

      if node['ucprole'] == "master"
        puts '--------------------------------'
        puts 'UCPFQDN: ['+ucpfqdn+']'
        puts 'UCPIP: ['+ucpip+']'
        puts 'UCPUSER: ['+ucpuser+']'
        puts 'UCPPASSWD: ['+ucppasswd+']'
        puts '--------------------------------'

    	  config.vm.network "forwarded_port", guest: 8443, host: 8443, auto_correct: true
          puts '- HTTP Routing Mesh -----------------------------------'
          puts 'UCP-MANAGER PORT 80 is redirected to 18080 if available'
          puts '-------------------------------------------------------'
    	  config.vm.network "forwarded_port", guest: 80, host: 18080, auto_correct: true
        ucpcontrollerip=node['managementip']
      end


      config.vm.network "forwarded_port", guest: 6080, host: 6080, auto_correct: true
      config.vm.network "forwarded_port", guest: 7080, host: 7080, auto_correct: true
      config.vm.network "forwarded_port", guest: 8080, host: 8080, auto_correct: true
      config.vm.network "forwarded_port", guest: 9080, host: 9080, auto_correct: true

      config.vm.provision "shell", inline: <<-SHELL
        apt-get update -qq && apt-get install -qq --no-install-recommends chrony && timedatectl set-timezone Europe/Madrid
      SHELL

      ## INSTALL DOCKER ENGINE ( we added jq for new tooling )
      config.vm.provision "shell", inline: <<-SHELL
        apt-get install -qq curl jq
        curl -s 'https://sks-keyservers.net/pks/lookup?op=get&search=0xee6d536cf7dc86e2d7d56f59a178ac6c6238f52e' | apt-key add --import
        apt-get update -qq && apt-get -qq install --no-install-recommends apt-transport-https linux-image-extra-virtual
        echo "deb https://packages.docker.com/1.12/apt/repo ubuntu-trusty main" | tee /etc/apt/sources.list.d/docker.list
        apt-get update --force-yes -qq && apt-get install -qq --force-yes --no-install-recommends docker-engine
	    echo "DOCKER_OPTS='-H tcp://0.0.0.0:2375 -H unix:///var/run/docker.sock'" >> /etc/default/docker
	    service docker restart
        usermod -aG docker vagrant
      SHELL

      ## ADD HOSTS
      #
      config.vm.provision :shell, :inline => update_hosts

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
