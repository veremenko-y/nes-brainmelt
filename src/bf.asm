.include "lib.inc"
.include "ppu.inc"
.include "nes.inc"
.include "bf.inc"

.segment "BSS"
    BF_ram: .res 1024
.segment "ZEROPAGE"
    BF_ptr: .res 2
    BF_line: .res 1

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
    ldy #0
    lda (BF_ptr),y
    cmp #$0A
    bne :+
        lda BF_line
        add #1
        sta BF_line
        call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, #1, BF_line
        jmp :++
    :
        sta PPU_DATA
    :
    rts
.endproc
.proc BF_read
    rts
.endproc

