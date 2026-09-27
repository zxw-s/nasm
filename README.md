# NASM汇编语言入门（Linux，x86‑64,Intel语法）

汇编语言是**机器码的助记符**，和CPU架构强绑定，最常见：x86（32位）、x86‑64（64位）、ARM。

> 汇编没有统一标准，Windows用MASM，Linux用NASM/GAS。
> 
> NASM默认使用Intel语法，和MASM语法风格接近，但有少量自己的细节差异。

## 核心概念

1. **寄存器**：CPU内部高速小存储单元，比内存快得多，汇编主要操作寄存器。

2. **指令**：助记符，对应一条机器指令，如 `mov` 、 `add` 。

3. **操作数**：指令处理的数据，可以是寄存器、立即数（常量）、内存地址。

4. **段(section)**：把程序分成代码段、数据段。

-  `.text` ：代码段，放指令

-  `.data` ：数据段，放全局变量、常量字符串

5. 程序最终要**汇编→链接**，生成可执行文件。

> NASM语法特点：**目的操作数在前，源在后**

```nasm
mov 源, 目的
```

## x86‑64 通用寄存器（Intel 汇编，System V ABI，Linux）

> 64位寄存器：`rax/rbx/rcx/rdx/rsi/rdi/rsp/rbp` 对应32位：`eax/ebx/ecx/edx/esi/edi/esp/ebp` 16位：`ax,bx,cx,dx,si,di,sp,bp`；8位：`al,bl,cl,dl…`

| 寄存器     | 名称                     | 主要用途（System V AMD64 ABI，Linux）                         |
| ------- | ---------------------- | ------------------------------------------------------ |
| **rax** | 累加器                    | 1. 函数返回值；整数返回放rax，指针也放rax<br>2. 乘法、除法隐式使用；syscall系统调用号 |
| **rbx** | 基址寄存器                  | **被调用者保存(callee‑saved)**，函数内要使用必须先入栈保存；可做基址指针          |
| **rcx** | 计数寄存器                  | 1. loop循环的计数器；<br>2. 函数第4个参数；<br>3. rep字符串指令计数         |
| **rdx** | 数据寄存器                  | 1. 乘法存高64位、除法存余数；<br>2. 函数第3个参数                        |
| **rsi** | 源索引 Source Index       | 1. `movsb/movsq` 字符串源地址；<br>2. **函数第2个参数**             |
| **rdi** | 目的索引 Destination Index | 1. 字符串操作目的地址；<br>2. **函数第1个参数**                        |
| **rsp** | 栈指针 Stack Pointer      | **栈顶指针**，永远指向栈顶；`push/pop/call/ret`自动修改；禁止随意改写         |
| **rbp** | 栈基址 Base Pointer       | 栈帧基址；可选使用；作为栈帧时定位局部变量、函数参数；callee‑saved                |

### 📌 System V AMD64 函数调用传参规则（重点！考试高频）

> Linux x86‑64：前6个整型/指针参数依次： `rdi(1) → rsi(2) → rdx(3) → rcx(4) → r8(5) → r9(6)` 超过6个的参数压入栈；返回值：`rax`

> Windows x64 ABI不一样：rcx,rdx,r8,r9，不要搞混。

### 寄存器分类：调用保存规则

1. **调用者保存（caller‑saved）**：`rax, rcx, rdx, rsi, rdi, r8‑r11`
   
   > 调用函数前，如果你的数据在这些寄存器，**自己要压栈保存**，被调用函数可能直接覆盖。

2. **被调用者保存（callee‑saved）**：`rbx, rbp, r12‑r15`
   
   > 如果被调用函数要用这些寄存器，函数内部必须压栈保存，返回前恢复原值。

## 经典指令示例（带注释）

```nasm
; 示例：调用 func(a,b)，a=10，b=20
mov rdi, 10    ; 第1参数 a
mov rsi, 20    ; 第2参数 b
call func
; 返回结果存在 rax
mov [res], rax
```

