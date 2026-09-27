; Linux x86?64 NASM汇编示例
; nasm -f elf64 helloLinux64.asm -o helloLinux64.o
; ld helloLinux64.o -o helloLinux64
; ./helloLinux64

section .data
   msg db  'Hello x86?64 Assembly',0xA
   len equ $ - msg   ; equ：宏，计算字符串字节长度

section .text
global _start

_start:
   ; write系统调用，输出字符串
   mov rax, 1          ; 系统调用号 1 = write
   mov rdi, 1          ; 文件描述符1 =标准输出屏幕
   mov rsi, msg        ; 字符串地址
   mov rdx, len        ; 字符串长度
   syscall             ; 触发Linux内核系统调用

   ; exit 退出程序
   mov rax, 60         ; 系统调用号60 = exit
   mov rdi, 0          ; 返回码0正常结束
   syscall