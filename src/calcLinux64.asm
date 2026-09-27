; x86?64 NASM Linux 输入+加法演示
; 逻辑：键盘读到的是ASCII字符，'0'=48，需要减去'0'(48)转为数值；计算后再转回ASCII输出
; nasm -f elf64 calc.asm -o calc.o
; ld calc.o -o calc
; ./calc

section .data
   prompt1 db  '请输入第一个数字(0?9): ',0
   len1    equ $ - prompt1
   prompt2 db  '请输入第二个数字(0?9): ',0
   len2    equ $ - prompt2
   out_msg db  '两数相加结果: ',0
   len_out equ $ - out_msg
   newline db  0xA

section .bss        ; bss段：未初始化数据，用来存放输入缓冲区
   buf resb 2      ; 预留2字节缓冲区，保存键盘输入

section .text
global _start

_start:
   ; =========输出提示1=========
   mov rax, 1
   mov rdi, 1
   mov rsi, prompt1
   mov rdx, len1
   syscall

   ; =========读取第一个键盘输入=========
   mov rax, 0      ; read系统调用号0
   mov rdi, 0      ; 标准输入stdin
   mov rsi, buf
   mov rdx, 2
   syscall
   mov r8b, [buf]  ; 取出输入的ASCII字符到r8b
   sub r8b, '0'    ; ASCII转真实数值  '5'?48 → 5

   ; =========输出提示2=========
   mov rax, 1
   mov rdi, 1
   mov rsi, prompt2
   mov rdx, len2
   syscall

   ; =========读取第二个键盘输入=========
   mov rax, 0
   mov rdi, 0
   mov rsi, buf
   mov rdx, 2
   syscall
   mov r9b, [buf]
   sub r9b, '0'

   ; =========做加法计算=========
   add r8b, r9b    ; r8b = r8b + r9b

   ; =========输出结果提示文字=========
   mov rax, 1
   mov rdi, 1
   mov rsi, out_msg
   mov rdx, len_out
   syscall

   ; =====简单处理：结果0?18，分个位十位输出=====
   mov al, r8b
   mov bl, 10
   div bl          ; al ÷ bl，al=商(十位)，ah=余数(个位)

   ; 如果十位>0，输出十位字符
   cmp al, 0
   jz print_digit
   add al, '0'
   mov [buf], al
   mov rax,1
   mov rdi,1
   mov rsi,buf
   mov rdx,1
   syscall

print_digit:
   ; 输出个位
   add ah, '0'
   mov [buf], ah
   mov rax,1
   mov rdi,1
   mov rsi,buf
   mov rdx,1
   syscall

   ; 输出换行
   mov rax,1
   mov rdi,1
   mov rsi,newline
   mov rdx,1
   syscall

   ; =====程序退出=====
   mov rax, 60
   mov rdi, 0
   syscall