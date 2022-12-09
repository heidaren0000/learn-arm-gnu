@ this snippet for demoing addressing in arm
@ by daren
.global _start
_start: 
@   1. without memory
    @   1.1 immeidate addressing
    mov r0, #1  @ decimal
    mov r0, #0x1    @ hexdeimal value
    @   1.2 register addressing
    mov r1, r0
    @   1.3 scaling addressing
    mov r2, r1, lsl #1
    mov r2, r1, asr #1
    mov r2, r1, lsr #1
    mov r2, r1, ror r1
    mov r2, r1, rrx

@ 2. memory related addressing
    @ 2.1 offset addressing
    ldr r1, =0x12345678
    ldr r1, =helloworld
    ldr r1, =myname
    ldr r2, [r1]
    ldr r2, [r1, #11]
    @ 2.2 pre-index addressing
    ldr r3, [r1, #1]!
    @ 2.3 post-index addressing
    ldr r4, [r2], #1

.data
helloworld: .ascii "helloworld\n"
myname:     .ascii "daren\n"