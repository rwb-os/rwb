#include <stdint.h>

#include <boot/multiboot.h>

uint8_t kernel_stack[4096];

void start_sys(uint64_t multiboot_magic, void *multiboot_info) {
	(void)multiboot_magic;
	(void)multiboot_info;
	for (;;) {}
}