; 如果你是学习 Linux x86?32 NASM（Linux汇编 32位）
; Linux下没有int 21h，使用Linux系统调用，完整示例：
; nasm -f elf32 helloLinux32.asm -o helloLinux32.o
; ld -m elf_i386 helloLinux32.o -o helloLinux32
; ./helloLinux32

section .data
    msg db  'Hello Linux Assembly',0xA
    len equ $ - msg

section .text
global _start

_start:
    ; write(1, msg, len)  1=stdout
    mov eax, 4      ; sys_write 系统调用号
    mov ebx, 1      ; 文件描述符stdout
    mov ecx, msg
    mov edx, len
    int 0x80        ; linux系统调用

    ; exit(0)
    mov eax, 1
    mov ebx, 0
    int 0x80