#!/bin/bash
# Clear the screen
clear
clear
# ArtifactExtractor v2022.02.23
# Updated Feb 2022
#
# Property of Nifferr
# Script developed to assist in preserve forensic image and extract artifacts
#
# Developed by Nicolas Ferreira
# Fraud Investigation, Forensic Technology and Discovery Services
# Computer Forensic Team BR
#

rm /home/$USER/Desktop/Extraction.log -f
sleep 2
log_output=/home/$USER/Desktop/Extraction.log

date | tee -a $log_output
echo "*************************************************************************************" | tee -a $log_output
echo "To successfully run this script, you must know the following information:" | tee -a $log_output
echo "A) evidence_id assigned to the custodian's computer" | tee -a $log_output
echo "B) Number of the mount evidence in veracrypt" | tee -a $log_output
echo "C) Custodian's user name/key" | tee -a $log_output
echo | tee -a $log_output
echo "*************************************************************************************" | tee -a $log_output
echo | tee -a $log_output
echo | tee -a $log_output
echo | tee -a $log_output
while [[ "$prompt1" != "y" ]]
do
echo -e "** Please press 'y' when you are ready to continue: \c "
read prompt1
done
echo
echo
echo
echo
echo "******************************************" | tee -a $log_output
echo "*        Disk Evidence Information       *" | tee -a $log_output
echo "******************************************" | tee -a $log_output
echo | tee -a $log_output
echo -e "** Please enter the evidence_id: \c " | tee -a $log_output
read evidence_id
echo
echo
echo "** Please enter the number of mount on veracrypt:" | tee -a $log_output
echo -e "** This number will be mount raw image and emulate disk: \c " | tee -a $log_output
read veracrypt_mount
echo | tee -a $log_output
echo | tee -a $log_output




mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder
mv /home/$USER/Desktop/Extraction.log /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder -f
log_output=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Extraction.log

echo "***********************************" | tee -a $log_output
echo "*      Mount Image and Emulate    *" | tee -a $log_output
echo "***********************************" | tee -a $log_output
echo | tee -a $log_output

