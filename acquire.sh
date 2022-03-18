#!/bin/bash
# Clear the screen
clear
clear
# acquire v2022.02.23
# Updated March 2022
#
# Property of Nifferr
# Script to image drives from distro
#
# Developed by Nicolas Ferreira
# Fraud Investigation, Forensic Technology and Discovery Services
# Computer Forensic Team BR
#
#
# Script developed to assist in Forensic collection and reports
# With this script you will be able to achieve some goals:
# 1) Get valuable information about the host
# 2) Securely save image in encrypted disks
# 3) Perform forensic imaging in various formats
# 4) Receive a device collection report
#
# This script has a few assumptions:
# 1) Use the custodian's computer as the imaging platform
# 2) Use this script for device collection
# 3) Have intermediate knowledge in Linux
# 4) Have target and backup disks, preferably preformatted
# 5) Use VeraCrypt encryption
#
echo "*************************************************************************************"
echo " To successfully execute this script, you must know the following information:"
echo " A) First and last name of the device owner"
echo " B) Unique identifier assigned to the evidence - if not, we recommend using a GUID"
echo " C) Linux device driver assigned to the hard drive of the custodian's computer."
echo " D) Evidence IDs assigned to the destination (and Backup) drives where you will write the images"
echo " E) Unique identifier assigned to the target and backup disks - if not, we recommend using a GUID"
echo " F) You must have a external drive as Target and Backup Drive that is formatted in a readable filesystem"
echo " G) You must have connected drives formatted in VeraCrypt 1.24"
echo " H) Enough free space to keep a forensic image of the internal disk of this computer"
echo "*************************************************************************************"
echo
mkdir /mnt/tmp
echo "Press CTRL-C if you want to abort anytime"
while [[ "$prompt1" != "y" ]]
do
echo -e "** Please press 'y' when you are ready to continue: \c "
read prompt1
done
echo
# Acquisition information
echo "******************************************"
echo "*     Enter Acquisition Information      *"
echo "******************************************"
echo
echo "** Please enter YOUR information"
echo -e "** Please enter YOUR First Name and your Last Name: \c "
read firstname lastname
echo -e "** Please enter the custodian's First Name and Last Name: \c "
read custodianFN custodianLN
echo -e "** Please enter the Project Name: \c "
read proj_name
echo -e "** Please enter the Engagement Code (or TBD): \c "
read eng_code
echo "** Please enter the city of acquisition (eg. Sao Paulo): \c "
read city
echo -e "** Please enter the state of acquisition (eg. SP): \c "
read state
echo -e "** Please enter the country of acquisition: \c "
read country
echo -e "** Please enter Google Plus Code (or TBD): \c"
read specific_location
echo -e "** Please enter the Asset Tag Host Information (or N/A): \c "
read host_tag
echo
echo
echo "***********************************"
echo "* Setting Date and Time Variables *"
echo "***********************************"
echo
# Ask the user if the current system date and time actual match local date and time. 
# If they match, use system date and time as local date and time.
# If they do not match, input local date and time.
date_match="x"
while [[ "$date_match" != "y" && "$date_match" != "n" ]]
do
#echo "debug: The current value of date_match is $date_match"
echo
echo "The current system DATE is:  `date +'%A, %B %d, %Y'`"
echo
echo "** Does the DATE displayed above match the"
echo "** match the actual current local DATE?"
echo
echo -e "** Enter 'y' for yes or 'n' for no: \c "
read date_match
done

if [ "$date_match" == "y" ]
then
	curr_date=`date +"%A, %B %d, %Y"`

else
	echo
	echo "** Please enter today's current DATE in"
	echo -e "** the format 'Saturday, March 05, 2022': \c "
	read curr_date
	echo
fi

time_match="x"
while [[ "$time_match" != "y" &&  "$time_match" != "n" ]]
do

echo
echo
echo "The current system TIME is:  `date +'%H:%M'`"
echo "And current timezone system is:  `date +'%:::z'`"
echo
echo "** Does the TIME displayed above match the"
echo "** match the actual current local TIME?"
echo
echo -e "** Enter 'y' for yes or 'n' for no: \c "
read time_match
done

if [ "$time_match" == "y" ]
then
	curr_time=`date +"%H:%M"`

else
	echo
	echo "** Please enter the current local TIME in"
	echo -e "** 24 hour format (e.g. 7:30 PM = 19:30): \c "
	read curr_time
	echo
fi
clear
echo
echo "Displaying physical disk by device drive. Information from the host computer's hard disk(s) via the dmesg command."
echo "*************************************************************************************"
dmesg | grep logical | grep blocks
echo "*************************************************************************************"
echo
echo "Displaying physical disk by device drive. Information from the host computer's hard disk(s) via the fdisk command."
echo "*************************************************************************************"
fdisk -l | grep bytes | grep Disk | grep -v veracrypt | grep -v ram | grep -v loop | awk '{print "sd 0:0:0:0:\t["$2"]\t"$5" "$6"\t logical blocks: ("$3" "$4")"}' | sed 's/,/./g'
echo "*************************************************************************************"
echo
echo
echo "Please make a note of the device driver assigned to the internal hard disk."
echo " i) An internal IDE drive is VERY COMMON /dev/hda - but check to make sure."
echo " ii) An internal SATA drive is VERY COMMON /dev/sda - but check to be sure."
echo " iii) If you have any doubts about which disk will be sampled try to identify the disk by the serial number"
echo " You will need to enter this information later in the script."
echo
echo    "** Please enter the device driver for the Evidence Drive"
echo -e "**                    (e.g. hda for IDE or sda for SATA): \c "
read evid_dev

echo -e "** Please enter the Evidence ID number for the Evidence Drive: \c "
read evid_code
echo
echo
echo "** PLEASE ATTACH THE *TARGET* HARDRIVE TO A USB OR ESATA PORT ON THE COMPUTER."
echo
while [[ "$prompt2" != "y" ]]
do
echo -e "** Press 'y' once the Target harddrive has been attached: \c "
read prompt2
done
echo
echo "Waiting 3 seconds for the computer to recognize the harddrive."
sleep 3
echo
echo "Displaying disk device driver information of host computer hard drive(s) by dmesg command"
echo "************************************************************************************"
dmesg | grep logical | grep blocks
echo "*************************************************************************************"
echo
echo "Displaying disk device driver information of host computer hard drive(s) by fdisk command"
echo "*************************************************************************************"
fdisk -l | grep bytes | grep Disk | grep -v veracrypt | grep -v ram | grep -v loop | awk '{print "sd 0:0:0:0:\t["$2"]\t"$5" "$6"\t logical blocks: ("$3" "$4")"}' | sed 's/,/./g'
echo "*************************************************************************************"
echo
echo "Please make note of the device driver assigned to the target harddrive."
echo "	i) An external USB Target Drive is likely /dev/sdb if the custodian's"
echo "		drive is /dev/hda (IDE) and this USB Jump Drive is /dev/sda"
echo
echo "	ii) An external USB Target Drive is likely /dev/sdc if the custodian's"
echo "		drive is /dev/sda (SATA) and this USB Jump Drive is /dev/sdb"
echo
echo "	iii) Depending on hardware devices, the order in which drives were detected, and"
echo "		the order in which external drives were attached, the Target Drive"
echo "		could be /dev/sda, /dev/sdb, or /dev/sdc."
echo
echo    "** Please enter the device driver for the Target Drive"
echo -e "**    (e.g. hdb or hdc for IDE or sdb or sdc for SATA): \c "
read tgt_dev

echo -e "** Please enter the Evidence ID Number for the Target Drive: \c "
read tgt_code
echo
ntfslabel /dev/$tgt_dev'1' "$tgt_code"
echo -e   "** Please enter the VeraCrypt password for the Target Drive: \c "
read tgt_pw
echo
veracrypt --password=$tgt_pw --slot=1 /dev/$tgt_dev'2'
tgt_mnt=/media/veracrypt1
echo
echo "Creating directory entry on the Target Drive to hold"
echo "an image of $evid_code and a log of this process."
mkdir $tgt_mnt/$evid_code
echo
#
# Establish an output_report name based on the Evidence ID assigned and the current system Date/Time
# This way the name is likely to be unique and we are not likely to overwrite an existing file
#
echo "Establishing report files"
echo

output_report=$tgt_mnt/$evid_code/$evid_code.`date +"%Y%m%d.%H%M%S"`.log
inventory=$tgt_mnt/$evid_code/$evid_code.inventory.log
diskoutput_report=$tgt_mnt/$evid_code/$evid_code.drive.log

# An example output_report is ID.20150617.150617.rawimage.log
# This represents the EvidenceID.YearMonthDay.HourMinuteSecond.rawimage.log

# Note - from here out we append certain output to the output_report using 'tee -a'
# Without the -a option to 'append' to an existing file, tee creates a new file 
# each time, overwriting prior content

echo "*** BEGIN FTK Acquisition Audit File for $evid_code ***" | tee -a $output_report
echo | tee -a $output_report
echo | tee -a $output_report

echo "************************************" | tee -a $output_report
echo "* Forensic Acquisition Information *" | tee -a $output_report
echo "************************************" | tee -a $output_report
echo | tee -a $output_report
timezone_host=`date +"%:::z %Z"`

echo "Forensic Examiner Name: $firstname $lastname" | tee -a $output_report
echo "Project Name: $proj_name" | tee -a $output_report
echo "Engagement Code: $eng_code" | tee -a $output_report
echo "Evidence Evidence ID: $evid_code" | tee -a $output_report
echo "Custodian Name: $custodianFN $custodianLN" | tee -a $output_report
echo "Current Date:" $curr_date | tee -a $output_report
echo "Current Time:" $curr_time | tee -a $output_report
echo "Current TimeZone:" $timezone_host  | tee -a $output_report
echo "Place of Acquisition: $specific_location - $city, $state, $country" | tee -a $output_report