```nasm
; 字符串拷贝 rep movsq
mov rsi, src   ; 源地址 rsi
mov rdi, dst   ; 目的地址 rdi
mov rcx, cnt   ; 拷贝数量给rcx
rep movsq      ; 重复拷贝 qword
```

```nasm
; 建立栈帧
push rbp
mov  rbp, rsp  ; rbp作为栈帧基址
sub  rsp, 32   ; 开辟32字节局部变量空间
; ...函数逻辑...
mov rsp, rbp
pop rbp
ret
```

## 完整最小示例：Linux64汇编 程序退出（Intel 语法）

文件： min.asm

```asm
section .text
global _start ; 链接器入口标记

_start:
    mov rax, 60 ; linux系统调用号60 = exit退出程序
    mov rdi, 0 ; exit返回码0，代表正常结束
    syscall ; 触发系统调用，交给内核执行
```

## 编译运行（Linux）

```bash
# nasm汇编，生成目标文件
nasm -f elf64 min.asm -o min.o
# ld链接生成可执行程序
ld min.o -o min
# 运行
./min
# 查看退出码
echo $?
```

> `syscall`  是64位Linux触发系统调用的指令，rax存系统调用编号，rdi rsi rdx依次传参数。

## 目录结构示例

```plaintext
nasm-demo/
├── src/
│   └── main.asm
├── build/          # 编译产物，make自动生成，不要提交到git
├── Makefile
├── README.md
└── .gitignore
```

## 易混点总结习题

1. x86‑64 Linux，函数第一个参数放在哪个寄存器？________
2. 函数返回值使用哪个寄存器？________
3. loop指令使用哪个寄存器做循环计数器？________
4. rsp 和 rbp 分别代表栈的什么位置？________
5. caller‑saved：`rax` 函数调用之后值是否一定保留？____

参考答案

1. rdi
2. rax
3. rcx
4. rsp=栈顶；rbp=栈帧基址
5. 不保证，调用者需要自己保存

可以再补充：段寄存器(`cs ss ds fs gs`)、r8‑r15扩展寄存器、以及简单手写汇编小练习。

> 也可以用32位子寄存器： `eax` (rax低32位),  `ebx` ；16位  `ax` ；8位  `al` 。
> 
> 修改32位寄存器，CPU会自动把对应64位高半部分清零。

# NASM代码段格式

## 汇编最小骨架示例（DOS‑16 NASM）min.asm

```nasm
; 最小汇编骨架：数据段、代码段、入口、退出
section .data

section .text
global _start
_start:
    ; DOS程序退出
    mov ah,4Ch
    int 21h
```

编译：

```bash
nasm -f bin min.asm -o min.com
```

## 汇编完整入门示例（x86‑DOS NASM + DOSBox）

> 这是一个**完整可运行**的汇编程序，实现：在屏幕输出一行字符串，然后退出程序。
> 面向理解汇编完整程序结构：数据段、代码段、入口、系统调用、退出。
> 环境：16位实模式 DOS，NASM 编译，DOSBox运行。

```nasm
; 文件名 hello.asm
; --------------------------
; 汇编程序完整结构演示
; 段定义：数据段data、代码段code
; --------------------------

section .data        ; 数据段：存放常量、字符串
    msg  db  'Hello Assembly!',0Dh,0Ah  ; 字符串+回车换行
    len  equ $ - msg  ; $代表当前地址，计算字符串字节长度

section .text        ; 代码段：存放执行指令
global _start        ; 声明程序入口，链接器识别

_start:
    ; DOS中断 0x21 功能09H：输出字符串(要求字符串以'$'结尾，这里换用02号功能逐字符输出)
    mov cx, len      ; cx = 要输出的字符个数
    mov si, 0        ; si = 字符串索引

print_loop:
    mov al, [msg+si] ; 取一个字符
    mov ah, 02h      ; DOS功能号：输出单个字符到屏幕
    mov dl, al       ; dl存放要打印的字符
    int 21h          ; 调用DOS系统中断

    inc si           ; 索引+1
    loop print_loop  ; cx自减，cx≠0跳回循环

    ; 程序退出，返回DOS
    mov ah, 4Ch
    int 21h
```

