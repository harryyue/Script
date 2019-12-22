# Scripe

## 用于放置各种脚本
***
|No.|File Name|Description|
|---|---|---|
|001|Makefile|linux驱动外部模块编译脚本|
|002|build_intel.sh|intel baytral Android编译脚本|
|003|flashimage_intel.sh|Intel baytral Android烧写image脚本|
|004|compile.sh|调用脚本|
|005|push_ko.py|Android用于push驱动模块的脚本|
|006|patch_classification_release.py|用于将git format patch分类存储|
|007|lib_useful_check_slim_release.sh|用于找出rootfs中没有被使用的library|
|008|apply_patch.sh|用于将一个分支的patch打到另外一个分支上|	
|009|lib_classification_release.sh|用于找出rootfs中没有被使用的library，并且分类(初选)|
|010|slim_rootfs_release.sh|读取指定文件内容，然后依次删除rootfs中的对应文件，实现rootfs的slim|
|011|build_full_ici2_image.sh|用于生成ICI2.0的Relese image|
|012|revert_library.sh|读取指定文件内容，然后依次把rootfs中的对应文件，实现rootfs的slim|
|013|memory_information_get.sh|Use to get the system memory information|
|014|GetAllPatchesOfSpecialFile.sh|Use to generate special files' patches in git repository|
|015|desip_message_conversion.sh|Use to conversion desip message from desip uart log|
|016|filter_special_desip_message.sh|Use to filter special desip message from desip message log file and calculate its checksum|
