#!/bin/bash
# Clear the screen
clear
clear
# Script to image devices with linux Distro
# v2021.12.29
# Updated December 2021
# GPL 3.0
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
while [[ "$prompt1" != "y" ]]
do
read prompt1
done
# Acquisition information
read firstname lastname
#
read custodianFN custodianLN
#
read proj_name
#
read eng_code
#
read city
read state
read country
#
read specific_location
#
read host_tag
# Ask the user if the current system date and time actual match local date and time. 
# If they match, use system date and time as local date and time.
# If they do not match, input local date and time.
date_match="x"
while [[ "$date_match" != "y" && "$date_match" != "n" ]]
do
read date_match
done

if [ "$date_match" == "y" ]
then

else
	read curr_date
fi

time_match="x"
while [[ "$time_match" != "y" &&  "$time_match" != "n" ]]
do
read time_match
done

if [ "$time_match" == "y" ]
then

else
	read curr_time
fi
clear
# End of Datetime information


dmesg | grep logical | grep blocks
fdisk -l | grep bytes | grep Disk | grep -v veracrypt | grep -v ram | grep -v loop | awk '{print "sd 0:0:0:0:\t["$2"]\t"$5" "$6"\t logical blocks: ("$3" "$4")"}' | sed 's/,//g'
read evid_dev
read evid_code
while [[ "$prompt2" != "y" ]]
do
read prompt2
done
sleep 3
dmesg | grep logical | grep blocks
fdisk -l | grep bytes | grep Disk | grep -v veracrypt | grep -v ram | grep -v loop | awk '{print "sd 0:0:0:0:\t["$2"]\t"$5" "$6"\t logical blocks: ("$3" "$4")"}' | sed 's/,//g'
read tgt_dev
read tgt_code
ntfslabel /dev/$tgt_dev'1' "$tgt_code"
read tgt_pw
veracrypt --password=$tgt_pw --slot=1 /dev/$tgt_dev'2'
tgt_mnt=/media/veracrypt1
#
## Uncomment if imaging to an unencrypted harddrive.
## mkdir /mnt/target
## ntfs-3g /dev/$tgt_dev'1' /mnt/target
## tgt_mnt=/mnt/target
#
mkdir $tgt_mnt/$evid_code
#
# Establish an auditfile name based on the Evidence ID assigned and the current system Date/Time
# This way the name is likely to be unique and we are not likely to overwrite an existing file
#

auditfile=$tgt_mnt/$evid_code/$evid_code.`date +"%Y%m%d.%H%M%S"`.wri
sysinfofull=$tgt_mnt/$evid_code/$evid_code.SystemFullInformation.wri
diskauditfile=$tgt_mnt/$evid_code/$evid_code.DisksInformation.wri

# An example auditfile is ID.20150617.150617.wri
# This represents the EvidenceID.YearMonthDay.HourMinuteSecond.wri

# Note - from here out we append certain output to the auditfile using 'tee -a'
# Without the -a option to 'append' to an existing file, tee creates a new file 
# each time, overwriting prior content




# Since we are using the custodian's computer as our forensic acquisition platform,
# record certain information about the custodian's computer


# dmidecode is a Linux utility to query the system BIOS for certain data

lshw >> $sysinfofull




hdparm -r1 /dev/$evid_dev'*'  | tee -a $auditfile

# Set blocksize == even multiple of LBASectors
# If BS != and even multiple of LBASectors, the image will have more sectors than the drive
# Part of our QC procedures is to verify the # of sectors in the image == the drive LBA

# Read and parse output lines from hdparm and fdisk to populate a local variables
# LBASectors = the number of sectors on the drive



if ((($LBASectors %64) == 0))
then
	blocksize=32768
elif ((($LBASectors %32) == 0))
then
	blocksize=16384
elif ((($LBASectors %16) == 0))
then
	blocksize=8192
elif ((($LBASectors %8) == 0))
then
	blocksize=4096
elif ((($LBASectors %4) == 0))
then
	blocksize=2048
elif ((($LBASectors %2) == 0))
then
	blocksize=1024
else
	blocksize=512
fi


fdisk -l /dev/$evid_dev | tee -a $auditfile

# Store information about the evidence drive partitions to facilitate verification.

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
# End of Hard Drive information

while [[ "$prompt4" != "y" ]]
do
read compress_rate
read prompt4
done	

#INICIO INFORMACAO HD TARGET




