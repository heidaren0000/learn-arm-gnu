@ this snippet is listing 2-3 from the smith book
@
@   Example of the ADD/ADC instructions
@
.global _start  @ Provide program starting address

@ Multiply 2 by -1 by using MVN and then adding 1
_start: 
    mvn r0, #2
    add r0, #1

@ Set up the parameters to exit the program
@ and then call Linux to do it
@ R0 is the return code and will be what we
@ calulaed above
    mov r7, #1      @ Service command code 1
    svc 0           @ call linux to terminate