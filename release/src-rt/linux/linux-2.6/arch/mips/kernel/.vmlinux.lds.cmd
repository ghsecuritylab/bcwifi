cmd_arch/mips/kernel/vmlinux.lds := mipsel-uclibc-gcc -E -Wp,-MD,arch/mips/kernel/.vmlinux.lds.d  -nostdinc -isystem /opt/brcm/K26/hndtools-mipsel-uclibc-4.2.4/bin/../lib/gcc/mipsel-linux-uclibc/4.2.4/include -D__KERNEL__ -Iinclude  -include include/linux/autoconf.h  -Wall -Wundef -Wstrict-prototypes -Wno-trigraphs -fno-strict-aliasing -fno-common -Werror-implicit-function-declaration -Wno-format-security -fno-delete-null-pointer-checks -I/home/rainkid/workspace/bcwifi/release/src-rt/include -DBCMDRIVER -Dlinux -O2 -ffunction-sections  -mno-check-zero-division -mabi=32 -G 0 -mno-abicalls -fno-pic -pipe -msoft-float -ggdb -ffreestanding  -march=mips32r2 -Wa,-mips32r2 -Wa,--trap  -Iinclude/asm-mips/mach-generic -D"LOADADDR=0xffffffff80001000" -D"JIFFIES=jiffies_64" -D"DATAOFFSET=0" -P -C -Umips -D__ASSEMBLY__ -o arch/mips/kernel/vmlinux.lds arch/mips/kernel/vmlinux.lds.S

deps_arch/mips/kernel/vmlinux.lds := \
  arch/mips/kernel/vmlinux.lds.S \
    $(wildcard include/config/boot/elf64.h) \
    $(wildcard include/config/mapped/kernel.h) \
    $(wildcard include/config/mips/l1/cache/shift.h) \
    $(wildcard include/config/blk/dev/initrd.h) \
  include/asm/asm-offsets.h \
  include/asm-generic/vmlinux.lds.h \

arch/mips/kernel/vmlinux.lds: $(deps_arch/mips/kernel/vmlinux.lds)

$(deps_arch/mips/kernel/vmlinux.lds):