# Since we are using the custodian's computer as our forensic acquisition platform,
# record certain information about the custodian's computer

echo | tee -a $output_report
echo "**********************************" | tee -a $output_report
echo "*    Host Computer Information   *" | tee -a $output_report
echo "**********************************" | tee -a $output_report
echo | tee -a $output_report

# dmidecode is a Linux utility to query the system BIOS for certain data
host_type=`dmidecode -t 3 | grep Type | awk '{print $2}'`
host_manufacturer=`dmidecode -s system-manufacturer`
host_product_name=`dmidecode -s baseboard-product-name`
host_version=`dmidecode -s system-version`
host_serial_number=`dmidecode -s system-serial-number`
host_system_family=`dmidecode -s system-family`
host_bios_vendor=`dmidecode -s bios-vendor`
bios_date=`date +"%A, %B %d, %Y"`
bios_date_formated=`date +"%4Y-%m-%d"`
bios_time=`date +"%H:%M"`
host_timeZone=`date +"%:::z %Z"`
datetime_host=`date +"%4Y-%m-%d %H:%M %:::z %Z"`
datetime_utc0=`date -u +"%4Y-%m-%d %H:%M %:::z %Z"`

echo >> $inventory
echo "***************************************" >> $inventory
echo "*    Host Computer Full Information   *" >> $inventory
echo "***************************************" >> $inventory
echo >> $inventory
echo >> $inventory
lshw >> $inventory

echo "Host Type: $host_type"  | tee -a $output_report
echo "Host Manufacturer: $host_manufacturer"  | tee -a $output_report
echo "Host Product Name: $host_product_name"  | tee -a $output_report
echo "Host Tag: $host_tag"  | tee -a $output_report
echo "Host Version: $host_version"  | tee -a $output_report
echo "Host Serial Number: $host_serial_number"  | tee -a $output_report
echo "BIOS Date: $bios_date"  | tee -a $output_report
echo "BIOS Time: $bios_time"  | tee -a $output_report
echo "Host Date/Time/Time Zone: $host_time"  | tee -a $output_report
echo | tee -a $output_report

echo "*******************************************************" | tee -a $output_report
echo "* Custodian's Hard Drive (Evidence Drive) Information *" | tee -a $output_report
echo "*******************************************************" | tee -a $output_report
echo | tee -a $output_report

echo "The Evidence Drive is device /dev/$evid_dev with Evidence ID $evid_Evidence" | tee -a $output_report

evid_dev_model=`hdparm -I /dev/$evid_dev 2>/dev/null | grep -i 'Model Number' | awk '{print $3" "$4" "$5" "$6}'`
evid_dev_serial=`hdparm -I /dev/$evid_dev 2>/dev/null | grep -i 'Serial Number' | awk '{print $3" "$4" "$5" "$6}'`
evid_dev_firmware=`hdparm -I /dev/$evid_dev 2>/dev/null | grep -i 'Firmware Revision' | awk '{print $3" "$4" "$5" "$6}'`
echo "Model Number: $evid_dev_model" | tee -a $output_report
echo "Serial Number: $evid_dev_serial" | tee -a $output_report
echo "Firmware Revision: $evid_dev_firmware" | tee -a $output_report
hdparm -r1 /dev/$evid_dev'*'  | tee -a $output_report
echo
echo

# Set blocksize == even multiple of LBASectors
# If BS != and even multiple of LBASectors, the image will have more sectors than the drive
# Part of our QC procedures is to verify the # of sectors in the image == the drive LBA

# Read and parse output lines from hdparm and fdisk to populate a local variables
# LBASectors = the number of sectors on the drive

LBASectors=`hdparm -g /dev/$evid_dev | awk -F'[=,]' '{print $4}'`
evid_sectors=`echo $LBASectors | awk '{print $1}'`
evid_bytes=`fdisk -l -u /dev/$evid_dev | grep $evid_dev | grep bytes | awk '{print $5}'`
evid_size=`fdisk -l -u /dev/$evid_dev | grep Disk | grep $evid_dev | awk -F ',' '{ print $1}' | awk '{print $3$4}'`

echo "The current value of LBASectors is:" $LBASectors | tee -a $output_report

if ((($LBASectors %64) == 0))
then
	echo "LBASectors is evenly divisible by 64" | tee -a $output_report
	blocksize=32768
	echo "blocksize is set to:" $blocksize | tee -a $output_report
elif ((($LBASectors %32) == 0))
then
	echo "LBASectors is evenly divisible by 32" | tee -a $output_report
	blocksize=16384
	echo "blocksize is set to:" $blocksize | tee -a $output_report
elif ((($LBASectors %16) == 0))
then
	echo "LBASectors is evenly divisible by 16" | tee -a $output_report
	blocksize=8192
	echo "blocksize is set to:" $blocksize | tee -a $output_report
elif ((($LBASectors %8) == 0))
then
	echo "LBASectors is evenly divisible by 8" | tee -a $output_report
	blocksize=4096
	echo "blocksize is set to:" $blocksize | tee -a $output_report
elif ((($LBASectors %4) == 0))
then
	echo "LBASectors is evenly divisible by 4" | tee -a $output_report
	blocksize=2048
	echo "blocksize is set to:" $blocksize | tee -a $output_report
elif ((($LBASectors %2) == 0))
then
	echo "LBASectors is evenly divisible by 2" | tee -a $output_report
	blocksize=1024
	echo "blocksize is set to:" $blocksize | tee -a $output_report
else
	echo "LBASectors is an odd number - imaging one sector at a time :-(" | tee -a $output_report
	blocksize=512
	echo "blocksize is set to:" $blocksize | tee -a $output_report
fi
echo | tee -a $output_report

echo "Evidence Drive Partition Table:" | tee -a $output_report
echo | tee -a $output_report

fdisk -l /dev/$evid_dev | tee -a $output_report

# Store information about the evidence drive partitions to facilitate verification.
evid_part_count=`fdisk -l -u /dev/$evid_dev | grep $evid_dev | grep -v Disk | wc -l`
evid_part1_field2=`fdisk -l -u /dev/$evid_dev | grep -A1 Device | grep $evid_dev'1' | awk '{print $2}'`
evid_part1_field3=`fdisk -l -u /dev/$evid_dev | grep -A1 Device | grep $evid_dev'1' | awk '{print $3}'`
evid_part2_field2=`fdisk -l -u /dev/$evid_dev | grep -A2 Device | grep $evid_dev'2' | awk '{print $2}'`
evid_part2_field3=`fdisk -l -u /dev/$evid_dev | grep -A2 Device | grep $evid_dev'2' | awk '{print $3}'`

# Take into account boot flag when parsing out partition information.

if [ "$evid_part1_field2" == "*" ]
then
	evid_part1_start=$evid_part1_field3
else
	evid_part1_start=$evid_part1_field2
fi

if [ "$evid_part2_field2" == "*" ]
then
	evid_part2_start=$evid_part2_field3
else
	evid_part2_start=$evid_part2_field2
fi

# Calculate offset value of first partition to facilitate later mounting of image files for verification.
evid_offset1=$(($evid_part1_start *512))
echo | tee -a $output_report
# End of Hard Drive information

echo
echo "****************************"
echo "*     Compression image    *"
echo "****************************"
while [[ "$prompt4" != "y" ]]
do
echo
echo -e "Please insert the compression rate (set compression level between 0 "
echo -e "and 9 [0=none, 1=fast, ..., 9=best]) before start: \c"
read compress_rate
echo
echo "If the above information is incorrect press Ctrl-C to abort the script."
echo -e "If information is correct press 'y' to start imaging: \c"
read prompt4
done	

#INICIO INFORMACAO HD TARGET
echo | tee -a $output_report
echo "****************************" | tee -a $output_report
echo "* Target Drive Information *" | tee -a $output_report
echo "****************************" | tee -a $output_report
echo | tee -a $output_report

echo "The Target Drive is device /dev/$tgt_dev with Evidence ID $tgt_code" | tee -a $output_report

tgt_dev_model=`hdparm -I /dev/$tgt_dev | grep -i 'Model Number' | awk '{print $3" "$4" "$5" "$6}'`
tgt_dev_serial=`hdparm -I /dev/$tgt_dev | grep -i 'Serial Number' | awk '{print $3" "$4" "$5" "$6}'`
tgt_dev_firmware=`hdparm -I /dev/$tgt_dev | grep -i 'Firmware Revision' | awk '{print $3" "$4" "$5" "$6}'`
tgt_act_mnt=`df -h -P | grep $tgt_mnt | awk {'print $6'}`

echo | tee -a $output_report
echo "The Target Drive is mounted at $tgt_act_mnt" | tee -a $output_report
echo | tee -a $output_report

# for grep, -i is case insensitive and -m stops reading after the 1st match

((tgt_dev_id=tgt_dev_id+0)) #make sure this variable is a number, not a string
((tgt_dev_id=tgt_dev_id+`dmesg | grep -i -m 1 $tgt_dev | awk -F'[sd:]' '{print $3}'`))

#echo "debug: tgt_dev_id = $tgt_dev_id"

echo "The Target Drive at $tgt_dev has scsi identifier scsi$tgt_dev_id" | tee -a $output_report
echo | tee -a $output_report

cat /proc/scsi/scsi | grep -A 1 "scsi$tgt_dev_id"  | tee -a $output_report
tgt_scsi_vendor=`cat /proc/scsi/scsi | grep -A 1 "scsi$tgt_dev_id" | grep "Vendor" | awk -F ':' '{print $2}'`
tgt_scsi_model=`cat /proc/scsi/scsi | grep -A 1 "scsi$tgt_dev_id" | grep "Vendor" | awk -F ':' '{print $3}' | awk -F 'Rev' '{print $1}'`
tgt_scsi_serial=`lshw -C Disk | grep -A 3 "/dev/$tgt_dev" | grep 'serial' | awk '{print $2}'`

