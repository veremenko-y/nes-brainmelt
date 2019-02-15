.include "nes.inc"
.include "ppu.inc"

.import main

.segment "CODE"
reset:
    sei        ; ignore IRQs
    cld        ; disable decimal mode
    ldx #APU_FRAMECT_IRQ_DISABLE
    stx APU_FRAMECT  ; disable APU frame IRQ
    ldx #$ff
    txs        ; Set up stack
    inx        ; now X = 0
    stx PPU_CTRL  ; disable NMI
    stx PPU_MASK  ; disable rendering
    stx APU_MODCTRL  ; disable DMC IRQs

    ; Optional (omitted):
    ; Set up mapper and jmp to further init code here.

    ; If the user presses Reset during vblank, the PPU may reset
    ; with the vblank flag still true.  This has about a 1 in 13
    ; chance of happening on NTSC or 2 in 9 on PAL.  Clear the
    ; flag now so the @vblankwait1 loop sees an actual vblank.
    bit PPU_STATUS

    ; First of two waits for vertical blank to make sure that the
    ; PPU has stabilized
    :
        bit PPU_STATUS
        bpl :-

    ; Clear ram
    txa
    :
        sta $000,x
        sta $100,x
        sta $300,x
        sta $400,x
        sta $500,x
        sta $600,x
        sta $700,x
        inx
        bne :-
    ; Clear OAM region
    lda #$ff
    :
        sta $200,x
        inx
        bne :-

    :
        bit PPU_STATUS
        bpl :-

    ; Enable NMI in order for ppu_On and ppu_Off to work
    lda PPU_STATUS ; Prevent immediate NMIs
    lda #PPU_CTRL_NMI_ON
    sta PPU_CTRL

    lda #0
    jmp main

; -----------------------------------------------------------------------------
; V-Blank interupt handler
nmi:
    pushseg
    ; Write to OAM DMA
    lda ppu_needOam
    beq @oamEnd
        mova ppu_needOam, #0 ; reset OAM flag
        lda #<ppu_oam
        sta PPU_SPR_ADDR
        lda #>ppu_oam
        sta APU_SPR_DMA
    @oamEnd:

    lda ppu_hasBuffer
    beq @bufferEnd
        jsr ppu_OutputBuffer
    @bufferEnd:
    ; Fix scroll
    jsr ppu_ResetScroll

    @end:
    m_ppu_SetNmiDone
    popseg
    rti

irq:
    rti

.proc lib_SwitchBank
    and #$0F
    sta $8000
    rts
.endproc

.segment "VECTORS"
    .word nmi
    .word reset
    .word irq
