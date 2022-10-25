@ this is the snippit of listing 1-1 from  the smith book

@ Assembler program to print "Helloworld"
@ to stdout
@
@ R0 - R2 - parameters to linux function services
@ R7 - linux function number
@
.global _start      @ Provice program starting
@ address to linker

@ Set up the parameters to print hello world
@ and then call linux to do it
_start: mov R0, #1          @ 1 = stdout
        ldr R1, =helloworld @ string to print
        mov R2, #11        @ length of our string
        mov R7, #4          @ linux write system call
        svc 0               @ call linux to print

@ Set up the parameters to exit the program
        mov R0, #0          @ Use 0 to return code
        mov R7, #1          @ Servicde command code 1
                            @ terminates this program
        svc 0

.data
helloworld:     .ascii  "Helloworld\n"

.end