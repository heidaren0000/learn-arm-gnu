@ snippet from the smith book 4_3

.global _start

_start: mov     r2, #10 @ r2 hold i
loop:   @ body of the loop start
        @ using subs instead of cmp
        subs    r2, #1  @ i = i - 1
        bne     loop    @ branch until i = 0

@ end the program
        mov r0, #0
        mov r7, #1
        svc 0
@ emit data section

.end