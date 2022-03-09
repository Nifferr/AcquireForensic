#!/bin/bash
# Clear the screen
clear
clear
# EarlyCase Assessment v2022.02.23
# Updated Feb 2022
#
# Property of Nifferr
# Script developed to assist in preserve forensic image and extract artifacts
#
# Developed by Nicolas Ferreira
# Fraud Investigation, Forensic Technology and Discovery Services
# Computer Forensic Team BR
#
echo "**************************************************************************************"
echo "To successfully run this report script, you must know the following basic information:"
echo "A) Custodian Full Name"
echo "B) Evidence assigned to the custodian's computer"
echo "C) Type of Device assigned custodian's host (Desktop or Laptop)"
echo "**************************************************************************************"
echo
echo
while [[ "$prompt1" != "y" ]]
do
echo -e "** Please press 'y' when you are ready to continue: \c "
read prompt1
done
echo
echo
#INFORMAÇÃO DE AQUISICAO - INICIO
echo "******************************************"
echo "*     Enter Acquisition Information      *"
echo "******************************************"
echo
echo -e "** Please enter custodian's name: \c "
read custodian
echo
echo -e "** Please enter custodian's username: \c "
read username
echo
echo -e "** Please enter the custodian's evidence: \c "
read evidence
echo
echo -e "** Please enter the host type (Desktop or Laptop): \c "
read device
echo
echo "***********************************"
echo "*      Mount Image and Emulate    *"
echo "***********************************"
echo
echo "** Please enter the number of mount on truecrypt:"
echo -e "** This number will be mount raw image and emulate disk: \c "
read keynum
mkdir /mnt/affuse"$keynum"
mkdir /mnt/WindowsImage"$keynum"

affuse /media/truecrypt"$keynum"/"$evidence"/"$evidence".image.001 /mnt/affuse"$keynum"
mmls /mnt/affuse"$keynum"/*

echo
echo
echo -e "** Please enter number offset of the image above: \c "
read offset1

mount -o ro,loop,noatime,noexec,show_sys_files,offset=$(( $offset1 * 512)) /mnt/affuse""$keynum""/* /mnt/WindowsImage""$keynum""/


echo "******************************************"
echo "*      Early Case Assessment Report      *"
echo "******************************************"
echo
echo "1. Basic System Information"
echo "2. Installed Softwares"
echo "3. Recently Accessed Files"
echo "4. Prefetch Files"
echo
echo "******************************************"
echo "*      1. Basic System Information       *"
echo "******************************************"
echo
echo "Custodian = "$custodian
echo "Evidence = "$evidence
echo "Host = "$device
perl /usr/share/regripper/rip.pl -r /mnt/WindowsImage1/Windows/System32/config/SOFTWARE -p winver 2> /dev/null | sed '1,3d'
echo 
echo "User List"
perl /usr/share/regripper/rip.pl -r /mnt/WindowsImage1/Windows/System32/config/SOFTWARE -p profilelist 2> /dev/null | sed '1,3d'
echo 
echo 
echo "******************************************"
echo "*         2. Installed Softwares         *"
echo "******************************************"
echo
perl /usr/share/regripper/rip.pl -r /mnt/WindowsImage1/Windows/System32/config/SOFTWARE -p product 2> /dev/null | sed '1,3d'
perl /usr/share/regripper/rip.pl -r /mnt/WindowsImage1/Windows/System32/config/SOFTWARE -p uninstall 2> /dev/null | sed '1,3d'
echo 
echo 
echo "******************************************"
echo "*        3. Recently Accessed Files      *"
echo "******************************************"
echo
echo "Recently Documents Accessed"
perl /usr/share/regripper/rip.pl -r "/mnt/WindowsImage1/Users/$username/NTUSER.DAT" -p recentdocs 2> /dev/null | sed '1,3d'
echo "Recently URLs Accessed"
perl /usr/share/regripper/rip.pl -r "/mnt/WindowsImage1/Users/$username/NTUSER.DAT" -p typedurls  2> /dev/null | sed '1,3d'
echo
echo
echo "******************************************"
echo "*          4. Prefeth Files List         *"
echo "******************************************"
echo
echo "INODE	FILENAME"
ls -i -1 -X /mnt/WindowsImage1/Windows/Prefetch
echo
echo
##umount /mnt/WindowsImage$keynum
##umount /mnt/affuse$keynum

