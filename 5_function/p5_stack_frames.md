# p5_stack_frames

## stack frame

当使用的变量超过了寄存器的数量怎么办?

这时候我们可以在栈上开辟一段空间. 用来保存变量. 

1. 在 subroutine 开始时`sp` = `sp` - 寄存器数量*4, 向下开辟一段空间用来存放数据
2. 读写这段空白空间来保存变量, 可以使用偏移寻址访问
3. 在 subroutine 结束之前, `sp` = `sp` + 寄存器数量*4, 让栈恢复回去

注意在初始化 stack frame 后, 释放 steaks frame 之前, 不要进行栈操作. 所以要在 push 和 pop 之间使用 stack frame.

```asm
@ subroutine that add two numbers and return result
adder: 
@ save states
    push    {r4-r12, lr}
@ define some variables
    .equ    var1, 0
    .equ    var2, 4
    .equ    var3, 8
@ initialize stack frame
    sub     sp, #12     @ to store three variables
    @ keep in mind that we cant operate stack after using stack frame
@ store register into stack
    str     r0, [sp, #var1]
    str     r1, [sp, #var2]
    str     r2, [sp, #var3]
@ load register into stack
    ldr     r0, [sp, #var1]
    ldr     r1, [sp, #var2]
    ldr     r2, [sp, #var3]
@ do some operation
    add     r0, r1, r2
@ restore state and return result
    add     sp, #12      @ restore stack frame before return 
    pop     {r4-r12, pc} @ !!! we directly pop to pc!

@ note that we can directly pop lr into pc,
@ by that way we dont need to call bx

end:    
        mov     r0, #0
        mov     r7, #1
        svc     0
```

