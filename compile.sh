#!/bin/bash 

echo ">>>$0:Executing..."

echo ">>$0:Compile the image..."
/bin/bash build_intel.sh
if [ $? -ne 0 ]
then 
	echo -e "\033[31;1m>$0:Fail to compile the image... \033[0m"
	exit 1
fi
echo -e "\033[32;1m>$0:Compile image successfully! \033[0m"

echo ">>$0:Flash the image..."
/bin/bash flashimage_intel.sh
if [ $? -ne 0 ]
then 
	echo -e "\033[31;1m>$0:Fail to flash the image... \033[0m"
	exit 1
fi
echo -e "\033[32;1m>$0:Flash image successfully! \033[0m"

echo ">>>$0:Finish..."
