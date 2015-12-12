#!/bin/bash -e

sudo apt-get update
sudo apt-get install -y \
    qemu \
    qemu-user-static \
    binfmt-support \
    debootstrap \
    debian-ports-archive-keyring \
    --no-install-recommends

sudo /vagrant/build.sh
cp rootfs.tar.gz /vagrant/rootfs.tar.gz
