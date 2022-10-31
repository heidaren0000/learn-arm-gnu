@ from smith's book list 2-1
@
@ Examples of the mov instruction
@
.global _start      @ Provide program starting address
@ Load R2 with 0x4f5d6e3a first using mov and movt
_start: mov r2, #0x6e3a
    movt r2, #0x4f5d

@ just move r2 to r1
    mov r1, r2
@ now let's see all the shift versions of mov
    mov r1, r2, lsl #1  @ logical shift left
    mov r1, r2, lsr #1  @ logical shift right
    mov r1, r2, asr #1  @ arithmetic shift right
    mov r1, r2, ror #1  @ rotate shift right
    mov r1, r2, rrx     @ rotate extended right

@ repeat the above shift using
@       the assembler mnemonics
    lsl r1, r2, #1  @ logical shift left
    lsr r1, r2, #1  @ logical shift right
    asr r1, r2, #1  @ arithmetic shift right
    ror r1, r2, #1  @ rotate shift right
    rrx r1, r2      @ rotate extended right

@ Example that works with 8 bit immediate and shift
    mov r1, #0xfffffffe @ aka -2
@ set up the parameters to exit the program
@ and then call linux to do it
    mov r0, #0          @ use 9 return code
    mov r7, #1          @ service command code 1
    svc 0               @ call linux to terminate