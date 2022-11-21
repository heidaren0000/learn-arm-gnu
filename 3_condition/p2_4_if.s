@ from smith book listing 4_5
@ if else with arm asm
@ if r5 < 10 theh
@   ..... if statements
@ else
@   ..... else statements
@ end if
.global _start
_start: mov r5, #1
        cmp r5, #10
        bge elseclause
        @ if statements
        mov r2, #10
        b endif
elseclause: @ else clause
        mov r2, #32
endif:  @ end the if. now lets end the prog
        mov r0, #0
        mov r7, #1
        svc 0;
.end