## 程序结构拆解（重点理解）

1. **`section .data` 数据段** 存放程序要用的常量、字符串、预置数据。程序运行前就已经确定，不会在这里写变量。
- `db` = define byte，定义字节数据
- `equ` 等价宏，编译时计算长度，不占用内存。
2. **`section .text` 代码段** 所有CPU指令写在这里，CPU只会执行text段的机器码。
3. **`global _start`** 告诉链接器：`_start` 是**程序入口点**，程序从这里第一条指令开始跑。
4. **标签 label**`_start:`、`print_loop:`，本质就是地址标记，供jmp/loop跳转用，本身不产生机器指令。
5. **寄存器使用**
- `ax/bx/cx/dx`：通用寄存器；`ah/al` 是ax的高低8位。
- `si`：源索引寄存器，用来遍历字符串。
6. **系统调用 `int 21h`** DOS系统中断，把功能号放入`ah`，设置参数，执行`int 21h`请求操作系统干活（打印、退出）。
7. **程序退出 `4Ch` 号功能**`mov ah,4Ch` + `int 21h`，标准DOS程序退出，交还控制权给操作系统。

### 编译运行步骤（NASM）

```bash
#编译生成16位bin
nasm -f bin hello.asm -o hello.com
```

放到DOSBox中，运行`hello.com`，屏幕输出：

```plaintect
Hello Assembly!
```

## 关键概念小结

1. **段**：数据段放数据，代码段放指令。
2. **入口点**：`_start`，程序第一行执行位置。
3. **寄存器**：CPU内部高速存储，汇编主要操作对象。
4. **系统调用（中断）**：汇编本身不能直接操作屏幕，请求操作系统完成IO、退出。
5. **标签**：标记内存地址，用于循环、跳转。

---

## Linux x86‑32 NASM（NASM Intel 语法）

Linux下没有`int 21h`，使用Linux系统调用，完整示例：

```nasm
; hello_linux.asm Linux 32位
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
```

编译命令（WSL / Linux）：

```bash
nasm -f elf32 hello_linux.asm -o hello_linux.o
ld -m elf_i386 hello_linux.o -o hello_linux
./hello_linux
```

> ⚠️ 只能在 Linux / WSL2 运行；原生 Windows MinGW 运行会段错误。

## Linux x86‑64 NASM（NASM Intel 语法）

Linux下使用`syscall`触发Linux内核系统调用；32 位 Linux 用 `int 0x80`，两套**完全独立的系统调用体系**，寄存器、调用号、ABI 全都不一样。

```nasm
; hello_linux.asm Linux 64位

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
```

编译命令（WSL / Linux）：

```bash
nasm -f elf64 hello_linux.asm -o hello_linux.o
ld hello_linux.o -o hello_linux
./hello_linux
```

> 提示：Windows下现代64位汇编和上面两套都不一样。

# Makefile（NASM x86_64 Linux）

```makefile
SRC_DIR := src
BUILD_DIR := build
ASM_FILE := $(SRC_DIR)/main.asm
OBJ := $(BUILD_DIR)/main.o
BIN := $(BUILD_DIR)/main
FORMAT := elf64

.PHONY: all clean

all: $(BIN)

# 创建build目录
$(BUILD_DIR):
    mkdir -p $(BUILD_DIR)

# 汇编阶段
$(OBJ): $(ASM_FILE) | $(BUILD_DIR)
    nasm -f $(FORMAT) -g -F dwarf $< -o $@

# 链接阶段
$(BIN): $(OBJ)
    ld $(OBJ) -o $(BIN)

# 清理产物
clean:
    rm -rf $(BUILD_DIR)
```

### 使用命令

```
make
./build/main
make clean
```

- `-g -F dwarf`：带上调试信息，方便 gdb
- `build/` 会自动创建，不需要手动新建

