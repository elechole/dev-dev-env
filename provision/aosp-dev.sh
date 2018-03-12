#!/bin/sh

echo "Installing Development Tools for AOSP..."
# Install packages for AOSP
sudo apt-get install -y libc6-dev-i386 lib32ncurses5-dev
sudo apt-get install -y zip unzip
sudo apt-get install -y curl
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y git-core
sudo apt-get install -y gnupg flex bison gperf
sudo apt-get install -y x11proto-core-dev libx11-dev
sudo apt-get install -y lib32z-dev ccache libgl1-mesa-dev libxml2-utils xsltproc

sudo apt-get install -y openjdk-7-jdk
sudo apt-get install -y openjdk-8-jdk

sudo apt-get install -y android-tools-adb
sudo apt-get install -y android-tools-fastboot

sudo apt-get install -y u-boot-tools

# Android NDK / SDK
#sudo mkdir -p /usr/local/android

#echo "Downloading & Installing Android SDK..."
#cd /tmp
#sudo wget -nv http://dl.google.com/android/android-sdk_r24.4.1-linux.tgz
#sudo tar -zxf /tmp/android-sdk_r24.4.1-linux.tgz > /dev/null 2>&1
#sudo mv /tmp/android-sdk-linux /usr/local/android/sdk
#sudo rm -rf /tmp/android-sdk_r24.4.1-linux.tgz

#echo "Downloading & Installing Android NDK..."
#cd /tmp
#sudo wget -nv http://dl.google.com/android/repository/android-ndk-r11c-linux-x86_64.zip
#sudo unzip /tmp/android-ndk-r11c-linux-x86_64.zip >/dev/null 2>&1
#sudo mv /tmp/android-ndk-r11c /usr/local/android/ndk
#sudo rm -rf /tmp/android-ndk-r11c-linux-x86_64.zip

#sudo chmod -R 755 /usr/local/android

#sudo ln -s /usr/local/android/sdk/tools/android /usr/bin/android
#sudo ln -s /usr/local/android/sdk/platform-tools/adb /usr/bin/adb

#echo "Updating ANDROID_SDK, ANDROID_NDK & PATH variables..."
#cd ~/
#cat << End >> .profile
#export ANDROID_HOME="/usr/local/android/sdk"
#export ANDROID_SDK="/usr/local/android/sdk"
#export ANDROID_NDK="/usr/local/android/ndk"
#export PATH=$ANDROID_SDK/tools:$ANDROID_SDK/platform-tools:$PATH
#End

#source ~/.profile

#echo "Updating Android SDK platform-tools"
#echo "y" | sudo android update sdk --no-https --no-ui --filter platform-tools

echo "Adding USB device driver information..."
echo "For more detail see http://developer.android.com/tools/device.html"

cat << EOF > ./51-android.rules
#Acer
SUBSYSTEM=="usb", ATTR{idVendor}=="0502", MODE="0666", GROUP="plugdev"

#ASUS
SUBSYSTEM=="usb", ATTR{idVendor}=="0b05", MODE="0666", GROUP="plugdev"

#Dell
SUBSYSTEM=="usb", ATTR{idVendor}=="413", MODE="0666", GROUP="plugdev"

#Foxconn
SUBSYSTEM=="usb", ATTR{idVendor}=="0489", MODE="0666", GROUP="plugdev"

#Fujitsu/Fujitsu Toshiba
SUBSYSTEM=="usb", ATTR{idVendor}=="04c5", MODE="0666", GROUP="plugdev"

#Garmin-Asus
SUBSYSTEM=="usb", ATTR{idVendor}=="091e", MODE="0666", GROUP="plugdev"

#Google
SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"

#Hisense
SUBSYSTEM=="usb", ATTR{idVendor}=="109b", MODE="0666", GROUP="plugdev"

#HTC
SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"

#Huawei
SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666", GROUP="plugdev"

#K-Touch
SUBSYSTEM=="usb", ATTR{idVendor}=="24e3", MODE="0666", GROUP="plugdev"

#KT Tech
SUBSYSTEM=="usb", ATTR{idVendor}=="2116", MODE="0666", GROUP="plugdev"

#Kyocera
SUBSYSTEM=="usb", ATTR{idVendor}=="0482", MODE="0666", GROUP="plugdev"

#Lenovo
SUBSYSTEM=="usb", ATTR{idVendor}=="2006", MODE="0666", GROUP="plugdev"

