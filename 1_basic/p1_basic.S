@ this snippet is from the robert book listing 1.1

.global _start  @ Indicate _start is global for linker
_start: mov     R0, #78 @ Move a decimal 78 value into register R0
        mov     R7, #1  @ Move a decimal 1 integer value into register R7
        svc     0       @ Perform Service Call to Linux
        .end