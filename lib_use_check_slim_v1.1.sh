#!/bin/bash
#
# This scripts job is below:
# 	1.Find out the path of all library and storing the path into lib_path file;
# 	2.Find out the path of execable files and storing the path into bin_path;
#

echo "###############   Find the unuse library   #############"

PRE="/home/user/pro/checklib/"
ROOTFS="$PRE/rootfs/"
TMP="$PRE/tmp/"
OUT="$PRE/out/"

if [ ! -d $TMP ]
then
	echo "Create the temp directory($TMP)."
	mkdir -p $TMP
fi

if [ ! -d $OUT ]
then
	echo "Create the out directory($OUT)."
	mkdir -p $OUT
fi

if [[ $1 = "clean" ]]
then
	echo "Clean all files..."
	rm -rf $TMP/* $OUT/*
	echo "done."
	exit 0
fi

if [ ! -d $ROOTFS ]
then
	echo "Can't find the rootfs in the $PRE,please check if the directory
	exist..."
	exit 1
fi

if [  -f $TMP/elf_file ]
then
	echo "Clean the temp..."
	rm -rf $TMP/elf_file
fi

if [  -f $TMP/readelf ]
then
	echo "Clean the temp..."
	rm -rf $TMP/readelf
fi

cd $ROOTFS

echo ">[1/5]Find all execable in */bin/* path and find all library in the rootfs..."
#Create temp files (bin_path，lib_path, elf_file） 
echo "###############   library path  ###############" > $OUT/report.txt
echo "# Name                    Count     LinkTo               Path" >> $OUT/report.txt

echo "###############   library path  ###############" > $OUT/report_unuse_link.txt
echo "# Name                    Count     LinkTo               Path" >> $OUT/report_unuse_link.txt

echo "###############   library path  ###############" > $OUT/report_unuse_lib.txt
echo "# Name                    Count     LinkTo               Path" >> $OUT/report_unuse_lib.txt

sudo find -name "*.so" -o -name "*.so.*" >> $TMP/lib_path_tmp

echo "###############   readelf files  ###############" > $TMP/readelf

sudo find -type d -name "bin" > $TMP/bin_path

cat $TMP/bin_path | while read line
do
	find $line -type f >> $TMP/elf_file
done
echo ">[1/5]done."

echo ">[2/5]Check the library if used..."
cat $TMP/elf_file | while read line
do
	file $line | grep -e "ELF" -e "execable" > /dev/null
	if [ $? = 0  ]
	then
		echo $line >> $TMP/readelf
		echo $line >> $OUT/report_bin.txt
		readelf -d $line | grep "Shared library" >> $TMP/readelf
		echo "" >> $TMP/readelf
	fi
done
sort $OUT/report_bin.txt -o $OUT/report_bin.txt
echo ">[2/5]done."

echo ">[3/5]Start to generate the summary report..."
cat $TMP/lib_path_tmp | while read line
do
	BASENAME=`basename $line`
	DIRNAME=`dirname $line`
	COUNT=`grep $BASENAME $TMP/readelf | wc -l`
	TYPE=`file -b $line`
	KEY=`echo $TYPE|cut -f 1 -d " "`
	if [ "ELF" = $KEY ]
	then
		echo "$BASENAME     $COUNT     NA     $DIRNAME" >> $OUT/report.txt
	elif [ "symbolic" = $KEY ]
	then
		echo "$BASENAME     $COUNT     `echo $TYPE | cut -f 4 -d " "`     $DIRNAME" >> $OUT/report.txt
	fi
done
echo ">[3/5]done."

#generate the symbolic link report.txt and library unuse report.txt
echo ">[4/5]Start to generate the summary report..."
awk -v out1="$OUT/report_unuse_link.txt" -v out2="$TMP/symb_use.txt" -v out3="$TMP/lib_unuse.txt" '!/^#/{if($3!="NA"){if($2==0){print $0 >> out1;}else{print $0 >> out2;}}else{if($2==0){print $0 >> out3;}}}' $OUT/report.txt

#combine the unuse peport.txt
cat $TMP/lib_unuse.txt | while read line
do
	KEY=`echo $line|cut -f 1 -d " "`
	grep "\`$KEY'" $TMP/symb_use.txt
	if [ $? != 0 ]
	then
		echo $line >> $OUT/report_unuse_lib.txt
	fi
done
#sort -k 3 -k 1 $OUT/report_unuse.txt -o $OUT/report_unuse.txt
echo ">[4/5]done."

#Clean the temp files
echo ">[5/5]Clean the temp files..."
#rm -rf $TMP/*
echo ">[5/5]done."

echo "###############   Done   #############"
