@ branch with lr
@ call a sub routine to print helloworld then return

.global _start
_start: 
        bl  print
        mov r4, #1  @ to test the link register
        b   ends

print:  mov r2, #11 @ return code 
        mov r0, #1  @ 1 = stdout
        ldr r1, =helloworld
        mov r7, #4
        svc 0
        bx  lr

@ let linux to terminate the program
ends:   mov r0, #0  @ return code
        mov r7, #1  @ service number
        svc 0

.data
helloworld: .asciz "hellowold\n"
.end