@ snippet for the smith book listing 4_4
@ while x < 5
@       executing....
@ end while
.global _start
_start:  
@ init r4
            mov r4, #0
loop:
            cmp r4, #5
            bge loopdone

            @ loop body
            add r4, #1

            b loop
loopdone:

            mov r0, #0
            mov r1, #1

            svc 0
.end
