#!/bin/bash

UBUNTU_VERSION="xenial"
IMAGEPATH="/var/chroot/"
IMAGENAME=${UBUNTU_VERSION}_intergration.img
MASTERMOUNTPOINT=/tmp/ppa_testing/master
SNAPSHOTMOUNTPOINT_CLEAR=/tmp/ppa_testing/clean
SNAPSHOTMOUNTPOINT_STOCK=/tmp/ppa_testing/stock_to_ppa
SNAPSHOTNAME=snapshot_$(date  '+%d.%m.%y')

# Unmount a jail
function unmountjail() {
    CHROOT_PATH=`pwd`
    if [ "$1" != "" ]; then
        CHROOT_PATH=$1
    fi
    echo Unmounting jail on $CHROOT_PATH
    umount -l $CHROOT_PATH/dev
    umount -l $CHROOT_PATH/dev/pts
    umount -l $CHROOT_PATH/sys
    umount -l $CHROOT_PATH/proc
    umount -l $CHROOT_PATH/var/cache/apt/archives/
}

# Mount the special APT packet cache to avoid redundant downloads
function mountcache() {
    MOUNT_PATH=$1
    CACHE_PATH=$IMAGEPATH/cache_${IMAGENAME}
    #If the cache doesn't exist, create it
    if [ ! -f $CACHE_PATH ]; then
        echo "Creating a package cache, this may take a while"
        dd if=/dev/zero of=$CACHE_PATH bs=1M count=3000
        mkfs.btrfs $CACHE_PATH
    fi

    # Mount the cache
    mount -o loop $CACHE_PATH $MOUNT_PATH

    # Check if the cache is full, clear it
    PERCENT_USE=`df  / | egrep "([0-9.]+)%" -o | egrep "([0-9.]+)" -o`
    if [ $PERCENT_USE -gt 75  ]; then
        echo The cache is full, forcing a cleanup
        rm $MOUNT_PATH/*.deb
    fi
}

# Mount a chroot jail in the current PWD or $1
function mountjail() {
    CHROOT_PATH=`pwd`
    if [ "$1" != "" ]; then
        CHROOT_PATH=$1
    fi
    unmountjail $CHROOT_PATH
    echo Mounting jail on $CHROOT_PATH
    mount -o bind /dev $CHROOT_PATH/dev
    mount -o bind /dev/pts $CHROOT_PATH/dev/pts
    mount -o bind /sys $CHROOT_PATH/sys
    mount -o bind /proc $CHROOT_PATH/proc
    mountcache $CHROOT_PATH/var/cache/apt/archives/
}

function clearmountpoints() {
    # Close the jails
    unmountjail $SNAPSHOTMOUNTPOINT_CLEAR
    unmountjail $SNAPSHOTMOUNTPOINT_STOCK

    # Delete the snapshot
    umount -l $SNAPSHOTMOUNTPOINT_CLEAR
    umount -l $SNAPSHOTMOUNTPOINT_STOCK
    btrfs subvolume delete ./${SNAPSHOTNAME}_clear
    btrfs subvolume delete ./${SNAPSHOTNAME}_stock

    # Unmount the master
    umount -l $MASTERMOUNTPOINT
}

# Check the dependencies
if  ! command -v debootstrap ; then
    echo Please install debootstrap
    exit 1
fi
if  ! command -v btrfs ; then
    echo Please install btrfs-tools
    exit 1
fi

# Enable echo mode
# set -x

# Check the script can be executed
if [ "$(whoami)" != "root" ]; then
    echo This script need to be executed as root
    exit 1
fi

# Make sure the mount points exist
mkdir $MASTERMOUNTPOINT $SNAPSHOTMOUNTPOINT_CLEAR $SNAPSHOTMOUNTPOINT_STOCK $IMAGEPATH -p

cd $IMAGEPATH

# Create the container image if it doesn't already exist
if [ ! -f $IMAGENAME ]; then
    echo "Creating a disk image (use space now), this make take a while"
    dd if=/dev/zero of=$IMAGEPATH/$IMAGENAME bs=1M count=8000
    mkfs.btrfs $IMAGENAME
fi

echo MOUNT: $MASTERMOUNTPOINT $IMAGEPATH/$IMAGENAME
# Mount the image master snapshot
clearmountpoints
mount -o loop $IMAGEPATH/$IMAGENAME $MASTERMOUNTPOINT
cd $MASTERMOUNTPOINT

# Create the chroot if empty
if [ "$(ls)" == "" ]; then
    debootstrap --variant=buildd --arch amd64 $UBUNTU_VERSION ./ http://ftp.ussg.iu.edu/linux/ubuntu/ #http://archive.ubuntu.com/ubuntu

    # We need universe packages
    sed -i 's/main/main universe restricted multiverse/' ./etc/apt/sources.list
fi


# Apply updates
mountjail
chroot ./ apt-get update --allow-insecure-repositories
chroot ./ apt-get upgrade -y
unmountjail

# Create
btrfs subvolume snapshot . ./${SNAPSHOTNAME}_clear
btrfs subvolume snapshot . ./${SNAPSHOTNAME}_stock

# Mount the subvolume
mount -t btrfs -o loop,subvol=${SNAPSHOTNAME}_clear $IMAGEPATH/$IMAGENAME $SNAPSHOTMOUNTPOINT_CLEAR
mount -t btrfs -o loop,subvol=${SNAPSHOTNAME}_stock $IMAGEPATH/$IMAGENAME $SNAPSHOTMOUNTPOINT_STOCK



###################################################
#                  Begin testing                  #
###################################################

mountjail $SNAPSHOTMOUNTPOINT_CLEAR
mountjail $SNAPSHOTMOUNTPOINT_STOCK

# Add the PPA to the clear/vanilla snapshot
echo deb http://lvindustries.net:8080/ netrunner/ \
    >> $SNAPSHOTMOUNTPOINT_CLEAR/etc/apt/sources.list

chroot $SNAPSHOTMOUNTPOINT_CLEAR apt-get update --allow-insecure-repositories

chroot $SNAPSHOTMOUNTPOINT_CLEAR bash -c 'DEBIAN_FRONTEND=noninteractive \
    apt-get install -y maui-apt-config base-files --allow-unauthenticated'

chroot $SNAPSHOTMOUNTPOINT_CLEAR apt-get update --allow-insecure-repositories

chroot $SNAPSHOTMOUNTPOINT_CLEAR apt-get upgrade -y --allow-unauthenticated


chroot $SNAPSHOTMOUNTPOINT_CLEAR bash -c 'DEBIAN_FRONTEND=noninteractive \
    apt-get install ring-kde -y --force-yes --allow-unauthenticated'
RET=$?
if [ "$RET" != "0" ]; then
    echo "\n\n\nInstall PPA to vanilla Ubuntu completed with $RET"
    clearmountpoints
    exit $RET
fi


clearmountpoints
