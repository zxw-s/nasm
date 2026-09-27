; x86汇编入门示例（DOS .exe，NASM + DOSBox）
; 16位DOS汇编程序，NASM语法
; 完整演示汇编程序结构：数据段、代码段、入口、字符串输出、程序退出
; 编译生成16位bin：nasm -f bin miniF.asm -o miniF.com

section .data         ; --------【数据段】存放常量、字符串等数据
   msg db  'Hello Assembly!', 0Dh, 0Ah, '$'
   ; db = define byte 定义字节
   ; 0Dh 回车，0Ah换行，$ 是DOS字符串结束标记

section .text         ;【代码段】存放执行指令
global _start         ; 声明程序入口，链接器标记程序入口点
_start:                   ; 【代码段】存放执行指令
   ; DOS中断21h，09号功能：输出$结尾字符串
   mov ah, 09h         ; ah寄存器存放功能号，09H=打印字符串
   mov dx, msg         ; dx寄存器放字符串的偏移地址
   int 21h             ; int 21h 调用DOS系统服务

   ; DOS中断21h，4C号功能：正常退出程序，返回操作系统
   mov ah, 4Ch
   mov al, 00h         ; 返回码0，表示正常结束
   int 21h