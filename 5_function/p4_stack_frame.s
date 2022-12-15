@
@ demo of stack frame
@
@ by daren

.global _start
_start:

    bl  adder
    b   end



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

