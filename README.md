#Scripe

#用于放置各种脚本
#001.Makefile										=>		linux驱动外部模块编译脚本
#002.build_intel.sh									=>		intel baytral Android编译脚本
#003.flashimage_intel.sh							=>		intel baytral Android烧写image脚本
#004.compile.sh										=>		调用脚本
#005.push_ko.py										=>		android用于push驱动模块的脚本
#006.patchcopy_1st.py								=>		用于将git format patch分类存储(初版)
#007.patchcopy_2st.py								=>		用于将git format patch分类存储(修正版)
#008.patchcopy_3st.py								=>		用于将git format patch分类存储(修正版更新)
#009.lib_useful_check_slim_release.sh 				=>  	用于找出rootfs中没有被使用的library
#010.apply_patch.sh 								=> 		用于将一个分支的patch打到另外一个分支上	
#011.lib_classification_release.sh  				=>      用于找出rootfs中没有被使用的library，并且分类(初选)
#012.slim_rootfs_release.sh 						=> 		读取指定文件内容，然后依次删除rootfs中的对应文件，实现rootfs的slim
