
@
@ Assembler program to convert a string to
@ all uppercase. @
@ R1 - address of output string
@ R0 - address of input string
@ R4 - original output string for length calc.
@ R5 - current character being processed 
@
.global toupper @ allow other files to call this routine

toupper:
@ save the registers we used
            push    {r4-r5}         @ save registers we used
            mov     r4, r1          @ r4 for backup address
            @ the loop is until byte pointed to by r1 is non-zero
loop:       ldrb    r5, [r0], #1    @ post index addressing
@ if r5 > 'z' then goto cont
            cmp     r5, #'z'        @ is letter > 'z'?
            bgt     cont
@ else if r5 < 'a' then goto cont
            cmp     r5, #'a'
            blt     cont
@ now char left for us is lowercase
            sub     r5, #('a'-'A')
cont:       @ endif
            strb    r5, [r1], #1    @ store character to output str
            cmp     r5, #0          @ stop on hitting a null character
            bne     loop            @ continue if not 0
            sub     r0, r1, r4      @ get the length bu subrating the pointers

            pop     {r4-r5}
            bx      lr              @ return to caller

