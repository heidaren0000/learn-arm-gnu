@ expecting the p1_moving
@
.global _start      @ Provide program starting address
@ Load R2 with 0x4f5d6e3a first using mov and movt
_start:
@ 1.1 using 16 bit immediate operand2
    mov r2, #0x6e3a
    movt r2, #0x4f5d
@ 1.2 using register as operand2
    mov r1, r2

@ 2.1 using register and shifting as operand2
    mov r1, r2, lsl #1  @ logical shift left
    mov r1, r2, lsr #1  @ logical shift right
    mov r1, r2, asr #1  @ arithmetic shift right
    mov r1, r2, ror #1  @ rotate shift right
    mov r1, r2, rrx     @ rotate extended right

    lsl r1, r2, #1  @ logical shift left
    lsr r1, r2, #1  @ logical shift right
    asr r1, r2, #1  @ arithmetic shift right
    ror r1, r2, #1  @ rotate shift right
    rrx r1, r2      @ rotate extended right

@ 2.2 using 8 bit immediate as operand2
@       4 bit for rotations
    mov r1, #0xfffffffe @ aka -2
    mov r2, #0x400 @ aka 1024
    mov r3, #0x1000 @ aka 4096
@ set up the parameters to exit the program
@ and then call linux to do it
    mov r0, #0          @ use 9 return code
    mov r7, #1          @ service command code 1
    svc 0               @ call linux to terminate