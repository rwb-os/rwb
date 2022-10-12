CC ?= gcc
AS = nasm

CFLAGS = -Wall -Wextra -Werror \
	-std=c2x -g -O2 -Ikernel \
	-nostdlib -ffreestanding \
	-fno-common -fno-pic -fno-pie \
	-fno-stack-protector -mno-red-zone \
	-mgeneral-regs-only \
	-m64 -mcmodel=kernel

ASFLAGS = -g -O4 -felf64

LDFLAGS = -static -nostdlib -O2 \
	-Wl,-zmax-page-size=0x1000 \
	-Wl,-no-pie -Wl,-T,kernel/arch/$(PLAT)/$(ARCH)/linker.ld \
	-Wl,-m,elf_x86_64 -Wl,--build-id=none

BUILDDIR = build

PLAT = x86
ARCH = amd64

CFILES := $(shell find kernel/arch/$(PLAT)/$(ARCH) -name "*.c")
CFILES += $(shell find kernel/arch/$(PLAT)  -maxdepth 1 -name "*.c")
CFILES += $(shell find kernel/ -name "*.c" -not -path "kernel/arch")
ASMFILES := $(shell find kernel/arch/$(PLAT)/$(ARCH) -name "*.asm")
ASMFILES += $(shell find kernel/arch/$(PLAT)  -maxdepth 1 -name "*.asm")
ASMFILES += $(shell find kernel/ -name "*.asm" -not -path "kernel/arch")

OBJS := $(CFILES:%.c=$(BUILDDIR)/%.o) $(ASMFILES:%.asm=$(BUILDDIR)/%.o)

kernel.elf: $(OBJS)
	${CC} $(LDFLAGS) -o $@ $^

$(BUILDDIR)/%.o: %.c
	mkdir -p $(@D)
	${CC} $(CFLAGS) -c -o $@ $<

$(BUILDDIR)/%.o: %.asm
	mkdir -p $(@D)
	${AS} $(ASFLAGS) $< -o $@

clean:
	rm -rf $(OBJS) kernel.elf
