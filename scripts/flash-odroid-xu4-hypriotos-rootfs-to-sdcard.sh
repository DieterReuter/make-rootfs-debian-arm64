#!/bin/bash -e
# details see: http://archlinuxarm.org/platforms/armv7/samsung/odroid-xu4

set -x
# This script only works on Linux
if [ "$(uname -s)" != "Linux" ]; then
  echo "ERROR: scripts works on Linux only, not on $(uname -s)!"
  exit 1
fi

# Redefine sudo command, when not available
if [ "$(whoami)" == "root" ]; then
  SUDO_CMD=""
else
  SUDO_CMD="sudo"
fi

# Define variables
BUILD_ARCH="${BUILD_ARCH:-armhf}"
ROOTFS_TARGZ="rootfs-${BUILD_ARCH}.tar.gz"
ROOTFS2_TARGZ="odroid-xu4-kernel.tar.gz"
SDCARD_DEVICE=/dev/sdc
SDCARD_DEVICE_NR="${SDCARD_DEVICE}1"
SDCARD_LABEL="HypriotOS/${BUILD_ARCH}"
SDCARD_MOUNT=/tmp/sdcard
ROOTFS_DIR="${SDCARD_MOUNT}"

# Create new mount point for SD card
# - unmount an already mounted disk
# - remove mount point
# - create new mount point
${SUDO_CMD} umount "${SDCARD_MOUNT}" || /bin/true
${SUDO_CMD} rm -fr "${SDCARD_MOUNT}"
${SUDO_CMD} mkdir -p "${SDCARD_MOUNT}"

# Display SD card stats
${SUDO_CMD} fdisk -l "${SDCARD_DEVICE}"

# Re-format the SD card
echo "Re-format SD card at ${SDCARD_DEVICE}"
cat << EOM | ${SUDO_CMD} fdisk "${SDCARD_DEVICE}"
d
w
EOM

# Display SD card stats
${SUDO_CMD} fdisk -l "${SDCARD_DEVICE}"

# Create new partition an SD card (use full disk size)
cat << EOM | ${SUDO_CMD} fdisk "${SDCARD_DEVICE}"
n
p
1


w
EOM

# Display SD card stats
${SUDO_CMD} fdisk -l "${SDCARD_DEVICE}"

# Format SD card as ext4
# - use -F to force ignoring questions like this
#   mke2fs 1.42.9 (4-Feb-2014)
#   /dev/sdc is entire device, not just one partition!
#   Proceed anyway? (y,n)
${SUDO_CMD} mkfs.ext4 -F "${SDCARD_DEVICE_NR}" -L "${SDCARD_LABEL}"

# Display SD card stats
${SUDO_CMD} fdisk -l "${SDCARD_DEVICE}"

# Mount the newly created SD card
echo "Mount empty SD card:"
${SUDO_CMD} mount "${SDCARD_DEVICE_NR}" "${SDCARD_MOUNT}"
df -h "${SDCARD_DEVICE_NR}"

# Copy rootfs to SD card
echo "Copy rootfs to SD card:"
${SUDO_CMD} tar -xzf "${ROOTFS_TARGZ}" -C "${SDCARD_MOUNT}"
${SUDO_CMD} tar -xzf "${ROOTFS2_TARGZ}" -C "${SDCARD_MOUNT}"
df -h "${SDCARD_DEVICE_NR}"

# Flash the bootloader files
pushd "${SDCARD_MOUNT}/boot"
${SUDO_CMD} sh sd_fusing.sh "${SDCARD_DEVICE}"
popd

# Unmount the finished SD card
${SUDO_CMD} umount "${SDCARD_MOUNT}"

echo "Status:"
echo "  Finished. RootFS ${ROOTFS_TARGZ} successfully flashed to SD card!"
