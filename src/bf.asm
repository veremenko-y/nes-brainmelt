.include "lib.inc"
.include "ppu.inc"
.include "nes.inc"
.include "bf.inc"

.segment "BSS"
    BF_ram: .res BF_RAM_SIZE
.segment "ZEROPAGE"
    BF_codePtr: .res 2
    BF_tmp: .res 1
    BF_ptr: .res 2
    BF_readCallback: .res 2
    BF_line: .res 1
    BF_endLine: .res 1
    BF_char: .res 1

    BF_SCREEN_WIDTH = 30
    BF_NEW_LINE = $0A
.segment "RODATA"
BF_jumptable:
    .word BF_incp-1
    .word BF_incp_multi-1
    .word BF_decp-1
    .word BF_decp_multi-1
    .word BF_inc-1
    .word BF_inc_multi-1
    .word BF_dec-1
    .word BF_dec_multi-1
    .word BF_print-1
    .word BF_read-1
    .word BF_condition-1
    .word BF_jmp-1

.segment "CODE"

.proc BF_run
    jsr ppu_Off
    lda #<BF_ram
    sta BF_ptr+0
    lda #>BF_ram
    sta BF_ptr+1
    lda #3
    sta BF_line
    lda #0
    sta BF_char
    lda #28
    sta BF_endLine ; current scroll position
    lda #0
    sta ppu_scrolly

    ; clear ram
    RamEnd = BF_ram + BF_RAM_SIZE
    movwa p, #BF_ram
    ldy #0
    lda #0
    @clearLoop:
        sta (p),y
        inc pl
        bne :+
            inc ph
        :
        ldx #>RamEnd
        cpx ph
        bne @clearLoop
        ldx #<RamEnd
        cpx pl
        bne @clearLoop
    m_ppu_BeginWrite
    call ppu_FillNameTable, #>PPU_ADDR_NAMETABLE1, #$20, #0
    call ppu_FillNameTable, #>PPU_ADDR_NAMETABLE3, #$20, #0
    call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, #1, BF_line
    jsr ppu_On
@loop:
    jsr BF_next
    cmp #$FF
    beq @end
    jsr BF_exec
    jmp @loop
@end:
    rts
.endproc

.proc BF_next
    ldy #0
    lda (BF_codePtr),y
    inc BF_codePtr+0
    bne :+
        inc BF_codePtr+1
    :
    rts
.endproc

; -------
; OPCODES
; -------

.proc BF_condition
    ldy #0
    lda (BF_ptr),y
    bne @else
        jsr BF_next
        tax
        jsr BF_next
        sta BF_codePtr+1
        stx BF_codePtr+0
        jmp @end
    @else:
        jsr BF_next
        jsr BF_next
    @end:
    rts
.endproc
.proc BF_jmp
    jsr BF_next
    tax
    jsr BF_next
    sta BF_codePtr+1
    stx BF_codePtr+0
    rts
.endproc
.proc BF_exec
    asl a
    tax
    lda BF_jumptable+1,x
    pha
    lda BF_jumptable+0,x
    pha
    rts
.endproc
.proc BF_incp
    inc BF_ptr+0
    bne :+
        inc BF_ptr+1
    :
    rts
.endproc
.proc BF_incp_multi
    jsr BF_next
    add BF_ptr+0
    sta BF_ptr+0
    lda BF_ptr+1
    adc #0
    sta BF_ptr+1
    rts
.endproc
.proc BF_decp
    dec BF_ptr+0
    bne :+
        dec BF_ptr+1
    :
    rts
.endproc
.proc BF_decp_multi
    jsr BF_next
    sta BF_tmp
    lda BF_ptr+0
    sub BF_tmp
    sta BF_ptr+0
    lda BF_ptr+1
    sbc #0
    sta BF_ptr+1
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
.proc BF_inc_multi
    jsr BF_next
    ldy #0
    add {(BF_ptr),y}
    sta (BF_ptr),y
    sta BF_tmp
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
.proc BF_dec_multi
    jsr BF_next
    sta BF_tmp
    ldy #0
    lda (BF_ptr),y
    sub BF_tmp
    sta (BF_ptr),y
    rts
.endproc
.proc BF_print
    jsr ppu_WaitForNmiDone
    ldy #0
    lda (BF_ptr),y
    cmp #BF_NEW_LINE
    jne @else
        @newLine:
        inc BF_line
        lda BF_line
        cmp #60         ; wrap around BF_line at 30*2 (two screens heights)
        bne :+
            lda #0
            sta BF_line
        :
        lda BF_line
        cmp BF_endLine
        jne @noLineClear
            inc BF_endLine
            lda BF_endLine
            cmp #60
            bne :+
                lda #0
                sta BF_endLine
            :

            lda BF_line
            cmp #30
            bge :+
                call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, #1, BF_line
                jmp :++
            :
                lda BF_line
                sub #30
                sta BF_tmp
                call ppu_SetAddr, #>PPU_ADDR_NAMETABLE3, #1, BF_tmp
            :
            lda ppu_scrolly
            add #8
            cmp #240
            bne :+++
                jsr ppu_Off
                lda BF_line
                cmp #30
                bge :+
                    lda #~$03
                    and ppu_ctrl
                    sta ppu_ctrl
                    call ppu_FillNameTable, #>PPU_ADDR_NAMETABLE3, #$20, #0
                    jmp :++
                :
                    lda #$02
                    ora ppu_ctrl
                    sta ppu_ctrl
                    call ppu_FillNameTable, #>PPU_ADDR_NAMETABLE1, #$20, #0
                :
                jsr ppu_On
                lda #0
            :
            sta ppu_scrolly
            jsr ppu_ResetScroll
            ; call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, #1, BF_line
            ; call ppu_FillNameTable, #>PPU_ADDR_NAMETABLE1, #$20, #0
            jsr ppu_On
            ;lda #3
        @noLineClear:
        lda #0
        sta BF_char

        lda BF_line
        cmp #30
        bge :+
            call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, #1, BF_line
            jmp :++
        :
            lda BF_line
            sub #30
            sta BF_tmp
            call ppu_SetAddr, #>PPU_ADDR_NAMETABLE3, #1, BF_tmp
        :
        jmp @endif
    @else:
        m_ppu_ResumeWrite
        m_ppu_Write
        lda BF_char
        add #1
        sta BF_char
        cmp #BF_SCREEN_WIDTH
        bne :+
            jsr ppu_ResetScroll
            jmp @newLine
        :
    @endif:
    jsr ppu_ResetScroll
    rts
.endproc
.proc BF_read
    ; return if callback is empty
    lda BF_readCallback+0
    bne :+
    lda BF_readCallback+1
    bne :+
        rts
    :
    jsr BF_execReadCallback
    jsr BF_print
    rts
.endproc
.proc BF_execReadCallback
    jmp (BF_readCallback)
.endproc