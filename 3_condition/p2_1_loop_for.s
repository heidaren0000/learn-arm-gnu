@ listing 4_2 from the smith book
@ for iteration structure:
@   for I = 1 to 10
@       some statements
@   next I
@
.global _start
_start: mov r2, #1  @ r2 holds I 
loop:   add r2, #1  @ i = i + 1 @ body of the loop start
        cmp r2, #10
        ble loop    @ if i <= 10 goto loop

        @ terminate the program
        mov r0, #0  @ return code 0
        mov r7, #1  @ service code 1
        svc 0

.data
.end