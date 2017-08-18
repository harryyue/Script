#!/bin/bash

PRE="/home/user/M2Hypervisor/"
PATCH_STOR="/home/user/pro/patch/\[3\]Cyber_Sercurity_Update/"
LINUX="$PRE/dom0/kernel_dom0/"
ANDROID="$PRE/domU/android/kernel/android-4.4/"
LINUX_BRANCH="cyber_security_local"
ANDROID_BRANCH="cyber_security"

echo "###############  Apply patch to Android kernel  ###############"
if [ -z $1 ]
then
	echo "No set commit ID..."
	echo "Usage:bash $0 commit_id"
	exit 1
fi

mkdir -p $PRE/tmp_patch

echo "[1/3]Generate patch in linux kernel's $LINUX_BRANCH branch..."
cd $LINUX
#Generate the patch
git checkout $LINUX_BRANCH
git format-patch $1
mv *.patch $PRE/tmp_patch
echo "[1/3]done."

echo "[2/3]Apply the patch to Android kernel's $ANDROID_BRANCH branch..."
cd $ANDROID
git checkout $ANDROID_BRANCH
git checkout -- .

ls $PRE/tmp_patch | while read line
do
	echo $line
	git am $PRE/tmp_patch/$line
done
echo "[2/3]done."

echo "[3/3]Compiling the Android kernel..."
cd $PRE
make target/domU_android/install V=99
cp *.patch $PATCH_STOR
echo "[3/3]done."
echo "###############  Finish  ###############"