# for grep, -i is case insensitive and -m stops reading after the 1st match

((tgt_dev_id=tgt_dev_id+0)) #make sure this variable is a number, not a string
((tgt_dev_id=tgt_dev_id+`dmesg | grep -i -m 1 $tgt_dev | awk -F'[sd:]' '{print $3}'`))



cat /proc/scsi/scsi | grep -A 1 "scsi$tgt_dev_id"  | tee -a $auditfile

read tgt_sn_match

if [ "$tgt_sn_match" == "y" ]
then

else
	old_tgt_dev_serial = $tgt_dev_serial
	old_tgt_scsi_serial = $tgt_scsi_serial
	read tgt_dev_serial
	read tgt_scsi_serial
fi


fdisk -l /dev/$tgt_dev | tee -a $auditfile
##End target info


backup_drive="x"
while [[ "$backup_drive" != "y" &&  "$backup_drive" != "n" ]]
do
read backup_drive
done

if [ "$backup_drive" == "n" ]
then


	
	cat /proc/scsi/scsi  | grep -i host -A 1 | tee -a $auditfile
	mount | tee -a $auditfile
	df -h | tee -a $auditfile
	cat /home/$USER/t_summary | column -t | tee -a $auditfile
	rm -f /home/$USER/t_summary
	while [[ "$prompt3" != "y" ]]
	do
	read prompt3
	done	


	# Deleting any previous image files from aborted imaging sessions and hash logs with the same Evidence ID before writing new image files
	rm -f $tgt_mnt/$evid_code/$evid_code.hash.log.wri
	rm -f $tgt_mnt/$evid_code/$evid_code.E*
	

	
	ftkimager /dev/$evid_dev $tgt_mnt/$evid_code/$evid_code --verify --no-sha1 --e01 --frag 2G --compress $compress_rate --case-number $evid_code --evidence-number $evid_code --examiner "$firstname $lastname"





	# Gather hash, byte and sector information for later verification.
	
	# Mount evidence drive and image files to obtain file counts.
	mkdir /mnt/evidence
	umount /dev/$evid_dev'1'
	mount -o ro -t auto /dev/$evid_dev'1' /mnt/evidence

	mkdir /media/target_raw
	xmount --in ewf $tgt_mnt/$evid_code/$evid_code.E?? /media/target_raw
	mkdir /mnt/target_image
	mount -o loop,offset=$evid_offset1,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image
	umount /mnt/target_image
	rmdir /mnt/target_image
	
	# If evidence drive has second partition, mount and count files for verification purposes.
	# Script is not currently configured to count files in a third partition.
	if [ "$evid_part_count" != "1" ]
	
	then
		
		evid_offset2=$(($evid_part2_start *512))
		mkdir /mnt/evidence2
		mount -o ro -t auto /dev/$evid_dev'2' /mnt/evidence2

		mkdir /mnt/target_image2
		mount -o loop,offset=$evid_offset2,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image2
		umount /mnt/target_image2
		rmdir /mnt/target_image2
	
		files_title="Files_P1\tFiles_P2"
		evid_count_table="$evid_count\t$evid_count2"
		tgt_count_table="$tgt_count\t$tgt_count2"
		
		find /mnt/evidence -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		find /mnt/evidence2 -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		umount /mnt/evidence
		umount /mnt/evidence2
		rmdir /mnt/evidence
		rmdir /mnt/evidence2

	else
		files_title="Files"
		evid_count_table="$evid_count"
		tgt_count_table="$tgt_count"

		find /mnt/evidence -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		umount /mnt/evidence
		rmdir /mnt/evidence

	fi

	umount /media/target_raw
	rmdir /media/target_raw
	#Launch perl script to parse out file types by key extensions
	perl /bin/filetype.pl $tgt_mnt/$evid_code/$evid_code.filelist.pipe > $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe

	# Display summary of file count
	cat $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | column -s '|' -t | tee -a $auditfile
	summaryfile=$tgt_mnt/$evid_code/$evid_code.summary.tsv

	cat $summaryfile | column -t | tee -a $auditfile
		
