#!/usr/bin/env bash
# Clear the screen
clear
# Script to image devices with linux Distro
# v2022.01.01
# Updated January 2022
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

### Colors ##
ESC=$(printf '\033') RESET="${ESC}[0m" BLACK="${ESC}[30m" RED="${ESC}[31m"
GREEN="${ESC}[32m" YELLOW="${ESC}[33m" BLUE="${ESC}[34m" MAGENTA="${ESC}[35m"
CYAN="${ESC}[36m" WHITE="${ESC}[37m" DEFAULT="${ESC}[39m"

### Color Functions ##
greenprint() { printf "${GREEN}%s${RESET}\n" "$1"; }
blueprint() { printf "${BLUE}%s${RESET}\n" "$1"; }
redprint() { printf "${RED}%s${RESET}\n" "$1"; }
yellowprint() { printf "${YELLOW}%s${RESET}\n" "$1"; }
magentaprint() { printf "${MAGENTA}%s${RESET}\n" "$1"; }
cyanprint() { printf "${CYAN}%s${RESET}\n" "$1"; }
fn_goodafternoon() { echo; echo "Good afternoon."; }
fn_goodmorning() { echo; echo "Good morning."; }
fn_bye() { echo "Bye bye."; exit 0; }
fn_fail() { echo "Wrong option." exit 1; }

output_report=/home/Nifferr/report.log

forensic_framework() {
    echo -ne "
$(greenprint 'REPORT ACQUISITION')
$(greenprint '1)') READ ME FIRST
$(yellowprint '2)') START ACQUISITION THE INFORMATION
$(blueprint '3)') GENERATE REPORT
$(magentaprint '4)') CANCEL
$(redprint '0)') Exit
Choose an option:  "
    read -r ans
    case $ans in
    1)
        fn_goodmorning
        function_readme
        forensic_framework
        ;;
    2)
        fn_getinfo
        fn_get_diskinfo
        fn_output_getinfo
        fn_report
        fn_report_evidence
        forensic_framework
        ;;
    3)
        fn_get_diskinfo
        forensic_framework
        ;;
    4)
        fn_report_evidence
        fn_report_target
        fn_report_backup
        forensic_framework
        ;;
    0)
        fn_bye
        ;;
    *)
        fn_fail
        ;;
    esac
}

fn_report() {
curr_date=`date +"%A, %B %d, %Y"`
curr_time=`date +"%H:%M"`
timezone_host=`date +"%:::z %Z"`
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
#host information
echo "******************************************"
echo "*           Host Information             *"
echo "******************************************"
echo
echo $(blueprint "Host Type:") $host_type 
echo $(blueprint "Host Manufacturer:") $host_manufacturer
echo $(blueprint "Host Product Name:") $host_product_name 
echo $(blueprint "Host Tag:") $host_tag
echo $(blueprint "Host Version:") $host_version
echo $(blueprint "Host Serial Number:") $host_serial_number
echo $(blueprint "BIOS Date:") $bios_date
echo $(blueprint "BIOS Time:") $bios_time 
echo
}

