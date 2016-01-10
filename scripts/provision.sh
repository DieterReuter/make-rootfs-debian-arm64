#!/bin/bash -e

# Install build dependencies
sudo apt-get update
sudo apt-get install -y \
    binfmt-support \
    debootstrap \
    debian-ports-archive-keyring \
    qemu \
    qemu-user-static \
    pv \
    --no-install-recommends

# Install Hypriot flash script
sudo wget -O /usr/local/bin/flash https://github.com/hypriot/flash/raw/master/Linux/flash
sudo chmod +x /usr/local/bin/flash

# Build for armhf (32-bit ARMv6, ARMv7)
sudo BUILD_ARCH=armhf /vagrant/build.sh
cp rootfs-armhf.tar.gz /vagrant/rootfs-armhf.tar.gz

# Build for arm64 (64-bit ARMv8, Aarch64)
sudo BUILD_ARCH=arm64 /vagrant/build.sh
cp rootfs-arm64.tar.gz /vagrant/rootfs-arm64.tar.gz
