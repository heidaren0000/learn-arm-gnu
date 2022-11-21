@ contains smith book list 4_6 and extended with more demo
.global _start
_start: 
@ and demo:
@ using and to mask a high byte
        movt r6, #0xffff @ immediate as op2
        and r6, #0xff000000
    @ mov it to low order position
        lsr r6, #24
@ eor demo: 
@ r6 exclusive or with 0
        eor r6, #0
@ orr demo:
        orr r6, #0xff
@ bic demo:
    @ clear the bottom byte
        bic r6, #0xff
.end