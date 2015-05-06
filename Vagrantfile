# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.define :client1 do | client1 |
    client1.vm.hostname = "client1"
    client1.vm.box      = "CentOS65"
    client1.vm.box_url  = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"
    client1.vm.network :private_network, ip: "192.168.33.21"
    client1.vm.provider "virtualbox" do | v |
      v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    end
    client1.vm.provision :shell, :path => "bootstrap.sh"
  end

  config.vm.define :client2 do | client2 |
    client2.vm.hostname = "client2"
    client2.vm.box      = "CentOS65"
    client2.vm.box_url  = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"
    client2.vm.network :private_network, ip: "192.168.33.22"
    client2.vm.provider "virtualbox" do | v |
      v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    end
    client2.vm.provision :shell, :path => "bootstrap.sh"
  end

  config.vm.define :monitor do | monitor |
    monitor.vm.hostname = "monitor"
    monitor.vm.box      = "CentOS65"
    monitor.vm.box_url  = "https://github.com/2creatives/vagrant-centos/releases/download/v6.5.3/centos65-x86_64-20140116.box"
    monitor.vm.network :private_network, ip: "192.168.33.20"
    monitor.vm.provider "virtualbox" do | v |
      v.customize ["modifyvm", :id, "--memory", "1024"]
      v.customize ["modifyvm", :id, "--natdnsproxy1", "off"]
      v.customize ["modifyvm", :id, "--natdnshostresolver1", "off"]
    end
    monitor.vm.provision :shell, :path => "bootstrap.sh"
  end
end
