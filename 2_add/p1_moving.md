# p1_moving

## 1. 指令

### MOV/MVN

用于各种寄存器之间移动数据. 有如下几种格式

1. `mov rd, #imm16`	把16位立即数放进寄存器的低6位中.
2. `movt rd, #imm16` 把 16 位立即数放进寄存器的高 16 位中, 配合上面实现完整 32 位操作
3. `mov rd, rs` 在寄存器之间移动
4. `mov rd, operand2` 使用
5. `mov rd, operand2`

> 这个 operand2 是什么呢? 在本笔记的[第六节](##6.-operand2)会介绍.

### MOVT

把16位立即数存放到寄存器的高 16bit, 配合 `movw`(也就是16位立即数 mov 指令), 可以访问完整的 32 位寄存器空间. 

```asm
mov r2, #0x6e3a ; 16位立即数 mov 等同于 movw
movt r2, #0x4f5d
```

为了方便寄存器访问, 还有一个 mov32 伪指令, 汇编器会在汇编之后自动把 mov32 换成 movw 和 movt 组合

```asm
mov32 r3, #0xABCDEF12  ; loads 0xABCDEF12 into R3
```

## 2. 伪指令

这代码里面没有出现新的伪指令. 前面提到的`mov32` 应该算一个

## 3. 位移电路和支持的位移

### 逻辑左移 LSL

就是简单的左移, 从右边补上0

### 逻辑右移 LSR

简单的右移, 在左边补上0

### 算数右移 ASR

右移之后在左边补上之前的 MSB. 

> 为啥没有算数左移呢? 这是因为可能会影响算数结果[quora](https://www.quora.com/Why-doesnt-arithmetic-left-shift-SAL-preserve-the-sign-bit-while-arithmetic-right-shift-does)

### 循环右移 RR

右移, 但是把右边被移走的一位在左边补上.

### 拓展的循环右移 RRE

循环右移, 但是把 flag 寄存器中的 carry flag 作为被右移的寄存器的第33位. 

**这种右移在 arm 中一次只能移动 1 位, 所以在后面的拓展循环右移 rrx 中是不能指定位移次数的. 至于有关 flag 寄存器, 在 p2_adding 的笔记中会提到**

### ARM 处理器中的位移电路

在 arm 处理器中有位移电路(Barrel Shifter). 但是并没有任何原生的位移指令. 只能通过 MOV 这种数据操作指令来进行位移(如果你使用 LSL 这类指令的话, 反汇编之后你会发现他们的 opcode 和使用 LSL 位移的 mov 是一样的.) 这是因为位移电路在算数逻辑单元(ALU)之外, 位于加载第二个 operand 的位置上,  [第六节](##6.-operand2) 会详细介绍这个 operand2

![knDwER](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/knDwER.png) 

## 4. 16位立即数

在代码中出现了直接使用 16 位立即数的例子. 如果你拿去问老师, 我估计他会当场暴走. 这个按照他的标准, 绝对是不合法的: 没有使用位移, 直接写了 16 位立即数.

```asm
mov r2, #0x6e3a
```

16位立即数是在 ARMv6T2 之后引入的. 算是比较新的语法. 老师讲课的材料是讲 s3c2410 的(虽然换了新书, 但是 PPT 还是原来的), 这是个 ARMv4T 的 CPU. 其实我在这个问题上也卡了好久, 因为最开始我找的文档只覆盖到 ARMv6. 真是服了.

参考资料: ARM 文档DUI0473M 的 404 页.

## 5. 反汇编后'指令'变了

下面这两行指令, 在汇编之后会产生相同的指令:

```asm
mov r1, r2, lsl #1 ; 反汇编之后得到 e1a01082 lsl     r1, r2, #1
lsl r1, r2, #1 	   ; 反汇编之后得到 e1a01082 lsl     r1, r2, #1
```

借助这个例子可以更好的理解 助记词(mnemonics), 指令(instruction), 操作码(opcode), 机器码(machine code) 之间的关系: 不同的助记词用的可能是同一个 opcode, 同一个助记词用的也可能是不同的 opcode. 

```asm
mov r2, #0x6e3a		; 反汇编 e3062e3a movw r2, #28218
mov r1, r2			; 反汇编 e1a01002 mov  r1, r2
mov r1, r2, lsl #1	; 反汇编 e1a01082 lsl  r1, r2, #1
mov r2, #0x400		; 反汇编 e3a02b01 mov  r2, #1024
```

咱们尝试拆解下这几个指令

第一个指令

```asm
; cond 	 op	 op1			   op2			
; 1110 00 1 10000 011000101110 0011 1010
; 分析他的这个 opcode, 一共有6位.
; 首先看 op = 1, op1 = 10000, 意味着这是一个 16 位立即数的 MOV, 而且没有 op2

; cond 		  	 imm4  Rd	 imm12
; 1110 0011 0000 0110 0010 111000111010
mov r2, #0x6e3a		; 反汇编 e3062e3a movw r2, #28218
; 找到 16 位立即数的 MOV 文档重新分析一下:
; 12-15位存放 目标寄存器, 也就是 0010, 从 0000 开始编号的话, 刚好是 R2
; 16-19位存放 高4位立即数, 也就是 0110
;  0-11位存放 低12位立即数, 也就是 111000111010
```



![ScreenShot2022-10-31at9.37.43PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen%20Shot%202022-10-31%20at%209.37.43%20PM.png)

截图来自 DDI0406B 210页

![ScreenShot2022-10-31at7.57.19PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen%20Shot%202022-10-31%20at%207.57.19%20PM.png)

截图来自 DDI0406B 的 506 页

第二条指令:

```asm
; cond		op1	  		   op2 op3
; 1110 000 11010 00000001 00000 00 0 0010
; 分析 opcode 有12位
; op1 = 11010, op2 = 00000, op3 = 00 , 说明这是一个寄存器MOV
;
; 再看寄存器MOV的文档
; cond			 s 		 rd			   rm
; 1110 00 0 1101 0 0000 0001 00000000 0010
; s = 0 意味着 flag 寄存器不受影响
; 可以看出 rd 是 0001, 也就是 R1
; Rm 是 0010 也就是 R2
mov r1, r2			; 反汇编 e1a01002 mov  r1, r2
```



![ScreenShot2022-10-31at8.31.55PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen%20Shot%202022-10-31%20at%208.31.55%20PM.png)

![ScreenShot2022-10-31at10.20.49PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen%20Shot%202022-10-31%20at%2010.20.49%20PM.png)

截图来自 DDI0406B 211 页

![ScreenShot2022-10-31at8.26.18PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen%20Shot%202022-10-31%20at%208.26.18%20PM.png)

截图来自 DDI0406B 的 508 页 

第三条指令

```asm
; bit pattern
; cond 		op1			   op2 op3 
; 1110 000 11010 00000001 00001 00 0 0010
; 分析 opcode, 有 10 位
; op1 = 11010, op2 = 00001, op3 = 00 说明这是一个用立即数来逻辑左移寄存器的MOV
;
; 再看寄存器位移MOV的文档
; cond 			 s  	 rd   imm5 		rm
; 1110 00 0 1101 0 0000 0001 00001 000 0010
; s = 0 意味着 flag 寄存器不会被修改
; rd 是 r1, rm 是 r2
; 立即数是 1, 意味着逻辑左移一次
mov r1, r2, lsl #1	; 反汇编 e1a01082 lsl  r1, r2, #1
```

![ScreenShot2022-10-31at11.43.00PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen%20Shot%202022-10-31%20at%2011.43.00%20PM.png)

![qq9y5r](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/qq9y5r.png)

截图来自 DDI0406B 的 211 页 

![ScreenShot2022-10-31at11.47.19PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen%20Shot%202022-10-31%20at%2011.47.19%20PM.png)

截图来自 DDI0406B 的 490 页 

第四条指令:

```asm
; cond 	  op  op1				op2
; 1110 00 1 11010 000000101011 0000 0001
; cond 	 	op	  rn
; 1110 001 11010 0000 0010101100000001
; cond 	 	op	 s 		 rd		imm12
; 1110 00 1 1101 0 0000 0010 101100000001
mov r2, #0x400		; 反汇编 e3a02b01 mov  r2, #1024
```



![ScreenShot2022-10-31at8.24.24PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen%20Shot%202022-10-31%20at%208.24.24%20PM.png)

##### 总结

我简单总结一下:

对于 arm v7 而言, 需要新的思维模式. 

- 不同 mnemonic 的 opcode 可能是相同的
- 虽然 mnemonic 是相同的, 不见得 opcode 就是相同的

## 6. operand2

在 smith 的书里面这个 operand2 就很有意思. 我在这个上面卡了好久, 这非常奇怪, 因为, 立即数和寄存器, 也是 operand 啊..... 你整个 operand2 算什么意思.

后来看了 DUI0473M(11.3节) , 原来这个 operand2 是 flexiable second operand  的简称, 在 ARM 和 Thumb 中有很多数据处理指令都支持这种 operand2, 包括 MOV, ADD 等.

他有下面两种格式

- 寄存器作为 operand2 + 位移
- 12位 operand2 , 其中 8 bit 数据, 4 bit 用来保存位移数据

> 这种 operand2 使用的意义在于它可以在一条指令中访问完整的 32 位寄存器空间, 提升效率.

### 寄存器作为 operand2

DUI0473M(11.5节)

例子:

```asm
mov r1, r2, lsl #1	; 反汇编 e1a01082 lsl  r1, r2, #1
```

首先, 要确保指令确实支持这种 operand2, 一般使用寄存器作为 operand2 的数据处理指令都支持.

接下来就在后面添加位移操作. 这里的位移不会更改 operand2 中寄存器的值.

```asm
; 可以实用的指令:
	asr #n ; 1 <= n <= 32 算数右移
	lsl #n ; 1 <= n <= 31 逻辑左移
	lsr #n ; 1 <= n <= 32 算数左移
	ror #n ; 1 <= n <= 31 循环右移
	rrx	   ; 托展的循环右移	
```

除了把立即数常量作为位移量, 你还可以把寄存器中的值用来做位移量, 例如:

```asm
mov r1, r2, lsl r3 ; 把 R3 中的值作为位移量.
; 这种方法需要注意两点:
; 1. 只有存放位移量的寄存器的 LSB(least significt byte) 的8位会被用到,
; 2. rrx 不能用(肯定不能用啊)
```

### 立即数常量作为 operand2

DUI0473M(11.4节)

DDI0406B(A5.2.4节)

例子:

```asm
mov r2, #0x400		; 反汇编 e3a02b01 mov  r2, #1024
```

这种方法就是老师上课讲到的 "合法立即数" 问题.

立即数总共 12bit 高位的 4bit 用来存放位循环右移的次数(具体的位移次数是4bit的值乘以2). 低8bit 用来存放. 下面这张图概括的很好 (DDI0406B A5.2.4). 

![e4SBTp](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/e4SBTp.png)

​	**除此之外, 如果使用 operand2 的指令如果使用了 flag 寄存器, 那么在指令结束之后, flag 寄存器的 carry flag 将会变成 operand2 的 bit[31], 有关 flag 寄存器会在后面有关算数的笔记中提到.**

**还要注意的一点是, 在 ARM 模式下的 operand2 常量的表示范围和 32位 Thumb 模式下的范围不同(32 位 thumb 使用的是 3 bit 存放位移量), 详见DDI0406B A6.3.2 **

> 这个方式会不会和 16 位立即数冲突呢?
>
> 不会的. 汇编器有能力判断到底该采用什么 opcode