# x86 32位 vs x86-64（64位）Linux汇编 核心区别

>  `syscall` 是 **64位Linux**；32位Linux用 `int 0x80`。两套**完全独立的系统调用体系**，寄存器、调用号、ABI全都不一样。

## 1. 寄存器差异

| 64位(x86-64) | 32位(x86) | 说明                   |
| ----------- | -------- | -------------------- |
| rax         | eax      | 存放系统调用号，rax低32位就是eax |
| rdi         | ebx      | 第1个参数                |
| rsi         | ecx      | 第2个参数                |
| rdx         | edx      | 第3个参数                |
| r10         | esi      | 第4个参数                |
| r8          | edi      | 第5个参数                |
| r9          | ebp      | 第6个参数                |

> 32位：最多6个参数，依次放在 `ebx,ecx,edx,esi,edi,ebp` 64位：前6个参数直接用通用寄存器，**不用栈传前6参**

## 2. 触发系统调用指令（最大不同）

- ✅ **64位 Linux：`syscall`**
- ✅ **32位 Linux：`int 0x80`**（软中断）

## 3. 系统调用号不一样！（非常容易踩坑）

> 同一个功能，数字完全不同！
> 
> | 功能    | 64位 rax | 32位 eax |
> | ----- | ------- | ------- |
> | write | 1       | 4       |
> | exit  | 60      | 1       |

### 示例对比：打印字符串 + exit

#### 64位 Linux（Intel语法）

```nasm
section .data
msg db 'Hello',0xA
len equ $ - msg

section .text
global _start
_start:
    mov rax, 1        ; write 系统调用号 = 1
    mov rdi, 1        ; 文件描述符 stdout = 1
    mov rsi, msg      ; 字符串起始地址
    mov rdx, len      ; 字符串长度
    syscall

    mov rax, 60       ; exit 系统调用号 = 60
    mov rdi, 0        ; 返回码 0
    syscall
```

#### 32位 Linux（Intel语法，int 0x80）

```nasm
section .data
msg db 'Hello',0xA
len equ $ - msg

section .text
global _start
_start:
    mov eax, 4
    mov ebx, 1
    mov ecx, msg
    mov edx, len
    int 0x80

    mov eax, 1
    mov ebx, 0
    int 0x80
```

## 4. 编译目标不同

- 64位：`nasm -f elf64 hello.s -o hello.o` + `ld hello.o -o hello` 输出elf64

- 32位：`nasm -f elf32 hello32.s -o hello32.o`，链接：`ld -m elf_i386 hello32.o -o hello32`
  
  > 你的系统如果是64位WSL，需要安装32位库：`sudo apt install gcc-multilib`

## 5. 地址空间与栈

- 32位：寻址上限 4GB；寄存器32bit；栈、指针都是32bit
- 64位：寻址极大空间；通用寄存器64bit；指针64bit

## 6. NASM Intel语法版本对照

64位 NASM：

```nasm
mov rax, 1
mov rdi, 1
mov rsi, msg
mov rdx, len
syscall
```

32位 NASM：

```nasm
mov eax, 4
mov ebx, 1
mov ecx, msg
mov edx, len
int 0x80
```

编译32位nasm：

```bash
nasm -f elf hello32.asm -o hello32.o
ld -m elf_i386 hello32.o -o hello32
```

## 重点总结

1. **64位：syscall，rax存调用号，参数rdi,rsi,rdx...；exit=60，write=1**
2. **32位：int 0x80，eax存调用号，参数ebx,ecx,edx...；exit=1，write=4**
3. 两套**不能混用**，64位程序不能直接用 `int 0x80` 做系统调用，反之也不行。

> 补充：Windows下32/64位又是另一套API，和Linux完全无关，别混淆。

# Linux x86‑64 AT&T和Intel汇编语法区别

指令名字（mov/add/sub）一样，但整体语法规则不一样，属于两套不同汇编语法

