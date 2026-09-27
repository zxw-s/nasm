; DOS 16 位程序（DOSBox，需要生成.com 或者.exe，不能用 ld）
; 不能用 elf64，要用 bin 原始二进制，并且开头bits 16
; 编译成 com 文件：nasm -f bin minibin.asm -o minibin.com

bits 16
org 100h        ; .com程序固定起始地址
; .com程序不需要section，全部在一个段
mov ah,4Ch
int 21h
