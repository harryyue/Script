#!/bin/bash

day=`date +%Y-%m-%d`

echo ">>>$0:Executing..."

echo -n ">>Input directory: "
if [ -z "$1" ]
then
	DIR="/home/harry/Project/AMZ/code/m_byt_cr_modify"
	echo "$DIR"
else	
	DIR=$1
	echo "$DIR"
fi

cd $DIR
if [ $? -ne 0 ]
then
	echo -n "\033[31;1m>$0:$DIR doesn't exist!!! \033[0m"
	exit 1
fi

echo ">>$0:Clean coho start..."
rm -rf $DIR/out/target/product/coho/*.img
rm -rf $DIR/out/target/product/coho/kernel 
rm -rf $DIR/out/target/product/coho/root/ 
rm -rf $DIR/out/target/product/coho/obj/kernel/ 
rm -rf $DIR/out/target/product/coho/system/ 
echo ">>$0:Clean coho end"

echo ">>$0:Source envsetup.sh satrt..."
source ./build/envsetup.sh
echo ">>$0:Source envsetup.sh end"

echo ">>$0:Lunch coho-eng start..."
lunch coho-eng
echo ">>$0:Lunch coho-eng end"

echo ">$0:Build bootimage start..."
make bootimage -j8 2>&1 | tee bootimage$day.log
cat bootimage$day.log | tail -2 | grep "successfully" > /dev/null 
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m>$0:Build bootimage failed! \033[0m"
	exit 1
fi
echo -e "\033[32;1m>$0:Build bootimage successfully! \033[0m"

echo ">$0:Build kernel start..."
make kernel -j8 2>&1 | tee kernel$day.log
cat kernel$day.log | tail -2 | grep "successfully" > /dev/null 
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m$0:>Build Kernel failed! \033[0m"
	exit 1
fi
echo -e "\033[32;1m>$0:Build kernel successfully! \033[0m"

echo ">$0:Build systemimage start..."
make systemimage -j4 2>&1 | tee systemimage$day.log
cat systemimage$day.log | tail -2 | grep "successfully" > /dev/null 
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m>$0:Build systemimage failed! \033[0m"
	exit 1
fi
echo -e "\033[32;1m>$0:Build systemimage successfully! \033[0m"

echo ">>>$0:Finish."

exit 0
