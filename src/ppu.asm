.include "lib.inc"
.include "nes.inc"
.include "ppu.inc"

.segment "ZEROPAGE"
    ; Public
    ppu_frameConter: .res 1 ; increases by one on every nmi
    ppu_spriteId: .res 1
    ppu_addr: .res 2
    ppu_hasBuffer: .res 1 ; set to 1 whenever buffered data for nametable is present

    ; Private
    _ppu_tmp1: .res 1
    _ppu_tmp2: .res 1
    _ppu_tmp3: .res 1
.segment "BSS"
    ; Public
    ppu_scrollx: .res 1
    ppu_scrolly: .res 1
    ppu_needOam: .res 1
    ppu_need_draw: .res 1
    ppu_ctrl: .res 1
    ppu_mask: .res 1
    ppu_attributes: .res 64 ; internal buffer for the attributes

    ppu_bufferCount     := $101
    ppu_buffer          := $104
    ; Private
    _ppu_bufferDirection := $100
    _ppu_bufferAddrLo    := $102
    _ppu_bufferAddrHi    := $103

.segment "OAM"
    ppu_oam:

.segment "CODE"

.proc ppu_WaitForNmiDone
    lda ppu_frameConter
@forever:
    cmp ppu_frameConter
    beq @forever
    rts
.endproc

; -----------------------------------------------------------------------------
; Fills nametable with specified value. Does not change the attributes
;   IN: [stackcall]
;        nameTable - high byte of nametable
;        fillValue - value to be put into the nametable
;   OUT: none
;   USE: a,x,y,ppu_tmp1
.proc ppu_FillNameTable
    stackparam nameTable
    stackparam fillValue
    stackparam fillAttribute
    tsx

    lda nameTable,x ; set address in PPU
    sta PPU_ADDR
    lda #0
    sta PPU_ADDR

    lda fillValue,x ; transfer fill value to A

    ldy #0
    ldx #4          ; repeat 4 times
    @loop:
        sta PPU_DATA
        iny

        cpx #1      ; if X is 0 and Y is C0-1 (pallete start)
        bne :+      ; then exit
            cpy #PPU_ADDR_ATTRIBUTE
            bne :+
                stx _ppu_tmp1
                tsx
                lda fillAttribute,x
                ldx _ppu_tmp1
        :
        cpy #0
        bne @loop
        dex         ; decrease X
        bne @loop
    @end:
    rts
.endproc

; -----------------------------------------------------------------------------
; Fills nametable with specified value. Does not change the attributes
;   IN: [regcall]
;        addr1 - low byte of palette
;        addr2 - high byte of palette
;   OUT: none
;   USE: a,y,p
.proc ppu_LoadPallete
    sta pl
    stx ph
    m_ppu_SetAddr PPU_ADDR_PALETTE

    ldy #$00
    @loop:
        lda (p),y
        sta PPU_DATA
        iny
        cpy #$20 ; Pallete length
        bne @loop
    rts
.endproc

; -----------------------------------------------------------------------------
; Enable NMI, enable Sprites
;   IN: none
;   OUT: none
;   USE: A
.proc ppu_On
    jsr ppu_WaitForNmiDone
    mova PPU_CTRL, ppu_ctrl
    mova PPU_MASK, ppu_mask
    jsr ppu_ResetScroll
    rts
.endproc

; -----------------------------------------------------------------------------
; Disable NMI, disable Sprites
;   IN: none
;   OUT: none
;   USE: A
.proc ppu_Off
    jsr ppu_WaitForNmiDone
    lda #0
    sta ppu_needOam
    sta ppu_need_draw
    lda #0
    sta PPU_MASK
    rts
.endproc

; USE: A, X
.proc ppu_ClearSprites
    mova ppu_needOam, #1
    mova ppu_spriteId, #0
    jmp ppu_FinishSprites
.endproc

ppu_BeginSprites:
    mova ppu_needOam, #1
    mova ppu_spriteId, #0
    rts
; USE: A, X
ppu_FinishSprites:
    lda ppu_spriteId
    asl a
    asl a
    tax
__ppu_sprites_loop:
    lda #$FF
    sta ppu_oam+OAM_YPOS,x
    inx
    inx
    inx
    inx
    bne __ppu_sprites_loop
    rts

