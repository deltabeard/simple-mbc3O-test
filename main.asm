DEF rSB = $FF01
DEF rSC = $FF02

SECTION "Header", ROM0[$0100]
    nop
    jp Start
    ds $0150 - @, 0

SECTION "Code", ROM0
Start:
    di
    ld hl, Text
PrintLoop:
    ld a, [hl+]
    or a
    jr z, Done
    call SendSerial
    jr PrintLoop
Done:
Hang:
    jr Hang

; Send character in A over serial
SendSerial:
    ld [rSB], a
    ld a, $81
    ld [rSC], a
Wait:
    ld a, [rSC]
    and $80
    jr nz, Wait
    ret

Text:
    db "Start Test",0
