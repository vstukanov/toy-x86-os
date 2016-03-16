DIST=./dist
ROOT=../root

all:
	mkdir -p $(DIST)

	nasm -O0 -fbin -o$(DIST)/boot0 ./boot0.S
	nasm -O0 -fbin -o$(DIST)/boot1 ./boot1.S

	dd conv=notrunc if=$(DIST)/boot0 of=$(DIST)/sda bs=446 count=1
	dd conv=notrunc if=/dev/zero     of=$(DIST)/sda bs=512 count=62 seek=1
	dd conv=notrunc if=$(DIST)/boot1 of=$(DIST)/sda bs=512 seek=1

run:
	qemu-system-i386 -boot c -drive file=$(DIST)/sda,format=raw

sda:
	dd if=/dev/zero of=$(DIST)/sda bs=4096 count=4096
	sfdisk $(DIST)/sda < sda.layout
	mkdir -p ./mnt
	@set -e ;\
	echo Loop back disk file ;\
	LOOP_DEV=$$(losetup --show -f -P $(DIST)/sda) ;\
	LOOP_PTR=$$LOOP_DEV"p1" ;\
	echo Loop patrition is: $$LOOP_PTR ;\
	mkfs.ext2 $$LOOP_PTR ;\
	mount $$LOOP_PTR ./mnt ;\
	echo Copy root ;\
	cp -Rv $(ROOT)/* ./mnt ;\
	umount ./mnt ;\
	echo Detach loop device ;\
	losetup -D $$LOOP_DEV ;\