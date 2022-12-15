@
@ a demo about how to access stack on arm
@ by daren
.global _start
_start:
        mov r1, #0x11
        mov r2, #0xff
@ push and pop with ldm and sdm
        @ push 
        stmdb   r13!, {r1, r2} @ same as {r1-r2}
        @ pop
        ldmia   r13!, {r1, r2} 
@ push and pop with push & pop instuction
        @ push
        push    {r1, r2} 
        @ pop
        pop     {r1, r2}
@ call linux to end the program
        mov r0, #0
        mov r7, #1
        svc 0