echo | tee -a $output_report
echo | tee -a $output_report
echo "Model Number: $tgt_dev_model $tgt_scsi_vendor $tgt_scsi_model" | tee -a $output_report
echo
echo "The serial number target device: $tgt_dev_serial" | tee -a $output_report
echo "SCSI target device: $tgt_scsi_serial" | tee -a $output_report
echo
echo "** Does the S/N displayed above"
echo "** match the real serial target number?"
echo
echo -e "** Enter 'y' for yes or 'n' for no: \c "
read tgt_sn_match

if [ "$tgt_sn_match" == "y" ]
then
	echo "Serial number confirmed"

else
	echo
	old_tgt_dev_serial = $tgt_dev_serial
	old_tgt_scsi_serial = $tgt_scsi_serial
	echo -e "** Please enter the S/N of the target: \c "
	read tgt_dev_serial
	echo -e "** Please enter the S/N in target case: \c "
	read tgt_scsi_serial
	echo
fi
echo "Firmware Revision: $tgt_dev_firmware" | tee -a $output_report
echo | tee -a $output_report
echo | tee -a $output_report

echo "Target Drive Partition Table:" | tee -a $output_report
echo | tee -a $output_report

fdisk -l /dev/$tgt_dev | tee -a $output_report
tgt_size=`fdisk -l -u /dev/$tgt_dev | grep Disk | grep $tgt_dev | awk -F ',' '{ print $1}' | awk '{print $3$4}'`
tgt_free=`df -h -P | grep $tgt_mnt | awk {'print $4'}`
echo | tee -a $output_report
##End target info


backup_drive="x"
while [[ "$backup_drive" != "y" &&  "$backup_drive" != "n" ]]
do
echo
echo
echo
echo
echo "************************ BACKUP IMAGE ? **************************"
echo "Are you planning to attach a Backup Drive so that"
echo "the script can write the image to both a Target and Backup drive??"
echo -e "	enter 'y' for yes or 'n' for no: \c "
read backup_drive
done

if [ "$backup_drive" == "n" ]
then

	echo  | tee -a $output_report
	echo "This acquisition will create *only* a Target copy." | tee -a $output_report
	echo "Make a Backup copy of this image after the imaging process is complete." | tee -a $output_report
	echo  | tee -a $output_report

	
	echo "********* ATTACHED SCSI, SATA AND USB DEVICES **********" | tee -a $output_report
	echo | tee -a $output_report
	cat /proc/scsi/scsi  | grep -i host -A 1 | tee -a $output_report
	echo  | tee -a $output_report
	echo "********************* MOUNTED FILE SYSTEMS *******************" | tee -a $output_report
	echo | tee -a $output_report
	mount | tee -a $output_report
	echo | tee -a $output_report
	echo "********************** AVAILABLE FREE SPACE ******************" | tee -a $output_report
	echo | tee -a $output_report
	df -h | tee -a $output_report
	echo | tee -a $output_report
	echo "************** PLEASE REVIEW THE FOLLOWING INFORMATION : **************"
	echo "Forensic Examiner Name: $firstname $lastname"
	echo "Project Name: $proj_name"
	echo "Engagement Code: $eng_code"
	echo "Custodian Name: $custodianFN $custodianLN"
	echo "Current Date:" $curr_date
	echo "Current Time:" $curr_time
	echo "Specific Place of Acquisition: $specific_location - $city, $state, $country"
	echo "Timezone:  `date +'%:::z %Z'`"
	echo
	echo 
	echo "Drive Assignment Summary:" | tee -a $output_report
	echo -e "Drive\tEvidence ID\tDevice\tDisk_Size\tFree_Space\tMount_Point" > /mnt/tmp/t_summary
	echo -e "Evidence\t$evid_code\t$evid_dev\t$evid_size\tN/A\tN/A" >> /mnt/tmp/t_summary
	echo -e "Target\t$tgt_code\t$tgt_dev\t$tgt_size\t$tgt_free"B"\t$tgt_act_mnt" >> /mnt/tmp/t_summary
	cat /mnt/tmp/t_summary | column -t | tee -a $output_report
	rm -f /mnt/tmp/t_summary
	echo 
	echo "***********************************************************************"
	while [[ "$prompt3" != "y" ]]
	do
	echo "If the above information is incorrect press Ctrl-C to abort the script."
	echo -e "If information is correct press 'y' to start imaging: \c"
	read prompt3
	done	
	

	# while [[ "$im_method" != "RAW" && "$im_method" != "E01" ]]
	# do
	# echo 
	# echo    "     1) RAW image is make with DC3DD and no compression"
	# echo    "     2) E01 image is make with FTK and have compression"
	# echo -e "** Please enter the Image Method: RAW (prefered) or E01: \c "

	echo | tee -a $output_report
	echo "*******************************" | tee -a $output_report
	echo "*  FTK Forensic Preservation  *" | tee -a $output_report
	echo "*******************************" | tee -a $output_report
	echo | tee -a $output_report

	image_start_date=`date +"%A, %B %d, %Y"`
	image_start_time=`date +"%H:%M"`
	echo "Beginning the imaging process with FTK Imager on $image_start_date at $image_start_time." | tee -a $output_report
#	echo "The FTK command executed is:" | tee -a $output_report
#	echo | tee -a $output_report

	# Deleting any previous image files from aborted imaging sessions and hash logs with the same Evidence ID before writing new image files
	rm -f $tgt_mnt/$evid_code/$evid_code.hash.log.rawimage.log
	rm -f $tgt_mnt/$evid_code/$evid_code.E*
	
	echo "ftkimager /dev/$evid_dev $tgt_mnt/$evid_code/$evid_code" | tee -a $output_report
	echo "--verify" | tee -a $output_report
	echo "--no-sha1" | tee -a $output_report
	echo "--e01" | tee -a $output_report
	echo "--frag 2G" | tee -a $output_report
	echo "--compress $compress_rate" | tee -a $output_report
	echo "--case-number $evid_code" | tee -a $output_report
	echo "--evidence-number $evid_code" | tee -a $output_report
	echo "--examiner "$firstname $lastname"" | tee -a $output_report
	echo | tee -a $output_report

	ftkimager /dev/$evid_dev $tgt_mnt/$evid_code/$evid_code --verify --no-sha1 --e01 --frag 2G --compress $compress_rate --case-number $evid_code --evidence-number $evid_code --examiner "$firstname $lastname"

	echo
	echo "The version of FTK Imager used in this acquisition was:" | tee -a $output_report
	echo "AccessData FTK Imager v3.1.1 CLI (Aug 24 2012)" | tee -a $output_report
	echo | tee -a $output_report

	echo "***********************" | tee -a $output_report
	echo "* Imaging is Complete *" | tee -a $output_report
	echo "***********************" | tee -a $output_report
	echo | tee -a $output_report
	echo -e '\a'
	image_end_date=`ls -l -t $tgt_mnt/$evid_code/*.E* | head -1 | awk {'print $7'}`
	image_end_time=`ls -l -t $tgt_mnt/$evid_code/*.E* | head -1 | awk {'print $8'}`

	echo "Imaging Completed on $image_end_date at $image_end_time" | tee -a $output_report
	echo | tee -a $output_report

	echo "Hashing Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $output_report
	echo | tee -a $output_report

	# Gather hash, byte and sector information for later verification.
	
	evid_hash=`cat $tgt_mnt/$evid_code/$evid_code.E01.txt | grep -i -A1 md5 | grep -i md5 | awk '{print $3}' | head -n1`
	tgt_hash=`cat $tgt_mnt/$evid_code/$evid_code.E01.txt | grep -i -A1 md5 | grep -i md5 | awk '{print $3"\t"$5}' | tail -n1`
	tgt_bytes=`cat $output_report | grep copied | awk '{print $1}'`
	tgt_sectors=`cat $output_report | grep -A1 results | grep -A1 $tgt_mnt| grep sectors | awk '{print $1}'`
	echo
	echo "The acquisition hash for $evid_code is:                    $evid_hash" | tee -a $output_report
	echo "The output hash for $evid_code on Target $tgt_code is:  $tgt_hash" | tee -a $output_report
	echo
	# Mount evidence drive and image files to obtain file counts.
	echo "Mounting Evidence drive read only and obtaining file counts" | tee -a $output_report
	mkdir /mnt/evidence
	umount /dev/$evid_dev'1'
	mount -o ro -t auto /dev/$evid_dev'1' /mnt/evidence
	evid_count=`find /mnt/evidence -type f -print | wc -l`
	echo "The file count for the Evidence drive $evid_code is: $evid_count"  | tee -a $output_report
	echo | tee -a $output_report

	echo "Mounting Target image files and obtaining file counts" | tee -a $output_report
	mkdir /media/target_raw
	xmount --in ewf $tgt_mnt/$evid_code/$evid_code.E?? /media/target_raw
	mkdir /mnt/target_image
	mount -o loop,offset=$evid_offset1,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image
	tgt_count=`find /mnt/target_image -type f -print | wc -l`
	umount /mnt/target_image
	rmdir /mnt/target_image
	echo "The file count for $evid_code on Target $tgt_code is: $tgt_count"  | tee -a $output_report
	echo | tee -a $output_report
	
	# If evidence drive has second partition, mount and count files for verification purposes.
	# Script is not currently configured to count files in a third partition.
	if [ "$evid_part_count" != "1" ]
	
	then
		
		evid_offset2=$(($evid_part2_start *512))
		echo "Mounting Evidence drive partition 2 read only and obtaining file counts" | tee -a $output_report
		mkdir /mnt/evidence2
		mount -o ro -t auto /dev/$evid_dev'2' /mnt/evidence2
		evid_count2=`find /mnt/evidence2 -type f -print | wc -l`
		echo "The file count for the Evidence drive $evid_code partition 2 is: $evid_count2"  | tee -a $output_report
		echo | tee -a $output_report		

		echo "Mounting Target image partition 2 files and obtaining file counts" | tee -a $output_report
		mkdir /mnt/target_image2
		mount -o loop,offset=$evid_offset2,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image2
		tgt_count2=`find /mnt/target_image2 -type f -print | wc -l`
		umount /mnt/target_image2
		rmdir /mnt/target_image2
		echo "The file count for $evid_code partition 2 on Target $tgt_code is: $tgt_count2"  | tee -a $output_report
		echo | tee -a $output_report
	
		files_title="Files_P1\tFiles_P2"
		evid_count_table="$evid_count\t$evid_count2"
		tgt_count_table="$tgt_count\t$tgt_count2"
		
		echo "Writing out file list to $tgt_mnt/$evid_code/$evid_code.filelist.pipe" | tee -a $output_report
		echo -e "file_name|size_bytes|last_modification_time|last_status_change_time|last_access_time|leading_directories" > $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		find /mnt/evidence -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		find /mnt/evidence2 -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		umount /mnt/evidence
		umount /mnt/evidence2
		rmdir /mnt/evidence
		rmdir /mnt/evidence2
		echo "File List Export Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $output_report

	else
		files_title="Files"
		evid_count_table="$evid_count"
		tgt_count_table="$tgt_count"

		echo "Writing out file list to $tgt_mnt/$evid_code/$evid_code.filelist.pipe" | tee -a $output_report
		echo -e "file_name|size_bytes|last_modification_time|last_status_change_time|last_access_time|leading_directories" > $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		find /mnt/evidence -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		umount /mnt/evidence
		rmdir /mnt/evidence
		echo "File List Export Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $output_report
		echo | tee -a $output_report
		echo | tee -a $output_report

	fi

	umount /media/target_raw
	rmdir /media/target_raw
	#Launch perl script to parse out file types by key extensions
	perl /bin/filetype.pl $tgt_mnt/$evid_code/$evid_code.filelist.pipe > $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe

	# Display summary of file count
	echo "**** SUMMARY FILE TYPE COUNT ****" | tee -a $output_report
	cat $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | column -s '|' -t | tee -a $output_report
	echo "*********************************" | tee -a $output_report
	echo | tee -a $output_report
	echo | tee -a $output_report
	summaryfile=$tgt_mnt/$evid_code/$evid_code.summary.tsv
	echo -e "Drive\tEvidence ID\tDevice\tBytes\tSectors\t$files_title\tMD5_Hash" > $summaryfile
	echo -e "Evidence\t$evid_code\t$evid_dev\t$evid_bytes\t$evid_sectors\t$evid_count_table\t$evid_hash" >> $summaryfile
	echo -e "Target\t$tgt_code\t$tgt_dev\t$evid_bytes\t$evid_sectors\t$tgt_count_table\t$tgt_hash" >> $summaryfile

	echo "*************************************Summary Counts**********************************" | tee -a $output_report
	cat $summaryfile | column -t | tee -a $output_report
	echo "*************************************************************************************" | tee -a $output_report
	echo | tee -a $output_report
	echo "Summary Counts Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $output_report
	echo "*** END FTK Imager Acquisition Audit File for $evid_code ***" | tee -a $output_report   
		
