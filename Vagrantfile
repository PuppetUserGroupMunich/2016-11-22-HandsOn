# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-vbguest landrush )

required_plugins.each do |plugin|
  raise "Please install vagrant plugin: #{plugin}" unless Vagrant.has_plugin? plugin
end

Vagrant.configure("2") do |config|

  if Vagrant.has_plugin?("vagrant-vbguest")
    # config.vbguest.auto_update = false
    config.vbguest.auto_update = true
  end

  if Vagrant.has_plugin?("landrush")
    config.landrush.enabled = true
    config.landrush.tld = 'vagrant'
    config.landrush.upstream '8.8.8.8'
    config.landrush.guest_redirect_dns = false
  end

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 8080, host: 80, auto_correct: true

  config.vm.synced_folder ".", "/vagrant", type: "virtualbox"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  config.vm.define "puppet" do |puppet|
    puppet.vm.box = "centos/7"
    puppet.vm.hostname = "puppet.vagrant"
    puppet.vm.provider "virtualbox" do |vb|
      vb.memory = "4096"
    end

    puppet.vm.provision "docker",
      images: [
        "puppet/puppetserver",
        "puppet/puppetdb-postgres",
        "puppet/puppetdb",
        "puppet/puppetboard",
        "puppet/puppetexplorer",
        "puppet/puppet-agent-alpine",
        "puppet/puppet-agent-ubuntu"
    ]

    puppet.vm.provision "shell", inline: <<-SHELL
    curl -L "https://github.com/docker/compose/releases/download/1.8.1/docker-compose-$(uname -s)-$(uname -m)" > /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    SHELL

    puppet.vm.provision "shell", inline: <<-SHELL
    yum update -y
    yum install -y git vim tree
    sed -i '/^search/d' /etc/resolv.conf
    SHELL

  end

  # config.vm.box = "ubuntu/xenial64"
  # config.vm.box = "centos/7"
  # config.vm.box = "centos/6"

  config.vm.define "client-centos", autostart: false do |centos|
    centos.vm.box = "centos/7"
    centos.vm.hostname = "client-centos.vagrant"
    centos.vm.provider "virtualbox" do |vb|
      vb.memory = "1024"
    end

    centos.vm.provision "shell", inline: <<-SHELL
    rpm -Uhv https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm
    yum update -y
    yum install -y git vim tree puppet-agent
    sed -i '/^search/d' /etc/resolv.conf
    SHELL

  end

end
