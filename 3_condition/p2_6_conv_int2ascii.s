@ listing 4_8 from the smith book
@
@ Assembler program to print register in hex
@ to stdout
@
@ R0-R2 - parameters to linux function services
@ R1 - is also address of byte we are writing
@ R4 - register to print
@ R5 - loop index
@ R6 - current character
@ R7 - linux fucntion number
@
.global _start @ provide program starting address to linker
_start: mov     r4, #0x12ab @ number to print
        movt    r4, #0xde65 @ high bis of number to print
        ldr     r1, =hexstr
        add     r1, #9      @ start at last character
        mov     r5, #8      @ got 8 digits to process
loop:   and     r6, r4, #0xf @ mask off bits but last byte
        cmp     r6, #10
        bge     letter
        add     r6, #'0'
        b       cont
letter: add     r6, #('A'-10)   @ handle char a-f     
cont:   strb    r6, [r1]    @ store the character
        sub     r1, #1      @ next character
        lsr     r4, #4      

        subs    r5, #1
        bne     loop

@ set up printing
        mov     r0, #1      @ 1 = stdout
        ldr     r1, =hexstr @ string to print
        mov     r2, #11     @ length of out srting
        mov     r7, #4     @ linux write system call number
        svc     0           @ call linux to output the string
@ exit the program
        mov     r0, #0      @ use 0 to return code
        mov     r7, #1      @ service command code 1 
        svc     0           @ call linux to terminate program
.data
hexstr: .ascii  "0x12345678\n"
.end