ENTRY(_start)

KERNEL_LMA = 0x100000;
KERNEL_VMA = 0xffffffff80100000;
KERNEL_OFF = KERNEL_VMA - KERNEL_LMA;

SECTIONS
{
	. = 0x0100000;
	.boot :
	{
		*(.multiboot)
		*(.boot.text)
		*(.boot.data)
		. = ALIGN(16);
		PROVIDE(init_stack = .);
		. += 1K;
		PROVIDE(init_stack_top = .);
	}

	. += KERNEL_OFF;
	.text ALIGN(4096) : AT(ADDR(.text) - KERNEL_OFF)
	{
		*(.text)
	}

	.data ALIGN(4096) : AT(ADDR(.data) - KERNEL_OFF)
    {
        *(.data)
    }

	.rodata ALIGN(4096) : AT(ADDR(.rodata) - KERNEL_OFF)
    {
        *(.rodata*)
    }

	.bss ALIGN(4096) : AT(ADDR(.bss) - KERNEL_OFF)
    {
        *(.bss)
		*(COMMON)
    }

	/DISCARD/ :
    {
        *(.eh_frame)
        *(.note.gnu.build-id)
        *(.comment)
    }
}