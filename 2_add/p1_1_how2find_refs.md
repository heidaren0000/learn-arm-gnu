# 如何快速的在文档中查指令?

这个文档没有对应的代码文件. 只是记录下查文档的一点小经验.

总结下查阅文档的方法. 我能够接触到的 ARM 芯片, 目前都是 v4 到 v7 的, 后面有机会在补充 v8 和 v9 的.

## ARM v4 - ARM v6

需要准备的文档: DDI0406B

待补充.

## ARM v7

也许是因为 32 位的空间不够用了. 到了 v7 的时候, 用的不再是像之前那种使用连续的 opcode. v7 的 opcode 可能有很多个部分组成, 而且不只是 4 位, 有可能有十几位. 在文档中甚至专门多了一章: ARM Instruction Set Encoding, 专门讲他这些新指令的编码. 我现在还看不到他这种编码的条理在哪里, 但是会查他的指令了. 

这些编码就很神奇, 提供向后兼容, 也就是之前的那些旧指令用这种编码也可以解释的通. 

需要准备的文档: 

1. DDI0406B: arm v7a 的文档
2. DDI0403C: arm v7m 的文档
3. DDI0403D: v7m文档, 包含一些拓展内容

下面举一个例子, 其他的指令查文档的过程可能不太一样, 但是具体的思路是不变的:

```asm
mov r2, #0x400		; 反汇编 e3a02b01 mov  r2, #1024
```

### 1. 判断指令类型

众所周知, ARM 指令有几种基本的类型:

- 分支指令 Branch Instructions
- 数据处理指令 Data Processing Instructions
- 状态寄存器指令 Status Register Instructions
- 加载和存储指令 Load And Store Instructions
- 协处理器指令 Coprocessor Instrucitons
- 异常生成指令 Exception-generating Instructions

首先咱们来判断下这是个啥指令. 

在文档的 A5.1 节(208页) 有关于指令分类的编码

![ZdQHuf](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/ZdQHuf.png)

先把这个指令弄成二进制, 再按照文档里的方法分一下:

```asm
mov r2, #0x400		; 反汇编 e3a02b01 mov  r2, #1024
; cond op1						op
; 1110 001 11010000000101011000 0 0001
```

cond 不是 1111, 所以要判断 op1 

op1 = 001, 说明这是个`数据处理和杂项指令(Data-processing and miscellaneous instructions)`

文档中提到了在 A5.4 节(其实文档这个地方标错了, 其实应该是 5.2)中会专门介绍这种指令. 点击会直接跳转过去

### 2. 数据处理和杂项指令

![6QRwUX](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/6QRwUX.png)

```asm
mov r2, #0x400		; 反汇编 e3a02b01 mov  r2, #1024
; cond 	 op  op1				op2
; 1110 00 1 11010 000000101011 0000 0001
```

再用刚才的方法给指令进行分类:

op = 1, 而且 op1 = 11010, 说明这是在 A5.8(这个地方文档标的码又是错的, 但是跳转还是对的) 中的`数据处理(立即数)指令(Data-processing (immediate))` 点击之后又跳转过去.

### 3. 数据处理(立即数)指令

![PunX2y](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/PunX2y.png)

![eSIf4S](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/eSIf4S.png)

```asm
mov r2, #0x400		; 反汇编 e3a02b01 mov  r2, #1024
; cond 	 	op	  rn
; 1110 001 11010 0000 0010101100000001
```

再分类一把

op = 11010, Rn 不生效. 说明这是个 MOVE 指令, 对应在 A8-194(依然是标注错误但跳转后正确) 的`MOV(immediate)` 指令.

### 4. MOV 指令

![ATGBkU](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/ATGBkU.png)

![ORnqAN](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/ORnqAN.png)

可以看到这里有各种各样的 MOV (immeidate) 指令, 他们的 opcode 不一定是一样的. 咱们在这里面找到自己的指令, 也就是 `Encoding A1`

```asm
mov r2, #0x400		; 反汇编 e3a02b01 mov  r2, #1024
; cond 	 	op	 s 		 rd		imm12
; 1110 00 1 1101 0 0000 0010 101100000001
```

最后得到分析出

op = 1101 , 这个指令用法在老的文档里就有, 所以也就是老文档中分给 MOV 的 1101 这个 opcode

s = 0, 意味着不会操作 flag 寄存器

rd = 0010, 目标寄存器是 R2

imm12 = 101100000001, 这个 imm12 是 flexiable second operand (Operand2 as a constant , 详见 DUI0473M 的 11.3 节或者DDI0406B 的 A5.2.4). 高4位代表位移次数, 低8位代表被移动的数据.

1011 = 8 + 2 + 1 = 11, 也就是右移 22 位.

把 00000001 这 8 位放进 32 位的数据中, 也就是 

```asm
0000 0000 0000 0000 0000 0000 0000 0001
```

让他左移 22 位, 等同于右移 10 位

```asm
0000 0000 0000 0000 0000 0010 0000 0000
```

换算成 10 进制, 就是 1024, 就是正确的值

由于咱们这里设置的 S = 0, 所以最后的结果不会把 bit[31] 移动到 flag 寄存器的 C 位.

### 5. 总结

总之这个新的指令编码方式真的是非常神奇, 跟着文档一步一步走总是能找到相应的指令

## ARM v8 - ARM v9

待补充.
