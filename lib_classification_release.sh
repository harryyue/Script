#!/bin/bash
#
# This scripts job is below:
# 	1.Find out the path of all library and storing the path into lib_path file;
# 	2.Find out the path of execable files and storing the path into bin_path;
#

PRE=$1
ROOTFS="$PRE/rootfs/"
TMP="$PRE/tmp/"
OUT="$PRE/out/"

RED="\033[31;1m"
GREEN="\033[32;1m"
RESET="\033[0m"

echo -e $GREEN "###############   Find the unuse library   #############" $RESET

if [ -z $1 ]
then
	echo -e $RED "ERROR:The input isn't right." $RESET
	exit 1
elif [ ! -d $1 ]
then
	echo -e $RED "ERROR:$1 doesn't exist." $RESET
	exit 1
fi


#for exaplem:
#do_find_source_of_link [checked_file_name,list,use_files]
#
# if the item of $1 could find in $2,then move it into $3,or move into tmp.txt
# Replacing $1 with tmp.txt after finishing check item of $1.
#
do_find_source_of_link()
{
	if [ $# -lt 3 ]
	then
		echo -e $RED "ERROR:the input isn't write." $RESET
		echo "Usage:"
		echo "$0 source_file list destion_file"
		
		return -1
	fi

	FLAG=0
	while read line
	do
		KEY=`echo $line|cut -f 1 -d " "`
		grep "\`$KEY'" $2
		if [ $? != 0 ]
		then
		#if can't find $KEY name in file $2,then write $KEY to tmp.txt 
			echo $line >> tmp.txt
		else
		#if can find $KEY name in file $2,then write $KEY to file $3
			echo $line >> $3
			FLAG=1
		fi
	done < $1
	mv tmp.txt $1

	return $FLAG
}

# do_check_use_shared_library()
# check the libraries used by items of $1,and record this message into $2
#
do_check_use_shared_library()
{
	while read line
	do
		LIB_NAME=`echo $line|cut -f 1 -d " "`
		LIB_PATH=`echo $line|cut -f 4 -d " "`
		echo "$LIB_PATH/$LIB_NAME" >> $2
		readelf -d $LIB_PATH/$LIB_NAME | grep "Shared library" >> $2
		echo "" >> $2
	done < $1

	return 0
}

# do_find_shared_library()
# check the item of $1 if exist in $2,if does,then store it into use_tmp.txt,or
# store it into useless_tmp.txt.
# Replacing the $1 with useless_tmp.txt after finishing check $1.
#
do_find_shared_library()
{
	FLAG=0
	
	rm -rf use_tmp.txt useless_tmp.txt

	while read line
	do
		LIB_NAME=`echo $line|cut -f 1 -d " "`
		COUNT=`grep "\[$LIB_NAME\]" $2 | wc -l`
		if [ $COUNT != 0 ]
		then
			echo $line >> use_tmp.txt
			FLAG=1
		else
			echo $line >> useless_tmp.txt
		fi
	done < $1
	
	mv useless_tmp.txt $1
	return $FLAG
}


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

if [[ $2 = "clean" ]]
then
	echo "Clean all files..."
	rm -rf $TMP/* $OUT/*
	echo "done."
	exit 0
fi

if [ ! -d $ROOTFS ]
then
	echo -e $RED "ERROR:Can't find the rootfs in the $PRE,please check if the directory exist..." $RESET
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

echo -e $GREEN ">[1/7]Find all execable in */bin/* path and find all library in the rootfs..." $RESET
#Create temp files (bin_path lib_path, elf_file )
echo "###############   library path  ###############" > $OUT/report.txt
echo "# Name                    Count     LinkTo               Path" >> $OUT/report.txt

echo "###############   library path  ###############" > $OUT/link_use_report.txt
echo "# Name                    Count     LinkTo               Path" >> $OUT/link_use_report.txt

echo "###############   library path  ###############" > $OUT/link_unuse_report.txt
echo "# Name                    Count     LinkTo               Path" >> $OUT/link_unuse_report.txt

echo "###############   library path  ###############" > $OUT/lib_use_report.txt
echo "# Name                    Count     LinkTo               Path" >> $OUT/lib_use_report.txt

echo "###############   library path  ###############" > $OUT/lib_unuse_report.txt
echo "# Name                    Count     LinkTo               Path" >> $OUT/lib_unuse_report.txt

sudo find -name "*.so" -o -name "*.so.*" >> $TMP/lib_path_tmp

echo "###############   readelf files  ###############" > $TMP/readelf

sudo find -type d -name "bin" -o -name "sbin" -o -name "libexec" > $TMP/bin_path

cat $TMP/bin_path | while read line
do
	find $line -type f >> $TMP/elf_file
done
echo -e $GREEN ">[1/7]done." $RESET

echo -e $GREEN ">[2/7]Check the library if used by application..." $RESET
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
echo -e $GREEN ">[2/7]done." $RESET

echo -e $GREEN ">[3/7]Start to generate the summary report..." $RESET
cat $TMP/lib_path_tmp | while read line
do
	BASENAME=`basename $line`
	DIRNAME=`dirname $line`
	COUNT=`grep "\[$BASENAME\]" $TMP/readelf | wc -l`
	TYPE=`file -b $line`
	KEY=`echo $TYPE|cut -f 1 -d " "`
	if [ "ELF" = $KEY ]
	then
		echo "$BASENAME     $COUNT     NA     $DIRNAME" >> $OUT/report.txt
		if [ $COUNT = 0 ]
		then
			echo "$BASENAME     $COUNT     NA     $DIRNAME" >> $TMP/lib_unuse.txt
		else
			echo "$BASENAME     $COUNT     NA     $DIRNAME" >> $TMP/lib_use.txt
		fi
	elif [ "symbolic" = $KEY ]
	then
		echo "$BASENAME     $COUNT     `echo $TYPE | cut -f 4 -d " "`  $DIRNAME" >> $OUT/report.txt
		if [ $COUNT = 0 ]
		then
			echo "$BASENAME     $COUNT     `echo $TYPE | cut -f 4 -d " "` $DIRNAME" >> $TMP/link_unuse.txt
		else
			echo "$BASENAME     $COUNT     `echo $TYPE | cut -f 4 -d " "` $DIRNAME" >> $TMP/link_use.txt
		fi
	fi
done
echo -e $GREEN ">[3/7]done." $RESET

#generate the symbolic link report.txt and library unuse report.txt
echo -e $GREEN ">[4/7]Start to classficate the link files and library..." $RESET

#find linked by use_link files in useless files
#link:find all of link files which be used
#
# 1.if useless link item of link_unuse.txt could be found in the link_use.txt,
#   then copy this item into link_use.txt.
# 2.if useless link item of link_unuse.txt couldn't be found in the link_use.txt,
#   then copy this item into tmp.txt.
# 3.if all of item are checked,then move the tmp.txt to link_unuse.txt.
# 4.do step 1-3 until the couldn't found useless item in lin_use.txt anymore.

#link
while [ "1" = "1" ]
do
	echo "find all of link files..."
	do_find_source_of_link $TMP/link_unuse.txt $TMP/link_use.txt $TMP/link_use.txt
	if [ $? = 0 ]
	then
		echo "have found out all useful link files."
		break
	fi
done
#library
# 
# 1.if useless lib item of lib_unuse.txt could be found in the link_use.txt,
#   then copy this item into lib_use.txt.
# 2.if useless lib item of lib_unuse.txt couldn't be found in the link_use.txt,
#   then copy this item into tmp.txt.
# 3.if all of item are checked,then move the tmp.txt to lib_unuse.txt.
# 4.because of lib item is source file,we just check lib_unuse.txt one time.

do_find_source_of_link $TMP/lib_unuse.txt $TMP/link_use.txt $TMP/lib_use.txt
echo -e $GREEN ">[4/7]done." $RESET

echo -e $GREEN ">[5/7]Check useless library if used by useful library" $RESET
while [ "1" = "1" ]
do
	FLAG_LIB=0
	FLAG_LINK=0
	
	echo -n ">>>>>>>>>>>>"

# check the shared libraries are used by lib_use items and link_use items
# lib_use
	do_check_use_shared_library $TMP/lib_use.txt $TMP/lib_readelf

# link_use
	do_check_use_shared_library $TMP/link_use.txt $TMP/lib_readelf

# check the shared libraries are used by link_useless items and lib_useless
# items.

	do_find_shared_library $TMP/link_unuse.txt $TMP/lib_readelf
	if [ $? != 0 ]
	then
		cat $TMP/link_use.txt >> $TMP/link_use_full.txt
		mv use_tmp.txt $TMP/link_use.txt
		FLAG_LINK=1
	fi

# when we find the new useful link items,we should find out its source file.
	do_find_source_of_link $TMP/lib_unuse.txt $TMP/link_use.txt $TMP/lib_use.txt

	do_find_shared_library $TMP/lib_unuse.txt $TMP/lib_readelf
	if [ $? != 0 ]
	then
		cat $TMP/lib_use.txt >> $TMP/lib_use_full.txt
		mv use_tmp.txt $TMP/lib_use.txt
		FLAG_LIB=1
	fi
	
	if [ $FLAG_LIB = 0 -a $FLAG_LINK = 0 ]
	then
		echo " " 
		echo "FLAG_LIB=$FLAG_LIB FLAG_LINK=$FLAG_LINK"
		cat $TMP/lib_use.txt >> $TMP/lib_use_full.txt
		cat $TMP/link_use.txt >> $TMP/link_use_full.txt
		cat $TMP/lib_readelf >> $TMP/readelf
		break
	fi
done

echo -e $GREEN ">[5/7]done." $RESET

echo -e $GREEN ">[6/7]Output the report files..." $RESET
sort $TMP/lib_use_full.txt -o $TMP/lib_use_full.txt
cat $TMP/lib_use_full.txt >> $OUT/lib_use_report.txt

sort $TMP/link_use_full.txt -o $TMP/link_use_full.txt
cat $TMP/link_use_full.txt >> $OUT/link_use_report.txt

sort $TMP/lib_unuse.txt -o $TMP/lib_unuse.txt
cat $TMP/lib_unuse.txt >> $OUT/lib_unuse_report.txt

sort $TMP/link_unuse.txt -o $TMP/link_unuse.txt
cat $TMP/link_unuse.txt >> $OUT/link_unuse_report.txt

cp $TMP/readelf $OUT/readelf_report.txt
echo -e $GREEN ">[6/7]done." $RESET

#Clean the temp files
echo -e $GREEN ">[7/7]Clean the temp files..." $RESET
rm -rf $TMP/*
echo -e $GREEN ">[7/7]done." $RESET

echo -e $GREEN "###############   Done   #############" $RESET
