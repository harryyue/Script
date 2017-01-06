#!/bin/bash 

echo ">>>$0:Executing..."

echo -n ">Please input directory:"

if [ -z "$1" ]
then
	DIR="/home/harry/Project/AMZ/code/m_byt_cr_modify/out/target/product/coho"
	echo "$DIR"
else
	DIR=$1
	echo "$DIR"
fi

cd $DIR
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m>$0:$DIR doesn't exist!!! \033[0m"
	exit 1
fi

echo ">>$0:Reboot device into bootloader..."
adb reboot bootloader
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m>$0:Device not found!!! \033[0m"
	exit 1
fi
echo -e "\033[32;1m>$0:Reboot device successful!! \033[0m"

echo ">>$0:Flash  boot..."
sleep 20s
fastboot flash boot boot.img

echo ">>$0:Flash system..."
fastboot flash system system.img

echo ">>$0:Reboot device..."
fastboot reboot

echo ">>>$0:Finish."
exit 0
