#!/bin/bash

########## OPTIONS ##########

# drive to use
INSTALLDRIVE=/dev/vda


########## END OPTIONS ########## 


# wipe partition-table and partitions
wipefs -a ${INSTALLDRIVE}

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
  +300M # 300 MB boot parttion
  n # new partition (SWAP partition)
  2 # partion number 2
    # default, start immediately after preceding partition
  +600M # 600 MB Linux Swap
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

