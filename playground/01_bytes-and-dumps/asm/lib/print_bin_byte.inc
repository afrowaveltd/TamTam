; Include guard: prevent multiple inclusion of this file
%ifndef PRINT_BIN_BYTE_INC
%define PRINT_BIN_BYTE_INC

; This library requires the 'putc' function to be available
; EXPECTS: putc

; Print a byte in binary format (8 bits as '0' or '1' characters)
; Input: AL = byte value to print
print_bin_byte:
    ; Save AX register on stack
    push ax
    ; Save BX register on stack (used for bit testing)
    push bx
    ; Save CX register on stack (used as loop counter)
    push cx

    ; Copy byte value from AL to BL for manipulation
    mov bl, al
    ; Set loop counter to 8 (8 bits in a byte)
    mov cx, 8

.loop:
    ; Test the most significant bit (bit 7) of BL
    test bl, 10000000b
    ; Jump if bit is zero
    jz .zero
    ; Load '1' character if bit is set
    mov al, '1'
    ; Jump to output
    jmp .out
.zero:
    ; Load '0' character if bit is clear
    mov al, '0'
.out:
    ; Print the '0' or '1' character
    call putc
    ; Shift BL left by 1 bit (next bit becomes MSB)
    shl bl, 1
    ; Decrement CX and loop if not zero
    loop .loop

    ; Restore CX register from stack
    pop cx
    ; Restore BX register from stack
    pop bx
    ; Restore AX register from stack
    pop ax
    ; Return to caller
    ret

; End of include guard
%endif