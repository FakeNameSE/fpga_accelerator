EXTRA_CFLAGS +=
APP_EXTRA_FLAGS:= -O2 -ansi -pedantic
KERNEL_SRC:= /lib/modules/$(shell uname -r)/build
SUBDIR= $(PWD)
GCC:=gcc
RM:=rm

all: modules

obj-m:= proc_comms.o

modules:
	$(MAKE) -C $(KERNEL_SRC) M=$(SUBDIR) modules

.PHONY : clean
clean:
	$(RM) -f *.ko *.o *.mod.c Module.symvers modules.order *~ .tmp_versions

load:
	sudo insmod proc_comms.ko

unload:
	sudo rmmod proc_comms

watch:
	sudo journalctl -xf | grep --color=always "filter:"

	
