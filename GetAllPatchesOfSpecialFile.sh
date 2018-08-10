#!/bin/bash
#
# File Name: 	GetAllPatchesOfSpecialFile.sh
# Author: 		Harry.Yue
# Create: 		2018.07.25
# Modify: 		2018.08.10
#

while getopts "o:a:f:r" arg
do
	case $arg in
		o)
			OUTPUT_DIR="$OPTARG"
			;;
		a)
			AUTHOR="$OPTARG"
			;;
		f)
			CHECK_FILE="$OPTARG"
			;;
		r)
			CLEAN="yes"
			;;
		?)
			echo "Usage:"
			echo "$0 -o <output_path> [-a <author>] [-f <special_file_name>] [-r]"
			exit 1
	esac
done

if [ "Y"$OUTPUT_DIR = "Y" ];then
	echo "[ERROR] Please input output_path"
	echo "Usage:"
	echo "$0 -o <output_path> [-a <author>] [-f <special_file_name>]"
	exit 1
elif [ ! -d $OUTPUT_DIR ];then
	echo "Create the patch store path."
	mkdir -p $OUTPUT_DIR
elif [ "T"$CLEAN = "Tyes" ];then
	echo "Remove old files."
	rm -rf $OUTPUT_DIR
	mkdir -p $OUTPUT_DIR
fi

if [ "Y"$CHECK_FILE != "Y" ];then
	if [[ ! -f $CHECK_FILE && ! -d $CHECK_FILE ]];then
		echo "[ERROR] $CHECK_FILE doesn't exist."
		exit 1
	fi
fi

echo "[1/3]Get all of commit id for special file."
git log --oneline --author=$AUTHOR $CHECK_FILE > $OUTPUT_DIR/commit_id.txt

echo "[2/3]Get all of patch and move it to $OUTPUT_DIR ."
#calculatint the commit_id.txt line number
TOTAL_LINES=`sed -n "$=" $OUTPUT_DIR/commit_id.txt`
CUR_LINE=$TOTAL_LINES
while read line
do
	echo "$CUR_LINE"
	COMMIT_ID=`echo $line |cut -f 1 -d " "`
	git format-patch $COMMIT_ID -1 -o $OUTPUT_DIR --start-number $CUR_LINE --subject-prefix "PATCH $CUR_LINE/$TOTAL_LINES"
	((CUR_LINE--))
done < $2/commit_id.txt

echo "[3/3]Finished"
exit 0
