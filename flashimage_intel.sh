#!/bin/sh 

echo ">>>start..."
echo -n "Please input directory:"

read DIR
if [ -z "$DIR" ]
then
	echo ">>>Using default directory..."
	DIR="/home/harry/Project/AMZ/code/m_byt_cr_modify/out/target/product/coho"
fi

cd $DIR
if [ $? -ne 0 ]
then
	echo "[error]$DIR doesn't exist!!!"
	exit 1
fi

echo ">>>reboot device into bootloader..."
adb reboot bootloader
if [ $? -ne 0 ]
then
	echo "[error]Device not found!!!"
	exit 1
fi

echo ">>>flash  boot..."
fastboot flash boot boot.img

echo ">>>flash system..."
fastboot flash system system.img

echo ">>>reboot device..."
fastboot reboot

echo ">>>end..."
