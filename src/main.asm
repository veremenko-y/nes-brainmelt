.include "nes.inc"
.include "ppu.inc"
.include "lib.inc"
.include "bf.inc"

.global main

.import BF_src1
.import BF_src2
.import BF_src3

.proc main
    jsr lib_Init
    lda #(PPU_CTRL_NMI_ON | PPU_CTRL_BG_ADDR_1 | PPU_CTRL_SPR_ADDR_1)
    sta ppu_ctrl
    lda #(PPU_MASK_SPR_ON | PPU_MASK_SPR_LEFT_ON | PPU_MASK_BG_ON | PPU_MASK_BG_LEFT_ON)
    sta ppu_mask
state_Title:
    jsr ppu_Off
    lda ppu_ctrl
    ora #PPU_CTRL_BG_ADDR_1
    sta ppu_ctrl

    m_ppu_BeginWrite
    call ppu_LoadPallete, #<Palette, #>Palette
    m_ppu_SetAddr PPU_ADDR_NAMETABLE1
    call ppu_LoadNameTableRle, #<TitleScreen, #>TitleScreen

    ; Print menu
    call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, {#((32 - Src1Text_Length) / 2)}, #16
    movwa p, #Src1Text
    jsr writeString
    call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, {#((32 - Src2Text_Length) / 2)}, #18
    movwa p, #Src2Text
    jsr writeString
    call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, {#((32 - Src3Text_Length) / 2)}, #20
    movwa p, #Src3Text
    jsr writeString
    ; Print footer
    call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, {#((32 - FooterText_Length) / 2)}, #28
    movwa p, #FooterText
    jsr writeString

    mova menuItem, #0       ; reset menu counter

    jsr ppu_ClearSprites
    jsr ppu_On
    @loop_Title:
        jsr controls_ReadPad1
        lda #PAD_UP
        bit controls_pad1_pressed
        beq :+
            lda menuItem
            sub #1
            bcc :+
                sta menuItem
        :
        lda #PAD_DOWN
        bit controls_pad1_pressed
        beq :+
            lda menuItem
            add #1
            cmp #3
            beq :+
                sta menuItem
        :
        lda #PAD_START
        bit controls_pad1_pressed
        beq :+
            jmp @state_Bf
        :
        jsr ppu_WaitForNmiDone
        jsr ppu_BeginSprites

        lda menuItem    ; Y = menuItem * 16 + 16 * 8
        asl
        asl
        asl
        asl
        add #16 * 8
        sub #2
        sta r1
        call ppu_AddSprite, #8*8, r1, #$3E, #0

        jsr ppu_FinishSprites
    jmp @loop_Title
@state_Bf:
    jsr ppu_Off
    lda ppu_ctrl
    and #~PPU_CTRL_BG_ADDR_1
    sta ppu_ctrl
    jsr ppu_ClearSprites
    lda menuItem
    asl
    tax
    movwa BF_codePtr, {Bf_Jumptable,x}
    jsr BF_run
    @loop_Bf:
        jsr controls_ReadPad1
        lda controls_pad1_pressed
        beq @loop_Bf
        jmp state_Title
.endproc

.proc writeString
    ldy #0
    @while:
        lda (p),y
        beq @end
        m_ppu_Write
        iny
        jmp @while
    @end:
    rts
.endproc

.segment "BSS"
    menuItem: .res 1


.segment "RODATA"
    ; Build info
    ; started this project on Mon 2019-02-12
    BUILDDAY = (.TIME / 86400) - 17939
    .out .sprintf("Build(0): Info: %d days since beginning of the project", BUILDDAY)
Src1Text:
    .byte "Hello World",0
    Src1Text_Length = * - Src1Text
Src2Text:
    .byte "Factorial",0
    Src2Text_Length = * - Src2Text
Src3Text:
    .byte "99 Bottles",0
    Src3Text_Length = * - Src3Text
FooterText:
    .byte "Yaroslav Veremenko (c) 2019",0
    FooterText_Length = * - FooterText
Palette:
    .incbin "assets/palette.pal"
    .incbin "assets/palette.pal"
Bf_Jumptable:
    .word BF_src1
    .word BF_src2
    .word BF_src3
TitleScreen:
    .incbin "assets/titlescreen.rle"
.segment "CHR"
    .incbin "assets/tiles.chr"