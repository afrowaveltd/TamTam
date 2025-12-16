; Set origin to 0x8000, where stage2 is loaded
[org 0x8000]
; Start in 16-bit real mode
[bits 16]

; Jump over data area to stage2 entry point
jmp stage2_start
; NOP for alignment
nop

; Include library files (libs resolved via NASM -I .\lib)
%include "bios_print.inc"      ; Include BIOS text output routines
%include "hex_print.inc"       ; Include hexadecimal printing routines
%include "print_bin_byte.inc"  ; Include binary printing routines
%include "hexdump.inc"         ; Include hex dump display routines

stage2_start:
    ; Disable interrupts during setup
    cli
    ; Clear AX register (set to 0)
    xor ax, ax
    ; Set data segment to 0x0000
    mov ds, ax
    ; Set extra segment to 0x0000
    mov es, ax
    ; Set stack segment to 0x0000
    mov ss, ax
    ; Set stack pointer to 0x9C00 (higher in memory)
    mov sp, 0x9C00
    ; Re-enable interrupts
    sti

    ; Load address of banner message into SI
    mov si, msg_banner
    ; Print the banner message
    call print_string

    ; Load address of header message into SI
    mov si, msg_hdr
    ; Print the header label
    call print_string

    ; Load address of TamTam header data into SI
    mov si, tamtam_header
    ; Set byte count to 32 (header size)
    mov cx, 32
    ; Display the header as a hex dump
    call hexdump

    ; Load address of magic field label into SI
    mov si, msg_magic
    ; Print the magic label
    call print_string
    ; Point SI to start of TamTam header
    mov si, tamtam_header
    ; Load first byte (low byte of magic) and increment SI
    lodsb
    ; Save first byte in DL
    mov dl, al
    ; Load second byte (high byte of magic) and increment SI
    lodsb
    ; Save second byte in DH
    mov dh, al
    ; Move high byte to AL for printing
    mov al, dh
    ; Print high byte of magic in hex
    call print_hex_byte
    ; Move low byte to AL for printing
    mov al, dl
    ; Print low byte of magic in hex
    call print_hex_byte
    ; Print a newline
    call newline

    ; Load address of version label into SI
    mov si, msg_version
    ; Print the version label
    call print_string
    ; Load version byte (3rd byte of header) into AL
    mov al, [tamtam_header+2]
    ; Print version in hexadecimal
    call print_hex_byte
    ; Print two spaces for separation
    call space2
    ; Load version byte again
    mov al, [tamtam_header+2]
    ; Print version in binary format
    call print_bin_byte
    ; Print a newline
    call newline

.hang:
    ; Halt the CPU
    hlt
    ; Loop forever (in case of spurious interrupt)
    jmp .hang

; Helper function to print two spaces
space2:
    ; Save AX register
    push ax
    ; Load space character
    mov al, ' '
    ; Print first space
    call putc
    ; Load space character again
    mov al, ' '
    ; Print second space
    call putc
    ; Restore AX register
    pop ax
    ; Return to caller
    ret

; Message strings (null-terminated)
msg_banner db " [Stage2] TamTam Playground is ready.", 13, 10, 0
msg_hdr db 13,10," TamTam header v1 (32B):", 13, 10, 0
msg_magic db " Magic: 0x", 0
msg_version db " Version: 0x", 0

; Sample TamTam header structure (32 bytes)
tamtam_header:
    dw 5454h                ; Magic number (0x5454 = 'TT')
    db 01h                  ; Version number
    db 20h                  ; Flags/attributes
    db 01h                  ; Field 1
    db 01h                  ; Field 2
    dw 0001h                ; 16-bit value
    dq 1122334455667788h    ; 64-bit identifier
    db 03h                  ; Type/category
    db 00h                  ; Reserved/padding
    dw 00A1h                ; Status/control word
    dq 0000000000000000h    ; 64-bit reserved field
    dw 0034h                ; Length/size indicator
    dw 0001h                ; Sequence/counter