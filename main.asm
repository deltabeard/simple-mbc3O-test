DEF rSB = $FF01
DEF rSC = $FF02
DEF ROM_BANK_PORT = $2000

SECTION "Header", ROM0[$0100]
    nop
    jp Start
    ds $0150 - @, 0

SECTION "Code", ROM0
Start:
    di
    ld hl, StartText
    call PrintString

    ld b, 1 ; start from bank 1
TestLoop:
    ld a, b
    ld [ROM_BANK_PORT], a ; switch bank
    ld hl, $4000
    ld a, [hl]
    cp b
    jr nz, Failed
    inc b
    ld a, b
    cp 0
    jr nz, TestLoop
    ld hl, SuccessText
    call PrintString
    jr Hang
Failed:
    ld hl, FailText
    call PrintString
Hang:
    jr Hang

; Print the 0-terminated string pointed by HL
PrintString:
    ld a, [hl+]
    or a
    jr z, .done
    call SendSerial
    jr PrintString
.done:
    ret

; Send character in A over serial
SendSerial:
    ld [rSB], a
    ld a, $81
    ld [rSC], a
.wait:
    ld a, [rSC]
    and $80
    jr nz, .wait
    ret

StartText:
    db "Start Test",0
SuccessText:
    db "All banks OK",0
FailText:
    db "Bank check fail",0

; Create ROM banks 1..255 with their bank number at address $4000
FOR BN, 1, 256
SECTION "ROM Bank {d:BN}", ROMX[$4000], BANK[BN]
    db BN
    ds $4000 - 1
ENDR