> 指令助记符是CPU层面的，不变；**汇编语法是汇编器的文本规则，差别很大**

## 核心语法区别汇总

| 项目     | Intel（NASM）     | AT&T（GAS）                   |
| ------ | --------------- | --------------------------- |
| 操作数顺序  | `mov 目的, 源`     | `mov $源, %目的`               |
| 寄存器    | 直接写 `rax`       | 必须加百分号 `%rax`               |
| 立即数    | 直接写 `10`        | 必须加美元 `$10`                 |
| 内存访问   | `[rax]` 方括号     | `(%rax)` 圆括号                |
| 操作宽度   | 由寄存器自动推断，一般不用后缀 | 指令加后缀：`movb/movw/movl/movq` |
| 当前地址符号 | `$`             | `.`                         |

### 例子：同一件事，语法写法完全不同

Intel：

```nasm
mov al, [rbx]   ; 把rbx指向的1字节读到al
```

AT&T：

```nasm
movb (%rbx), %al
```

## 相同点

- 指令单词：`mov`、`add`、`sub`、`jmp`、`syscall` 这些助记符**文本一样**
- 跳转、栈、标志位的逻辑不变
- 最终产出的机器码相同

## 总结

**助记符单词相同，但整套书写语法完全不是一套。** 不能把Intel语法直接丢给GAS，也不能把AT&T直接丢给默认模式NASM，会报语法错误。

举个直观例子：

```nasm
; Intel
mov rax, 1
; AT&T
mov $1, %rax
```

都是把1放进rax，但**语法格式不一样**。

# NASM README（x32/x64）

```plaintext
# 项目简介

基于 NASM 汇编器，Windows平台，支持 **32位(x32) / 64位(x64)** 汇编程序开发。
内置3套链接方案：

1. MinGW GCC（封装ld，入门推荐）
2. MinGW ld（原生链接器，无C运行时包装，底层学习）
3. Microsoft link.exe（VS BuildTools微软原生链接器，PE原生）

开发工具：VSCode + C/C++插件 + cppvsdbg调试器

> 调试特性：VSCode调试面板直接查看CPU寄存器（rax/rbx/rip / eax/ebx/eip）

# 环境依赖

## 必须安装

1. **NASM**
  - 下载并将 `nasm.exe` 添加到系统环境变量 PATH
2. **MinGW-w64**（提供 gcc / ld）
  - 编译32位程序需要完整32bit库支持
3. **Visual Studio BuildTools**（可选，使用link.exe才需要）
  - 安装组件：Desktop development with C++
  - ⚠️ 使用link.exe时，**必须从VS开发者终端启动VSCode**，否则无法识别link.exe
4. VSCode插件：C/C++（Microsoft官方插件，提供cppvsdbg调试）

# 关于 tasks.json 中 command 路径说明

> 本项目tasks.json上传GitHub/Gitee时，**全部直接写程序名，不硬编码绝对路径**
> 示例：`"command":"nasm"` / `"command":"link"` / `"command":"gcc"`

## 两种写法对比

1. 直接写命令名（✅推荐，仓库版本使用这个）
  - 原理：读取终端环境变量`PATH`自动搜索程序
  - 优点：可移植，其他人克隆项目不需要修改tasks.json
  - 前提：
    - `nasm`、`gcc`、`ld`：添加到系统PATH，重启VSCode即可
    - `link.exe`：需要从VS开发者终端启动VSCode加载环境
2. 写死绝对路径（❌不建议提交到代码仓库，仅本地临时调试）

  ```json
  "command": "C:\\Tools\\nasm\\nasm.exe"
