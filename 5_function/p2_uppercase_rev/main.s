@
@ Assembler program to convert a string to
@ all uppercase by calling a function. @
@ R0-R2 - parameters to linux function services
@ R1 - address of output string
@ R0 - address of input string
@ R5 - current character being processed
@ R7 - linux function number @
.global _start @ provide prgram starting address
_start: ldr r0, =instr  @ start of input string
        ldr r1, =outstr @ address of output string

        bl toupper              @ call routin
@ set up the parameters to print out hex number
@ and then call Linux to do it
        mov     r2,     r0      @ return code is the length of the string
        mov     r0,     #1      @ 1 = stdout
        ldr     r1,     =outstr @ string to print
        mov     r7,     #4      @ linux write system call
        svc     0               @ call linux to output the string

@ set up the parameters to exit the program
@ and then call Linux to do it
        mov     r0,     #0      @ use 0 return code
        mov     r7,     #1      @ command code 1 terminates
        svc     0               @ call linux to terminate the program

.data
instr:  .asciz  "This is out Test String that we will convert.\n"
outstr: .fill   255, 1, 0
