#!/bin/bash

day=`date +%Y-%m-%d`
PRO_NAME=coho
JOBS=`nproc|awk '{s=$1+1<16 ? $1+1 : 16} END{print s}'`
OUT=out/target/product/$PRO_NAME/

echo ">>>$0:Executing..."

echo -n ">>Input directory: "
if [ -z "$1" ]
then
	SRC_DIR="/home/harry/Project/AMZ/code/m_byt_cr_modify"
	echo "$SRC_DIR"
else	
	SRC_DIR=$1
	echo "$SRC_DIR"
fi

cd $SRC_DIR/$OUT
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m>$0:$SRC_DIR/$OUT doesn't exist!!! \033[0m"
	mkdir -p $SRC_DIR/$OUT 
	cd $SRC_DIR/$OUT
fi

echo ">>$0:Clean coho start..."
DEL=`ls | grep "img$\|kernel\|system\|root"`
DEL+=" "
#maxdepth 指定搜寻的深度;1,表示只在当前目录下搜寻,不搜寻子目录
#type 指定搜寻的文件类型;d,表示搜寻的文件类型为目录
#-name 指定搜寻的文件名
DEL+=`find ./obj -maxdepth 1 -type d -name "kernel"`

for i in $DEL
do
	rm -rf $i
	echo ">remove $i ..."
done

echo ">>$0:Clean coho end"

cd $SRC_DIR
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m>$0:$SRC_DIR doesn't exist!!! \033[0m"
	exit 1
fi

echo ">>$0:Source envsetup.sh satrt..."
source ./build/envsetup.sh
echo ">>$0:Source envsetup.sh end"

echo ">>$0:Lunch coho-eng start..."
lunch coho-eng
echo ">>$0:Lunch coho-eng end"

echo ">$0:Build bootimage start..."
make bootimage -j$JOBS 2>&1 | tee bootimage$day.log
cat bootimage$day.log | tail -2 | grep "successfully" > /dev/null 
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m>$0:Build bootimage failed! \033[0m"
	exit 1
fi
echo -e "\033[32;1m>$0:Build bootimage successfully! \033[0m"

echo ">$0:Build kernel start..."
make kernel -j$JOBS 2>&1 | tee kernel$day.log
cat kernel$day.log | tail -2 | grep "successfully" > /dev/null 
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m$0:>Build Kernel failed! \033[0m"
	exit 1
fi
echo -e "\033[32;1m>$0:Build kernel successfully! \033[0m"

echo ">$0:Build systemimage start..."
make systemimage -j$JOBS 2>&1 | tee systemimage$day.log
cat systemimage$day.log | tail -2 | grep "successfully" > /dev/null 
if [ $? -ne 0 ]
then
	echo -e "\033[31;1m>$0:Build systemimage failed! \033[0m"
	exit 1
fi
echo -e "\033[32;1m>$0:Build systemimage successfully! \033[0m"

echo ">>>$0:Finish."

exit 0