; -----------------------------------------------------------------------------
; Add new entry to OAM
; IN: [stachcall]
;   xParam - x coordinate
;   yParam - y coordin
;   attribute - attribute
;   title - tile
; OUT:
;   A - next available sprite ID
; USE: A, X, Y
.proc ppu_AddSprite
    stackparam xParam
    stackparam yParam
    stackparam tile
    stackparam attribute
    tsx ; SP => X

    lda ppu_spriteId
    asl ; a * 4 to get address of the Sprite
    asl
    tay
    lda yParam,x
    sta ppu_oam+OAM_YPOS,y
    lda xParam,x
    sta ppu_oam+OAM_XPOS,y
    lda attribute,x
    sta ppu_oam+OAM_ATTR,y
    lda tile,x
    sta ppu_oam+OAM_TILE,y

    lda ppu_spriteId ; save sprite ID to X
    add #1
    sta ppu_spriteId
    rts
.endproc

; -----------------------------------------------------------------------------
; Resets scroll to 0
; PARAMS:
;   None
; RETURN:
;   None
.export ppu_ResetScroll
.proc ppu_ResetScroll
    mova PPU_CTRL, ppu_ctrl
    mova PPU_SCROLL, ppu_scrollx
    mova PPU_SCROLL, ppu_scrolly
    rts
.endproc

; -----------------------------------------------------------------------------
; Loads nametable from the address
; PARAMS:
;   Stack+0 - Data hi address
;   Stack+1 - Data lo address
.proc ppu_LoadNameTable
    ; Declaring subroutines parameters
    stackparam addrLo
    stackparam addrHi
    tsx
    lda addrLo,x
    sta _ppu_tmp1
    lda addrHi,x
    sta _ppu_tmp2
    ldx #0 ; high loop counter
    ldy #0 ; low loop counter
    @while: ; X < 4
        lda (_ppu_tmp1),y
        sta PPU_DATA
        iny
        cpy #0
        bne @while
        lda _ppu_tmp2
        add #1
        sta _ppu_tmp2
        inx
        cpx #4
        bne @while
    rts
.endproc

; -----------------------------------------------------------------------------
; Loads attribtues
; PARAMS:
;   Stack+0 - Data hi address
;   Stack+1 - Data lo address
.proc ppu_LoadAttributes
    ; Declaring subroutines parameters
    stackparam addrLo
    stackparam addrHi
    tsx
    lda addrLo,x
    sta _ppu_tmp1
    lda addrHi,x
    sta _ppu_tmp2
    ldy #0 ; low loop counter
    @while: ; X < 4
        lda (_ppu_tmp1),y
        sta PPU_DATA
        sta ppu_attributes,y
        iny
        cpy #$20
        bne @while
    rts
.endproc

; -----------------------------------------------------------------------------
; Sets address in nametable
; IN:
;   A - nametable high address (eg $20, $24 etc)
;   X - X coordinate
;   Y - Y coordinate
; OUT:
;   none
; USE:
;   ppu_tmp1, ppu_tmp2
.proc ppu_SetAddr
    ; high then low
    sta _ppu_tmp1+0 ; move nametable high address to high byte
    stx _ppu_tmp1+1 ; store low x address in low byte
    ; local variables on stack
    stackalloc yShiftHi
    stackalloc yShiftLo
    tsx ; transfer stack pointer on x
    lda #0 ; initialize yShiftHi with 0
    sta yShiftHi,x
    tya ; now we shift y << 5 and add it to both bytes

    ; do y << 3 as maximum value of Y is 30 and it will not overflow
    asl
    asl
    asl
    clc
    asl
    bcc :+
        pha
        lda #(1 << 1) ; put bit 1 if carry
        sta yShiftHi,x
        pla
    :
    asl
    bcc :+
        pha
        lda #(1 << 0) ; put bit 0 if carry
        ora yShiftHi,x
        sta yShiftHi,x
        pla
    :
    ; Not we finally have y<<5
    sta yShiftLo,x
    ; not we need to add these two numbers
    add _ppu_tmp1+1
    sta _ppu_tmp1+1
    lda yShiftHi,x
    adc _ppu_tmp1+0
    sta PPU_ADDR
    sta ppu_addr+0
    lda _ppu_tmp1+1
    sta PPU_ADDR
    sta ppu_addr+1

    stackfree
    rts
.endproc