#mount in affuse folder
affuse /media/veracrypt"$veracrypt_mount"/"$evidence_id"/"$evidence_id".image.001 /mnt/affuse"$veracrypt_mount" | tee -a $log_output
echo
#get offset
mmls /mnt/affuse"$veracrypt_mount"/* | tee -a $log_output
echo | tee -a $log_output
echo | tee -a $log_output
echo | tee -a $log_output
echo -e "** Please enter number offset of the image above: \c "
read offset1

mount -o ro,loop,noatime,noexec,show_sys_files,offset=$(( $offset1 * 512)) /mnt/affuse""$veracrypt_mount""/* /mnt/WindowsImage""$veracrypt_mount""/


echo "***********************************" | tee -a $log_output
echo "* Create directories and folders  *" | tee -a $log_output
echo "***********************************" | tee -a $log_output
echo | tee -a $log_output
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/LogFiles
echo "Directory 'LogFiles' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Custodian
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Notes
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Desktop
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Downloads
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Documents
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/UserRoot
echo "Directory 'I30' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Bulk\ Extractor
echo "Directory 'Bulk Extractor' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Carving
echo "Directory 'Carving' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Cryptography
echo "Directory 'Cryptography' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Early\ Assessment
echo "Directory 'Early Assessment' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Format\ Date
echo "Directory 'Format Date' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Hiberfil
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Hiberfil/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Hiberfil/ParsedFiles
echo "Directory 'HIBERFIL' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Internet\ History
echo "Directory 'Internet History' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/ANJP
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/LNK
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/LNK/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/LNK/ParsedFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/log2timeline
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/Logfile
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/Logfile/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/Logfile/ParsedFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/MFT
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/MFT/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/MFT/ParsedFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/USNJournal
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/USNJournal/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/USNJournal/ParsedFiles
echo "Directory 'Mass Deletion' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Pagefile
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Pagefile/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Pagefile/ParsedFiles
echo "Directory 'PAGEFILE' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/Prefetch
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/Prefetch/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/Prefetch/ParsedFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SAM
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SAM/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SAM/ParsedFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SECURITY
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SECURITY/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SECURITY/ParsedFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SOFTWARE
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SOFTWARE/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SOFTWARE/ParsedFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SYSTEM
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SYSTEM/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SYSTEM/ParsedFiles
echo "Directory 'Registry Analysis' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/NTUSER
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/NTUSER/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/NTUSER/ParsedFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/UsrClass
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/UsrClass/OriginalFiles
mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/UsrClass/ParsedFiles
echo "Directory 'Shellbags' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Volume\ Shadow\ Copy
echo "Directory 'Volume Shadow Copy' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/UNALLOCATED
echo "Directory 'UNALLOCATED' criated." | tee -a $log_output

mkdir /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Slack
echo "Directory 'Slack' criated." | tee -a $log_output

echo | tee -a $log_output
echo "***********************************" | tee -a $log_output
echo "*    Beggin Extract Artifacts     *" | tee -a $log_output
echo "***********************************" | tee -a $log_output
echo | tee -a $log_output

versionwin="x"
while [[ "$versionwin" != "y" && "$versionwin" != "n" ]]
do
echo "The disk contains User folder in Root?" | tee -a $log_output
echo -e "You can below verify: \c" | tee -a $log_output
echo | tee -a $log_output
ls -hls /mnt/WindowsImage"$veracrypt_mount" | grep Users | tee -a $log_output
echo | tee -a $log_output
echo -e "** Enter 'y' for yes or 'n' for no: \c "
read versionwin
done

#inicio condicional
if [ "$versionwin" == "y" ]
then

	echo
	userpath="Users"	
	ls /mnt/WindowsImage"$veracrypt_mount"/$userpath/
	echo
	echo
	echo -e "Please enter custodian's name: \c"
	read username
	echo

	echo "Extracting NTUSER..." | tee -a $log_output
	sleep 2
	echo "..."
	dd if=/mnt/WindowsImage"$veracrypt_mount"/"$userpath"/"$username"/NTUSER.DAT of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/NTUSER/OriginalFiles/NTUSER.DAT | tee -a $log_output
	echo | tee -a $log_output

	echo "Extracting UsrClass..." | tee -a $log_output
	sleep 2
	echo "..."
	dd if=/mnt/WindowsImage"$veracrypt_mount"/"$userpath"/"$username"/AppData/Local/Microsoft/Windows/UsrClass.dat of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/UsrClass/OriginalFiles/UsrClass.dat | tee -a $log_output	
	echo | tee -a $log_output
	
	echo "Extracting Internet History..." | tee -a $log_output
	sleep 2
	echo "..."
	pasco /mnt/WindowsImage"$veracrypt_mount"/"$userpath"/"$username"/AppData/Local/Microsoft/Windows/History/History.IE5/index.dat > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Internet\ History/IE_History.csv
	echo | tee -a $log_output


else

	echo
	userpath="Documents\ and\ Settings"	
	ls /mnt/WindowsImage"$veracrypt_mount"/$userpath/
	echo
	echo
	echo -e "Please enter custodian's name: \c"
	read username
	echo
	echo

	echo "Extracting NTUSER..." | tee -a $log_output
	sleep 2
	echo "..."
	dd if=/mnt/WindowsImage"$veracrypt_mount"/"$userpath"/"$username"/NTUSER.DAT of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/NTUSER/OriginalFiles/NTUSER.DAT | tee -a $log_output
	echo | tee -a $log_output

	echo "Extracting UsrClass..." | tee -a $log_output
	sleep 2
	echo "..."
	dd if=/mnt/WindowsImage"$veracrypt_mount"/"$userpath"/"$username"/Local\ Settings/ApplicationData/Microsoft/Windows/UsrClass.dat of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/UsrClass/OriginalFiles/UsrClass.dat | tee -a $log_output 
	echo | tee -a $log_output

	echo "Extracting Internet History..." | tee -a $log_output
	sleep 2
	echo "..."
	pasco /mnt/WindowsImage"$veracrypt_mount"/"$userpath"/"$username"/Local\ Settings/History/History.IE5/index.dat > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Internet\ History/IE_History.csv
	echo | tee -a $log_output



fi

echo "Copy LogFiles of colect.." | tee -a $log_output
sleep 2
echo "..."
find /media/veracrypt"$veracrypt_mount"/"$evidence_id"/ -name "*.wri" -exec cp {} /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/LogFiles/ \;
find /media/veracrypt"$veracrypt_mount"/"$evidence_id"/ -name "*.log" -exec cp {} /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/LogFiles/ \;
echo | tee -a $log_output

echo "Finding Early.." | tee -a $log_output
find /media/veracrypt"$veracrypt_mount"/"$evidence_id"/ -name "*.pdf" -exec cp {} /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Early\ Assessment/ \;
echo | tee -a $log_output

echo "Extracting I30.." | tee -a $log_output
sleep 2
echo "..."
u_root_inode=`fls -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw | grep $userpath | cut -d " " -f 2 | cut -d ":" -f 1 | cut -d "-" -f 1`
istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $u_root_inode > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/UserRoot/INDEX_INFORMATION.log
attr_root=`istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $u_root_inode | grep "Type: \$INDEX_ALLOCATION" | cut -d "(" -f 2 | cut -d ")" -f 1 | grep "160"`
icat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw "$u_root_inode"-"$attr_root"  > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/UserRoot/\$I30
echo "..."
user_inode=`fls -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $u_root_inode | grep $username | cut -d " " -f 2 | cut -d ":" -f 1 | cut -d "-" -f 1`
istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $user_inode > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Custodian/INDEX_INFORMATION.log
attr_user=`istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $user_inode | grep "Type: \$INDEX_ALLOCATION" | cut -d "(" -f 2 | cut -d ")" -f 1 | grep "160"`
icat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw "$user_inode"-"$attr_user"  > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Custodian/\$I30
echo "..."
desk_inode=`fls -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $user_inode | grep Desktop | cut -d " " -f 2 | cut -d ":" -f 1 | cut -d "-" -f 1`
istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $desk_inode  > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Desktop/INDEX_INFORMATION.log
attr_desk=`istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $desk_inode | grep "Type: \$INDEX_ALLOCATION" | cut -d "(" -f 2 | cut -d ")" -f 1 | grep "160"`
icat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw "$desk_inode"-"$attr_desk"  > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Desktop/\$I30
echo "..."
down_inode=`fls -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $user_inode | grep Downloads | cut -d " " -f 2 | cut -d ":" -f 1 | cut -d "-" -f 1`
istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $down_inode  > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Downloads/INDEX_INFORMATION.log
attr_down=`istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $down_inode | grep "Type: \$INDEX_ALLOCATION" | cut -d "(" -f 2 | cut -d ")" -f 1 | grep "160"`
icat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw "$down_inode"-"$attr_down"  > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Downloads/\$I30
echo "..."
docs_inode=`fls -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $user_inode | grep Documents | cut -d " " -f 2 | cut -d ":" -f 1 | cut -d "-" -f 1`
istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $docs_inode  > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Documents/INDEX_INFORMATION.log
attr_docs=`istat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $docs_inode | grep "Type: \$INDEX_ALLOCATION" | cut -d "(" -f 2 | cut -d ")" -f 1 | grep "160"`
icat -o"$offset1" /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw "$docs_inode"-"$attr_docs"  > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/\$I30/Documents/\$I30
echo | tee -a $log_output

echo "Extracting USNJournal..." | tee -a $log_output
sleep 2
echo "..."
inodej=`fls -o$offset1 /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw 11 | grep "UsnJrnl" | grep -v "Max" | cut -d " " -f 2 | cut -d ":" -f 1`
icat -o$offset1 /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw $inodej > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/USNJournal/OriginalFiles/\$J
echo | tee -a $log_output

echo "Extracting MFT" | tee -a $log_output
sleep 2
echo "..."
icat -f ntfs -o $offset1 /mnt/affuse"$veracrypt_mount"/"$evidence_id".image.001.raw 0 > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/MFT/OriginalFiles/\$MFT | tee -a $log_output
echo | tee -a $log_output

echo "Extracting Hiberfil..." | tee -a $log_output
sleep 2
echo "..."
dd if=/mnt/WindowsImage"$veracrypt_mount"/hiberfil.sys of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Hiberfil/OriginalFiles/hiberfil.sys | tee -a $log_output
echo | tee -a $log_output

echo "Extracting Logfile..." | tee -a $log_output
sleep 2
echo "..."
dd if=/mnt/WindowsImage"$veracrypt_mount"/\$LogFile of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/Logfile/OriginalFiles/\$LogFile | tee -a $log_output
echo | tee -a $log_output

echo "Extracting Pagefile..." | tee -a $log_output
sleep 2
echo "..."
dd if=/mnt/WindowsImage"$veracrypt_mount"/pagefile.sys of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Pagefile/OriginalFiles/pagefile.sys | tee -a $log_output
echo | tee -a $log_output

echo "Extracting SAM..." | tee -a $log_output
sleep 2
echo "..."
dd if=/mnt/WindowsImage"$veracrypt_mount"/Windows/System32/config/SAM of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SAM/OriginalFiles/SAM | tee -a $log_output
echo | tee -a $log_output

echo "Extracting SECURITY..." | tee -a $log_output
sleep 2
echo "..."
dd if=/mnt/WindowsImage"$veracrypt_mount"/Windows/System32/config/SECURITY of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SECURITY/OriginalFiles/SECURITY | tee -a $log_output
echo | tee -a $log_output

echo "Extracting SOFTWARE..." | tee -a $log_output
sleep 2
echo "..."
dd if=/mnt/WindowsImage"$veracrypt_mount"/Windows/System32/config/SOFTWARE of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SOFTWARE/OriginalFiles/SOFTWARE | tee -a $log_output
echo | tee -a $log_output

echo "Extracting SYSTEM..." | tee -a $log_output
sleep 2
echo "..."
dd if=/mnt/WindowsImage"$veracrypt_mount"/Windows/System32/config/SYSTEM of=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SYSTEM/OriginalFiles/SYSTEM | tee -a $log_output
echo | tee -a $log_output

echo "Extracting Slack Space" | tee -a $log_output
sleep 2
echo "..."
#blkls -s -o $offset1 /mnt/affuse"$veracrypt_mount"/* > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Slack/"$evidence_id"_Slack.dd | tee -a $log_output
echo | tee -a $log_output

echo "Extracting area nao alocada da particao numero 1." | tee -a $log_output
sleep 2
echo "..."
#blkls -A -o $offset1 /mnt/affuse"$veracrypt_mount"/* > /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/UNALLOCATED/UnallocatedClusters.dd | tee -a $log_output
echo | tee -a $log_output
echo | tee -a $log_output
echo | tee -a $log_output


echo "***********************************" | tee -a $log_output
echo "*   Verifing Volume Shadow Copy   *" | tee -a $log_output
echo "***********************************" | tee -a $log_output
echo | tee -a $log_output
echo | tee -a $log_output
vshadowinfo -o $(( $offset1 * 512 )) /mnt/affuse"$veracrypt_mount"/* >> $log_output 2>&1
echo "..."
vshadowinfo -o $(( $offset1 * 512 )) /mnt/affuse"$veracrypt_mount"/*
echo | tee -a $log_output
echo | tee -a $log_output


#Creation doc in VSC folder
vsclog=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Volume\ Shadow\ Copy/VolumeShadow.log
echo "***********************************" > $vsclog
echo "*    Status Volume Shadow Copy    *" >> $vsclog
echo "***********************************" >> $vsclog
echo >> $vsclog
echo >> $vsclog
vshadowinfo -o $(( $offset1 * 512 )) /mnt/affuse"$veracrypt_mount"/* >> $vsclog 2>&1
echo >> -a $vsclog
echo >> -a $vsclog



echo "***********************************" | tee -a $log_output
echo "*    Create hash artifacts list   *" | tee -a $log_output
echo "***********************************" | tee -a $log_output
echo | tee -a $log_output
echo | tee -a $log_output

hashlog=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Hash.md5

echo "Hash Verification." | tee -a $log_output
echo Hash exported you can verify in ./"$evidence_id"_CaseFolder/Hash.md5 | tee -a $log_output
echo
echo
echo "***********************************" > $hash
echo "*        Hash Artifacts List      *" >> $hash
echo "***********************************" >> $hash
echo "*" >> $hash
echo "*" >> $hash
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Hiberfil/OriginalFiles/hiberfil.sys | tee -a $hashlog
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Mass\ Deletion/Logfile/OriginalFiles/\$LogFile | tee -a $hashlog
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Pagefile/OriginalFiles/pagefile.sys | tee -a $hashlog
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SAM/OriginalFiles/SAM | tee -a $hashlog
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SECURITY/OriginalFiles/SECURITY | tee -a $hashlog
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SOFTWARE/OriginalFiles/SOFTWARE | tee -a $hashlog
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Registry\ Analysis/SYSTEM/OriginalFiles/SYSTEM | tee -a $hashlog
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/NTUSER/OriginalFiles/NTUSER.DAT | tee -a $hashlog
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/Shellbags/UsrClass/OriginalFiles/UsrClass.dat | tee -a $hashlog
md5sum /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/UNALLOCATED/UnallocatedClusters.dd | tee -a $hashlog
echo | tee -a $log_output
echo "Artifact Extraction complete in `date`!" | tee -a $log_output

sleep 2
echo "..."

echo >> $log_output
echo >> $log_output

log_output=/media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder/DirList.log

ls -hsR /media/veracrypt"$veracrypt_mount"/"$evidence_id"_CaseFolder --ignore=Carving | grep -v "total"| grep -v "ParsedFiles" >> $log_output
echo "Generate extraction list of the evidence "$evidence_id" complete!" | tee -a $log_output

sleep 2
umount /mnt/WindowsImage"$veracrypt_mount"
sleep 2
umount /mnt/affuse"$veracrypt_mount"

echo "Please UMOUNT evidence '"$evidence_id"' of veracrypt"
exit
exit