else

	echo | tee -a $output_report
	echo "This acquisition will capture both a Target and Backup image." | tee -a $output_report
	echo | tee -a $output_report
	echo "******************************************************************************"
	echo "* ATTACH THE *BACKUP* HARDRIVE TO ANOTHER USB OR ESATA PORT ON THE COMPUTER. *"
	echo
	while [[ "$prompt4" != "y" ]]
	do
	echo -e "Press 'y' once the Backup harddrive has been attached: \c "
	read prompt4
	done
	echo
	echo "Waiting 3 seconds for the computer to recognize the harddrive..."
	sleep 3
	echo
	echo "Displaying display driver information of:"
	echo " A) Host B) Target and C) Backup hard drive(s)"
	echo
	echo "Displaying disk device driver information of host computer hard drive(s) by dmesg command"
	echo "*************************************************************************************"
	dmesg | grep logical | grep blocks
	echo "*************************************************************************************"
	echo
	echo "Displaying disk device driver information of host computer hard drive(s) by fdisk command"
	echo "*************************************************************************************"
	fdisk -l | grep bytes | grep Disk | grep -v veracrypt | grep -v ram | grep -v loop | awk '{print "sd 0:0:0:0:\t["$2"]\t"$5" "$6"\t logical blocks: ("$3" "$4")"}' | sed 's/,/./g'
	echo "*************************************************************************************"
	echo
	echo "Please make note of the device driver assigned to the Backup harddrive."
	echo
	echo "	i) An external USB Backup Drive is likely /dev/sdc if the custodian's"
	echo "		drive is /dev/hda (IDE), the USB Jump Drive is /dev/sda,"
	echo "		and the Target drive is /dev/sdb"
	echo "	ii) An external USB Backup Drive is likely /dev/sdd if the custodian's"
	echo "		drive is /dev/sda (SATA), the USB Jump Drive is /dev/sdb"
	echo "		and the Target drive is /dev/sdc"
	echo "	iii) Depending on hardware devices, the order in which drives were detected, and"
	echo "		the order in which external drives were attached, the Backup Drive"
	echo "		could be /dev/sdb, /dev/sdc, or /dev/sdd."
	echo "	iv) If you have any doubt about the device assignments, please ask for help !!!"
	echo "You will need to input this information later in the script."
	echo	

	echo    "** Please enter the device driver for the Backup Drive"
	echo -e "**                           (e.g. sdb, sdc, or sdd): \c "
	read bkup_dev
	echo

	echo -e "** Please enter the Evidence ID Number for the Backup Drive: \c "
	read bkup_code
	echo

	ntfslabel /dev/$bkup_dev'1' "$bkup_code"

	echo -e   "** Please enter the VeraCrypt password for the Backup Drive: \c "
	read bkup_pw
	echo

	veracrypt --password=$bkup_pw --slot=2 /dev/$bkup_dev'2'

	bkup_mnt=/media/veracrypt2

	## Uncomment if imaging to an unencrypted drive.
	##mkdir /mnt/backup
	##ntfs-3g /dev/$bkup_dev'1' /mnt/backup
	##bkup_mnt=/mnt/backup

	echo "Creating directory entry on the Backup Drive to hold"
	echo "an image of $evid_code and a log of this process."
	mkdir $bkup_mnt/$evid_code
	echo

	echo "****************************" | tee -a $output_report
	echo "* Backup Drive Information *" | tee -a $output_report
	echo "****************************" | tee -a $output_report
	echo | tee -a $output_report

	echo "The Backup Drive is device /dev/$bkup_dev with Evidence ID $bkup_code" | tee -a $output_report

	bkup_dev_model=`hdparm -I /dev/$bkup_dev | grep -i 'Model Number' | awk '{print $3" "$4" "$5" "$6}'`
	bkup_dev_serial=`hdparm -I /dev/$bkup_dev | grep -i 'Serial Number' | awk '{print $3" "$4" "$5" "$6}'`
	bkup_dev_firmware=`hdparm -I /dev/$bkup_dev | grep -i 'Firmware Revision' | awk '{print $3" "$4" "$5" "$6}'`
	bkup_act_mnt=`df -h -P | grep $bkup_mnt | awk {'print $6'}`
	echo | tee -a $output_report
	echo "The Backup Drive should be mounted at $bkup_act_mnt" | tee -a $output_report
	echo | tee -a $output_report

	# for grep, -i is case insensitive and -m stops reading after the 1st match
	
	((bkup_dev_id=bkup_dev_id+0)) #make sure this variable is a number, not a string
	((bkup_dev_id=bkup_dev_id+`dmesg | grep -i -m 1 $bkup_dev | awk -F'[sd:]' '{print $3}'`))

	#echo "debug: bkup_dev_id = $bkup_dev_id"

	echo "The Backup Drive at $bkup_dev has scsi identifier scsi$bkup_dev_id" | tee -a $output_report
	echo | tee -a $output_report

	cat /proc/scsi/scsi | grep -A 1 "scsi$bkup_dev_id"  | tee -a $output_report
	bkup_scsi_vendor=`cat /proc/scsi/scsi | grep -A 1 "scsi$bkup_dev_id" | grep "Vendor" | awk -F ':' '{print $2}'`
	bkup_scsi_model=`cat /proc/scsi/scsi | grep -A 1 "scsi$bkup_dev_id" | grep "Vendor" | awk -F ':' '{print $3}' | awk -F 'Rev' '{print $1}'`
	bkup_scsi_serial=`lshw -C Disk | grep -A 3 "/dev/$bkup_dev" | grep 'serial' | awk '{print $2}'`

	echo | tee -a $output_report
	echo | tee -a $output_report
	echo "Model Number: $bkup_dev_model $bkup_scsi_vendor $bkup_scsi_model" | tee -a $output_report
	echo "The serial number target device: $bkup_dev_serial" | tee -a $output_report
	echo "SCSI target device: $bkup_scsi_serial" | tee -a $output_report
	echo
	echo "** Does the S/N displayed above"
	echo "** match the real serial target number?"
	echo
	echo -e "** Enter 'y' for yes or 'n' for no: \c "
	read bkup_sn_match

	if [ "$bkup_sn_match" == "y" ]
	then
		echo "Serial number confirmed"

	else
		echo
		bkup_dev_serialOld = $bkup_dev_serial
		bkup_scsi_serialOld = $bkup_scsi_serial
		echo "** Please enter the real S/N in target"
		echo -e "** the format 'Target Serial Number' 'Target Case HD S/N': \c "
		read bkup_dev_serial bkup_scsi_serial
		echo
	fi
	echo "Firmware Revision: $bkup_dev_firmware" | tee -a $output_report
	echo | tee -a $output_report
	echo | tee -a $output_report

	echo "Backup Drive Partition Table:" | tee -a $output_report
	echo | tee -a $output_report

	fdisk -l /dev/$bkup_dev | tee -a $output_report
	bkup_size=`fdisk -l -u /dev/$bkup_dev | grep Disk | grep $bkup_dev | awk -F ',' '{ print $1}' | awk '{print $3$4}'`
	bkup_free=`df -h -P | grep $bkup_mnt | awk {'print $4'}`
	echo | tee -a $output_report



	echo "********* ATTACHED SCSI, SATA AND USB DEVICES **********" | tee -a $output_report
	echo | tee -a $output_report
	cat /proc/scsi/scsi  | grep -i host -A 1 | tee -a $output_report
	echo  | tee -a $output_report
	echo  | tee -a $output_report
	echo "********************* MOUNTED FILE SYSTEMS *******************" | tee -a $output_report
	echo | tee -a $output_report
	mount | tee -a $output_report
	echo  | tee -a $output_report
	echo  | tee -a $output_report
	echo "********************** AVAILABLE FREE SPACE ******************" | tee -a $output_report
	echo | tee -a $output_report
	df -h | tee -a $output_report
	echo  | tee -a $output_report
	echo  | tee -a $output_report
	echo "************** PLEASE REVIEW THE FOLLOWING INFORMATION : **************"
	echo "Technician Name: $firstname $lastname"
	echo "Project Name: $proj_name"
	echo "Engagement Code: $eng_code"
	echo "Custodian Name: $custodianFN $custodianLN"
	echo "Current Date:" $curr_date
	echo "Current Time:" $curr_time
	echo "Specific Place of Acquisition: $specific_location - $city, $state, $country"

	#### DISK INFORMATION FOR ANALYSIS
	echo "********* ATTACHED SCSI, SATA AND USB DEVICES **********" >> $diskoutput_report
	echo >> $diskoutput_report
	lshw -class disk | egrep "description|product|vendor|serial|size|logical name-" >> $diskoutput_report
	echo >> $diskoutput_report
	echo >> $diskoutput_report
	echo "**************** DISK EVIDENCE INFORMATION *************" >> $diskoutput_report
	echo >> $diskoutput_report
	smartctl -i /dev/$evid_dev | grep : >> $diskoutput_report
	echo >> $diskoutput_report
	echo >> $diskoutput_report
	echo "***************** DISK TARGET INFORMATION **************" >> $diskoutput_report
	echo >> $diskoutput_report
	smartctl -i /dev/$tgt_dev | grep : >> $diskoutput_report
	echo >> $diskoutput_report
	echo >> $diskoutput_report
	echo "***************** DISK BACKUP INFORMATION **************" >> $diskoutput_report
	echo >> $diskoutput_report
	smartctl -i /dev/$bkup_dev | grep : >> $diskoutput_report

	echo 
	echo "Drive Assignment Summary:" | tee -a $output_report
	echo -e "Drive\tEvidence ID\tDevice\tDisk_Size\tFree_Space\tMount_Point" > /mnt/tmp/t_summary
	echo -e "Evidence\t$evid_code\t$evid_dev\t$evid_size\tN/A\tN/A" >> /mnt/tmp/t_summary
	echo -e "Target\t$tgt_code\t$tgt_dev\t$tgt_size\t$tgt_free"B"\t$tgt_act_mnt" >> /mnt/tmp/t_summary
	echo -e "Backup\t$bkup_code\t$bkup_dev\t$bkup_size\t$bkup_free"B"\t$bkup_act_mnt" >> /mnt/tmp/t_summary
	cat /mnt/tmp/t_summary | column -t | tee -a $output_report
	rm -f /mnt/tmp/t_summary
	echo 
	echo "***********************************************************************"
	while [[ "$prompt5" != "y" ]]
	do
	echo "If the above information is incorrect press Ctrl-C to abort the script."
	echo -e "If information is correct press 'y' to start imaging: \c"
	read prompt5
	done
	echo "*******************************" | tee -a $output_report
	echo "*  FTK Forensic Preservation  *" | tee -a $output_report
	echo "*******************************" | tee -a $output_report
	echo | tee -a $output_report

	image_start_date=`date +"%A, %B %d, %Y"`
	image_start_time=`date +"%H:%M"`
	echo "Beginning the imaging process with FTK Imager on $image_start_date at $image_start_time." | tee -a $output_report
