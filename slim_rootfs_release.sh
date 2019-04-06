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
ROOTFS_BAK="/home/nj335b/rootfs_bak"

#Enter rootfs dir_path
cd $1

do_remove() {
	COUNT_f=0
	COUNT_d=0
	COUNT_e=1
	COUNT_m=1

	if [ ! -f $1 ]
	then
		echo "No find the list about needed remove files."
	else
	awk -v out="$LIST_PATH/tmp.txt" '!/^#/{print $0 > out;}' $1
	while read line
	do
		if sudo test -e $line
		then
			echo "[$COUNT_m]sudo rsync -a $line $ROOTFS_BAK"
			dest=$ROOTFS_BAK/`dirname $line`
			if sudo test ! -e $dest
			then
				sudo mkdir -p $dest
			fi
			sudo rsync -a $line $dest
			((COUNT_m++))
		else
			echo "[E]$line doesn't exist."
			((COUNT_e++))
		fi

#		if sudo test -d $line
#		then
#			echo "[D]rm -rf $line"
#			sudo rm -rf  $line
#			((COUNT_d++))
#		elif sudo test -f $line -o -L $line
#		then
#			echo "[F]rm -rf $line"
#			sudo rm -rf  $line
#			((COUNT_f++))
#		fi

	done < $LIST_PATH/tmp.txt
#	echo "Total:$COUNT_f file(s) and $COUNT_d directori(es) are remove."
	echo "Total:$COUNT_m items are moved and $COUNT_e items don't remove."
	rm $LIST_PATH/tmp.txt
	fi
	
	return 0
}


echo ">Slim the rootfs ..."
echo ">>>[1/4]Remove the useless head files..."
#	sudo find -name "*.h" -o -name "*.hpp" > $LIST_PATH/headfile.txt
#	do_remove $LIST_PATH/headfile.txt
echo ">>>[1/4]done."

echo ">>>[2/4]Remove the useless application..."
#	do_remove $LIST_PATH/useless_application.txt
echo ">>>[2/4]done."

echo ">>>[3/4]Remove the useless library..."
#	do_remove $LIST_PATH/useless_library.txt
echo ">>>[3/4]done."

echo ">>>[4/4]Remove other useless files..."
	do_remove $LIST_PATH/useless_other_files.txt
echo ">>>[4/4]done."

echo ">Finish."

exit 0
