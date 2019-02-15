.ifndef PPU_INC
.define PPU_INC

.include "lib_macroses.inc"

.segment "ZEROPAGE"
    ; increases by one on every nmi
    .globalzp ppu_frameConter
    ; ID of the last sprite added to oam
    .globalzp ppu_spriteId
    .globalzp ppu_addr
    .globalzp ppu_hasBuffer
    ;.globalzp ppu_tmp1

.segment "BSS"
    .global ppu_scrollx
    .global ppu_scrolly
    .global ppu_needOam
    .global ppu_need_draw
    .global ppu_ctrl
    .global ppu_mask
    .global ppu_buffer
    .global ppu_bufferCount

.segment "OAM"
    .global ppu_oam

.segment "CODE"
    decl "stack", ppu_AddSprite
    decl "stack", ppu_FillNameTable
    decl "stack", ppu_LoadNameTable
    decl "stack", ppu_LoadAttributes
    decl "stack", ppu_LoadNameTableRle
    decl "reg", ppu_SetAddr
    decl "reg", ppu_LoadPallete
    .global ppu_BeginSprites
    .global ppu_FinishSprites
    .global ppu_ClearSprites
    .global ppu_ResetScroll
    .global ppu_Off
    .global ppu_On
    .global ppu_WaitForNmiDone

    decl "reg", ppu_BeginBufferWrite
    decl "reg", ppu_WriteBuffer
    .global ppu_OutputBuffer
    .global ppu_FinishBufferWrite

; -----------------------------------------------------------------------------
; Macroses

OAM_YPOS = 0
OAM_TILE = 1
OAM_ATTR = 2
OAM_XPOS = 3

.macro m_ppu_BeginWrite
    lda PPU_STATUS
.endmacro

.macro m_ppu_ResumeWrite
    pha
    m_ppu_BeginWrite
    lda ppu_addr+0
    sta PPU_ADDR
    lda ppu_addr+1
    sta PPU_ADDR
    pla
.endmacro

.macro m_ppu_Write
    sta PPU_DATA
    pha
    lda #1
    add ppu_addr+1
    sta ppu_addr+1
    lda #0
    adc ppu_addr+0
    sta ppu_addr+0
    pla
.endmacro

.macro m_ppu_Read
    lda PPU_DATA
    pha
    lda #1
    add ppu_addr+1
    sta ppu_addr+1
    lda #0
    adc ppu_addr+0
    sta ppu_addr+0
    pla
.endmacro

.macro m_ppu_SetAddr addr
    .if     .paramcount <> 1
    .error  "Too few parameters for macro m_ppu_SetAddr"
    .endif
    lda #>addr
    sta PPU_ADDR
    sta ppu_addr+0
    lda #<addr
    sta PPU_ADDR
    sta ppu_addr+1
.endmacro

.macro m_ppu_SetXy nameTable, xCoord, yCoord
    ;POSITION =
    m_ppu_SetAddr {(nameTable | ((yCoord << 5) | xCoord))}
.endmacro

.endif