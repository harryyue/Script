#!/bin/bash

filter=(
	"1D 41"
)

INPUT_FILE="invalid"

Usage() {
	echo " "
	echo "`basename $1` - version:20190405"
	echo " "
	echo "This script is used to find a special desip message from a files,"
	echo "and calculate the checksum of these special desip message. Before"
	echo "using it,you should add filter into arrary filter by modified this"
	echo "script.If not,it will calculate the checksum of all of messages wh-"
	echo "ich included by the files you input."
	echo "The input file's name is necesarry,you could use -f to special its"
	echo "name.Also you are able to assign a output file name by -o,if you "
	echo "don't use it,the output name will be <input_file>_output.txt."
	echo "If you want to sort the desip message id and output it to file,may"
	echo "option -s you could choose it.Have enjoy it!"
	echo " "
	echo "Usage:"
	echo "`basename $1` -f <input_file> [-o <output_file>] [-s]"
	echo " "
	return 0
}

while getopts "f:o:sh" arg
do
	case $arg in
		f)
			INPUT_FILE="$OPTARG"
			;;
		o)
			OUTPUT_FILE="$OPTARG"
			;;
		s)
			SORT="yes"
			;;
		h|?|*)
			Usage $0
			exit 0
	esac
done

if [ "Y"$INPUT_FILE = "Y" -o ! -f $INPUT_FILE ];then
	echo "[ERROR] Please give desip message file name."
	Usage $0
	exit 1
fi

if [ "Y"$OUTPUT_FILE = "Y" ];then
	OUTPUT_FILE="`basename $INPUT_FILE`"
	OUTPUT_FILE="${OUTPUT_FILE%.*}_output.txt"
fi

if [ -f $OUTPUT_FILE ];then
	rm -rf $OUTPUT_FILE
fi

echo "========== Begin =========="
echo "[1/2]Filter special desip message."
if [ ${#filter} -eq 0 ];
then
	echo "[Warning]No filter assigned,so we will calculate all of desip message's checksum."
	cp $INPUT_FILE tmp.txt
else
	IFSBAK=$IFS
	IFS="\n"
	echo "Filter:"
	for key in ${filter[@]}
	do
		echo "  $key"
	done
	while read line
	do
		echo -n ">"
		for key in ${filter[@]}
		do
			result=$(echo $line | grep "^$key")
			if [ -n "$result" ];
			then
				echo "$line" >> tmp.txt
			fi
			echo -n "-"
		done
	done < $INPUT_FILE
	IFS=$IFSBAK
	echo " "
fi
if [ $SORT = "yes" ];then
	sort tmp.txt -o tmp.txt
fi
echo "[1/2]Done."

echo "[2/2]Calculating the checksum of desip message."
while read line
do
	arr=($line)
	checksum=0
	length=${#arr[@]}
	for word in ${arr[@]}
	do
		echo -n "$word " >> $OUTPUT_FILE
		((checksum = checksum + 0x$word))
	done
	echo " " >> $OUTPUT_FILE
	printf "checksum: %X, length: %d\n\n" $checksum $length >> $OUTPUT_FILE
	echo -n "."
done < tmp.txt
rm -rf tmp.txt
echo "."
echo "[2/2]Done."
echo "========== Finish =========="
