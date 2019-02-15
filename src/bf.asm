.include "lib.inc"
.include "ppu.inc"
.include "nes.inc"
.include "bf.inc"

.segment "BSS"
    BF_ram: .res BF_RAM_SIZE
.segment "ZEROPAGE"
    BF_ptr: .res 2
    BF_line: .res 1
    BF_char: .res 1

.segment "CODE"
.proc BF_incp
    inc BF_ptr+0
    bne :+
        inc BF_ptr+1
    :
    rts
.endproc
.proc BF_decp
    dec BF_ptr+0
    bne :+
        dec BF_ptr+1
    :
    rts
.endproc
.proc BF_inc
    ldy #0
    lda (BF_ptr),y
    clc
    adc #1
    sta (BF_ptr),y
    rts
.endproc
.proc BF_dec
    ldy #0
    lda (BF_ptr),y
    sec
    sbc #1
    sta (BF_ptr),y
    rts
.endproc
.proc BF_print
    jsr ppu_WaitForNmiDone
    ldy #0
    lda (BF_ptr),y
    cmp #$0A
    bne @else
        @newLine:
        lda BF_line
        add #1
        cmp #28
        bne :+
            jsr ppu_Off
            call ppu_FillNameTable, #>PPU_ADDR_NAMETABLE1, #$20, #0
            jsr ppu_On
            lda #3
        :
        sta BF_line
        lda #0
        sta BF_char
        call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, #1, BF_line
        jmp @endif
    @else:
        m_ppu_ResumeWrite
        m_ppu_Write
        lda BF_char
        add #1
        sta BF_char
        cmp #28
        bne :+
            jsr ppu_ResetScroll
            jmp @newLine
        :
    @endif:
    jsr ppu_ResetScroll
    rts
.endproc
.proc BF_read
    rts
.endproc

