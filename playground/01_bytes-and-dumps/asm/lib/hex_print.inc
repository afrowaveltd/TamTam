; Include guard: prevent multiple inclusion of this file
%ifndef HEX_PRINT_INC
%define HEX_PRINT_INC

; This library requires the 'putc' function to be available
; EXPECTS: putc

; Print a single hexadecimal nibble (4 bits, 0-F)
; Input: AL = nibble value (only lower 4 bits used)
print_hex_nibble:
    ; Mask to keep only lower 4 bits (0x00-0x0F)
    and al, 0x0F
    ; Compare AL with 9
    cmp al, 9
    ; Jump if below or equal (0-9 are digits)
    jbe .digit
    ; Add 7 to convert 10-15 to 'A'-'F' (10+7+48='A')
    add al, 7
.digit:
    ; Add ASCII '0' to convert to character ('0'-'9' or 'A'-'F')
    add al, '0'
    ; Print the hex character
    call putc
    ; Return to caller
    ret

; Print a byte in hexadecimal (two hex digits)
; Input: AL = byte value to print
print_hex_byte:
    ; Save AX register on stack
    push ax
    ; Copy AL to AH for later use
    mov ah, al
    ; Move AH back to AL (contains original value)
    mov al, ah
    ; Shift right 4 bits to get high nibble
    shr al, 4
    ; Print high nibble
    call print_hex_nibble
    ; Restore original value from AH to AL
    mov al, ah
    ; Mask to get low nibble only
    and al, 0x0F
    ; Print low nibble
    call print_hex_nibble
    ; Restore AX register from stack
    pop ax
    ; Return to caller
    ret

; End of include guard
%endif