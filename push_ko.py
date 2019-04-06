import os

os.system('adb wait-for-device ; adb remount')

for filename in os.listdir(r'system/lib/modules'):
	if '.ko' in filename:
		cmd = 'adb push system/lib/modules/' +  filename + '  /system/lib/modules/' + filename
		os.system(cmd)
    
os.system('adb reboot bootloader; fastboot flash boot boot.img; fastboot reboot')