```

```
- 缺点：VS安装目录每个人不一样，换电脑直接失效；提交仓库会给其他人带来麻烦
- Windows JSON路径规则：必须使用双反斜杠`\\`，单反斜杠`\`会导致JSON解析报错

## 报错处理：提示“xxx不是内部或外部命令”

二选一：

1. 【推荐】配置环境变量：NASM/MinGW加入系统PATH；link工具使用VS开发者终端启动VSCode，自动加载环境变量，重启VSCode生效
2. 本地临时方案：command填写完整绝对路径，**提交仓库前务必改回命令名**

# 项目目录结构

```plaintext
.
├── .vscode
│ ├── tasks.json // 编译任务配置，x32/x64 + gcc/ld/mslink全套任务
│ └── launch.json // 调试配置，6套调试方案
├── src // 汇编源码目录（*.asm）
├── README.md
└── .gitignore
```

```
# 编译任务说明（Ctrl+Shift+B 调出任务列表）

> 编译产物命名规则：`文件名_位数_链接器.exe`，产物互不覆盖
> 例：`test_x64_gcc.exe`、`test_x32_mslink.exe`

## 🔹 64位(x64)任务

1. `nasm-build-x64`：仅汇编，生成 x64 obj目标文件
2. `nasm-link-x64-gcc`：汇编 + GCC链接
3. `nasm-link-x64-ld`：汇编 + MinGW ld链接
4. `nasm-link-x64-mslink`：汇编 + MS link.exe链接
5. `build-run-x64-gcc`：汇编+链接+一键运行(GCC)
6. `build-run-x64-ld`：汇编+链接+一键运行(ld)
7. `build-run-x64-mslink`：汇编+链接+一键运行(link.exe)

## 🔹 32位(x32)任务

1. `nasm-build-x32`：仅汇编，生成 x32 obj目标文件
2. `nasm-link-x32-gcc`：汇编 + GCC链接
3. `nasm-link-x32-ld`：汇编 + MinGW ld链接
4. `nasm-link-x32-mslink`：汇编 + MS link.exe链接
5. `build-run-x32-gcc`：汇编+链接+一键运行(GCC)
6. `build-run-x32-ld`：汇编+链接+一键运行(ld)
7. `build-run-x32-mslink`：汇编+链接+一键运行(link.exe)

# 三套链接器对比

| 链接器 | 来源  | 优点  | 适用场景 |
| --- | --- | --- | --- |
| GCC | MinGW-w64 | 使用最简单，自动处理入口main，新手友好 | 汇编入门、简单Demo |
| ld  | MinGW-w64 | 底层原生链接器，无C标准库包装，更贴近原理 | 学习PE底层、操作系统底层实验 |
| link.exe | VS BuildTools | Windows原生链接器，生成标准PE文件，和微软工具链完全兼容 | Windows底层逆向、MASM配套学习 |

> 注意：使用link.exe必须在VS开发者命令行启动VSCode，否则找不到link命令。

# 调试使用方法

1. 选中对应的`.asm`源码文件
2. 先执行编译任务（Ctrl+Shift+B）生成exe
3. F5启动调试，在调试下拉框选择对应配置：
  - NASM x64 GCC
  - NASM x64 LD
  - NASM x64 MS Link
  - NASM x32 GCC
  - NASM x32 LD
  - NASM x32 MS Link
4. VSCode左侧调试面板，可直接查看通用寄存器、指令指针、栈信息。

# 示例代码

## x64示例 src/test_x64.asm

```nasm
section .text
global main
main:
    mov rax, 0x1234
    ret
```

```
## x32示例 src/test_x32.asm

```nasm
section .text
global main
main:
    mov eax, 0x1234
    ret
```

```
# Git提交规范

```plaintext
feat: 新增xxx汇编demo
fix: 修复汇编链接报错
docs: 更新README说明
refactor: 重构汇编代码
```

```
# 常见问题排查

1. `nasm不是内部命令`：检查nasm是否加入系统PATH，重启VSCode
2. gcc `-m32`报错：MinGW缺少32位库，重新下载完整MinGW-w64
3. link.exe无法识别：**从VS开发者终端打开VSCode**
4. 程序直接闪退：在调试模式F5运行，断点停在入口查看寄存器
5. 寄存器窗口看不到：确认调试器选择`cppvsdbg`，不要用gdb

# License

MIT
```