#LG
SUBSYSTEM=="usb", ATTR{idVendor}=="1004", MODE="0666", GROUP="plugdev"

#Motorola
SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666", GROUP="plugdev"

#NEC
SUBSYSTEM=="usb", ATTR{idVendor}=="0409", MODE="0666", GROUP="plugdev"

#Nook
SUBSYSTEM=="usb", ATTR{idVendor}=="2080", MODE="0666", GROUP="plugdev"

#Nvidia
SUBSYSTEM=="usb", ATTR{idVendor}=="0955", MODE="0666", GROUP="plugdev"

#OTGV
SUBSYSTEM=="usb", ATTR{idVendor}=="2257", MODE="0666", GROUP="plugdev"

#Pantech
SUBSYSTEM=="usb", ATTR{idVendor}=="10a9", MODE="0666", GROUP="plugdev"

#Pegatron
SUBSYSTEM=="usb", ATTR{idVendor}=="1d4d", MODE="0666", GROUP="plugdev"

#Philips
SUBSYSTEM=="usb", ATTR{idVendor}=="0471", MODE="0666", GROUP="plugdev"

#PMC-Sierra
SUBSYSTEM=="usb", ATTR{idVendor}=="04da", MODE="0666", GROUP="plugdev"

#Qualcomm
SUBSYSTEM=="usb", ATTR{idVendor}=="05c6", MODE="0666", GROUP="plugdev"

#SK Telesys
SUBSYSTEM=="usb", ATTR{idVendor}=="1f53", MODE="0666", GROUP="plugdev"

#Samsung
SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"

#Sharp
SUBSYSTEM=="usb", ATTR{idVendor}=="04dd", MODE="0666", GROUP="plugdev"

#Sony
SUBSYSTEM=="usb", ATTR{idVendor}=="054c", MODE="0666", GROUP="plugdev"

#Sony Ericsson
SUBSYSTEM=="usb", ATTR{idVendor}=="0fce", MODE="0666", GROUP="plugdev"

#Teleepoch
SUBSYSTEM=="usb", ATTR{idVendor}=="2340", MODE="0666", GROUP="plugdev"

#Toshiba
SUBSYSTEM=="usb", ATTR{idVendor}=="0930", MODE="0666", GROUP="plugdev"

#ZTE
SUBSYSTEM=="usb", ATTR{idVendor}=="19d2", MODE="0666", GROUP="plugdev"
EOF

sudo mv ./51-android.rules /etc/udev/rules.d/
sudo chmod a+r /etc/udev/rules.d/51-android.rules

sudo service udev restart

if [ 0 ] ; then
	echo " "
	echo " "
	echo " "
	echo "[ Next Steps ]================================================================"
	echo " "
	echo "1. Manually setup a USB connection for your Android device to the new VM"
	echo " "
	echo "	If using VMware Fusion (for example, will be similar for VirtualBox):"
	echo "  	1. Plug your android device hardware into the computers USB port"
	echo "  	2. Open the 'Virtual Machine Library'"
	echo "  	3. Select the VM, e.g. 'android-vm: default', right-click and choose"
	echo " 		   'Settings...'"
	echo "  	4. Select 'USB & Bluetooth', check the box next to your device and set"
	echo " 		   the 'Plug In Action' to 'Connect to Linux'"
	echo "  	5. Plug the device into the USB port and verify that it appears when "
	echo "         you run 'lsusb' from the command line"
	echo " "
	echo "2. Your device should appear when running 'lsusb' enabling you to use adb, e.g."
	echo " "
	echo "		$ adb devices"
	echo "			ex. output,"
	echo " 		       List of devices attached"
	echo " 		       007jbmi6          device"
	echo " "
	echo "		$ adb shell"
	echo " 		    i.e. to log into the device (be sure to enable USB debugging on the device)"
	echo " "
	echo "See the included README.md for more detail on how to run and work with this VM."
	echo " "
	echo "[ Start your Ubuntu VM ]======================================================"
	echo " "
	echo "To start the VM, "
	echo " 	To use with VirtualBox (free),"
	echo " "
	echo "			$ vagrant up"
	echo " "
	echo " 	To use with VMware Fusion (OS X) (requires paid plug-in),"
	echo " "
	echo "			$ vagrant up --provider=vmware_fusion"
	echo " "
	echo " 	To use VMware Workstation (Windows, Linux) (requires paid plug-in),"
	echo " "
	echo "			$ vagrant up --provider=vmware_workstation"
fi

