# p2_adding_p2_1_carry

来看看如何进行加法, 和如何处理进位

注意: 这里出现的指令都可以追溯到 ARMv7 之前. 所以用旧的指令编码方式即可.

## 1. 指令

1. `ADD{S} Rd, Rs, Operand2`
3. `ADD{S} Rd, Rs1, Rs2`
4. `ADC{S} Rd, Rs, Operand2`
5. `ADC{S} Rd, Rs1, Rs2`

smith 的书里面单独列出了 `imm12`  查了下文档, 发现这个就是 `operand2` 的 12 位立即数(高4位是位移量, 剩下8位是值). 所以这个地方就归类到 op2 里面了

## 2. 处理进位

在使用单纯的 ADD 指令的时候, 不会涉及到进位的问题, 多余出来的溢出的 carry 会被直接丢掉. 

但是如果使用 ADDS 指令, 加了 `S` 后缀, 意思就是在运算中有 CPSR 的参与. 暂时只会用到其中的 C 位. 也就是 carry 位. 每当加法发出溢出(也就是进位), carry 就会自动变成1. 对于某些运算来说, 非常有用. 

比如这里的 64 位加法. 寄存器只有 32 位, 要处理 64 位加法就要多个寄存器拼起来用. 这时候就需要单独处理进位:

```asm
@ First 64-bit number is 0x0x00000003
mov r2, #0x00000003
mov r3, #0xFFFFFFFF  @ as will change to mvn
@ Second 64-bit number is 0x0000000500000001
mov r4, #0x00000005
mov r5, #0x00000001

adds r1, r3, r5     @ lower order word
adc  r0, r2, r4     @ highter order word
```

首先用 `adds` 这个指令来让底部的 32 位相加. 这时发生了进位 carry 位就变成了 1.

计算高位的时候, 使用 `adc` 指令就可以在高32位相加的时候, 额外加上 carry 位.

运算完成后, r0 和 r1 拼接就得到了正确答案.