#	echo "The FTK command executed is:" | tee -a $output_report
#	echo | tee -a $output_report

	# Deleting any previous image files from aborted imaging sessions and hash logs with the same Evidence ID before writing new image files
	rm -f $tgt_mnt/$evid_code/$evid_code.hash.log.rawimage.log
	rm -f $tgt_mnt/$evid_code/$evid_code.E*
	
	echo "ftkimager /dev/$evid_dev $tgt_mnt/$evid_code/$evid_code" | tee -a $output_report
	echo "--verify" | tee -a $output_report
	echo "--no-sha1" | tee -a $output_report
	echo "--e01" | tee -a $output_report
	echo "--frag 2G" | tee -a $output_report
	echo "--compress $compress_rate" | tee -a $output_report
	echo "--case-number $evid_code" | tee -a $output_report
	echo "--evidence-number $evid_code" | tee -a $output_report
	echo "--examiner "$firstname $lastname"" | tee -a $output_report
	echo | tee -a $output_report

	
echo '	ftkimager /dev/$evid_dev $tgt_mnt/$evid_code/$evid_code --verify --no-sha1 --e01 --frag 2G --compress $compress_rate --case-number $evid_code --evidence-number $evid_code --examiner "$firstname $lastname"'

	echo
	echo "The version of FTK Imager used in this acquisition was:" | tee -a $output_report
	echo "AccessData FTK Imager v3.1.1 CLI (Aug 24 2012)" | tee -a $output_report
	echo | tee -a $output_report
	echo "***********************" | tee -a $output_report
	echo "* Imaging is Complete *" | tee -a $output_report
	echo "***********************" | tee -a $output_report
	echo | tee -a $output_report
	echo -e '\a'
	image_end_date=`ls -l -t $tgt_mnt/$evid_code/*.E* | head -1 | awk {'print $7'}`
	image_end_time=`ls -l -t $tgt_mnt/$evid_code/*.E* | head -1 | awk {'print $8'}`

	echo "Imaging Completed on $image_end_date at $image_end_time" | tee -a $output_report
	echo | tee -a $output_report

	echo "Hashing Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $output_report
	echo | tee -a $output_report
	
	echo "******************************************************" | tee -a $output_report
	echo "* Copying E01 Files from Target to Backup with rsync *" | tee -a $output_report
	echo "******************************************************" | tee -a $output_report
	# Establish an rsync log name based on the Evidence ID assigned and the current system Date/Time
	# This way the name is likely to be unique and we are not likely to overwrite an existing file
	echo "Establishing rsync log to document copying imaging logs to backup drive" | tee -a $output_report
	echo

	# An example rsync log is rsynclog.CFS-A00001.20091027.180345.rawimage.log
	# This represents the Evidence IDNumber.YearMonthDay.HourMinuteSecond.rawimage.log
	
	# Note - from here out we append certain output to the rsync log using 'tee -a'
	# Without the -a option to 'append' to an existing file, tee creates a new file 
	# each time, overwriting prior content
	
	echo "*** BEGIN RSYNC Copy Log File for $evid_code ***" | tee -a $output_report
	echo | tee -a $output_report
	copy_date=`date +"%A, %B %d, %Y"`
	copy_time=`date +"%H:%M"`

	echo "***************************************************" | tee -a $output_report
	rsync --version | tee -a $rsynclog		
	echo "***************************************************" | tee -a $output_report
	echo | tee -a $output_report
	echo "Started : $copy_date $copy_time" | tee -a $output_report
	echo | tee -a $output_report
	echo "     Source : $tgt_mnt/$evid_code" | tee -a $output_report
	echo "Destination : $bkup_mnt/$evid_code" | tee -a $output_report
	echo | tee -a $output_report
	echo "Files : *.E" | tee -a $output_report
	echo | tee -a $output_report
	echo "Options : -v -t -P --stats" | tee -a $output_report
	echo | tee -a $output_report
	echo | tee -a $output_report

	rsync -v -t -P --stats $tgt_mnt/$evid_code/*.E* $bkup_mnt/$evid_code | tee -a $rsynclog

	echo | tee -a $output_report
	echo "***********************" | tee -a $output_report
	echo "* Copying is Complete *" | tee -a $output_report
	echo "***********************" | tee -a $output_report
	echo | tee -a $output_report

	echo "Copying Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $output_report
	echo | tee -a $output_report
	cp $rsynclog $tgt_mnt/$evid_code/
	echo
	echo "Image files, Hash log, error log, and audit file copied from Target to Backup"
	echo

	# Gathering imaging and verification statistics for hashing, bytes and sectors imaged
	evid_hash=`cat $tgt_mnt/$evid_code/$evid_code.E01.txt | grep -i -A1 md5 | grep -i md5 | awk '{print $3}' | head -n1`
	tgt_hash=`cat $tgt_mnt/$evid_code/$evid_code.E01.txt | grep -i -A1 md5 | grep -i md5 | awk '{print $3}' | tail -n1`
	bkup_hash=`ewfinfo $bkup_mnt/$evid_code/$evid_code.E01 | grep -i -A1 md5 | awk '{print $2}' | head -n1`
	tgt_bytes=`cat $output_report | grep copied | awk '{print $1}'`
	bkup_bytes=`cat $output_report | grep copied | awk '{print $1}'`
	tgt_sectors=`cat $output_report | grep -A1 results | grep -A1 $tgt_mnt| grep sectors | awk '{print $1}'`
	bkup_sectors=`cat $output_report | grep -A1 results | grep -A1 $bkup_mnt| grep sectors | awk '{print $1}'`

	echo "The acquisition hash for $evid_code is:                   \t$evid_hash" | tee -a $output_report
	echo "The output hash for $evid_code on Target $tgt_code is: \t$tgt_hash" | tee -a $output_report
	echo "The output hash for $evid_code on Backup $bkup_code is:\t$bkup_hash" | tee -a $output_report
	echo | tee -a $output_report

	# Mount evidence drive and image files to obtain file counts.
	echo "Mounting Evidence drive read only and obtaining file counts" | tee -a $output_report
	mkdir /mnt/evidence
	umount /dev/$evid_dev'1'
	mount -o ro -t auto /dev/$evid_dev'1' /mnt/evidence
	evid_count=`find /mnt/evidence -type f -print | wc -l`
	echo "The file count for the Evidence drive $evid_code is: $evid_count"  | tee -a $output_report
	echo | tee -a $output_report

	echo "Mounting Target image files and obtaining file counts" | tee -a $output_report
	mkdir /media/target_raw
	xmount --in ewf $tgt_mnt/$evid_code/$evid_code.E?? /media/target_raw
	mkdir /mnt/target_image
	mount -o loop,offset=$evid_offset1,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image
	tgt_count=`find /mnt/target_image -type f -print | wc -l`
	umount /mnt/target_image
	rmdir /mnt/target_image
	echo "The file count for $evid_code on Target $tgt_code is: $tgt_count"  | tee -a $output_report
	echo | tee -a $output_report

	echo "Mounting Backup image files and obtaining file counts" | tee -a $output_report
	mkdir /media/backup_raw
	xmount --in ewf $bkup_mnt/$evid_code/$evid_code.E?? /media/barget_raw
	mkdir /mnt/backup_image
	mount -o loop,offset=$evid_offset1,ro -t auto /media/backup_raw/$evid_code.dd /mnt/backup_image
	bkup_count=`find /mnt/target_image -type f -print | wc -l`

	umount /mnt/backup_image
	rmdir /mnt/backup_image

	umount /mnt/backup_raw
	rmdir /mnt/backup_raw
	echo "The file count for $evid_code on Backup $bkup_code is: $bkup_count"  | tee -a $output_report
	echo | tee -a $output_report

	
	# If evidence drive has second partition, mount and count files for verification purposes.
	# Script is not currently configured to count files in a third partition.
	if [ "$evid_part_count" != "1" ]
	
	then
		
		evid_offset2=$(($evid_part2_start *512))
		echo "Mounting Evidence drive partition 2 read only and obtaining file counts" | tee -a $output_report
		mkdir /mnt/evidence2
		mount -o ro -t auto /dev/$evid_dev'2' /mnt/evidence2
		evid_count2=`find /mnt/evidence2 -type f -print | wc -l`
		echo "The file count for the Evidence drive $evid_code partition 2 is: $evid_count2"  | tee -a $output_report
		echo | tee -a $output_report		

		echo "Mounting Target image partition 2 files and obtaining file counts" | tee -a $output_report
		mkdir /mnt/target_image2
		mount -o loop,offset=$evid_offset2,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image2
		tgt_count2=`find /mnt/target_image2 -type f -print | wc -l`
		umount /mnt/target_image2
		rmdir /mnt/target_image2
		echo "The file count for $evid_code partition 2 on Target $tgt_code is: $tgt_count2"  | tee -a $output_report
		echo | tee -a $output_report		

		echo "Mounting Target image partition 2 files and obtaining file counts" | tee -a $output_report
		mkdir /mnt/backup_image2
		mount -o loop,offset=$evid_offset2,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image2
		bkup_count2=`find /mnt/target_image2 -type f -print | wc -l`
		umount /mnt/backup_image2
		rmdir /mnt/backup_image2
		echo "The file count for $evid_code partition 2 on Target $bkup_code is: $bkup_count2"  | tee -a $output_report
		echo | tee -a $output_report
	
		files_title="Files_P1\tFiles_P2"
		evid_count_table="$evid_count\t$evid_count2"
		tgt_count_table="$tgt_count\t$tgt_count2"
		bkup_count_table="$bkup_count\t$bkup_count2"

		echo "Writing out file list to $tgt_mnt/$evid_code/$evid_code.filelist.pipe" | tee -a $output_report
		echo -e "file_name|size_bytes|last_modification_time|last_status_change_time|last_access_time|leading_directories" > $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		find /mnt/evidence -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		find /mnt/evidence2 -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		umount /mnt/evidence
		umount /mnt/evidence2
		rmdir /mnt/evidence
		rmdir /mnt/evidence2
		echo "File List Export Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $output_report

	else
		files_title="Files"
		evid_count_table="$evid_count"
		tgt_count_table="$tgt_count"
		bkup_count_table="$bkup_count"

		echo "Writing out file list to $tgt_mnt/$evid_code/$evid_code.filelist.pipe" | tee -a $output_report
		echo -e "file_name|size_bytes|last_modification_time|last_status_change_time|last_access_time|leading_directories" > $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		find /mnt/evidence -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		umount /mnt/evidence
		rmdir /mnt/evidence
		echo "File List Export Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $output_report
		echo | tee -a $output_report
		echo | tee -a $output_report

	fi

	umount /media/target_raw
	rmdir /media/target_raw
	#Launch perl script to parse out file types by key extensions
	perl /bin/filetype.pl $tgt_mnt/$evid_code/$evid_code.filelist.pipe > $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe

	# Display summary of file count
	echo "**** SUMMARY FILE TYPE COUNT ****" | tee -a $output_report
	cat $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | column -s '|' -t | tee -a $output_report
	echo "*********************************" | tee -a $output_report
	echo | tee -a $output_report
	echo | tee -a $output_report
	summaryfile=$tgt_mnt/$evid_code/$evid_code.summary.tsv
	echo -e "Drive\tEvidence ID\tDevice\tBytes\tSectors\t$files_title\tMD5_Hash" > $summaryfile
	echo -e "Evidence\t$evid_code\t$evid_dev\t$evid_bytes\t$evid_sectors\t$evid_count_table\t$evid_hash" >> $summaryfile
	echo -e "Target\t$tgt_code\t$tgt_dev\t$evid_bytes\t$evid_sectors\t$tgt_count_table\t$tgt_hash" >> $summaryfile
	echo -e "Backup\t$bkup_code\t$bkup_dev\t$evid_bytes\t$evid_sectors\t$bkup_count_table\t$bkup_hash" >> $summaryfile

	echo "*************************************Summary Counts**********************************" | tee -a $output_report
	cat $summaryfile | column -t | tee -a $output_report
	echo "*************************************************************************************" | tee -a $output_report
	echo | tee -a $output_report
	echo "Summary Counts Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $output_report
	echo "*** END FTK Acquisition Audit File for $evid_code ***" | tee -a $output_report

	echo "******************************************************"
	echo "* Copying Log Files from Target to Backup with rsync *"
	echo "******************************************************"
	# Establish an rsync log name based on the Evidence ID assigned and the current system Date/Time
	# This way the name is likely to be unique and we are not likely to overwrite an existing file
	echo "Establishing rsync log to document copying imaging logs to backup drive"
	echo
		
	rsynclog=$bkup_mnt/$evid_code/$evid_code.rsynclog.`date +"%Y%m%d.%H%M%S"`.rawimage.log

	# An example rsync log is rsynclog.CFS-A00001.20091027.180345.rawimage.log
	# This represents the Evidence IDNumber.YearMonthDay.HourMinuteSecond.rawimage.log
	
	# Note - from here out we append certain output to the rsync log using 'tee -a'
	# Without the -a option to 'append' to an existing file, tee creates a new file 
	# each time, overwriting prior content
	
	echo "*** BEGIN RSYNC Copy Log File for $evid_code ***" | tee -a $rsynclog
	echo | tee -a $rsynclog
	copy_date=`date +"%A, %B %d, %Y"`
	copy_time=`date +"%H:%M"`

	echo "***************************************************" | tee -a $rsynclog
	rsync --version | tee -a $rsynclog		
	echo "***************************************************" | tee -a $rsynclog
	echo | tee -a $rsynclog
	echo "Started : $copy_date $copy_time" | tee -a $rsynclog
	echo | tee -a $rsynclog
	echo "     Source : $tgt_mnt/$evid_code" | tee -a $rsynclog
	echo "Destination : $bkup_mnt/$evid_code" | tee -a $rsynclog
	echo | tee -a $rsynclog
	echo "Files : *" | tee -a $rsynclog
	echo | tee -a $rsynclog
	echo "Options : -v -t -P --stats --logfile=$rsynclog" | tee -a $rsynclog
	echo | tee -a $rsynclog
	echo "Logging Format : current_time file_name modified_time file_length" | tee -a $rsynclog
	echo | tee -a $rsynclog

	rsync -v -t -P --stats --log-file=$rsynclog --log-file-format="%t  %f  %M  %l" $tgt_mnt/$evid_code/* $bkup_mnt/$evid_code | tee -a $rsynclog

	echo | tee -a $rsynclog
	echo "***********************" | tee -a $rsynclog
	echo "* Copying is Complete *" | tee -a $rsynclog
	echo "***********************" | tee -a $rsynclog
	echo | tee -a $rsynclog

	echo "Copying Completed on" `date +"%A, %B %d %Y"` "at" `date +"%T"` | tee -a $rsynclog
	echo | tee -a $rsynclog
	cp $rsynclog $tgt_mnt/$evid_code/
	echo
	echo "Image files, Hash log, error log, and audit file copied from Target to Backup"
	echo

fi

#Read individual values from pipe log
pst_count=`grep "PST|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
pst_size=`grep "PST|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
ost_count=`grep "OST|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
ost_size=`grep "OST|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
dbx_count=`grep "DBX|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
dbx_size=`grep "DBX|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
nsf_count=`grep "NSF|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
nsf_size=`grep "NSF|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
doc_count=`grep "DOC|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
doc_size=`grep "DOC|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
docx_count=`grep "DOCX|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
docx_size=`grep "DOCX|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
xls_count=`grep "XLS|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
xls_size=`grep "XLS|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
xlsx_count=`grep "XLSX|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
xlsx_size=`grep "XLSX|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
ppt_count=`grep "PPT|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
ppt_size=`grep "PPT|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
pptx_count=`grep "PPTX|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
pptx_size=`grep "PPTX|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`
pdf_count=`grep "PDF|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $2'}`
pdf_size=`grep "PDF|" $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | awk -F "|" {'print $3'}`

# Define logs to store acquisition metadata
info=$tgt_mnt/$evid_code/$evid_code.info.log
info2=$tgt_mnt/$evid_code/$evid_code.info2.tsv
info3=$tgt_mnt/$evid_code/$evid_code.info3.pipe

# Write variables to seperate pipe log on multiple lines to facilitate reporting
echo -e "output_report|$output_report" > $info
echo -e "backup_drive|$backup_drive" >> $info
echo -e "bios_date|$bios_date" >> $info
echo -e "bios_time|$bios_time" >> $info
echo -e "bkup_act_mnt|$bkup_act_mnt" >> $info
echo -e "bkup_code|$bkup_code" >> $info
echo -e "bkup_bytes|$bkup_bytes" >> $info
echo -e "bkup_count|$bkup_count" >> $info
echo -e "bkup_count2|$bkup_count2" >> $info
echo -e "bkup_dev|$bkup_dev" >> $info
echo -e "bkup_dev_firmware|$bkup_dev_firmware" >> $info
echo -e "bkup_dev_id|$bkup_dev_id" >> $info
echo -e "bkup_dev_model|$bkup_dev_model" >> $info
echo -e "bkup_dev_serial|$bkup_dev_serial" >> $info
echo -e "bkup_dev_serialOld|$bkup_dev_serialOld" >> $info
echo -e "bkup_free|$bkup_free" >> $info
echo -e "bkup_hash|$bkup_hash" >> $info
echo -e "bkup_pw|$bkup_pw" >> $info
echo -e "bkup_scsi_model|$bkup_scsi_model" >> $info
echo -e "bkup_scsi_serial|$bkup_scsi_serial" >> $info
echo -e "bkup_scsi_serialOld|$bkup_scsi_serialOld" >> $info
echo -e "bkup_scsi_vendor|$bkup_scsi_vendor" >> $info
echo -e "bkup_sectors|$bkup_sectors" >> $info
echo -e "bkup_size|$bkup_size" >> $info
echo -e "bkup_sn_match|$bkup_sn_match" >> $info
echo -e "blocksize|$blocksize" >> $info
echo -e "city|$city" >> $info
echo -e "copy_date|$copy_date" >> $info
echo -e "copy_time|$copy_time" >> $info
echo -e "country|$country" >> $info
echo -e "curr_date|$curr_date" >> $info
echo -e "curr_time|$curr_time" >> $info
echo -e "custodianFN|$custodianFN" >> $info
echo -e "custodianLN|$custodianLN" >> $info
echo -e "date_match|$date_match" >> $info
echo -e "dbx_count|$dbx_count" >> $info
echo -e "dbx_size|$dbx_size" >> $info
echo -e "doc_count|$doc_count" >> $info
echo -e "doc_size|$doc_size" >> $info
echo -e "docx_count|$docx_count" >> $info
echo -e "docx_size|$docx_size" >> $info
echo -e "eng_code|$eng_code" >> $info
echo -e "evid_code|$evid_code" >> $info
echo -e "evid_bytes|$evid_bytes" >> $info
echo -e "evid_count|$evid_count" >> $info
echo -e "evid_count2|$evid_count2" >> $info
echo -e "evid_dev|$evid_dev" >> $info
echo -e "evid_dev_firmware|$evid_dev_firmware" >> $info
echo -e "evid_dev_model|$evid_dev_model" >> $info
echo -e "evid_dev_serial|$evid_dev_serial" >> $info
echo -e "evid_hash|$evid_hash" >> $info
echo -e "evid_offset1|$evid_offset1" >> $info
echo -e "evid_offset2|$evid_offset2" >> $info
echo -e "evid_part1_field2|$evid_part1_field2" >> $info
echo -e "evid_part1_field3|$evid_part1_field3" >> $info
echo -e "evid_part1_start|$evid_part1_start" >> $info
echo -e "evid_part2_field2|$evid_part2_field2" >> $info
echo -e "evid_part2_field3|$evid_part2_field3" >> $info
echo -e "evid_part2_start|$evid_part2_start" >> $info
echo -e "evid_part_count|$evid_part_count" >> $info
echo -e "evid_sectors|$evid_sectors" >> $info
echo -e "evid_size|$evid_size" >> $info
echo -e "firstname|$firstname" >> $info
echo -e "host_manufacturer|$host_manufacturer" >> $info
echo -e "host_product_name|$host_product_name" >> $info
echo -e "host_serial_number|$host_serial_number" >> $info
echo -e "host_tag|$host_tag" >> $info
echo -e "host_time|$host_time" >> $info
echo -e "host_version|$host_version" >> $info
echo -e "image_end_date|$image_end_date" >> $info
echo -e "image_end_time|$image_end_time" >> $info
echo -e "image_start_date|$image_start_date" >> $info
echo -e "image_start_time|$image_start_time" >> $info
echo -e "lastname|$lastname" >> $info
echo -e "info|$info" >> $info
echo -e "info2|$info2" >> $info
echo -e "nsf_count|$nsf_count" >> $info
echo -e "nsf_size|$nsf_size" >> $info
echo -e "ost_count|$ost_count" >> $info
echo -e "ost_size|$ost_size" >> $info
echo -e "pdf_count|$pdf_count" >> $info
echo -e "pdf_size|$pdf_size" >> $info
echo -e "ppt_count|$ppt_count" >> $info
echo -e "ppt_size|$ppt_size" >> $info
echo -e "pptx_count|$pptx_count" >> $info
echo -e "pptx_size|$pptx_size" >> $info
echo -e "proj_name|$proj_name" >> $info
echo -e "pst_count|$pst_count" >> $info
echo -e "pst_size|$pst_size" >> $info
echo -e "rsynclog|$rsynclog" >> $info
echo -e "state|$state" >> $info
echo -e "summaryfile|$summaryfile" >> $info
echo -e "specific_location|$specific_location" >> $info
echo -e "tgt_act_mnt|$tgt_act_mnt" >> $info
echo -e "tgt_code|$tgt_code" >> $info
echo -e "tgt_bytes|$tgt_bytes" >> $info
echo -e "tgt_count|$tgt_count" >> $info
echo -e "tgt_count2|$tgt_count2" >> $info
echo -e "tgt_dev|$tgt_dev" >> $info
echo -e "tgt_dev_firmware|$tgt_dev_firmware" >> $info
echo -e "tgt_dev_id|$tgt_dev_id" >> $info
echo -e "tgt_dev_model|$tgt_dev_model" >> $info
echo -e "tgt_dev_serial|$tgt_dev_serial" >> $info
echo -e "old_tgt_dev_serial|$old_tgt_dev_serial" >> $info
echo -e "tgt_free|$tgt_free" >> $info
echo -e "tgt_hash|$tgt_hash" >> $info
echo -e "tgt_mnt|$tgt_mnt" >> $info
echo -e "tgt_pw|$tgt_pw" >> $info
echo -e "tgt_scsi_model|$tgt_scsi_model" >> $info
echo -e "tgt_scsi_serial|$tgt_scsi_serial" >> $info
echo -e "old_tgt_scsi_serial|$old_tgt_scsi_serial" >> $info
echo -e "tgt_scsi_vendor|$tgt_scsi_vendor" >> $info
echo -e "tgt_sectors|$tgt_sectors" >> $info
echo -e "tgt_size|$tgt_size" >> $info
echo -e "tgt_sn_match|$tgt_size" >> $info
echo -e "xls_count|$xls_count" >> $info
echo -e "xls_size|$xls_size" >> $info
echo -e "xlsx_count|$xlsx_count" >> $info
echo -e "xlsx_size|$xlsx_size" >> $info

# Write variables to separete tsv log on single line to facilitate importing to database
echo -e "output_report\tbackup_drive\tbios_date\tbios_time\tbkup_act_mnt\tbkup_code\tbkup_bytes\tbkup_count\tbkup_count2\tbkup_dev\tbkup_dev_firmware\tbkup_dev_id\tbkup_dev_model\tbkup_dev_serial\tbkup_dev_serialOld\tbkup_free\tbkup_hash\tbkup_pw\tbkup_scsi_model\tbkup_scsi_serial\tbkup_scsi_serialOld\tbkup_scsi_vendor\tbkup_sectors\tbkup_size\tbkup_sn_match\tblocksize\tcity\tcopy_date\tcopy_time\tcountry\tcurr_date\tcurr_time\tcustodianFN\tcustodianLN\tdate_match\tdbx_count\tdbx_size\tdoc_count\tdoc_size\tdocx_count\tdocx_size\teng_code\tevid_code\tevid_bytes\tevid_count\tevid_count2\tevid_dev\tevid_dev_firmware\tevid_dev_model\tevid_dev_serial\tevid_hash\tevid_offset1\tevid_offset2\tevid_part1_field2\tevid_part1_field3\tevid_part1_start\tevid_part2_field2\tevid_part2_field3\tevid_part2_start\tevid_part_count\tevid_sectors\tevid_size\tfirstname\thost_manufacturer\thost_product_name\thost_serial_number\thost_tag\thost_time\thost_version\timage_end_date\timage_end_time\timage_start_date\timage_start_time\tlastname\tinfo\tinfo2\tnsf_count\tnsf_size\tost_count\tost_size\tpdf_count\tpdf_size\tppt_count\tppt_size\tpptx_count\tpptx_size\tproj_name\tpst_count\tpst_size\trsynclog\tstate\tsummaryfile\tspecific_location\ttgt_act_mnt\ttgt_code\ttgt_bytes\ttgt_count\ttgt_count2\ttgt_dev\ttgt_dev_firmware\ttgt_dev_id\ttgt_dev_model\ttgt_dev_serial\told_tgt_dev_serial\ttgt_free\ttgt_hash\ttgt_mnt\ttgt_pw\ttgt_scsi_model\ttgt_scsi_serial\told_tgt_scsi_serial\ttgt_scsi_vendor\ttgt_sectors\ttgt_size\ttgt_sn_match\txls_count\txls_size\txlsx_count\txlsx_size" > $info2
echo -e "$output_report\t$backup_drive\t$bios_date\t$bios_time\t$bkup_act_mnt\t$bkup_code\t$bkup_bytes\t$bkup_count\t$bkup_count2\t$bkup_dev\t$bkup_dev_firmware\t$bkup_dev_id\t$bkup_dev_model\t$bkup_dev_serial\t$bkup_dev_serialOld\t$bkup_free\t$bkup_hash\t$bkup_pw\t$bkup_scsi_model\t$bkup_scsi_serial\t$bkup_scsi_serialOld\t$bkup_scsi_vendor\t$bkup_sectors\t$bkup_size\t$bkup_sn_match\t$blocksize\t$city\t$copy_date\t$copy_time\t$country\t$curr_date\t$curr_time\t$custodianFN\t$custodianLN\t$date_match\t$dbx_count\t$dbx_size\t$doc_count\t$doc_size\t$docx_count\t$docx_size\t$eng_code\t$evid_code\t$evid_bytes\t$evid_count\t$evid_count2\t$evid_dev\t$evid_dev_firmware\t$evid_dev_model\t$evid_dev_serial\t$evid_hash\t$evid_offset1\t$evid_offset2\t$evid_part1_field2\t$evid_part1_field3\t$evid_part1_start\t$evid_part2_field2\t$evid_part2_field3\t$evid_part2_start\t$evid_part_count\t$evid_sectors\t$evid_size\t$firstname\t$host_manufacturer\t$host_product_name\t$host_serial_number\t$host_tag\t$host_time\t$host_version\t$image_end_date\t$image_end_time\t$image_start_date\t$image_start_time\t$lastname\t$info\t$info2\t$nsf_count\t$nsf_size\t$ost_count\t$ost_size\t$pdf_count\t$pdf_size\t$ppt_count\t$ppt_size\t$pptx_count\t$pptx_size\t$proj_name\t$pst_count\t$pst_size\t$rsynclog\t$state\t$summaryfile\t$specific_location\t$tgt_act_mnt\t$tgt_code\t$tgt_bytes\t$tgt_count\t$tgt_count2\t$tgt_dev\t$tgt_dev_firmware\t$tgt_dev_id\t$tgt_dev_model\t$tgt_dev_serial\t$old_tgt_dev_serial\t$tgt_free\t$tgt_hash\t$tgt_mnt\t$tgt_pw\t$tgt_scsi_model\t$tgt_scsi_serial\t$old_tgt_scsi_serial\t$tgt_scsi_vendor\t$tgt_sectors\t$tgt_size\t$tgt_sn_match\t$xls_count\t$xls_size\t$xlsx_count\t$xlsx_size" >> $info2

# Write variables to seperate pipe delimited log on single line to facilitate importing to database
echo -e "output_report|backup_drive|bios_date|bios_time|bkup_act_mnt|bkup_code|bkup_bytes|bkup_count|bkup_count2|bkup_dev|bkup_dev_firmware|bkup_dev_id|bkup_dev_model|bkup_dev_serial|bkup_dev_serialOld|bkup_free|bkup_hash|bkup_pw|bkup_scsi_model|bkup_scsi_serial|bkup_scsi_serialOld|bkup_scsi_vendor|bkup_sectors|bkup_size|bkup_sn_match|blocksize|city|copy_date|copy_time|country|curr_date|curr_time|custodianFN|custodianLN|date_match|dbx_count|dbx_size|doc_count|doc_size|docx_count|docx_size|eng_code|evid_code|evid_bytes|evid_count|evid_count2|evid_dev|evid_dev_firmware|evid_dev_model|evid_dev_serial|evid_hash|evid_offset1|evid_offset2|evid_part1_field2|evid_part1_field3|evid_part1_start|evid_part2_field2|evid_part2_field3|evid_part2_start|evid_part_count|evid_sectors|evid_size|firstname|host_manufacturer|host_product_name|host_serial_number|host_tag|host_time|host_version|image_end_date|image_end_time|image_start_date|image_start_time|lastname|info|info2|nsf_count|nsf_size|ost_count|ost_size|pdf_count|pdf_size|ppt_count|ppt_size|pptx_count|pptx_size|proj_name|pst_count|pst_size|rsynclog|state|summaryfile|specific_location|tgt_act_mnt|tgt_code|tgt_bytes|tgt_count|tgt_count2|tgt_dev|tgt_dev_firmware|tgt_dev_id|tgt_dev_model|tgt_dev_serial|old_tgt_dev_serial|tgt_free|tgt_hash|tgt_mnt|tgt_pw|tgt_scsi_model|tgt_scsi_serial|old_tgt_scsi_serial|tgt_scsi_vendor|tgt_sectors|tgt_size|tgt_sn_match|xls_count|xls_size|xlsx_count|xlsx_size" > $info3
echo -e "$output_report|$backup_drive|$bios_date|$bios_time|$bkup_act_mnt|$bkup_code|$bkup_bytes|$bkup_count|$bkup_count2|$bkup_dev|$bkup_dev_firmware|$bkup_dev_id|$bkup_dev_model|$bkup_dev_serial|$bkup_dev_serialOld|$bkup_free|$bkup_hash|$bkup_pw|$bkup_scsi_model|$bkup_scsi_serial|$bkup_scsi_serialOld|$bkup_scsi_vendor|$bkup_sectors|$bkup_size|$bkup_sn_match|$blocksize|$city|$copy_date|$copy_time|$country|$curr_date|$curr_time|$custodianFN|$custodianLN|$date_match|$dbx_count|$dbx_size|$doc_count|$doc_size|$docx_count|$docx_size|$eng_code|$evid_code|$evid_bytes|$evid_count|$evid_count2|$evid_dev|$evid_dev_firmware|$evid_dev_model|$evid_dev_serial|$evid_hash|$evid_offset1|$evid_offset2|$evid_part1_field2|$evid_part1_field3|$evid_part1_start|$evid_part2_field2|$evid_part2_field3|$evid_part2_start|$evid_part_count|$evid_sectors|$evid_size|$firstname|$host_manufacturer|$host_product_name|$host_serial_number|$host_tag|$host_time|$host_version|$image_end_date|$image_end_time|$image_start_date|$image_start_time|$lastname|$info|$info2|$nsf_count|$nsf_size|$ost_count|$ost_size|$pdf_count|$pdf_size|$ppt_count|$ppt_size|$pptx_count|$pptx_size|$proj_name|$pst_count|$pst_size|$rsynclog|$state|$summaryfile|$specific_location|$tgt_act_mnt|$tgt_code|$tgt_bytes|$tgt_count|$tgt_count2|$tgt_dev|$tgt_dev_firmware|$tgt_dev_id|$tgt_dev_model|$tgt_dev_serial|$old_tgt_dev_serial|$tgt_free|$tgt_hash|$tgt_mnt|$tgt_pw|$tgt_scsi_model|$tgt_scsi_serial|$old_tgt_scsi_serial|$tgt_scsi_vendor|$tgt_sectors|$tgt_size|$tgt_sn_match|$xls_count|$xls_size|$xlsx_count|$xlsx_size" >> $info3
   

# Write infos to backup image (if it exists)
if [ "$backup_drive" == "n" ]
then
	echo ""
else
	cp $tgt_mnt/$evid_code/$evid_code.info* $bkup_mnt/$evid_code/
fi

# beep five times to alert imager that the image is done
echo -e '\a'
sleep .4
echo -e '\a'
sleep .4
echo -e '\a'
sleep .4
echo -e '\a'
sleep .4
echo -e '\a'

# Display last lines of audit log on screen to ease verification.
tail -26 $output_report
echo
echo "*********************************************************************************"
echo "* REVIEW SUMMARY COUNTS AND PERFORM VERIFICATION PROCEDURES.  WHEN VERIFICATION *"
echo "* PROCEDURES ARE COMPLETE, SHUTDOWN THE COMPUTER BY ISSUING THE COMMAND:        *"
echo "*********************************************************************************"
echo
while [[ "$promptEnd" != "Close" ]]
do
echo -e "** Please type 'Close' when you are ready to exit: \c "
read promptEnd
done