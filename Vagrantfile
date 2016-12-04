# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  config.vm.box = 'ubuntu/trusty64'
  config.vm.box_check_update = false

  config.vm.network :private_network, ip: '192.168.20.21'
  # config.vm.network "public_network"

  config.vm.network 'forwarded_port', guest: 2990, host: 2990

  config.vm.synced_folder '.', '/vagrant', type: 'nfs'

  config.vm.provider 'virtualbox' do |vb|
    vb.customize ["modifyvm", :id, "--memory", 4096]
    vb.customize ["modifyvm", :id, "--cpus", 2]
    # vb.gui = true
  end

  # config.vm.provision :shell, path: 'dev/bootstrap.sh', keep_color: true
end
