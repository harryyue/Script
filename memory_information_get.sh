#!/bin/sh

if [ $# = 0 ]
then
	echo "please set the save file path..."
	exit 1
fi

date > $1
echo "" >> $1
#echo "####################   procrank information   #####################">> $1
#procrank >> $1

echo "" >> $1
echo "#######################   free information   #######################">> $1
free -lm >> $1

echo "" >> $1
echo "##################   /proc/buddyinfo information   ##################">> $1
cat /proc/buddyinfo >> $1

echo "" >> $1
echo "###################   /proc/meminfo information   ###################">> $1
cat /proc/meminfo >> $1

echo "" >> $1
echo "##################   /proc/zoneinfo information   ##################">> $1
cat /proc/zoneinfo >> $1

echo "" >> $1
echo "#################   /proc/vmallocinfo information   #################">> $1
cat /proc/vmallocinfo >> $1
