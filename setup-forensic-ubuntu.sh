#!/bin/sh
###################################################
# Install all manner of forensics tools 
# on Ubuntu 
###################################################

###################################################
# Disk Image tools 
###################################################
sudo apt-get -y install xmount
sudo apt-get -y install virtualbox
sudo apt-get -y install dc3dd
sudo apt-get -y install lsscsi
sudo apt-get -y install afflib-tools
sudo apt-get -y install libfuse-dev 
sudo apt-get -y install fuse-utils
sudo echo "user_allow_other" >> /etc/fuse.conf
sudo chmod 644 /etc/fuse.conf

###################################################
# Virtualization 
###################################################
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install vagrant
sudo apt-get -y install virtualbox-fuse

###################################################
# Install log2timeline
###################################################
wget https://log2timeline.googlecode.com/files/log2timeline_0.65.tgz
#OR
sudo nano -w /etc/apt/sources.list
deb http://log2timeline.net/pub/ lucid main
wget -q http://log2timeline.net/gpg.asc -O- | sudo apt-key add -
sudo apt-get update
sudo apt-get install log2timeline-perl

###################################################
# Vinetto is a forensics tool to examine Thumbs.db 
# files
###################################################
sudo apt-get install vinetto

###################################################
# Install pasco for Recovering IE History
###################################################
sudo apt-get install pasco

###################################################
#  Perl script to parse a shortcut (LNK) file and retrieve data
###################################################
svn checkout http://jaygeeplayground.googlecode.com/svn/trunk/ lslink

###################################################
#  Wireshark dependencies
###################################################
sudo apt install qttools5-dev qttools5-dev-tools libqt5svg5-dev qtmultimedia5-dev build-essential automake autoconf libgtk2.0-dev libglib2.0-dev flex bison libpcap-dev libgcrypt20-dev cmake -y

###################################################
# Regripper 
###################################################
perl -MCPAN -e 'install Parse::Win32Registry'
sudo mkdir -p /opt/regripper
cd /opt/regripper
sudo wget https://regripper.googlecode.com/files/rrv2.5.zip
sudo unzip rrv2.5.zip

sudo mkdir -p /opt/regripper/plugins
cd /opt/regripper/plugins
sudo wget https://regripperplugins.googlecode.com/files/regripperplugins_20130218.zip
sudo unzip regripperplugins_20130218.zip
cd ..
	
# Shell script which makes rip.pl run on Linux (riplin.pl)
# Fix end of line
sudo cat rip.pl | sed 's|\r$||g' > /tmp/riplin0.pl
# Now fix the first line so linux perl executed
sudo cat /tmp/riplin0.pl | sed "s| c:\\\\perl\\\\bin\\\\perl.exe|`which perl`|" > /tmp/riplin1.pl
# Fix the backslash before the plugins directory
sudo cat /tmp/riplin1.pl | sed 's|plugins\\\\|plugins/|' > riplin.pl
# Make executable
sudo chmod +x riplin.pl

###################################################
# Drive tools 
###################################################
apt-get install hdparm -y
apt-get install smartmontools -y
apt-get install lshw -y
apt install inxi -y
apt install sdparm -y
apt install hwinfo -y

