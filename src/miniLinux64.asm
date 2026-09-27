; 改成 Linux 64 位版本（NASM+ld 环境）
; nasm -f elf64 miniLinux64.asm -o miniLinux64.o
; ld miniLinux64.o -o miniLinux64
; ./miniLinux64
; echo $?


section .data

section .text
global _start
_start:
    ; Linux 64-bit exit 系统调用
    mov rax, 60    ; syscall number: exit
    mov rdi, 0     ; return code 0
    syscall
