.include "lib.inc"
.include "ppu.inc"
.include "nes.inc"
.include "bf.inc"

.segment "BSS"
    BF_ram: .res BF_RAM_SIZE
.segment "ZEROPAGE"
    BF_codePtr: .res 2
    BF_ptr: .res 2
    BF_line: .res 1
    BF_char: .res 1
.segment "RODATA"
BF_jumptable:
    .word BF_incp-1
    .word BF_incp2-1
    .word BF_incp5-1
    .word BF_incp10-1
    .word BF_incp20-1
    .word BF_decp-1
    .word BF_decp2-1
    .word BF_decp5-1
    .word BF_decp10-1
    .word BF_decp20-1
    .word BF_inc-1
    .word BF_inc2-1
    .word BF_inc5-1
    .word BF_inc10-1
    .word BF_inc20-1
    .word BF_dec-1
    .word BF_dec2-1
    .word BF_dec5-1
    .word BF_dec10-1
    .word BF_dec20-1
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
.proc BF_incp2
    jsr BF_incp
    jmp BF_incp
.endproc
.proc BF_incp5
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jmp BF_incp
.endproc
.proc BF_incp10
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jmp BF_incp
.endproc
.proc BF_incp20
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jsr BF_incp
    jmp BF_incp
.endproc
.proc BF_decp
    dec BF_ptr+0
    bne :+
        dec BF_ptr+1
    :
    rts
.endproc
.proc BF_decp2
    jsr BF_decp
    jmp BF_decp
.endproc
.proc BF_decp5
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jmp BF_decp
.endproc
.proc BF_decp10
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jmp BF_decp
.endproc
.proc BF_decp20
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jsr BF_decp
    jmp BF_decp
.endproc
.proc BF_inc
    ldy #0
    lda (BF_ptr),y
    clc
    adc #1
    sta (BF_ptr),y
    rts
.endproc
.proc BF_inc2
    jsr BF_inc
    jmp BF_inc
.endproc
.proc BF_inc5
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jmp BF_inc
.endproc
.proc BF_inc10
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jmp BF_inc
.endproc
.proc BF_inc20
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jsr BF_inc
    jmp BF_inc
.endproc
.proc BF_dec
    ldy #0
    lda (BF_ptr),y
    sec
    sbc #1
    sta (BF_ptr),y
    rts
.endproc
.proc BF_dec2
    jsr BF_dec
    jmp BF_dec
.endproc
.proc BF_dec5
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jmp BF_dec
.endproc
.proc BF_dec10
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jmp BF_dec
.endproc
.proc BF_dec20
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jsr BF_dec
    jmp BF_dec
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
    jsr controls_ReadPad1
    jsr ppu_WaitForNmiDone
    ldx #0
    lda #PAD_A
    bit controls_pad1_pressed
    beq :+
        ldx 'l'
        jmp @end
    :
    lda #PAD_B
    bit controls_pad1_pressed
    beq :+
        ldx 'i'
        jmp @end
    :
    lda #PAD_SELECT
    bit controls_pad1_pressed
    beq :+
        ldx 'd'
        jmp @end
    :
    lda #PAD_START
    bit controls_pad1_pressed
    beq :+
        ldx 'u'
        jmp @end
    :
    lda #PAD_UP
    bit controls_pad1_pressed
    beq :+
        ldx 'u'
        jmp @end
    :
    lda #PAD_DOWN
    bit controls_pad1_pressed
    beq :+
        ldx 'd'
        jmp @end
    :
    lda #PAD_LEFT
    bit controls_pad1_pressed
    beq :+
        ldx 'l'
        jmp @end
    :
    lda #PAD_RIGHT
    bit controls_pad1_pressed
    beq :+
        ldx 'r'
        jmp @end
    :
@end:
    cpx #0
    beq :+
        ldy #0
        txa
        sta (BF_ptr),y
    :
    rts
.endproc

