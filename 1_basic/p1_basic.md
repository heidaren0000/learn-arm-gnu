# p1_basic 

```asm
        .global _start  @ Indicate _start is global for linker
_start: mov     R0, #78 @ Move a decimal 78 value into register R0
        mov     R7, #1  @ Move a decimal 1 integer value into register R7
        svc     0       @ Perform Service Call to Linux
        .end
```

## 伪指令

1. `.global`: 把这个 `label` 交给链接器
2. `.end`: 表示这个文本文件的结束
3. `_start`: 一个 label. linker 会查找名叫 `_start` 的全局 label 来作为程序执行的起点. 这就是为啥之前要先把这个定义成 `global`
4. 在一个项目中, 可以有多个 `.S` 结尾的文件, 但是只能有一个文件中包含 `_start` 全局标签.

## 指令

1. `mov`: 数据移动
2. `svc`: Service Call. 调用 Linux 的系统服务. 配合 R7 中的 1, 意思是结束这个程序. 
3. `svc 0 ` 执行了软中断0, 会调用 Linux 内核中的中断服务函数, 同时解析 R7 中作为参数传递的数据

## 工具使用

```shell
as -o source.o source.S # 把汇编源码翻译成字节码
ld -o target source.o # 把字节码链接成 Linux 可执行文件
```

如果源码的后缀名是大写S, 意味着源码会先经过 C 预处理器再给汇编器. 这时可以使用 C 的注释格式.
