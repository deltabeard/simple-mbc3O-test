DEF rSB = $FF01
DEF rSC = $FF02
DEF rLCDC = $FF40
DEF rBGP = $FF47
DEF ROM_BANK_PORT = $2000
DEF RAM_ENABLE_PORT = $0000
DEF RAM_BANK_PORT = $4000
DEF RAM_ADDR = $A000
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
    call TestRAMBanks
    jr c, Failed
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

; Check the 8 RAM banks available on MBC3O
; Returns with carry set if any bank check fails
TestRAMBanks:
    ld a, $0A
    ld [RAM_ENABLE_PORT], a ; enable RAM
    ld b, 0
.write_loop:
    ld a, b
    ld [RAM_BANK_PORT], a ; select bank
    ld hl, RAM_ADDR
    ld a, b
    ld [hl], a
    inc b
    ld a, b
    cp 8
    jr nz, .write_loop

    ld b, 0
.read_loop:
    ld a, b
    ld [RAM_BANK_PORT], a ; select bank
    ld hl, RAM_ADDR
    ld a, [hl]
    cp b
    jr nz, .fail
    inc b
    ld a, b
    cp 8
    jr nz, .read_loop
    xor a ; clear carry
    ret
.fail:
    scf
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
    db $30,$00,$78,$00,$cc,$00,$cc,$00,$fc,$00,$cc,$00,$cc,$00,$00,$00
    ; tile for C
    db $3c,$00,$66,$00,$c0,$00,$c0,$00,$c0,$00,$66,$00,$3c,$00,$00,$00
    ; tile for D
    db $f8,$00,$6c,$00,$66,$00,$66,$00,$66,$00,$6c,$00,$f8,$00,$00,$00
    ; tile for E
    db $fe,$00,$62,$00,$68,$00,$78,$00,$68,$00,$62,$00,$fe,$00,$00,$00
    ; tile for F
    db $fe,$00,$62,$00,$68,$00,$78,$00,$68,$00,$60,$00,$f0,$00,$00,$00
    ; tile for I
    db $78,$00,$30,$00,$30,$00,$30,$00,$30,$00,$30,$00,$78,$00,$00,$00
    ; tile for L
    db $f0,$00,$60,$00,$60,$00,$60,$00,$62,$00,$66,$00,$fe,$00,$00,$00
    ; tile for S
    db $78,$00,$cc,$00,$e0,$00,$70,$00,$1c,$00,$cc,$00,$78,$00,$00,$00
    ; tile for U
    db $cc,$00,$cc,$00,$cc,$00,$cc,$00,$cc,$00,$cc,$00,$fc,$00,$00,$00
FontDataEnd:

DEF TILE_BLANK = 0
DEF TILE_A = 1
DEF TILE_C = 2
DEF TILE_D = 3
DEF TILE_E = 4
DEF TILE_F = 5
DEF TILE_I = 6
DEF TILE_L = 7
DEF TILE_S = 8
DEF TILE_U = 9

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
