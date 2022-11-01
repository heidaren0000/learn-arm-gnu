 

# p1_moving

## 指令

### MOV/MVN

用于各种寄存器之间移动数据. 有如下几种格式

1. `mov rd, #imm16`	把16位立即数放进寄存器的低6位中.
2. `movt rd, #imm16` 把 16 位立即数放进寄存器的高 16 位中, 配合上面实现完整 32 位操作
3. `mov rd, rs` 在寄存器之间移动
4. `mov rd, operand2` 使用
5. `mov rd, operand2`

#### 问题1: 16位立即数

在代码中出现了直接使用 16 位立即数的例子. 如果你拿去问老师, 我估计他会当场暴走. 这个按照他的标准, 绝对是不合法的: 没有使用位移, 直接写了 16 位立即数.

```asm
mov r2, #0x6e3a
```

16位立即数是在 ARMv6T2 之后引入的. 算是比较新的语法. 老师讲课的材料是讲 s3c2410 的(虽然换了新书, 但是 PPT 还是原来的), 这是个 ARMv4T 的 CPU. 其实我在这个问题上也卡了好久, 因为最开始我找的文档只覆盖到 ARMv6. 真是服了.

参考资料: ARM 文档DUI0473M 的 404 页.

#### 问题2: 反汇编后'指令'变了

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



![ScreenShot2022-10-31at9.37.43PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen Shot 2022-10-31 at 9.37.43 PM.png)

截图来自 DDI0406B 210页

![ScreenShot2022-10-31at7.57.19PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen Shot 2022-10-31 at 7.57.19 PM.png)

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



![ScreenShot2022-10-31at8.31.55PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen Shot 2022-10-31 at 8.31.55 PM.png)

![ScreenShot2022-10-31at10.20.49PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen Shot 2022-10-31 at 10.20.49 PM.png)

截图来自 DDI0406B 211 页

![ScreenShot2022-10-31at8.26.18PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen Shot 2022-10-31 at 8.26.18 PM.png)

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

![ScreenShot2022-10-31at11.43.00PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen Shot 2022-10-31 at 11.43.00 PM.png)

![qq9y5r](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/qq9y5r.png)

截图来自 DDI0406B 的 211 页 

![ScreenShot2022-10-31at11.47.19PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen Shot 2022-10-31 at 11.47.19 PM.png)

截图来自 DDI0406B 的 490 页 

第四条指令:



```asm
; cond 	  op  op1				op2
; 1110 00 1 11010 000000101011 0000 0001
; cond 	  op  op1				op2
; 1110 001 11010 0000 0010101100000001
mov r2, #0x400		; 反汇编 e3a02b01 mov  r2, #1024
```



![ScreenShot2022-10-31at8.24.24PM](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screen Shot 2022-10-31 at 8.24.24 PM.png)

#### 问题3:  `operand2` 是什么

在 smith 的书里面这个 operand2 就很有意思. 我在这个上面卡了好久, 这就整的非常奇怪, 因为, 立即数和寄存器, 也是 operand 啊..... 



- 寄存器作为 operand2 + 位移
- 12位 operand2 , 其中 8 bit 数据, 4 bit 用来保存位移数据

下面咱们仔细分析一下, 结合字节码和ARM官方的字节码文档:

> 我们重新写一下这个程序, 把使用 "oprend2" 方法寻址的指令放在一起, 使用寄存器寻址的放在一起, 使用立即数寻址的放在一起, 进行一下标记. 
>
> ```bash
> daren@localhost:~/WorkspaceDior/learn-arm-gnu/2_add$ objdump -s -d ./p1_1_moving_inspect
> 
> ./p1_1_moving_inspect:     file format elf32-littlearm
> 
> Contents of section .text:
> 10054 3a2e06e3 5d2f44e3 0210a0e1 8210a0e1  :...]/D.........
> 10064 a210a0e1 c210a0e1 e210a0e1 6210a0e1  ............b...
> 10074 8210a0e1 a210a0e1 c210a0e1 e210a0e1  ................
> 10084 6210a0e1 0110e0e3 0000a0e3 0170a0e3  b............p..
> 10094 000000ef                             ....            
> Contents of section .ARM.attributes:
> 0000 41130000 00616561 62690001 09000000  A....aeabi......
> 0010 06080801                             ....            
> 
> Disassembly of section .text:
> 
> 00010054 <_start>:
> 10054:       e3062e3a        movw    r2, #28218      ; 0x6e3a ; 这个是 16 位立即数
> 10058:       e3442f5d        movt    r2, #20317      ; 0x4f5d
> 1005c:       e1a01002        mov     r1, r2  ; 这个是 寄存器 复制
> ; 从这里开始就是 寄存器 + 位移
> 10060:       e1a01082        lsl     r1, r2, #1
> 10064:       e1a010a2        lsr     r1, r2, #1
> 10068:       e1a010c2        asr     r1, r2, #1
> 1006c:       e1a010e2        ror     r1, r2, #1
> 10070:       e1a01062        rrx     r1, r2
> 10074:       e1a01082        lsl     r1, r2, #1
> 10078:       e1a010a2        lsr     r1, r2, #1
> 1007c:       e1a010c2        asr     r1, r2, #1
> 10080:       e1a010e2        ror     r1, r2, #1
> 10084:       e1a01062        rrx     r1, r2
> ; 下面是 8 bit 作为 immeidate number, 4 bit 作为位移,
> 10088:       e3e01001        mvn     r1, #1 ; 被优化成了 mvn, 这个不是咱想要的
> 1008c:       e3a02b01        mov     r2, #1024       ; 0x400 
> 10090:       e3a03a01        mov     r3, #4096       ; 0x1000
> 10094:       e3a00000        mov     r0, #0
> 10098:       e3a07001        mov     r7, #1
> 1009c:       ef000000        svc     0x00000000
> ```
>
> 结合一下文档, 以及之前的笔记:
>
> ![指令格式](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/data%20instruction%20format.png)
>
> ![](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/20221025_174127_temp.jpg)
>
> 我们拆解一下这几个指令:

### MOVT

### ADD/ADC



## 伪指令

## CPSR

## 位移电路和支持的模式

Barrel Shifter

### 逻辑左移 LSL

### 逻辑右移 LSR

### 算数右移 ASR

### 循环右移 RR

### 拓展的循环右移 RRE



## 灵活的 Op2