; -----------------------------------------------------------------------------
; Initialized buffered write on stack
; PARAMS:
;   A: 0 - horizontal write, 1 - vertical write
;   X: X coordinate
;   Y: Y coordinate
.proc ppu_BeginBufferWrite
    sta _ppu_bufferDirection
    stx _ppu_bufferAddrLo
    mova _ppu_bufferAddrHi, #0 ; reset High address
    mova ppu_hasBuffer, #0 ; reset flag, in case our buffer write take too long
    mova ppu_bufferCount, #0

    tya
    ; do y << 3 as maximum value of Y is 30 and it will not overflow
    asl
    asl
    asl
    clc
    asl
    bcc :+
        pha
        lda #(1 << 1) ; put bit 1 if carry
        sta _ppu_bufferAddrHi
        pla
    :
    clc
    asl
    bcc :+
        pha
        lda _ppu_bufferAddrHi
        ora #(1 << 0) ; put bit 1 if carry
        sta _ppu_bufferAddrHi
        pla
    :
    ; in the end we finally have y<<5
    ; now we need to add low part of Y<<5 and X
    add _ppu_bufferAddrLo
    sta _ppu_bufferAddrLo
    ; now we get high part of y<<5 and add it to high part of nametable address
    ; make sure we use carry flag we might got from the addition above
    lda _ppu_bufferAddrHi
    adc #>PPU_ADDR_NAMETABLE1
    sta _ppu_bufferAddrHi
    rts
.endproc

; -----------------------------------------------------------------------------
; Puts byte in the buffer
; PARAM:
;   A - next byte in buffer
; USE: A
.proc ppu_WriteBuffer
    stx _ppu_tmp2

    ldx ppu_bufferCount
    sta ppu_buffer,x
    inx
    stx ppu_bufferCount

    ldx _ppu_tmp1 ; restore registers
    rts
.endproc

; -----------------------------------------------------------------------------
; Outputs the buffer. To be used in NMI
; Test code for this functionality below
;   call ppu_BeginBufferWrite, #0, #29, #29
;   call ppu_WriteBuffer, #01
;   call ppu_WriteBuffer, #02
;   call ppu_WriteBuffer, #03
;   jsr ppu_FinishBufferWrite
.proc ppu_OutputBuffer
    lda _ppu_bufferDirection
    beq :+
        lda ppu_ctrl ; use current ppu_ctrl settings to set vertical increment
        ora #PPU_CTRL_INREMENT_V
        sta PPU_CTRL
    :
    m_ppu_BeginWrite ; set address
    lda _ppu_bufferAddrHi
    sta PPU_ADDR
    lda _ppu_bufferAddrLo
    sta PPU_ADDR

    ldx #0
    @loop:
        lda ppu_buffer,x
        sta PPU_DATA
        inx
        cpx ppu_bufferCount
        bne @loop

    lda ppu_ctrl ; restore PPU_CTRL
    sta PPU_CTRL
    mova ppu_hasBuffer, #0
    rts
.endproc

; -----------------------------------------------------------------------------
; Finishes the buffer write
; USE: A
.proc ppu_FinishBufferWrite
    mova ppu_hasBuffer, #1
    rts
.endproc

; -----------------------------------------------------------------------------
; Loads RLE packed nametable from the address
; PARAMS:
;   Stack+0 - Data hi address
;   Stack+1 - Data lo address
.proc ppu_LoadNameTableRle
    ; Declaring subroutines parameters
    stackparam addrLo
    stackparam addrHi
    rleTag = _ppu_tmp1
    rleByte = _ppu_tmp2
    tsx
    lda addrLo,x
    sta ppu_addr+0
    lda addrHi,x
    sta ppu_addr+1

	ldy #0
	jsr @readByte
	sta rleTag
@checkTag:
	jsr @readByte
	cmp rleTag
	beq @checkEnd
	sta PPU_DATA
	sta rleByte
	bne @checkTag
@checkEnd:
	jsr @readByte
	cmp #0
	beq @end
	tax
	lda rleByte
@writeRun:
	sta PPU_DATA
	dex
	bne @writeRun
	beq @checkTag
@end:
	rts

@readByte:
	lda (ppu_addr),y
	inc ppu_addr+0
	bne :+
	inc ppu_addr+1
:
	rts
.endproc

; .macro m_ppu_SetXy nameTable, xCoord, yCoord
;     ;POSITION =
;     m_ppu_SetAddr {(nameTable | ((yCoord << 5) | xCoord))}
; .endmacro
