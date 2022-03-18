#!/bin/bash
# Clear the screen
clear
clear
# format_encryption v2022.02.23
# Updated Feb 2022
#
# Property of Nifferr
# Script developed to assist in formatting multiple NTFS drives
#
# Developed by Nicolas Ferreira
# Fraud Investigation, Forensic Technology and Discovery Services
# Computer Forensic Team BR
#
#
echo
echo "************************** WARNING **********************************"
echo "This script may inadvertently form the internal disk of your computer"
echo " use *extreme care* when selecting devices"
echo "*********************************************************************"
echo
echo "Press CTRL-C if you wish to abort!"
while [[ "$prompt0" != "y" ]]
do
echo -e "** Please press 'y' when you are ready to continue: \c "
read prompt0
done
clear
echo
echo "*********************************************************************"
echo "Before running this script, please make sure the target disk(s) are"
echo "Unallocated!"
echo 
echo "Please attach the hard drives to USB or eSATA port"
echo
echo "This script will format up to FOUR drives attached to a computer and"
echo "create VeraCrypt encrypted volumes on those drives."
echo "*********************************************************************"
echo
while [[ "$prompt1" != "y" ]]
do
echo -e "** Press 'y' once the harddrives have been attached: \c "
read prompt1
done
echo
echo "Waiting 3 seconds for the computer to recognize the harddrives."
sleep 3
echo "Displaying display driver information of all connected hard drive(s)"
echo
echo "********************************************************************"
fdisk -l | grep '^Disk' | grep dev | grep -v ram | grep -v loop
echo "********************************************************************"
echo
echo    "** Please enter the device driver for the *FIRST* drive"
echo -e "** you want to format (e.g. sdb or sdc): \c "
read fmt1_dev
echo -e "** Please enter your First Name and your Last Name: \c "
read firstname lastname
echo -e   "** Please enter password you wish to set for each VeraCrypt volume: \c "
read fmt_pw
echo
echo "********************* SUMMARY INFORMATION ************************"
echo
## Comment out the following two lines for formatting an NTFS drive.
echo -e "Your name:\t\t$firstname $lastname"
echo -e "VeraCrypt password:\t$fmt_pw"
echo
echo "These are the harddrives I plan to format:"
fdisk -l /dev/$fmt1_dev 2>/dev/null | grep dev
echo
echo "******************************************************************"
echo
echo "PRESS CTRL-C NOW IF YOU WISH TO ABORT!"
echo
while [[ "$prompt2" != "y" ]]
do
echo -e "** Please press 'y' when you are ready start formatting: \c "
read prompt2
done
echo
echo "Reading size of each drive......"
echo
fmt1_size=`parted -s /dev/$fmt1_dev unit MB print 2>/dev/null | grep Disk | awk {'print $3'} | awk -F 'M' {'print $1'}` 
echo
echo -e "Drive\tSize(MB)"
echo -e "$fmt1_dev\t$fmt1_size"
echo
##echo "Clear all volumes in disk......"
#dd if=/dev/zero of=/dev/$fmt1_dev  bs=512  count=1
echo "Creating a unencrypted NTFS partition on each drive......"
echo
parted -s /dev/$fmt1_dev select /dev/$fmt1_dev mklabel msdos mkpart primary NTFS 1 $fmt1_size 2>/dev/null
echo
echo "Creating first 100MB unencrypted NTFS partition on each drive......"
echo
parted -s /dev/$fmt1_dev select /dev/$fmt1_dev mklabel msdos mkpart primary NTFS 1 100 2>/dev/null
echo
echo "Formating first 100MB unencrypted partition with NTFS and labeling VERACRYPT......"
echo
mkntfs -f -v -L "VERACRYPT" /dev/$fmt1_dev'1' 2>/dev/null
echo
echo "Creating second partition to hold VeraCrypt volume on each drive......"
echo
parted -s /dev/$fmt1_dev select /dev/$fmt1_dev mkpart primary FAT16 100 $fmt1_size 2>/dev/null
echo
echo "Creating new VeraCrypt volume on second partition of each drive......"
echo
veracrypt --text --create --filesystem=none --password=$fmt_pw --non-interactive --quick --encryption=AES --volume-type=normal --hash=RIPEMD-160 /dev/$fmt1_dev'2' 2>/dev/null
echo
echo "Temporarily mounting each VeraCrypt volume to allow for placement of NTFS filesystem......"
echo
veracrypt --text --password=$fmt_pw --filesystem=none --non-interactive --slot=1 /dev/$fmt1_dev'2' 2>/dev/null
echo
echo "Formatting each VeraCrypt volume NTFS ....."
echo
mkntfs -f -v /dev/mapper/veracrypt1 2>/dev/null
echo
echo "Done!"
echo
echo "Here is what we created:"
echo 
echo "********************* PARTITION SUMMARY **************************"
echo 
fdisk -l /dev/$fmt1_dev 2>/dev/null
echo 
echo "******************************************************************"
echo
echo "Making sure we can write to these drives."
echo
echo "Dismounting temporarily mounted VeraCrypt volumes...."
veracrypt -d
echo
echo "Removing any previous mount point files...."
rm /mnt/nt1/* 2>/dev/null
echo
echo "Removing any previous mount point directories...."
rmdir /mnt/nt1 2>/dev/null
echo
echo "Making new mount point directories for 100MB partition...."
mkdir /mnt/nt1 2>/dev/null
echo
##echo "Mounting newly formatted NTFS drives to the mount points...."
echo "Mounting newly formatted 100MB unencrypted partitions to the mount points...."
ntfs-3g /dev/$fmt1_dev'1' /mnt/nt1 2>/dev/null
echo
echo "Remounting each VeraCrypt volume as an NTFS file system...."
veracrypt --text --filesystem=ntfs-3g --password=$fmt_pw --non-interactive --slot=1 /dev/$fmt1_dev'2' 2>/dev/null
echo
echo "Displaying mount points...."
echo "******************************************************************"
echo
df -h
echo
echo "******************************************************************"
echo
mount
echo
echo "******************************************************************"
echo
echo "Making sure we can write to the 100MB partition...."
echo "This drive has a VeraCrypt encrypted volume on `date`." > /mnt/nt1/README.veracrypt.log 2>/dev/null
echo
echo "Making autorun to the 100MB partition...."
echo
echo -e "[autorun]\r\nlabel=Evidence\r\nshellexecute=README.veracrypt.log" > /mnt/nt1/autorun.inf 2>/dev/null
echo
echo "Making autorun to the 100MB partition...."
cp /home/$USER/Binaries/VeraCrypt_1.25.exe /mnt/nt1/VeraCrypt_1.25.exe 2>/dev/null
echo
echo "Making sure we can write to the VeraCrypt partition...."
echo "Please check the evidence tracking to consulting more informations. Disk format assigned by $firstname $lastname on $date." > /media/veracrypt1/format_time.txt 2>/dev/null
echo
echo "Listing the files we just created...."
ls -l /mnt/nt1 2>/dev/null
ls -l /media/veracrypt1 2>/dev/null
echo
echo "Unmounting the drives from the mount points...."
umount /mnt/nt1 2>/dev/null
echo
echo "Dismounting VeraCrypt Volumes...."
veracrypt -d
echo
echo "Removing the mount point directories...."
rm /mnt/nt1/* 2>/dev/null
echo
rmdir /mnt/nt1 2>/dev/null
echo "Make a hidden encryption partitions...."
sfdisk --part-type /dev/$fmt1_dev 2 16 2>/dev/null

echo "Done!"
while [[ "$promptEnd" != "Close" ]]
do
echo -e "** Please type 'Close' when you are ready to exit: \c "
read promptEnd
done