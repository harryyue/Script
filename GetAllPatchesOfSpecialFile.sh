#!/bin/bash

if [ $# != 2 ];then
	echo "[ERROR] Please input correct params."
	echo "Usage:"
	echo "$0 <special_file_name> <patch_store_path>"
	exit 1
fi

if [ ! -f $1 ];then
	echo "[ERROR] $1 doesn't exist."
	exit 1
fi

if [ ! -d $2 ];then
	echo "Create the patch store path."
	mkdir -p $2
fi

echo "[1/3]Get all of commit id for special file."
git log --oneline $1 > $2/commit_id.txt

echo "[2/3]Get all of patch and move it to $2 ."
#calculatint the commit_id.txt line number
TOTAL_LINES=`sed -n "$=" $2/commit_id.txt`
CUR_LINE=$TOTAL_LINES
while read line
do
	echo "$CUR_LINE"
	COMMIT_ID=`echo $line |cut -f 1 -d " "`
	git format-patch $COMMIT_ID -1 -o $2 --start-number $CUR_LINE --subject-prefix "PATCH $CUR_LINE/$TOTAL_LINES"
	((CUR_LINE--))
done < $2/commit_id.txt

echo "[3/3]Finished"
exit 0
