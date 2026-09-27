; 最小汇编骨架：数据段、代码段、入口、退出
; nasm -f bin mini.asm -o mini.com

section .data

section .text
global _start

_start:
    ; DOS程序退出
    mov ah,4Ch
    int 21h