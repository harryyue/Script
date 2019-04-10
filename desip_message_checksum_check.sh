#!/bin/bash 

#Color
RED="\033[31;1m"
GREEN="\033[32;1m"
RESET="\033[0m"

INPUT_FILE="invalid"
SORT="no"
START_TIME=`date +'%Y-%m-%d %H:%M:%S'`

filter=(
	"17 41"
)

Usage() {
	echo " "
	echo "`basename $1` - version:20190410"
	echo " "
	echo "Usage:"
	echo "`basename $1` -f <input_file> [-s] [-h]"
	echo " "
	return 0
}

#Check necessary tools

#Get argument from terminal
while getopts "f:sh" arg
do
	case $arg in
		f)
			INPUT_FILE="$OPTARG"
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
	echo -e $RED "[ERROR] Please give desip message file name." $RESET
	Usage $0
	exit 1
fi

TMP_NAME="`basename $INPUT_FILE`"
OUTPUT_FILE1="${TMP_NAME%.*}_update.txt"
OUTPUT_FILE2="${TMP_NAME%.*}_output.txt"
ERROR_LOG="${TMP_NAME%.*}_invalid_checksum.txt"

if [ -f $OUTPUT_FILE1 ];then
	rm -rf $OUTPUT_FILE1
fi
if [ -f $OUTPUT_FILE2 ];then
	rm -rf $OUTPUT_FILE2
fi
if [ -f $ERROR_LOG ];then
	rm -rf $ERROR_LOG
fi

dos2unix $INPUT_FILE

echo -e $GREEN "==================== Begin ====================" $RESET
#Convert Uart data to Desip message data
# 1C => SEP 
echo "[1/2]Convert UART data to DESIP message data."
while read line
do
	if [[ ! -z $line ]];
	then
		PRE=`echo $line | cut -d - -f 1`
		DATA=`echo $line | cut -d - -f 2`
		echo -n "$PRE - " >> $OUTPUT_FILE1
		arr=($DATA)
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
						echo -n "1B " >> $OUTPUT_FILE1
						((skip ++))
						echo -n "."
					elif [ ${arr[((count+1))]} == "1E" ];
					then
						echo -n "1C " >> $OUTPUT_FILE1
						((skip ++))
						echo -n "."
					else
						echo " " >> $OUTPUT_FILE1
						echo $word >> $OUTPUT_FILE1
						echo -n "."
					fi
					;;
				"1C")
					echo "" >> $OUTPUT_FILE1
					echo -n "|"
					;;
				*)
					echo -n "$word " >> $OUTPUT_FILE1
					echo -n "."
					;;
			esac
			((count ++))
		done
	fi
done  < $INPUT_FILE
echo ""
echo "[1/2]Done"

echo "[2/3]Filter special desip message."
if [ ${#filter} -eq 0 ];
then
	echo "[Warning]No filter assigned,so we will calculate all of desip message's checksum."
	cp $OUTPUT_FILE1 tmp.txt
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
			result=`echo $line | cut -d "-" -f 2| grep "^ $key"`
			if [ -n "$result" ];
			then
				echo "$line" >> tmp.txt
			fi
			echo -n "-"
		done
	done < $OUTPUT_FILE1
	IFS=$IFSBAK
	echo " "
fi

if [ $SORT = "yes" ];then
	sort tmp.txt -o tmp.txt
fi

echo "[2/3]Done."

echo "[3/3]Calculating the checksum of desip message."
while read line
do
	if [[ ! -z $line ]];
	then
		PRE=`echo $line | cut -d - -f 1`
		DATA=`echo $line | cut -d - -f 2`
		echo -n "$PRE - " >> $OUTPUT_FILE2
		arr=($DATA)
		checksum=0
		checkvalid=0
		length=${#arr[@]}
		for word in ${arr[@]}
		do
			echo -n "$word " >> $OUTPUT_FILE2
			((checksum = checksum + 0x$word))
		done
		checkvalid=$(( $checksum % 0x100 ))
		if [ $checkvalid != 255 ];
		then
			echo ""
			echo -e $RED $line $RESET
			printf $RED"\nchecksum: 0x%X, length: %d\n\n"$RESET $checksum $length
			echo -e $RED $line $RESET >> $ERROR_LOG
			printf $RED"\nchecksum: 0x%X, length: %d\n\n"$RESET $checksum $length >> $ERROR_LOG
		fi
		printf "\nchecksum: 0x%X, length: %d\n\n" $checksum $length >> $OUTPUT_FILE2
		echo -n "."
	fi
done < tmp.txt

#Delete tmp.txt
rm -rf tmp.txt

echo ""
echo "[3/3]Done."
echo -e $GREEN "==================== Finish ====================" $RESET

END_TIME=`date +'%Y-%m-%d %H:%M:%S'`
start_seconds=$(date --date="$START_TIME" +%s);
end_seconds=$(date --date="$END_TIME" +%s);
cost=$((end_seconds -start_seconds))

echo "# START: $START_TIME"
echo "# END:   $END_TIME"
echo "# COST:" $(( $cost / 60 ))"m" $(( $cost % 60 ))"s"

exit 0
