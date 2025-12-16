; Set origin to 0x7C00, where BIOS loads boot sector into memory
[org 0x7C00]
; Start in 16-bit real mode
[bits 16]

; Jump over BPB-compatible data area to start label
jmp start
; NOP for alignment (some BIOSes expect this)
nop

; Define number of sectors to load for stage2 if not already defined
%ifndef STAGE2_SECTORS
%define STAGE2_SECTORS 8
%endif

; Include library files (libs resolved via NASM -I .\lib)
%include "bios_print.inc"  ; Include BIOS text output routines
%include "disk_read.inc"    ; Include disk reading routines

start:
    ; Disable interrupts during stack setup
    cli
    ; Clear AX register (set to 0)
    xor ax, ax
    ; Set stack segment to 0x0000
    mov ss, ax
    ; Set stack pointer to 0x7000 (just below bootloader)
    mov sp, 0x7000
    ; Re-enable interrupts
    sti

    ; Save boot drive number (passed by BIOS in DL)
    mov [boot_drive], dl

    ; Clear AX register again
    xor ax, ax
    ; Set data segment to 0x0000
    mov ds, ax
    ; Set extra segment to 0x0000
    mov es, ax

    ; Load address of stage1 message into SI
    mov si, msg_stage1
    ; Print the stage1 loading message
    call print_string

    ; Restore boot drive number into DL
    mov dl, [boot_drive]
    ; Set destination address for stage2 to 0x8000
    mov bx, 0x8000

    ; Set number of sectors to read (stage2 size)
    mov al, STAGE2_SECTORS
    ; Set cylinder number to 0
    mov ch, 0x00
    ; Set head number to 0
    mov dh, 0x00
    ; Set sector number to 2 (sector 1 is bootloader)
    mov cl, 0x02

    ; Call BIOS disk read function
    call bios_read_sectors_chs
    ; Jump to error handler if carry flag is set (read failed)
    jc disk_error

    ; Load address of jump message into SI
    mov si, msg_jump
    ; Print the jumping message
    call print_string

    ; Far jump to stage2 entry point at 0x0000:0x8000
    jmp 0x0000:0x8000

disk_error:
    ; Load address of disk error message into SI
    mov si, msg_disk_err
    ; Print the error message
    call print_string
.hang:
    ; Halt the CPU
    hlt
    ; Loop forever (in case of spurious interrupt)
    jmp .hang

; Variable to store boot drive number (1 byte)
boot_drive db 0

; Message strings (null-terminated)
msg_stage1      db 13,10," [Stage1] Loading Stage2...", 13, 10, 0
msg_jump        db " [Stage1] Jumping to Stage2.", 13, 10, 0
msg_disk_err    db " [Stage1] Disk read error!", 13, 10, 0

; Pad with zeros to byte 510 (fill remaining boot sector)
times 510-($-$$) db 0
; Boot sector signature (0xAA55 - required by BIOS)
dw 0xAA55