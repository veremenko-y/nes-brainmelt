.ifndef BF_INC
.define BF_INC

.globalzp BF_ptr, BF_line, BF_char
.global BF_ram
.global BF_incp
.global BF_decp
.global BF_inc
.global BF_dec
.global BF_print
.global BF_read

BF_MAX_SOURCE_LENGTH = 3000
BF_RAM_SIZE = $FF

bflabel .set 0
bfstack .set 0
.macro BF_compile src
    .local bfbegin
    bfbegin = *
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
    ldx #0
    lda #0
    :
        sta BF_ram,x
        inx
        bne :-
    m_ppu_BeginWrite
    call ppu_FillNameTable, #>PPU_ADDR_NAMETABLE1, #$20, #0
    call ppu_SetAddr, #>PPU_ADDR_NAMETABLE1, #1, BF_line
    jsr ppu_On
    .if .strlen(src) > BF_MAX_SOURCE_LENGTH
        .error .sprintf("Brainfuck source is too long. Max ", BF_MAX_SOURCE_LENGTH)
    .endif
    .repeat BF_MAX_SOURCE_LENGTH, i
        .if i < .strlen(src)
            .if .strat(src, i) = '>'
                jsr BF_incp
            .endif
            .if .strat(src, i) = '<'
                jsr BF_decp
            .endif
            .if .strat(src, i) = '+'
                jsr BF_inc
            .endif
            .if .strat(src, i) = '-'
                jsr BF_dec
            .endif
            .if .strat(src, i) = '.'
                jsr BF_print
            .endif
            .if .strat(src, i) = ','
                jsr BF_read
            .endif
            .if .strat(src, i) = '['
                .ident(.concat("BF_LABEL", .sprintf("%d", bflabel))):
                ldy #0
                lda (BF_ptr),y
                bne :+
                jmp .ident(.concat("BF_LABEL_END", .sprintf("%d", bflabel)))
                :
                ; put label onto stack
                bfstack .set bfstack + 1
                .ident(.concat("bfstack", .sprintf("%d", bfstack))) .set bflabel
                bflabel .set bflabel + 1
            .endif
            .if .strat(src, i) = ']'
                jmp .ident(.concat("BF_LABEL", .sprintf("%d", .ident(.concat("bfstack", .sprintf("%d", bfstack))))))
                .ident(.concat("BF_LABEL_END", .sprintf("%d", .ident(.concat("bfstack", .sprintf("%d", bfstack)))))):
                bfstack .set bfstack - 1
            .endif
        .endif
    .endrep
    rts
    .out .sprintf("Brainfuck sucessfuly compiled. Size: %d bytes", * - bfbegin)
.endmacro

.endif