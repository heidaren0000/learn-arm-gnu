 

# p1_moving

## 1. 指令

### MOV/MVN

用于各种寄存器之间移动数据. 有如下几种格式

1. `mov rd, #imm16`	把16位立即数放进寄存器的低6位中.
2. `movt rd, #imm16` 把 16 位立即数放进寄存器的高 16 位中, 配合上面实现完整 32 位操作
3. `mov rd, rs` 在寄存器之间移动
4. `mov rd, operand2` 使用
5. `mov rd, operand2`

> 这个 operand2 是什么呢? 在本笔记的[第七节](##7.-operand2)专门介绍了.

### MOVT

### ADD/ADC



## 2. 伪指令

## 3. CPSR

## 4. 位移电路和支持的模式

Barrel Shifter

### 逻辑左移 LSL

### 逻辑右移 LSR

### 算数右移 ASR

### 循环右移 RR

### 拓展的循环右移 RRE





## 5. 16位立即数

在代码中出现了直接使用 16 位立即数的例子. 如果你拿去问老师, 我估计他会当场暴走. 这个按照他的标准, 绝对是不合法的: 没有使用位移, 直接写了 16 位立即数.

```asm
mov r2, #0x6e3a
```

16位立即数是在 ARMv6T2 之后引入的. 算是比较新的语法. 老师讲课的材料是讲 s3c2410 的(虽然换了新书, 但是 PPT 还是原来的), 这是个 ARMv4T 的 CPU. 其实我在这个问题上也卡了好久, 因为最开始我找的文档只覆盖到 ARMv6. 真是服了.

参考资料: ARM 文档DUI0473M 的 404 页.

## 6. 反汇编后'指令'变了

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

## 7. operand2

在 smith 的书里面这个 operand2 就很有意思. 我在这个上面卡了好久, 这非常奇怪, 因为, 立即数和寄存器, 也是 operand 啊..... 你整个 operand2 算什么意思.

后来看了 DUI0473M(11.3节) , 原来这个 operand2 是 flexiable second operand  的简称, 在 ARM 和 Thumb 中有很多数据处理指令都支持这种 operand2, 包括 MOV, ADD 等.

他有下面两种格式

- 寄存器作为 operand2 + 位移
- 12位 operand2 , 其中 8 bit 数据, 4 bit 用来保存位移数据

​	**除此之外, 如果使用 operand2 的指令如果使用了 flag 寄存器, 那么在指令结束之后, flag 寄存器的 carry flag 将会变成 operand2 的 bit[32], 有关 flag 寄存器会在后面有关算数的笔记中提到.**

> 这种 operand2 使用的意义在于它可以在一条指令中访问完整的 32 位寄存器空间, 提升效率.

### 寄存器作为 operand2

DUI0473M(11.5节)

### 立即数常量作为 operand2

