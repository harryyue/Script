#!/bin/bash
#
# File Name: 	GetAllPatchesOfSpecialFile.sh
# Author: 		Harry.Yue
# Create: 		2018.07.25
# Modify: 		2019.03.25
#

Usage() {
	echo "Usage:"
	echo "$1 -o <output_path> [-a <author>] [-n <special_file_name>] [-s <start commit id>] [-e <end commit id>] [-r]"
	exit 1
}

while getopts "o:a:n:s:e:r" arg
do
	case $arg in
		o)
			OUTPUT_DIR="$OPTARG"
			;;
		a)
			AUTHOR="$OPTARG"
			;;
		f)
			START_DATE="$OPTARG"
			;;
		n)
			CHECK_FILE="$OPTARG"
			;;
		t)
			END_DATE="$OPTARG"
			;;
		s)
			START_ID="$OPTARG"
			;;
		e)
			END_ID="$OPTARG"
			;;
		r)
			CLEAN="yes"
			;;
		?)
			Usage $0
	esac
done

if [ "Y"$OUTPUT_DIR = "Y" ];then
	echo "[ERROR] Please input output_path"
	Usage $0
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

if [ "Y"$START_ID != "Y" ];then
	START_ID="$START_ID.."
fi

#if [ "Y"$START_DATE = "Y" ];then
#	START_DATE=19700101
#	echo "[INFO] use $START_DATE as the begin date"
#fi

#if [ "Y"$END_DATE = "Y" ];then
#	END_DATE=`data +%Y%m%d`
#	((END_DATE ++))
#	echo "[INFO] use $END_DATE as the end date"
#fi

#if [ $END_DATE -lt $START_DATE ];then
#	echo "[ERROR] Invalid value."
#	Usage $0
#fi

echo "[1/3]Get all of commit id for special file."
git log --oneline --author=$AUTHOR $START_ID$END_ID $CHECK_FILE > $OUTPUT_DIR/commit_id.txt

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
