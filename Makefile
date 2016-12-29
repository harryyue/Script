KERNELDIR:=/lib/modules/$(shell uname -r)/build
SRC:=
APP:=

module:
	make -C $(KERNELDIR) M=$(shell pwd) modules
#	gcc $(APP).c -o $(APP)

ins:
	@$(shell sudo insmod $(SRC).ko)
	@$(sudo chmod 666 /dev/chrdev_driver1)
	@sudo dmesg
	@echo "<---------echo------------------------------------->"
	@lsmod|head

rm:
	@$(shell sudo rmmod $(SRC))
	@sudo dmesg
	@echo "<---------------------------------echo------------->"
	@lsmod|head

test:
	#@$(shell sudo chmod 666 /dev/chrdev_driver1ev_driver1)
	#@$(shell ./$(APP))
	#@sudo dmesg

clean:
	@sudo dmesg -c
	@sudo dmesg -c
	rm -rf *.o module*  Module* *.ko *.mod* $(APP)
	@echo "<---------------------------------------------->"
	@ls -l

obj-m=$(SRC).o
