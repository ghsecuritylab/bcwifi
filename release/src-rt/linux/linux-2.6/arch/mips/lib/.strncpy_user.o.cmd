cmd_arch/mips/lib/strncpy_user.o := mipsel-uclibc-gcc -Wp,-MD,arch/mips/lib/.strncpy_user.o.d  -nostdinc -isystem /opt/brcm/K26/hndtools-mipsel-uclibc-4.2.4/bin/../lib/gcc/mipsel-linux-uclibc/4.2.4/include -D__KERNEL__ -Iinclude  -include include/linux/autoconf.h -D__ASSEMBLY__ -I/home/rainkid/workspace/bcwifi/release/src-rt/include -ffunction-sections  -mno-check-zero-division -mabi=32 -G 0 -mno-abicalls -fno-pic -pipe -msoft-float -ggdb -ffreestanding  -march=mips32r2 -Wa,-mips32r2 -Wa,--trap  -Iinclude/asm-mips/mach-generic    -c -o arch/mips/lib/strncpy_user.o arch/mips/lib/strncpy_user.S

deps_arch/mips/lib/strncpy_user.o := \
  arch/mips/lib/strncpy_user.S \
  include/linux/errno.h \
  include/asm/errno.h \
  include/asm-generic/errno-base.h \
  include/asm/asm.h \
    $(wildcard include/config/printk.h) \
    $(wildcard include/config/cpu/has/prefetch.h) \
  include/asm/sgidefs.h \
  include/asm/asm-offsets.h \
  include/asm/regdef.h \

arch/mips/lib/strncpy_user.o: $(deps_arch/mips/lib/strncpy_user.o)

$(deps_arch/mips/lib/strncpy_user.o):
