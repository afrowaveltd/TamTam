; Include guard: prevent multiple inclusion of this file
%ifndef BIOS_PRINT_INC
%define BIOS_PRINT_INC

; Define default text attribute if not already defined
%ifndef ATTR
%define ATTR 0x07  ; Light gray on black background
%endif

; Print single character in AL using BIOS teletype output
putc:
    ; Save AX register on stack
    push ax
    ; Save BX register on stack
    push bx
    ; Set BIOS function 0x0E (teletype output)
    mov ah, 0x0E
    ; Set display page number to 0
    mov bh, 0x00
    ; Set text attribute (color)
    mov bl, ATTR
    ; Call BIOS video services interrupt
    int 0x10
    ; Restore BX register from stack
    pop bx
    ; Restore AX register from stack
    pop ax
    ; Return to caller
    ret

; Print a newline (CR+LF) sequence
newline:
    ; Save AX register on stack
    push ax
    ; Load carriage return character (13)
    mov al, 13
    ; Print carriage return
    call putc
    ; Load line feed character (10)
    mov al, 10
    ; Print line feed
    call putc
    ; Restore AX register from stack
    pop ax
    ; Return to caller
    ret

; Print null-terminated string pointed to by SI
print_string:
    ; Save AX register on stack
    push ax
.next:
    ; Load byte from [SI] into AL, increment SI
    lodsb
    ; Test if AL is zero (end of string)
    test al, al
    ; Jump to done if zero flag is set
    jz .done
    ; Print character in AL
    call putc
    ; Loop to process next character
    jmp .next
.done:
    ; Restore AX register from stack
    pop ax
    ; Return to caller
    ret

; End of include guard
%endif