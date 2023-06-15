firmware.elf: sections.lds start.s firmware.c
	riscv64-unknown-elf-gcc -march=rv32i -mabi=ilp32 -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -nostdlib -o firmware.elf start.s firmware.c

firmware.bin: firmware.elf
	riscv64-unknown-elf-objcopy -O binary firmware.elf /dev/stdout > firmware.bin

firmware.hex: firmware.bin
	python3 makehex.py $^ 4096 > $@

inspect:
	riscv64-unknown-elf-objdump -b binary -mriscv:rv32 -D firmware.bin | tr '\t' '_' | sed 's/\_/del/2' | sed 's/^.*del//g' | sed 's/_.*//g' | sort | uniq

ROM: 
	./fill_rom firmware.bin ROM_template.vhd
