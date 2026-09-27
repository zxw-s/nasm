; 汇编完整入门示例（x86?DOS NASM + DOSBox）
; 这是一个完整可运行的汇编程序，实现：在屏幕输出一行字符串，然后退出程序。
; 面向理解汇编完整程序结构：数据段、代码段、入口、系统调用、退出。
; 环境：16位实模式 DOS，NASM 编译，DOSBox运行。

; nasm -f bin hello16.asm -o hello16.com
; --------------------------
; 汇编程序完整结构演示
; 段定义：数据段data、代码段code
; --------------------------

section .data        ; 数据段：存放常量、字符串，程序加载时就分配内存
    ; 定义字节字符串，0Dh=回车，0Ah=换行
    msg  db  'Hello Assembly!',0Dh,0Ah
    ; $代表当前内存地址，$?msg计算字符串字节长度，equ编译期计算，不占内存
    len  equ $ - msg

section .text        ; 代码段：存放CPU执行的机器指令
global _start        ; 声明程序入口点，链接器知道从 _start 开始执行

_start:
    mov cx, len      ; cx寄存器存放循环次数，即字符总个数
    mov si, 0        ; si寄存器作为字符串索引，从第0个字符开始

print_loop:          ; 标签，标记内存地址，用于循环跳转，不生成机器码
    mov al, [msg+si] ; 从内存读取msg[si]位置的一个字符送入al
    mov ah, 02h      ; DOS中断功能号02h：输出单个字符
    mov dl, al       ; dl存放待打印的字符，int21h要求参数放在dl
    int 21h          ; 触发DOS系统中断，请求操作系统打印字符

    inc si           ; 索引+1，处理下一个字符
    loop print_loop  ; cx = cx?1；cx不等于0就跳转到print_loop

    ; DOS 4Ch功能：程序退出返回操作系统
    mov ah, 4Ch
    int 21h