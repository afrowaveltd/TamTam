; Include guard: prevent multiple inclusion of this file
%ifndef HEXDUMP_INC
%define HEXDUMP_INC

; This library requires the following functions to be available
; EXPECTS: putc, newline, print_hex_byte

; Display a memory region as a formatted hex dump (16 bytes per line)
; Inputs:
;   SI = pointer to data buffer
;   CX = number of bytes to display
hexdump:
    ; Save AX register on stack
    push ax
    ; Save BX register on stack (used as byte counter)
    push bx
    ; Save CX register on stack
    push cx
    ; Save SI register on stack
    push si

    ; Clear BX to use as bytes-per-line counter
    xor bx, bx

.next:
    ; Check if remaining byte count is zero
    cmp cx, 0
    ; Jump to done if no more bytes to process
    je .done

    ; Load byte from [SI] into AL, increment SI
    lodsb
    ; Print byte in hexadecimal format
    call print_hex_byte
    ; Load space character for separation
    mov al, ' '
    ; Print the space
    call putc

    ; Increment bytes-per-line counter
    inc bx
    ; Decrement remaining bytes counter
    dec cx

    ; Check if 16 bytes have been printed
    cmp bx, 16
    ; Continue on same line if less than 16
    jne .next

    ; Print newline after 16 bytes
    call newline
    ; Reset bytes-per-line counter to 0
    xor bx, bx
    ; Continue processing next line
    jmp .next

.done:
    ; Print final newline
    call newline
    ; Restore SI register from stack
    pop si
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