fn_report_evidence() {
evid_dev_model=`/bin/udevadm info --name=/dev/$evid_dev | egrep ID_MODEL | awk  -F'[=,]' '{print $2}' | sed -n 1p`
evid_dev_vendor=`/bin/udevadm info --name=/dev/$evid_dev | egrep ID_VENDOR | awk  -F'[=,]' '{print $2}' | sed -n 1p`
evid_dev_serial=`/bin/udevadm info --name=/dev/$evid_dev | egrep ID_SERIAL_SHORT | awk  -F'[=,]' '{print $2}'`
evid_dev_firmware=`hdparm -I /dev/$evid_dev 2>/dev/null | grep -i 'Firmware Revision' | awk '{print $3" "$4" "$5" "$6}'`
LBASectors=`hdparm -g /dev/$evid_dev | awk -F'[=,]' '{print $4}'`
evid_transport=`/bin/udevadm info --name=/dev/$evid_dev | egrep ID_BUS | awk  -F'[=,]' '{print $2}'`
evid_sectors=`echo $LBASectors | awk '{print $1}'`
evid_bytes=`fdisk -l -u /dev/$evid_dev | grep $evid_dev | grep bytes | awk '{print $5}'`
evid_size=`fdisk -l -u /dev/$evid_dev | grep Disk | grep $evid_dev | awk '{print $3$4}'`
evid_part_count=`fdisk -l -u /dev/$evid_dev | grep $evid_dev | grep -v Disk | wc -l`
evid_part1_field2=`fdisk -l -u /dev/$evid_dev | grep -A1 Device | grep $evid_dev'1' | awk '{print $2}'`
evid_part1_field3=`fdisk -l -u /dev/$evid_dev | grep -A1 Device | grep $evid_dev'1' | awk '{print $3}'`
evid_part2_field2=`fdisk -l -u /dev/$evid_dev | grep -A2 Device | grep $evid_dev'2' | awk '{print $2}'`
evid_part2_field3=`fdisk -l -u /dev/$evid_dev | grep -A2 Device | grep $evid_dev'2' | awk '{print $3}'`
trim_status=`sudo systemctl status fstrim | grep Active | awk '{print $2}'`
#evidence information
echo "******************************************"
echo "*         Evidence Information           *"
echo "******************************************"
echo
echo $(blueprint "Evidence mount point:") "/dev/$evid_dev" 
echo $(blueprint "Evidence device vendor:") "$evid_dev_vendor" 
echo $(blueprint "Evidence device model:") "$evid_dev_model" 
echo $(blueprint "Evidence device serial:") "$evid_dev_serial" 
echo $(blueprint "Evidence device firmware:") "$evid_dev_firmware" 
echo $(blueprint "Evidence transport type:") "$evid_transport"
echo $(blueprint "Evidence trim status:") "$trim_status"
echo $(blueprint "Evidence sectors:") "$evid_sectors"
echo $(blueprint "Evidence bytes:") "$evid_bytes"
echo $(blueprint "Evidence size:") "$evid_size" 
if ((($LBASectors %64) == 0))
then
	blocksize=32768
	echo $(blueprint "Evidence blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %32) == 0))
then
	blocksize=16384
	echo $(blueprint "Evidence blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %16) == 0))
then
	blocksize=8192
	echo $(blueprint "Evidence blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %8) == 0))
then
	blocksize=4096
	echo $(blueprint "Evidence blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %4) == 0))
then
	blocksize=2048
	echo $(blueprint "Evidence blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %2) == 0))
then
	blocksize=1024
	echo $(blueprint "Evidence blocksize:") $blocksize | tee -a $output_report
else
	blocksize=512
	echo $(blueprint "Evidence blocksize:") $blocksize | tee -a $output_report
fi
echo
}

fn_report_target() {
tgt_dev_model=`/bin/udevadm info --name=/dev/$tgt_dev | egrep ID_MODEL | awk  -F'[=,]' '{print $2}' | sed -n 1p`
tgt_dev_vendor=`/bin/udevadm info --name=/dev/$tgt_dev | egrep ID_VENDOR | awk  -F'[=,]' '{print $2}' | sed -n 1p`
tgt_dev_serial=`/bin/udevadm info --name=/dev/$tgt_dev | egrep ID_SERIAL_SHORT | awk  -F'[=,]' '{print $2}'`
tgt_dev_firmware=`hdparm -I /dev/$tgt_dev 2>/dev/null | grep -i 'Firmware Revision' | awk '{print $3" "$4" "$5" "$6}'`
LBASectors=`hdparm -g /dev/$tgt_dev | awk -F'[=,]' '{print $4}'`
tgt_transport=`/bin/udevadm info --name=/dev/$tgt_dev | egrep ID_BUS | awk  -F'[=,]' '{print $2}'`
tgt_sectors=`echo $LBASectors | awk '{print $1}'`
tgt_bytes=`fdisk -l -u /dev/$tgt_dev | grep $tgt_dev | grep bytes | awk '{print $5}'`
tgt_size=`fdisk -l -u /dev/$tgt_dev | grep Disk | grep $tgt_dev | awk '{print $3$4}'`
tgt_part_count=`fdisk -l -u /dev/$tgt_dev | grep $tgt_dev | grep -v Disk | wc -l`
tgt_part1_field2=`fdisk -l -u /dev/$tgt_dev | grep -A1 Device | grep $tgt_dev'1' | awk '{print $2}'`
tgt_part1_field3=`fdisk -l -u /dev/$tgt_dev | grep -A1 Device | grep $tgt_dev'1' | awk '{print $3}'`
tgt_part2_field2=`fdisk -l -u /dev/$tgt_dev | grep -A2 Device | grep $tgt_dev'2' | awk '{print $2}'`
tgt_part2_field3=`fdisk -l -u /dev/$tgt_dev | grep -A2 Device | grep $tgt_dev'2' | awk '{print $3}'`
trim_status=`sudo systemctl status fstrim | grep Active | awk '{print $2}'`
#Target information
echo "******************************************"
echo "*          Target Information            *"
echo "******************************************"
echo
echo $(blueprint "Target mount point:") "/dev/$tgt_dev" 
echo $(blueprint "Target device vendor:") "$tgt_dev_vendor" 
echo $(blueprint "Target device model:") "$tgt_dev_model" 
echo $(blueprint "Target device serial:") "$tgt_dev_serial" 
echo $(blueprint "Target device firmware:") "$tgt_dev_firmware" 
echo $(blueprint "Target transport type:") "$tgt_transport"
echo $(blueprint "Target trim status:") "$trim_status"
echo $(blueprint "Target sectors:") "$tgt_sectors"
echo $(blueprint "Target bytes:") "$tgt_bytes"
echo $(blueprint "Target size:") "$tgt_size" 
if ((($LBASectors %64) == 0))
then
	blocksize=32768
	echo $(blueprint "Target blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %32) == 0))
then
	blocksize=16384
	echo $(blueprint "Target blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %16) == 0))
then
	blocksize=8192
	echo $(blueprint "Target blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %8) == 0))
then
	blocksize=4096
	echo $(blueprint "Target blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %4) == 0))
then
	blocksize=2048
	echo $(blueprint "Target blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %2) == 0))
then
	blocksize=1024
	echo $(blueprint "Target blocksize:") $blocksize | tee -a $output_report
else
	blocksize=512
	echo $(blueprint "Target blocksize:") $blocksize | tee -a $output_report
fi
echo
}


fn_get_diskinfo() {
echo "******************************************"
echo "*           Disk Information             *"
echo "******************************************"
fdisk -l | grep bytes | grep Disk | grep -v veracrypt | grep -v ram | grep -v loop | awk '{print "["$2"]\t"$5" "$6"\t logical blocks: ("$3" "$4")"}' | sed 's/,/./g'
echo "******************************************"
echo
echo -e "** Please enter the mount point of evidence drive (eg. sda): \c "
read evid_dev
echo -e "** Please enter the mount point of target drive (eg. sdb): \c "
read tgt_dev
echo -e "** Please enter the mount point of backup drive (eg. sdc): \c "
read bkp_dev
}

fn_encrypt() {
    echo
}


fn_report_backup() {
bkp_dev_model=`/bin/udevadm info --name=/dev/$bkp_dev | egrep ID_MODEL | awk  -F'[=,]' '{print $2}' | sed -n 1p`
bkp_dev_vendor=`/bin/udevadm info --name=/dev/$bkp_dev | egrep ID_VENDOR | awk  -F'[=,]' '{print $2}' | sed -n 1p`
bkp_dev_serial=`/bin/udevadm info --name=/dev/$bkp_dev | egrep ID_SERIAL_SHORT | awk  -F'[=,]' '{print $2}'`
bkp_dev_firmware=`hdparm -I /dev/$bkp_dev 2>/dev/null | grep -i 'Firmware Revision' | awk '{print $3" "$4" "$5" "$6}'`
LBASectors=`hdparm -g /dev/$bkp_dev | awk -F'[=,]' '{print $4}'`
bkp_transport=`/bin/udevadm info --name=/dev/$bkp_dev | egrep ID_BUS | awk  -F'[=,]' '{print $2}'`
bkp_sectors=`echo $LBASectors | awk '{print $1}'`
bkp_bytes=`fdisk -l -u /dev/$bkp_dev | grep $bkp_dev | grep bytes | awk '{print $5}'`
bkp_size=`fdisk -l -u /dev/$bkp_dev | grep Disk | grep $bkp_dev | awk '{print $3$4}'`
bkp_part_count=`fdisk -l -u /dev/$bkp_dev | grep $bkp_dev | grep -v Disk | wc -l`
bkp_part1_field2=`fdisk -l -u /dev/$bkp_dev | grep -A1 Device | grep $bkp_dev'1' | awk '{print $2}'`
bkp_part1_field3=`fdisk -l -u /dev/$bkp_dev | grep -A1 Device | grep $bkp_dev'1' | awk '{print $3}'`
bkp_part2_field2=`fdisk -l -u /dev/$bkp_dev | grep -A2 Device | grep $bkp_dev'2' | awk '{print $2}'`
bkp_part2_field3=`fdisk -l -u /dev/$bkp_dev | grep -A2 Device | grep $bkp_dev'2' | awk '{print $3}'`
trim_status=`sudo systemctl status fstrim | grep Active | awk '{print $2}'`
#Backup information
echo "******************************************"
echo "*          Backup Information            *"
echo "******************************************"
echo
echo $(blueprint "Backup mount point:") "/dev/$bkp_dev" 
echo $(blueprint "Backup device vendor:") "$bkp_dev_vendor" 
echo $(blueprint "Backup device model:") "$bkp_dev_model" 
echo $(blueprint "Backup device serial:") "$bkp_dev_serial" 
echo $(blueprint "Backup device firmware:") "$bkp_dev_firmware" 
echo $(blueprint "Backup transport type:") "$bkp_transport"
echo $(blueprint "Backup trim status:") "$trim_status"
echo $(blueprint "Backup sectors:") "$bkp_sectors"
echo $(blueprint "Backup bytes:") "$bkp_bytes"
echo $(blueprint "Backup size:") "$bkp_size" 
if ((($LBASectors %64) == 0))
then
	blocksize=32768
	echo $(blueprint "Backup blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %32) == 0))
then
	blocksize=16384
	echo $(blueprint "Backup blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %16) == 0))
then
	blocksize=8192
	echo $(blueprint "Backup blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %8) == 0))
then
	blocksize=4096
	echo $(blueprint "Backup blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %4) == 0))
then
	blocksize=2048
	echo $(blueprint "Backup blocksize:") $blocksize | tee -a $output_report
elif ((($LBASectors %2) == 0))
then
	blocksize=1024
	echo $(blueprint "Backup blocksize:") $blocksize | tee -a $output_report
else
	blocksize=512
	echo $(blueprint "Backup blocksize:") $blocksize | tee -a $output_report
fi
echo
}




fn_report_working() {
    echo
}

fn_report_connected-devices() {
    echo
}

fn_report_mounted-filesystems() {
    echo
}
fn_report_available-freespace() {
    echo
}

fn_summary() {
    echo
}



function_readme(){
    echo "
Script developed to assist in Forensic collection and reports
With this script you will be able to achieve some goals:
1) Get valuable information about the host
2) Securely save image in encrypted disks
3) Perform forensic imaging in various formats
4) Receive a device collection report

This script has a few assumptions:
1) Use the custodian's computer as the imaging platform
2) Use this script for device collection
3) Have intermediate knowledge in Linux
4) Have target and backup disks, preferably preformatted
5) Use VeraCrypt encryption

Dependencies to run this script:
1) You must install this tools in your distribuition before 
run:
    inxi
    smartctl
    ftkimager
    ddrescue
    dc3dd 
    " | more
}


fn_output_getinfo(){
clear
echo "******************************************"
echo "*        Acquisition Information         *"
echo "******************************************"
echo
echo $(blueprint "First responder:")  $firstname $lastname
echo $(blueprint "Custodian's name:") $custodianFN $custodianLN
echo $(blueprint "Project Name:") $proj_name
echo $(blueprint "Engagement Code (or TBD):") $eng_code
echo $(blueprint "City:") $city1 $city2 $city3 $city4
echo $(blueprint "State:") $state1 $state2 $state3 $state4
echo $(blueprint "Country:") $country
echo $(blueprint "Google Plus Code:") $specific_location
echo
}

fn_getinfo(){
clear
echo -e "** Please enter YOUR First Name and your Last Name: \c "
read firstname lastname
echo -e "** Please enter the custodian's First Name and Last Name: \c "
read custodianFN custodianLN
echo -e "** Please enter the Project Name: \c "
read proj_name
echo -e "** Please enter the Engagement Code (or TBD): \c "
read eng_code
echo -e "** Please enter the city of acquisition: \c"
read city1 city2 city3 city4
echo -e "** Please enter the state of acquisition: \c "
read state1 state2 state3 state4
echo -e "** Please enter the country of acquisition: \c "
read country
echo -e "** Please enter Google Plus Code (or TBD): \c"
read specific_location
echo -e "** Please enter the Asset Tag Host Information (or N/A): \c "
read host_tag
echo
}

fn_acquire_e01(){
    echo "************************************" | tee -a $output_report
	echo "* FTK Imager Forensic Preservation *" | tee -a $output_report
	echo "************************************" | tee -a $output_report
	echo | tee -a $output_report
	image_start_date=`date +"%A, %B %d, %Y"`
	image_start_time=`date +"%H:%M"`
	echo "Beginning the imaging process with DDRescue Imager on $image_start_date at $image_start_time."
    ftkimager /dev/$evid_dev $tgt_mnt/$evid_barcode/$evid_barcode --verify --no-sha1 --e01 --frag 2G --compress $compress_rate --case-number $evid_barcode --evidence-number $evid_barcode --examiner "$firstname $lastname"
}
fn_acquire_raw(){
    echo "********************************" | tee -a $output_report
	echo "* DDC3DD Forensic Preservation *" | tee -a $output_report
	echo "********************************" | tee -a $output_report
	echo | tee -a $output_report
	image_start_date=`date +"%A, %B %d, %Y"`
	image_start_time=`date +"%H:%M"`
	echo "Beginning the imaging process with DDRescue Imager on $image_start_date at $image_start_time."
    dc3dd if=/dev/$evid_dev verb=on bufsz=$blocksize hash=md5 ofsz=2G hlog=$tgt_mnt/$evid_barcode/$evid_barcode.hash.log.wri log=$output_report hofs=$tgt_mnt/$evid_barcode/$evid_barcode.image.111 hofs=$bkup_mnt/$evid_barcode/$evid_barcode.image.111
}
fn_acquire_aff(){
    echo "**********************************" | tee -a $output_report
	echo "*   AFF Forensic Preservation    *" | tee -a $output_report
	echo "**********************************" | tee -a $output_report
	echo | tee -a $output_report
	image_start_date=`date +"%A, %B %d, %Y"`
	image_start_time=`date +"%H:%M"`
	echo "Beginning the imaging process with DDRescue Imager on $image_start_date at $image_start_time."

}
fn_acquire_img(){
	echo "**********************************" | tee -a $output_report
	echo "* DDRescue Forensic Preservation *" | tee -a $output_report
	echo "**********************************" | tee -a $output_report
	echo | tee -a $output_report
	image_start_date=`date +"%A, %B %d, %Y"`
	image_start_time=`date +"%H:%M"`
	echo "Beginning the imaging process with DDRescue Imager on $image_start_date at $image_start_time."
    ddrescue /dev/$evid_dev $tgt_mnt/$evid_barcode/$evid_barcode.img
}


fn_getdrives(){
echo -e "** Please check the source, target and backup drives (eg. sda sdb sdc): \c "
read host_tag
echo
}

forensic_framework