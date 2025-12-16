; Include guard: prevent multiple inclusion of this file
%ifndef DISK_READ_INC
%define DISK_READ_INC

; Read sectors from disk using BIOS CHS (Cylinder-Head-Sector) addressing
; Inputs:
;   AL = number of sectors to read
;   CH = cylinder number (low 8 bits)
;   CL = sector number (bits 0-5), high 2 bits of cylinder (bits 6-7)
;   DH = head number
;   DL = drive number (0x00-0x7F floppy, 0x80-0xFF hard disk)
;   ES:BX = destination buffer address
; Outputs:
;   CF = 0 on success, 1 on error
;   AH = status (0 on success)
bios_read_sectors_chs:
    ; Save AX register on stack
    push ax
    ; Save BX register on stack
    push bx
    ; Save CX register on stack
    push cx
    ; Save DX register on stack
    push dx

    ; Set BIOS function 0x02 (read sectors from drive)
    mov ah, 0x02
    ; Call BIOS disk services interrupt
    int 0x13

    ; Restore DX register from stack
    pop dx
    ; Restore CX register from stack
    pop cx
    ; Restore BX register from stack
    pop bx
    ; Restore AX register from stack
    pop ax
    ; Return to caller (carry flag indicates success/failure)
    ret

; End of include guard
%endif