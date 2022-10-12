section .multiboot
align 8
multiboot_header:
	dd 0xe85250d6									; Multiboot header magic
	dd 0											; 32-bit x86
	dd (.end - multiboot_header)					; Length
	dd -(0xe85250d6 + (.end - multiboot_header))	; Checksum

	; Tags
	;dw 5
	;dw 0
	;dd 20
	;dd 0
	;dd 0
	;dd 0

	dw 0
	dw 0
	dd 8
.end:

section .boot.data
gdtptr:
	dw (gdt64.end - gdt64)
	dd gdt64

gdt64:
	dq 0

	dw 0
	dw 0
	db 0
	db 0b10011010
	db 0b00100000
	db 0

	dw 0
	dw 0
	db 0
	db 0b10010010
	db 0
	db 0
.end:

align 4096
pml4:
	resq 512

pdpt:
	resq 512

pd:
	resb 16384

section .boot.text

bits 32

extern init_stack_top

global _start
_start:
	mov edi, eax
	mov esi, ebx
	
	; Set up stack
	mov esp, init_stack_top

	push dword 0
	popfd

	push dword 0
	push esi
	push dword 0
	push edi

	mov edi, pml4
	xor edx, edx
	mov ecx, 1024
.1:
	mov [edi], edx
	add edi, 4
	loop .1

	mov edi, pdpt
	mov ecx, 1024
.2:
	mov [edi], edx
	add edi, 4
	loop .2

	mov edi, pml4
	mov ecx, pdpt
	or ecx, 7
	mov [edi], ecx
	mov [edi + 0x800], ecx
	mov [edi + 4088], ecx

	mov ecx, pd
	or ecx, 7
	mov edi, pdpt
	mov [edi], ecx
	mov [edi + 4080], ecx
	add ecx, 0x1000
	mov [edi + 8], ecx
	add ecx, 0x1000
	mov [edi + 16], ecx
	add ecx, 0x1000
	mov [edi + 24], ecx

	mov edi, pd
	mov ecx, 2048
	mov edx, 0x7
.3:
	mov [edi], edx
	add edx, 0x200000
	add edi, 8
	loop .3

	mov eax, pml4
	mov cr3, eax

	; Enable PAE
	mov edx, cr4
	or edx, (1 << 5)
	mov cr4, edx

	; Enable long mode :yay:
	mov ecx, 0xc0000080
	rdmsr
	or eax, (1 << 8)
	wrmsr

	; Enable paging
	mov eax, cr0
	or eax, 0x80000000
	mov cr0, eax

	lgdt [gdtptr]
	jmp 0x08:_start64

bits 64
_start64:
	mov rax, _entry64
	jmp rax

section .text
bits 64

extern kernel_stack
extern start_sys

_entry64:
	mov rax, 0xffffffff80000000
	add rsp, rax
	add rbp, rax

	pop rdi
	pop rsi

	mov rsp, kernel_stack + 4096
	jmp start_sys
