@
@ demo for nested routine, and parameter
@ theres three subroutines
@   1. adder to add two unit number and converter them to string then return the address
@   2. printer to print a string end with zero
@   3. converter to convert a number to zero ended string and store it in memory
@ do steps below
@ 2. call subroutine to calculate 1 + 1 and store result
@ 3. call subroutine to print helloworld
@ 4. call subroutine to print result.
@ created by daren

.global _start
_start: 
        @ prepare to call add
        push    {r0-r4}
        @ set parameter
        mov     r0, #1
        mov     r1, #2
        bl      adder
        mov     r5, r0         @ save result
        pop     {r0-r4}

        @ prepare to call printer
        push    {r0-r4}
        @ set parameter
        mov     r0, #4
        mov     r1, r5
        bl      printer
        pop     {r0-r4}

        @ call end to end the program
        b       end


@ adder: 
@ r0, r1 as two add number, r5 store result temp, r6 for temp store return value, 
@ return address store the string
adder:  
        push    {r4-r12, lr}    @ save state if nested call
        
        @ performing add
        add     r5, r0, r1

        @ preparing to call subroutine to convert
        push    {r0-r4}         @ save value for using regs as parameter
        mov     r0, r5
        ldr     r1, =calculated
        bl      converter           @ call the subroutine
            @ mov     r6, r0          @ no return value, so dont save
        pop     {r0-r4}         @ restore regs after called
        
        ldr     r0, =calculated @ return value
        pop     {r4-r12, lr}    @ restore state for caller
        bx      lr              @ return

@ printer: 
@ r1 store address to print, 
@ r0 is length of string 
@ no return value
printer:  
        push    {r4-r12, lr}    @ save state for caller

        mov     r2, r0          @ set the length 
        @ mov     r1,           r1 already have address       
        mov     r0, #1          @ set stdout
        mov     r7, #4          @ choose linux system call
        @ ldr     r1, =helloworld
        svc     0
        
        pop     {r4-r12, lr}
        bx      lr

@ converter: r0 store value to convert, r1 store address to store, no return value
converter:
        push    {r4-r12, lr}    @ save state for caller
        add     r0, #'0'        @ get ascii code
        lsl     r0, #8
        add     r0, #'\0'       @ add '\0'
        lsl     r0, #8
        add     r0, #'\n'

        str     r0, [r1]
        

        pop     {r4-r12, lr}
        bx      lr

end:    
        mov     r0, #0
        mov     r7, #1
        svc     0

.data
helloworld: .asciz  "helloworld\n"
calculated: .fill   1, 4, 1