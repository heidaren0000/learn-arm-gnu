# p2_helloworld

## 指令

1. `ldr r1, =helloworld`: ldr 指令用来从内存中读出数据. 这行指令的意思是把 helloworld 标签的初始地址读到 R1 中

## 伪指令

1. `.data` 用来表示源码文件接下来的部分一直到结束都是用来定义程序的数据区
2. `.ascii` 告诉汇编器接下来你想存放一段 ASCII 数据, 之后我们可以通过 label 来访问这些数据.

## 重点: Linux 系统调用

在这个例子里面, 通过使用 Linux 系统调用, 来把程序输出到 stdout 中, 进而在命令行中显示.

```asm
_start: mov R0, #1          @ 1 = stdout
        ldr R1, =helloworld @ string to print
        mov R2, #11         @ length of our string
        mov R7, #4          @ linux write system call
        svc 0               @ call linux to print
```

之所以使用软中断而不是子程序或者分支语句的优点是不需要知道这段中断服务程序在内存中的具体地址. 这样如果 Linux 系统更新后更换了地址咱们的调用也不受影响.

在使用系统调用的时候, R0 - R4 这四个寄存器用来传递参数, R7来指定要调用的系统调用类型. 

R0 用来选择要输出的文件. 1 代表标准输出流. 这个跟 Linux 系统设计有关系. 在 Linux 中东西都是文件. 输出到终端本质上也是在写入文件. 在 Linux 中程序启动的时候, 系统会给每个进程分配三个文件:

- 标准输入流 `stdin` 分配 FileDescripor 0
- 标准输出流 `stdout` 分配 FileDescriptor 1
- 标准错误流 `stderr` 分配 FD 2

所以输出到标准输出流本质上就是写入到 FD1, 所以 R0 写入 1

R1 中存放了 helloworld 这个标签的首地址.

R2 指定了字符串的长度. 注意不要太长, 不然就会访问超过范围的内容, 会输出乱码, 可能引发崩溃.

> 汇编之后的可执行文件的大小只有 884byte 我又尝试用 C 写了一个输出同样内容的 helloworld, 编译结果的文件大小竟然有 8096k, 差了将近 10倍.

## 重点: 逆向

```bash
obdump -s -d p2_helloworld
```



![](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screenshot_20221025_172159.png)

```shell
daren@localhost:~/WorkspaceDior/learn-arm/1_basic$ objdump -s -d p2_helloworld

p2_helloworld:     file format elf32-littlearm

Contents of section .text:
 10074 0100a0e3 14109fe5 0b20a0e3 0470a0e3  ......... ...p..
 10084 000000ef 0000a0e3 0170a0e3 000000ef  .........p......
 10094 98000200                             ....            
Contents of section .data:
 20098 48656c6c 6f776f72 6c640a             Helloworld.     
Contents of section .ARM.attributes:
 0000 41110000 00616561 62690001 07000000  A....aeabi......
 0010 0801                                 ..              

Disassembly of section .text:

00010074 <_start>:
   10074:       e3a00001        mov     r0, #1
   10078:       e59f1014        ldr     r1, [pc, #20]   ; 10094 <_start+0x20>
   1007c:       e3a0200b        mov     r2, #11
   10080:       e3a07004        mov     r7, #4
   10084:       ef000000        svc     0x00000000
   10088:       e3a00000        mov     r0, #0
   1008c:       e3a07001        mov     r7, #1
   10090:       ef000000        svc     0x00000000
   10094:       00020098        .word   0x00020098
```

输出的第一部分是 `.text` 这个部分包含了文件中的所有数据, 由于字节序的原因和下面的源码是反过来的

第二部分是 `.data` 包含了程序的 `.data`区

后面接着是对程序的反汇编, 结合之前书中对于数据处理指令的格式,

![](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/data instruction format.png)

![](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/20221025_174127_temp.jpg)

- 31-28, 4位 用来设置 CPSR 状态寄存器, 这里的是 `e` , 表示无条件执行
- 27-25, 3位 用来表示操作数, 001 表示是操作数的类型是立即数
- 24-21, 4位 存放操作码, 1110 是 `mov` 指令的操作码
- 20位, 在这个例子中没有用到
- 19-16, 4位 第一个操作码的寄存器编号, 这里是 R0 所以是 0
- 剩下的地方在这个例子中用来存放立即数

```asm
ldr 	R1, =helloworld 
ldr     r1, [pc, #20]	; 10094 <_start+0x20>
```

另外, 源码中访问 helloworld 这个标签的语句经过汇编之后换成了 PC + #20 这样的偏移地址

不过我有个疑问是, #20 这种表示的立即数到底是十进制还是十六进制, 同时这个偏移地址怎么计算, 他后面有一个注释写的是 _start+0x20, 问题是到了这一行的时候 PC 的值早就不是 _start 了