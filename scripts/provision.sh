#!/bin/bash -e

# Install build dependencies
sudo apt-get update
sudo apt-get install -y \
    qemu \
    qemu-user-static \
    binfmt-support \
    debootstrap \
    debian-ports-archive-keyring \
    --no-install-recommends

# Build for armhf (32-bit ARMv6, ARMv7)
sudo BUILD_ARCH=armhf /vagrant/build.sh
cp rootfs-armhf.tar.gz /vagrant/rootfs-armhf.tar.gz

# Build for arm64 (64-bit ARMv8, Aarch64)
sudo BUILD_ARCH=arm64 /vagrant/build.sh
cp rootfs-arm64.tar.gz /vagrant/rootfs-arm64.tar.gz
