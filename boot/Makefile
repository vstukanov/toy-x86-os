DIST=./dist

all:
	mkdir -p $(DIST)

	nasm -O0 -fbin -o$(DIST)/boot0 ./boot0.S
	nasm -O0 -fbin -o$(DIST)/boot1 ./boot1.S

	dd conv=notrunc if=$(DIST)/boot0 of=$(DIST)/sda bs=446 count=1
	dd conv=notrunc if=/dev/zero     of=$(DIST)/sda bs=512 count=62 seek=1
	dd conv=notrunc if=$(DIST)/boot1 of=$(DIST)/sda bs=512 seek=1

run:
	qemu-system-i386 -boot c -drive file=$(DIST)/sda,format=raw