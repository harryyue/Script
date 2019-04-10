#!/bin/bash 

INPUT_FILE="invalid"

Usage() {
	echo " "
	echo "`basename $1` - version:20190405"
	echo " "
	echo "This script is used to conversion desip message from desip uart log."
	echo "The input file's name is necesarry,you could use -f to special its"
	echo "name.Also you are able to assign a output file name by -o,if you "
	echo "don't use it,the output name will be <input_file>_update.txt."
	echo " "
	echo "Usage:"
	echo "`basename $1` -f <input_file> [-o <output_file>] [-h]"
	echo " "
	return 0
}

while getopts "f:o:h" arg
do
	case $arg in
		f)
			INPUT_FILE="$OPTARG"
			;;
		o)
			OUTPUT_FILE="$OPTARG"
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
	OUTPUT_FILE="${OUTPUT_FILE%.*}_update.txt"
fi

if [ -f $OUTPUT_FILE ];then
	rm -rf $OUTPUT_FILE
fi

while read line
do
	arr=($line)
	count=0
	skip=0
	for word in ${arr[@]}
	do
		if [ $skip -gt 0 ];
		then
			((skip --))
			((count ++))
			continue
		fi
		case $word in
			"1B")
				if [ ${arr[((count+1))]} == "1D" ];
				then
					echo -n "1B " >> $OUTPUT_FILE
					((skip ++))
					echo -n "."
				elif [ ${arr[((count+1))]} == "1E" ];
				then
					echo -n "1C " >> $OUTPUT_FILE
					((skip ++))
					echo -n "."
				else
					echo " " >> $OUTPUT_FILE
					echo $word >> $OUTPUT_FILE
					echo -n "."
				fi
				;;
			"1C")
				echo "" >> $OUTPUT_FILE
				echo -n "|"
				;;
			*)
				echo -n "$word " >> $OUTPUT_FILE
				echo -n "."
				;;
		esac
		((count ++))
	done
done  < $INPUT_FILE
echo ""
exit 0