else

	while [[ "$prompt4" != "y" ]]
	do
	read prompt4
	done
	sleep 3
	dmesg | grep logical | grep blocks
	fdisk -l | grep bytes | grep Disk | grep -v veracrypt | grep -v ram | grep -v loop | awk '{print "sd 0:0:0:0:\t["$2"]\t"$5" "$6"\t logical blocks: ("$3" "$4")"}' | sed 's/,//g'

	read bkup_dev

	read bkup_code

	ntfslabel /dev/$bkup_dev'1' "$bkup_code"

	read bkup_pw

	veracrypt --password=$bkup_pw --slot=2 /dev/$bkup_dev'2'

	bkup_mnt=/media/veracrypt2

	## Uncomment if imaging to an unencrypted drive.
	##mkdir /mnt/backup
	##ntfs-3g /dev/$bkup_dev'1' /mnt/backup
	##bkup_mnt=/mnt/backup

	mkdir $bkup_mnt/$evid_code




	# for grep, -i is case insensitive and -m stops reading after the 1st match
	
	((bkup_dev_id=bkup_dev_id+0)) #make sure this variable is a number, not a string
	((bkup_dev_id=bkup_dev_id+`dmesg | grep -i -m 1 $bkup_dev | awk -F'[sd:]' '{print $3}'`))



	cat /proc/scsi/scsi | grep -A 1 "scsi$bkup_dev_id"  | tee -a $auditfile

	read bkup_sn_match

	if [ "$bkup_sn_match" == "y" ]
	then

	else
		bkup_dev_serialOld = $bkup_dev_serial
		bkup_scsi_serialOld = $bkup_scsi_serial
		read bkup_dev_serial bkup_scsi_serial
	fi


	fdisk -l /dev/$bkup_dev | tee -a $auditfile



	cat /proc/scsi/scsi  | grep -i host -A 1 | tee -a $auditfile
	mount | tee -a $auditfile
	df -h | tee -a $auditfile

	#### DISK INFORMATION FOR ANALYSIS
	lshw -class disk | egrep "description|product|vendor|serial|size|-" >> $diskauditfile
	smartctl -i /dev/$evid_dev | grep : >> $diskauditfile
	smartctl -i /dev/$tgt_dev | grep : >> $diskauditfile
	smartctl -i /dev/$bkup_dev | grep : >> $diskauditfile

	cat /home/$USER/t_summary | column -t | tee -a $auditfile
	rm -f /home/$USER/t_summary
	while [[ "$prompt5" != "y" ]]
	do
	read prompt5
	done


	# Deleting any previous image files from aborted imaging sessions and hash logs with the same Evidence ID before writing new image files
	rm -f $tgt_mnt/$evid_code/$evid_code.hash.log.wri
	rm -f $tgt_mnt/$evid_code/$evid_code.E*
	

	
	ftkimager /dev/$evid_dev $tgt_mnt/$evid_code/$evid_code --verify --no-sha1 --e01 --frag 2G --compress $compress_rate --case-number $evid_code --evidence-number $evid_code --examiner "$firstname $lastname"



	
	# Establish an rsync log name based on the Evidence ID assigned and the current system Date/Time
	# This way the name is likely to be unique and we are not likely to overwrite an existing file

	# An example rsync log is rsynclog.CFS-A00001.20091027.180345.wri
	# This represents the Evidence IDNumber.YearMonthDay.HourMinuteSecond.wri
	
	# Note - from here out we append certain output to the rsync log using 'tee -a'
	# Without the -a option to 'append' to an existing file, tee creates a new file 
	# each time, overwriting prior content
	

	rsync --version | tee -a $rsynclog		

	rsync -v -t -P --stats $tgt_mnt/$evid_code/*.E* $bkup_mnt/$evid_code | tee -a $rsynclog


	cp $rsynclog $tgt_mnt/$evid_code/

	# Gathering imaging and verification statistics for hashing, bytes and sectors imaged


	# Mount evidence drive and image files to obtain file counts.
	mkdir /mnt/evidence
	umount /dev/$evid_dev'1'
	mount -o ro -t auto /dev/$evid_dev'1' /mnt/evidence

	mkdir /media/target_raw
	xmount --in ewf $tgt_mnt/$evid_code/$evid_code.E?? /media/target_raw
	mkdir /mnt/target_image
	mount -o loop,offset=$evid_offset1,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image
	umount /mnt/target_image
	rmdir /mnt/target_image

	mkdir /media/backup_raw
	xmount --in ewf $bkup_mnt/$evid_code/$evid_code.E?? /media/barget_raw
	mkdir /mnt/backup_image
	mount -o loop,offset=$evid_offset1,ro -t auto /media/backup_raw/$evid_code.dd /mnt/backup_image

	umount /mnt/backup_image
	rmdir /mnt/backup_image

	umount /mnt/backup_raw
	rmdir /mnt/backup_raw

	
	# If evidence drive has second partition, mount and count files for verification purposes.
	# Script is not currently configured to count files in a third partition.
	if [ "$evid_part_count" != "1" ]
	
	then
		
		evid_offset2=$(($evid_part2_start *512))
		mkdir /mnt/evidence2
		mount -o ro -t auto /dev/$evid_dev'2' /mnt/evidence2

		mkdir /mnt/target_image2
		mount -o loop,offset=$evid_offset2,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image2
		umount /mnt/target_image2
		rmdir /mnt/target_image2

		mkdir /mnt/backup_image2
		mount -o loop,offset=$evid_offset2,ro -t auto /media/target_raw/$evid_code.dd /mnt/target_image2
		umount /mnt/backup_image2
		rmdir /mnt/backup_image2
	
		files_title="Files_P1\tFiles_P2"
		evid_count_table="$evid_count\t$evid_count2"
		tgt_count_table="$tgt_count\t$tgt_count2"
		bkup_count_table="$bkup_count\t$bkup_count2"

		find /mnt/evidence -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		find /mnt/evidence2 -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		umount /mnt/evidence
		umount /mnt/evidence2
		rmdir /mnt/evidence
		rmdir /mnt/evidence2

	else
		files_title="Files"
		evid_count_table="$evid_count"
		tgt_count_table="$tgt_count"
		bkup_count_table="$bkup_count"

		find /mnt/evidence -type f -printf "%f|%s|%t|%c|%a|%h\n" >> $tgt_mnt/$evid_code/$evid_code.filelist.pipe
		umount /mnt/evidence
		rmdir /mnt/evidence

	fi

	umount /media/target_raw
	rmdir /media/target_raw
	#Launch perl script to parse out file types by key extensions
	perl /bin/filetype.pl $tgt_mnt/$evid_code/$evid_code.filelist.pipe > $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe

	# Display summary of file count
	cat $tgt_mnt/$evid_code/$evid_code.filetype_count.pipe | column -s '|' -t | tee -a $auditfile
	summaryfile=$tgt_mnt/$evid_code/$evid_code.summary.tsv

	cat $summaryfile | column -t | tee -a $auditfile

	# Establish an rsync log name based on the Evidence ID assigned and the current system Date/Time
	# This way the name is likely to be unique and we are not likely to overwrite an existing file
		
	rsynclog=$bkup_mnt/$evid_code/$evid_code.rsynclog.`date +"%Y%m%d.%H%M%S"`.wri

	# An example rsync log is rsynclog.CFS-A00001.20091027.180345.wri
	# This represents the Evidence IDNumber.YearMonthDay.HourMinuteSecond.wri
	
	# Note - from here out we append certain output to the rsync log using 'tee -a'
	# Without the -a option to 'append' to an existing file, tee creates a new file 
	# each time, overwriting prior content
	

	rsync --version | tee -a $rsynclog		

	rsync -v -t -P --stats --log-file=$rsynclog --log-file-format="%t  %f  %M  %l" $tgt_mnt/$evid_code/* $bkup_mnt/$evid_code | tee -a $rsynclog


	cp $rsynclog $tgt_mnt/$evid_code/

fi

#Read individual values from pipe log

# Define logs to store acquisition metadata
metalog=$tgt_mnt/$evid_code/$evid_code.metalog.log
metalog2=$tgt_mnt/$evid_code/$evid_code.metalog2.tsv
metalog3=$tgt_mnt/$evid_code/$evid_code.metalog3.pipe

# Write variables to seperate pipe log on multiple lines to facilitate reporting

# Write variables to separete tsv log on single line to facilitate importing to database

# Write variables to seperate pipe delimited log on single line to facilitate importing to database
   

# Write metalogs to backup image (if it exists)
if [ "$backup_drive" == "n" ]
then
else
	cp $tgt_mnt/$evid_code/$evid_code.metalog* $bkup_mnt/$evid_code/
fi

# beep five times to alert imager that the image is done
sleep .4
sleep .4
sleep .4
sleep .4

# Display last lines of audit log on screen to ease verification.
tail -26 $auditfile
while [[ "$promptEnd" != "Close" ]]
do
read promptEnd
done
