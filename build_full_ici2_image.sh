#!/bin/bash

#Variable
CUR_PATH=`pwd`
MIRROR_PATH="/mnt/ngi2-integration-4.4/"
BSP_PATH="/home/user/M2Hypervisor/"
AP_PATH="/home/user/pro/cc0818aa_AP/"
ODC_PATH="/home/user/pro/ici2/ngi20_linux/linux-rootfs/"
ANDROID_PATH="/home/user/pro/Android_AP/"

RED="\033[31;1m"
GREEN="\033[32;1m"
RESET="\033[0m"

set -e

if [ $# -lt 2 -o $# -gt 3 ]
then
	echo -e $RED"[ERROR]The numbers of variable should be 2 or 3."$RESET 
	echo "Usage:"
	echo "       bash $0 (hardware) (bench) [choose]  "
	echo "Example:"
	echo "         bash $0 dv1 k226 all  "
	exit 1
fi

echo  -e $GREEN"Start..."$RESET
echo "[1/6]Prepare the mirror repository."
test -d $MIRROR_PATH && cd $MIRROR_PATH || { echo -e $RED "[ERROR]Couldn't access $MIRROR_PATH ." $RESET ; exit 1; }
./cleanall && ./pre-integration
echo "[1/6]done."

echo "[2/6]Merge the AP component to mirror repository."
test -d $AP_PATH && cd $AP_PATH || {echo -e $RED "[ERROR]Couldn't access$AP_PATH ." $RESET ;exit 1; }
./build $2
test -d tools/scripts && cd tools/scripts || {echo -e $RED "[ERROR]Couldn't access $AP_PATH/tools/scripts ." $RESET ; exit 1; }
./merge.sh $2
echo "[2/6]done."

echo "[3/6]Merge the ODC component to mirror repository."
test -d $ODC_PATH && cd $ODC_PATH || {echo -e $RED "[ERROR]Couldn't access $ODC_PATH ." $RESET ;exit 1; }
sudo rsync -a usr/app usr/odc usr/rpc $MIRROR_PATH/merge/usr
sudo rsync -a var/odc var/sdk $MIRROR_PATH/merge/var
sync
echo "[3/6]done."

echo "[4/6]Create the release image."
cd $MIRROR_PATH
./pos-integration
echo "[4/6]done."

echo "[5/6]Update the BSP component to mirror repository."
if [ $# = 3 ]
then
	test -d $BSP_PATH && cd $BSP_PATH || {echo -e $RED "[ERROR]Couldn't access $BSP_PATH ." $RESET ;exit 1; }
	if [ $3 = "all" ]
	then
		./ReleaseBsp.sh $1
	elif [ $3 = "kernel" ]
	then
		./BuildKernel.sh
	fi
	./BspMerge.sh
else
	echo "Not Update the BSP component."
fi
echo "[5/6]done."

echo "[6/6]Merge the Android component to mirror repository."
test -d $ANDROID_PATH && cd $ANDROID_PATH || {echo -e $RED "[ERROR]Couldn't access $ANDROID_PATH ." $RESET ; exit 1; }
if [ $# = 3 ]
then
	test $3 = "all" && sudo rsync -a  *.img $MIRROR_PATH/release || echo "Not Update the Android component."
else
	echo "Not Update the Android component."
fi
echo "[6/6]done."

echo -e $GREEN"Finish..."$RESET
