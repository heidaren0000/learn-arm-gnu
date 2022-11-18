# p2_1_tools

 总结需要使用的工具以及方法

## todo

- gdb 远程调试. 
- none eabi 的 gdb 调试方法

## 汇编和链接

目前使用的是来自 `binutils` 的工具

```bash
as -o source.o source.S # 把汇编源码翻译成字节码
ld -o target source.o # 把字节码链接成 Linux 可执行文件
```

## 二进制文件分析: objdump

```bash
obdump -s -d p2_helloworld
```

## 运行时调试: GDB

这里使用 p2_helloworld 这个程序作为例子

![](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screenshot_20221118_140508.png)

### 基本指令

- 加载可执行文件 `[f]ile 可执行文件路径` 也可以直接把路径作为 gdb 第一个参数
- 执行程序 `[r]un` 
  - 如果执行时需要传递参数, 可在其后添加参数: `[r]un arg1 args...`
    - 也可使用 gdb 命令的 `--args` 参数来传递参数
- 退出 `[q]uit`
- 结束当前调试会话 `[k]ill`
- 查看当前信息 `[i]nfo` 这个指令很有用, 也比较复杂, 有很多参数
  -  `[i]nfo [r]egisters`  查看所有寄存器状态
  -  `[i]nfo [r]egister 寄存器名` 查看某个寄存器状态
    - 用  `[i]nfo [all-r]egister`  可以列出更多的寄存器  
  -  `[i]nfo [b]reak` 列出当前所有断点   
  -  `[i]nfo [s]tack` 暂未用到, 后续补充
  -  `[i]nfo [f]rame` 暂未用到, 后续补充
  -  `[i]nfo [f]unctions` 暂未用到, 后续补充   

> 如何在 gdb 直接执行某些指令?
>
> 可以使用 `-ex` 参数, 比如 `gdb -ex=r` 就会在 gdb 运行的时候直接使用 `run`执行程序

### 断点和单步执行

- 继续运行 `[c]ontinue`

- 设置断点 `[b]reak 内存地址或者代码行`

- 单步执行 , 进入经过的函数`[s]tep`
  - `[s]tep 数字` 可以指定执行的步数
- 单步执行, 跳过经过的函数 `[n]ext`
  - `[n]ext 数字`  可以指定执行的步数

### 栈相关-后续补充

- `[b]ack[t]race`
- `[w]here`

## 解析内存

这里主要是用来处理 data 块的

- 获取和解析内存地址指向的数据 dereference `*`
- 输出表达式 `[p]rint 表达式`
  - 在寄存器名加一个 `$` 前缀来获取其中的值
  - 可以使用 c 中的类型转换语法.
  - 也可以使用数组语法
  - 如果在调试 C 语言的话, 可以直接访问当前作用域下的变量
- 输出表达式, 但是 16 进制 `[p]rint/x 表达式`
  - 跟`print`一样, 只是输出的格式是16进制
- 解析内存中的数据 `[x]/(数字)(格式)(大小) 地址`
  - 数字, 要展示的元素的数量
  - 格式, 表示数据用那种方式输出
    - 用的字符和 printf 中的占位字符一样, 例外是 `i` 表示解析成指令而不是十进制整数. 详细可以看 10.5 节文档
  - 单元大小, 表示要解析的数据单元大小, 
    - `[b]ytes`
    - `[h]alfwords`
    - `[w]ords`
    - `[g]iant`
- 在 gdb 等待输入的时候解析内存并输出`display`
  - 这个指令的用法和 `x`完全一样, 区别是会在每次 gdb 停下等待用户输入的时候都会输出

下面举个例子

```shell
# 使用 print
(gdb) p $r1
$7 = 131224
(gdb) p (char *)$r1
$5 = 0x20098 "Helloworld\nA\021"
(gdb) p (char)*$r1
$6 = 72 'H'
(gdb) p ((char *)$r1)[2]
$8 = 108 'l'
(gdb) p (char)*($r1+2)
$10 = 108 'l'
# 使用 x
(gdb) x/1ub $r1
0x20098:        72 # 如果输出之后继续按下回车, 会自动执行上一条命令
0x20099:        101
0x2009a:        108
(gdb) x/1cc $r1	    # 这里的写法不对, 应该用 b 作为第三个参数
0x20098:        72 'H'
(gdb) x/1uc $r1
0x20098:        72 'H'
(gdb) x/1uc $r1
(gdb) x/1sb $r1
0x20098:        "Helloworld\nA\021"
(gdb) x/1sb ($r1)+1
0x20099:        "elloworld\nA\021"
(gdb) x/10sb ($r1)+1 # 输出十个字串会输出之后越界读到后面的 bss 段了
0x20099:        "elloworld\nA\021"
0x200a6:        ""
0x200a7:        ""
0x200a8:        "aeabi"
0x200ae:        "\001\a"
0x200b1:        ""
0x200b2:        ""
0x200b3:        "\b\001"
0x200b6:        ""
0x200b7:        ""
```

### 使用 TUI 

- 开启\关闭 TUI `组合键 ctrl + x + a`
- 切换布局 `[l]ayout 参数`
  - `[l]ayout asm`展示 汇编布局, 在 TUI  中显示反汇编代码
  - `[l]ayout src` 展示 源码布局, 在 TUI 中显示源码
  - `[l]ayout split` 展示 "分屏布局", 同时展示源码和反汇编代码
  - `[l]ayout regs` 同时展示 寄存器, 反汇编, 源码 三个窗口
- 在分屏的时候切换窗口 `focus 参数`, 这个指令的缩写是 `fs`
  - `focus prev` 上一个窗口
  - `focus next` 下一个窗口
  - `focus regs` 寄存器窗口
  - `focus src`源码窗口
  - `focus asm`反汇编窗口
  - `focus cmd` 命令窗口, 这个时候可以用上下左右来导航光标和历史命令
    - 另外, 组合键 `ctrl + x + o` 可以直接执行上一条指令

