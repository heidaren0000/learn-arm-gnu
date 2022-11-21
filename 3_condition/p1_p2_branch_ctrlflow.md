# p1_p2_branch_ctrlflow

## 指令

### `CMP` 比较

使用这个指令需要先了解 CPSR 寄存器相关的内容, 查看[相关笔记](#CPSR 寄存器)

这个指令用来比较两个操作数, 并且结果会影响到 CPSR 寄存器

```gas
; 来自 p2_1_loop
; 此时 r2 = 1
cmp r2, #10	; 对比 r2 中的 1 和  10, 明显是 1 < 10
			; 运行之后 CPSR 中 N = 1
```

`cmp` 语句执行起来就像是一个特殊的 `subs` 语句, 对 flag 寄存器的影响完全相同, 但是不会修改操作数寄存器的值.

```gas
subs r1, r1, #10; 这个指令和下面是等效的, 下面的指令是这个的简单形式
subs r1, #10 ; 这个指令会用 r1 - 10, 然后把结果存放到 r1 中
cmp  r1, #10 ; 相当于上面的 subs 指令, 但是不会擦偶走 r1, 只改动 cpsr
```

`cmp` 语句两个参数的大小对比会对 cpsr 的 flags 产生影响, 足以表示两个参数是大于还是小于还是大于等于还是小于等于还是相等.

### `b` 跳转

跳转到某 label

```gas
; p1_branch.s
.global _start
_start: mov r1, #1
        b   _start ; 跳转到 _start
```

### 条件跳转指令

这些指令用到了 CPSR 寄存器相关的内容, [相关笔记](#CPSR 寄存器)

可以根据 cmp 指令执行之后对 cspr 的影响来执行跳转, 下面的条件跳转刚还可以配合 cmp

指令格式:

```
B{condition} label
```

![](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screenshot_20221121_220856.png)

## CPSR 寄存器

![](https://cdn.jsdelivr.net/gh/heidaren0000/blogGallery@master/img/Screenshot_20221121_213612.png)

current program status register

## 例子: 实现常见控制流

### for 循环

```gas
.global _start
_start: mov r2, #1  @ r2 holds I 
loop:   add r2, #1  @ i = i + 1 @ body of the loop start
        cmp r2, #10
        ble loop    @ if i <= 10 goto loop

        @ terminate the program
        mov r0, #0  @ return code 0
        mov r7, #1  @ service code 1
        svc 0

.data
.end
```

还可以反过来

```gas
.global _start

_start: mov     r2, #10 @ r2 hold i
loop:   @ body of the loop start
        @ using subs instead of cmp
        subs    r2, #1  @ i = i - 1
        bne     loop    @ branch until i = 0

@ end the program
        mov r0, #0
        mov r7, #1
        svc 0
@ emit data section

.end
```

### while 循环

```asm
.global _start
_start:  
@ init r4
            mov r4, #0
loop:
            cmp r4, #5
            bge loopdone

            @ loop body
            add r4, #1

            b loop
loopdone:

            mov r0, #0
            mov r1, #1

            svc 0
.end

```

### if 语句

```gas
.global _start
_start: mov r5, #1
        cmp r5, #10
        bge elseclause
        @ if statements
        mov r2, #10
        b endif
elseclause: @ else clause
        mov r2, #32
endif:  @ end the if. now lets end the prog
        mov r0, #0
        mov r7, #1
        svc 0;
.end
```

## 例子: 把十六进制数字转换成字符文本

详见 p2_6
