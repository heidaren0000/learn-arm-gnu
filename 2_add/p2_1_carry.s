@ listing 2.4 from the smith book
@
@ Example of 64 bit addition with 
@           the add/adc/ instructions
@
.global _start @ Provide program starting address

@ Load the registers with some data
@ First 64-bit number is 0x0x00000003
_start: 
        mov r2, #0x00000003
        mov r3, #0xFFFFFFFF  @ as will change to mvn
@ Second 64-bit number is 0x0000000500000001
        mov r4, #0x00000005
        mov r5, #0x00000001

        adds r1, r3, r5     @ lower order word
        adc  r0, r2, r4     @ highter order word

@ Set up the parameters to exit the program
@ and then call liux to do it
@ r0 is the recode and will be what we 
@ calculated above
        mov r7, #1  @ service command code 1
        svc 0       @ call linux to terminate