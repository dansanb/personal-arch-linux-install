#!/bin/bash

########## OPTIONS ##########

# drive to use
INSTALLDRIVE=/dev/vda

# root password
ROOTPASSWORD=root

# user to create automatically
USERNAME=testuser
USERPASSWORD=testuser

# size of EFI partition
EFISIZE=+300M

# size of SWAP partition
SWAPSIZE=+600M

#fcm timezone
TIMEZONE=America/Los_Angeles

# hostname
HOSTNAME=arch

# microcode package install 
# for amd-powered computers: amd-ucode
# for intel-powered computers: intel-ucode
MICROCODE=amd-ucode

########## END OPTIONS ########## 

# update system clock
timedatectl set-ntp true

# wipe partition-table and partitions of install drive
wipefs -a -f ${INSTALLDRIVE}

# create partition table and partitions on install drive. This  creates:
#  /dev/xxx1 => EFI partition
#  /dev/xxx2 => SWAP partition
#  /dev/xxx3 => Linux Root (x86-64) partition
# 
# taken from:
# https://superuser.com/questions/332252/how-to-create-and-format-a-partition-using-a-bash-script
# 
# to create the partitions programatically (rather than manually)
# we're going to simulate the manual input to fdisk
# The sed script strips off all the comments so that we can 
# document what we're doing in-line with the actual commands
# Note that a blank line (commented as "defualt" will send a empty
# line terminated with a newline to take the fdisk default.
sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | fdisk ${INSTALLDRIVE}
  g # create GPT partition table
  n # new partition (EFI partition)
  1 # partition number 1
    # default - start at beginning of disk 
  $EFISIZE # EFI boot parttion
  n # new partition (SWAP partition)
  2 # partion number 2
    # default, start immediately after preceding partition
  $SWAPSIZE # Linux Swap
  n # new partition (Linux Root Partition)
  3 # partion number 3
    # default, start immediately after preceding partition
    # default, use the  rest of the disk
  t # set partition type
  1 # select partition 1
  1 # set to EFI
  t # set partition type
  2 # select partition 2
  19 # set to Linux Swap
  t # set partition type
  3 # select partition 3
  24 # set to Linux Root (x86-64)
  w # write the partition table
  q # and we're done
EOF


# format /prepare partitions

# FAT32 is recommended for UEFI partition
mkfs.fat -F32 ${INSTALLDRIVE}1

# initialize Swap 
mkswap ${INSTALLDRIVE}2

# format linux root partition
mkfs.ext4 ${INSTALLDRIVE}3

# mount partitions
mount ${INSTALLDRIVE}3 /mnt
mkdir /mnt/efi
mount ${INSTALLDRIVE}1 /mnt/efi

#enable swap
swapon ${INSTALLDRIVE}2

#install essential packages
pacstrap /mnt base linux linux-firmware

# generate fstab
genfstab -U /mnt >> /mnt/etc/fstab

# chroot into new system to configure it
# arch-chroot /mnt

# set timezone
echo -e "ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime" | arch-chroot /mnt

# generate /etc/adjtime
echo -e "hwclock --systohc" | arch-chroot /mnt

# set locale to en_US.UTF-8 UTF-8
echo -e "sed -i '/^#en_US.UTF-8 UTF-8 /s/^#//' /etc/locale.gen" | arch-chroot /mnt
echo -e "locale-gen" | arch-chroot /mnt

# /etc/locale.conf
echo - "printf 'LANG=en_US.UTF-8' > /etc/locale.conf" | arch-chroot /mnt

# /etc/hostname
arch-chroot /mnt printf "${HOSTNAME}" > /etc/hostname

#  /etc/hosts
arch-chroot /mnt printf "127.0.0.1   localhost\n::1     localhost\n127.0.1.1   ${HOSTNAME}.localdomain  ${HOSTNAME}" >> etc/hosts

# set root password
arch-chroot /mnt echo -c $ROOTPASSWORD | passwd 

# install microcode (so that grub picks it up)
arch-chroot /mnt pacman -S ${MICROCODE}

# install / configure grub
arch-chroot /mnt pacman -S grub efibootmgr
arch-chroot /mnt grub-install --target=x86_64-efi --efi-directory=/efi --bootloader-id=GRUB
arch-chroot /mnt grub-mkconfig -o /boot/grub/grub.cfg 

# install packages

# enable services

# set bridge networking

# exit and reboot
arch-chroot /mnt exit
# reboot
