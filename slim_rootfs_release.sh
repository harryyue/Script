#!/bin/bash


if [ -z $1 ]
then
	echo "ERROR:No give the rootfs path."
	exit 1
elif [ ! -d $1 ]
then 
	echo "ERROR:The rootfs path doesn't exist."
	exit 1
fi

LIST_PATH=`pwd`
ROOTFS=$1

#Enter rootfs dir_path
cd $1

do_remove() {
	COUNT_f=0
	COUNT_d=0

	if [ ! -f $1 ]
	then
		echo "No find the list about needed remove files."
	else
	awk -v out="$LIST_PATH/tmp.txt" '!/^#/{print $0 > out;}' $1
	while read line
	do
		if [ -d $line ]
		then
			((COUNT_d++))
		else
			((COUNT_f++))
		fi

		echo "rm -rf $line"
		sudo rm -rf  $line
	done < $LIST_PATH/tmp.txt
	echo "Total:$COUNT_f files and $COUNT_d directories are remove."
	fi
	
	rm $LIST_PATH/tmp.txt
	return 0
}


echo ">Slim the rootfs ..."
echo ">>>[1/4]Remove the useless head files..."
#	sudo find -name "*.h" -o -name "*.hpp" > $LIST_PATH/headfile.txt
#	do_remove $LIST_PATH/headfile.txt
echo ">>>[1/4]done."
#exit 1

echo ">>>[2/4]Remove the useless application..."
	do_remove $LIST_PATH/useless_application.txt
echo ">>>[2/4]done."

echo ">>>[3/4]Remove the useless library..."
	do_remove $LIST_PATH/useless_library.txt
echo ">>>[3/4]done."

echo ">>>[4/4]Remove other useless files..."
	do_remove $LIST_PATH/useless_other_files.txt
echo ">>>[4/4]done."

echo ">Finish."

exit 0
