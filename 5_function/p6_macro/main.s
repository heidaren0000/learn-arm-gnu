@
@ Assembler program to convert a string to
@ all uppercase by calling a macro. @
@ R0-R2 - parameters to linux function services
@ R1 - address of output string
@ R0 - address of input string
@ R7 - linux function number @
.include "uppermacro.s"
.global _start @ Provide program starting address 
_start: toupper tststr, buffer
@ Set up the parameters to print our hex number @ and then call Linux to do it.
    MOV R2,R0 @ R0 is the length of the string 
    MOV R0, #1 @ 1 = StdOut
    LDR R1, =buffer @ string to print
    MOV R7, #4 @ linux write system call
    SVC 0 @ Call linux to output the string
@ Call it a second time with our second string.
    toupper tststr2, buffer

@ Set up the parameters to print our hex number 
@ and then call Linux to do it.
    MOV R2,R0 @ R0 is the length of the string MOV R0, #1 @ 1 = StdOut
    LDR R1, =buffer @ string to print
    MOV R7, #4 @ linux write system call 
    SVC 0 @ Call linux to output the string
@ Set up the parameters to exit the program 
@ and then call Linux to do it.
    MOV     R0, #0     @ Use 0 return code
    MOV     R7, #1     @ Service command code 1 terminates this program
    SVC     0  @ Call linux to terminate
.data
tststr: .asciz "This is our Test String that we will convert.\n"
tststr2: .asciz "A second string to uppercase!!\n" 
buffer: .fill 255, 1, 0