apt-get update && apt-get install -y wget gnupg \
    && wget -q -O - https://download.bell-sw.com/pki/GPG-KEY-bellsoft | apt-key add - \
    && echo "deb [arch=amd64] https://apt.bell-sw.com/ stable main" | tee /etc/apt/sources.list.d/bellsoft.list \
    && apt-get update && apt-get install -y \
      git \
      build-essential \
      libafflib-dev zlib1g-dev libewf-dev unzip patch libssl-dev \
      autoconf automake autopoint libtool pkg-config yasm gettext wget \
      libaa1-dev libasound2-dev libcaca-dev libcdparanoia-dev libdca-dev \
      libdirectfb-dev libenca-dev libfontconfig1-dev libfreetype6-dev \
      libfribidi-dev libgif-dev libgl1-mesa-dev libjack-jackd2-dev libopenal1 libpulse-dev \
      libsdl1.2-dev libvdpau-dev libxinerama-dev libxv-dev libxvmc-dev libxxf86dga-dev \
      libxxf86vm-dev librtmp-dev libsctp-dev libass-dev libfaac-dev libsmbclient-dev libtheora-dev \
      libogg-dev libxvidcore-dev libspeex-dev libvpx-dev libdv4-dev \
      libopencore-amrnb-dev libopencore-amrwb-dev libmp3lame-dev liblivemedia-dev libtwolame-dev \
      libmad0-dev libgsm1-dev libbs2b-dev liblzo2-dev ladspa-sdk libfaad-dev \
      libmpg123-dev libopus-dev libbluray-dev libaacs-dev \
      libjpeg-dev \
      libtiff-dev \
      libpng-dev \
      libwmf-dev \
      libgif-dev \
      libheif-dev \
      libwebp-dev \
      librsvg2-dev \
      libopenexr-dev \
      vim \
      less\      
      unzip \
      libparse-win32registry-perl \
      tesseract-ocr tesseract-ocr-por tesseract-ocr-osd \
      graphviz \  
      bellsoft-java8-full \
      mplayer \
      && apt-get download ant && ls *.deb | awk '{system("dpkg-deb -x "$1" /")}' \
      && apt-get clean && rm -rf /var/lib/apt/lists/* \
    && cd /opt \
    && git clone https://github.com/lfcnassif/sleuthkit-APFS \
    && cd /opt/sleuthkit-APFS/ \
    && ./bootstrap \ 
    && ./configure --prefix=/usr/ \
    && make && make install \
    && rm -rf /opt/sleuthkit-APFS/ \
    && echo "#####################################" \
    && echo "The libagdb only have branch master" \
    && cd /opt \
    && git clone https://github.com/libyal/libagdb.git \
    && cd /opt/libagdb \
    && ./synclibs.sh \
    && ./autogen.sh \    
    && ./configure --prefix=/usr \ 
    && make all install \
    && rm -rf /opt/libagdb \
    && echo "#####################################" \
    && echo "install libevtx" \
    && cd /opt \
    && git clone --branch="20210525" https://github.com/libyal/libevtx \
    && cd /opt/libevtx \ 
    && ./synclibs.sh \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make all install \
    && rm -rf /opt/libevtx \
    && echo "#####################################" \
    && echo "Install libevt" \
    && cd /opt \
    && git clone --branch="20210424" https://github.com/libyal/libevt \
    && cd /opt/libevt \
    && ./synclibs.sh \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make all install \
    && rm -rf /opt/libevt \
    && echo "#####################################" \
    && echo "Install libscca" \
    && cd /opt \
    && git clone --branch="20210419" https://github.com/libyal/libscca \
    && cd /opt/libscca \
    && ./synclibs.sh \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make all install \
    && rm -rf /opt/libscca \
    && echo "#####################################" \
    && echo "Install libesedb" \
    && cd /opt \
    && git clone --branch="20210424" https://github.com/libyal/libesedb \
    && cd /opt/libesedb \
    && ./synclibs.sh \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make all install \
    && rm -rf /opt/libesedb \
    && echo "#####################################" \
    && echo "Install libpff without branch also, because latest release got problems" \
    && cd /opt \
    && git clone https://github.com/libyal/libpff \
    && cd /opt/libpff \
    && ./synclibs.sh \
    && ./autogen.sh \
    && ./configure --prefix=/usr \ 
    && make all install \
    && rm -rf /opt/libpff \
    && echo "#####################################" \
    && echo "Install libmsiecf" \
    && cd /opt \
    && git clone --branch="20210420" https://github.com/libyal/libmsiecf \
    && cd /opt/libmsiecf \
    && ./synclibs.sh \
    && ./autogen.sh \
    && ./configure --prefix=/usr \
    && make all install \
    && rm -rf /opt/libmsiecf \
    && echo "#####################################" \
    && echo "Install rifiuti2" \
    && cd /opt \
    && git clone --branch="0.7.0" https://github.com/abelcheung/rifiuti2 \
    && cd /opt/rifiuti2 \
    && autoreconf -f -i -v \
    && ./configure --prefix=/usr \
    && make all install \
    && rm -rf /opt/rifiuti2 \
    && echo "#####################################" \
    && echo "Instal ImageMagik" \
    && cd /opt \
    && git clone --branch "7.0.10-61" https://github.com/ImageMagick/ImageMagick \
    && cd /opt/ImageMagick \
    && ./configure --prefix=/usr \
    && make all install \
    && rm -rf /opt/ImageMagick \
    && echo "#####################################" \
    && echo "Creating mplayer config" \
    && mplayer \
    && echo "#####################################" \
    && echo "Installing IPED" \
    && mkdir -p /root/IPED/ && cd /root/IPED/ \
    && wget --progress=bar:force https://github.com/sepinf-inc/IPED/releases/download/$IPED_VERSION/IPED-${IPED_VERSION}_and_plugins.zip -O iped.zip \
    && unzip iped.zip && rm iped.zip && ln -s iped-$IPED_VERSION iped \
    && echo "#####################################" \
    && echo "Configuring Local config with our default values" \
    && echo "#####################################" \
    && echo "If you need to change the IPED LocalConfig, use the environment variables available on /entrypoint.sh" \
    && echo "#####################################" \    
    && sed -i -e "s/locale =.*/locale = pt-BR/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/indexTemp =.*/indexTemp = \/mnt\/ipedtmp/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/indexTempOnSSD =.*/indexTempOnSSD = true/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/outputOnSSD =.*/outputOnSSD = false/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/numThreads =.*/numThreads = 8/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/#kffDb =.*/kffDb = \/mnt\/kff\/kff.db/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/#ledWkffPath =.*/ledWkffPath = \/mnt\/led\/wkff/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/#projectVicHashSetPath =.*/projectVicHashSetPath = \/mnt\/ProjectVic\/latest.json/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/#photoDNAHashDatabase =.*/photoDNAHashDatabase = \/mnt\/PhotoDNA\/PhotoDNAChildPornHashes.txt/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/#tskJarPath =.*/tskJarPath = \/usr\/share\/java\/sleuthkit-4.6.5.jar/" /root/IPED/iped/LocalConfig.txt \
    && sed -i -e "s/mplayerPath =.*/mplayerPath = \/usr\/bin\/mplayer/" /root/IPED/iped/LocalConfig.txt \
    && echo "#####################################" \
    && echo "Configuring GraphConfig with our default values:BR" \
    && echo "#####################################" \
    && sed -i -e "s/\"phone-region\":.*/\"phone-region\":\"BR\",/" /root/IPED/iped/profiles/*/*/conf/GraphConfig.json \
    && echo "#####################################" \
    && echo "Creating custom Profiles" \
    && echo "#####################################" \
    && echo "FastRobust: Disable IndexUnknownFiles and enable excludeKffIgnorable, externalParsers and robustImageReading" \
    && echo "General analysis cases where processing errors are occurring" \
    && echo "#####################################" \
    && cp -r /root/IPED/iped/profiles/pt-BR/forensic /root/IPED/iped/profiles/pt-BR/fastrobust \
    && cp -r /root/IPED/iped/profiles/en/forensic /root/IPED/iped/profiles/en/fastrobust \
    && sed -i -e "s/indexUnknownFiles =.*/indexUnknownFiles = false/" /root/IPED/iped/profiles/*/fastrobust/IPEDConfig.txt \
    && sed -i -e "s/excludeKffIgnorable =.*/excludeKffIgnorable = true/" /root/IPED/iped/profiles/*/fastrobust/IPEDConfig.txt \
    && sed -i -e "s/robustImageReading =.*/robustImageReading = true/" /root/IPED/iped/profiles/*/fastrobust/conf/AdvancedConfig.txt \
    && sed -i -e "s/enableExternalParsing =.*/enableExternalParsing = true/" /root/IPED/iped/profiles/*/fastrobust/conf/AdvancedConfig.txt \
    && echo "#####################################" \
    && echo "PedoRobust: enable excludeKffIgnorable, externalParsers and robustImageReading" \
    && echo "For child abuse cases where processing errors are occurring" \
    && echo "#####################################" \    
    && cp -r /root/IPED/iped/profiles/pt-BR/pedo /root/IPED/iped/profiles/pt-BR/pedorobust \
    && cp -r /root/IPED/iped/profiles/en/pedo /root/IPED/iped/profiles/en/pedorobust \
    && sed -i -e "s/excludeKffIgnorable =.*/excludeKffIgnorable = true/" /root/IPED/iped/profiles/*/pedorobust/IPEDConfig.txt \
    && sed -i -e "s/robustImageReading =.*/robustImageReading = true/" /root/IPED/iped/profiles/*/pedorobust/conf/AdvancedConfig.txt \
    && sed -i -e "s/enableExternalParsing =.*/enableExternalParsing = true/" /root/IPED/iped/profiles/*/pedorobust/conf/AdvancedConfig.txt 
