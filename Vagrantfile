# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"

  config.vm.provision "shell", path: "scripts/provision.sh", privileged: false

  config.vm.provider :virtualbox do |vb|
    vb.memory = 2048
    vb.cpus = 4
    vb.customize ['modifyvm', :id, '--usb', 'on']
    vb.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'sdcard-reader', '--vendorid', '0x1307']
  end
end
