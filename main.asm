DEF rSB = $FF01
DEF rSC = $FF02
DEF rLCDC = $FF40
DEF rBGP = $FF47
DEF ROM_BANK_PORT = $2000
DEF VRAM_ADDR = $8000
DEF BG_MAP = $9800

SECTION "Header", ROM0[$0100]
    nop
    jp Start
    ds $0150 - @, 0

SECTION "Code", ROM0
Start:
    di
    xor a
    ld [rLCDC], a ; disable LCD
    ld hl, FontData
    ld de, VRAM_ADDR
    ld bc, FontDataEnd - FontData
    call Memcpy
    ld a, %11100100
    ld [rBGP], a
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
    xor a
    ld [rLCDC], a
    ld hl, SuccessTiles
    ld b, SuccessTilesEnd - SuccessTiles
    ld de, BG_MAP
    call PrintTiles
    ld a, $91
    ld [rLCDC], a
    jr Hang
Failed:
    ld hl, FailText
    call PrintString
    xor a
    ld [rLCDC], a
    ld hl, FailedTiles
    ld b, FailedTilesEnd - FailedTiles
    ld de, BG_MAP
    call PrintTiles
    ld a, $91
    ld [rLCDC], a
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

; Copy BC bytes from HL to DE
Memcpy:
    ld a, b
    or c
    jr z, .done
.loop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec bc
    ld a, b
    or c
    jr nz, .loop
.done:
    ret

; Write B tiles from HL to BG map at DE
PrintTiles:
.loop:
    ld a, [hl+]
    ld [de], a
    inc de
    dec b
    jr nz, .loop
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

; Tile data for screen messages
FontData:
    ; tile for A
    db $0c,$00,$1e,$00,$33,$00,$33,$00,$3f,$00,$33,$00,$33,$00,$00,$00
    ; tile for C
    db $3c,$00,$66,$00,$03,$00,$03,$00,$03,$00,$66,$00,$3c,$00,$00,$00
    ; tile for D
    db $1f,$00,$36,$00,$66,$00,$66,$00,$66,$00,$36,$00,$1f,$00,$00,$00
    ; tile for E
    db $7f,$00,$46,$00,$16,$00,$1e,$00,$16,$00,$46,$00,$7f,$00,$00,$00
    ; tile for F
    db $7f,$00,$46,$00,$16,$00,$1e,$00,$16,$00,$06,$00,$0f,$00,$00,$00
    ; tile for I
    db $1e,$00,$0c,$00,$0c,$00,$0c,$00,$0c,$00,$0c,$00,$1e,$00,$00,$00
    ; tile for L
    db $0f,$00,$06,$00,$06,$00,$06,$00,$46,$00,$66,$00,$7f,$00,$00,$00
    ; tile for S
    db $1e,$00,$33,$00,$07,$00,$0e,$00,$38,$00,$33,$00,$1e,$00,$00,$00
    ; tile for U
    db $33,$00,$33,$00,$33,$00,$33,$00,$33,$00,$33,$00,$3f,$00,$00,$00
FontDataEnd:

DEF TILE_A = 0
DEF TILE_C = 1
DEF TILE_D = 2
DEF TILE_E = 3
DEF TILE_F = 4
DEF TILE_I = 5
DEF TILE_L = 6
DEF TILE_S = 7
DEF TILE_U = 8

SuccessTiles:
    db TILE_S, TILE_U, TILE_C, TILE_C, TILE_E, TILE_S, TILE_S
SuccessTilesEnd:
FailedTiles:
    db TILE_F, TILE_A, TILE_I, TILE_L, TILE_E, TILE_D
FailedTilesEnd:

; Create ROM banks 1..255 with their bank number at address $4000
FOR BN, 1, 256
SECTION "ROM Bank {d:BN}", ROMX[$4000], BANK[BN]
    db BN
    ds $4000 - 1
ENDR
