.ifndef BF_INC
.define BF_INC

.globalzp BF_ptr, BF_line, BF_char
.global BF_ram
.global BF_incp, BF_incp2, BF_incp5, BF_incp10, BF_incp20
.global BF_decp, BF_decp2, BF_decp5, BF_decp10, BF_decp20
.global BF_inc, BF_inc2, BF_inc5, BF_inc10, BF_inc20
.global BF_dec, BF_dec2, BF_dec5, BF_dec10, BF_dec20
.global BF_print
.global BF_read

BF_MAX_SOURCE_LENGTH = 8000
BF_RAM_SIZE = $FF
.define BF_OPTIMIZATON ; comment to disable optimization

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
    bfSkipTill .set 0
    .repeat BF_MAX_SOURCE_LENGTH, i
        .if i < .strlen(src) .and (bfSkipTill = 0 .or i > bfSkipTill)
            .if i+19 < .strlen(src)
                ; additional if because ca65 macro tries to evaluate all parameters even if first condition
                ; is false resulting in range error
                .if .strat(src, i) = '+' .and .strat(src, i+1) = '+' .and .strat(src, i+2) = '+' .and .strat(src, i+3) = '+' .and .strat(src, i+4) = '+' .and .strat(src, i+5) = '+' .and .strat(src, i+6) = '+' .and .strat(src, i+7) = '+' .and .strat(src, i+8) = '+' .and .strat(src, i+9) = '+' .and .strat(src, i+10) = '+' .and .strat(src, i+11) = '+' .and .strat(src, i+12) = '+' .and .strat(src, i+13) = '+' .and .strat(src, i+14) = '+' .and .strat(src, i+15) = '+' .and .strat(src, i+16) = '+' .and .strat(src, i+17) = '+' .and .strat(src, i+18) = '+' .and .strat(src, i+19) = '+'
                    jsr BF_inc20
                    bfSkipTill .set i+19
                .elseif .strat(src, i) = '-' .and .strat(src, i+1) = '-' .and .strat(src, i+2) = '-' .and .strat(src, i+3) = '-' .and .strat(src, i+4) = '-' .and .strat(src, i+5) = '-' .and .strat(src, i+6) = '-' .and .strat(src, i+7) = '-' .and .strat(src, i+8) = '-' .and .strat(src, i+9) = '-' .and .strat(src, i+10) = '-' .and .strat(src, i+11) = '-' .and .strat(src, i+12) = '-' .and .strat(src, i+13) = '-' .and .strat(src, i+14) = '-' .and .strat(src, i+15) = '-' .and .strat(src, i+16) = '-' .and .strat(src, i+17) = '-' .and .strat(src, i+18) = '-' .and .strat(src, i+19) = '-'
                    jsr BF_dec20
                    bfSkipTill .set i+19
                .elseif .strat(src, i) = '>' .and .strat(src, i+1) = '>' .and .strat(src, i+2) = '>' .and .strat(src, i+3) = '>' .and .strat(src, i+4) = '>' .and .strat(src, i+5) = '>' .and .strat(src, i+6) = '>' .and .strat(src, i+7) = '>' .and .strat(src, i+8) = '>' .and .strat(src, i+9) = '>' .and .strat(src, i+10) = '>' .and .strat(src, i+11) = '>' .and .strat(src, i+12) = '>' .and .strat(src, i+13) = '>' .and .strat(src, i+14) = '>' .and .strat(src, i+15) = '>' .and .strat(src, i+16) = '>' .and .strat(src, i+17) = '>' .and .strat(src, i+18) = '>' .and .strat(src, i+19) = '>'
                    jsr BF_incp20
                    bfSkipTill .set i+19
                .elseif .strat(src, i) = '<' .and .strat(src, i+1) = '<' .and .strat(src, i+2) = '<' .and .strat(src, i+3) = '<' .and .strat(src, i+4) = '<' .and .strat(src, i+5) = '<' .and .strat(src, i+6) = '<' .and .strat(src, i+7) = '<' .and .strat(src, i+8) = '<' .and .strat(src, i+9) = '<' .and .strat(src, i+10) = '<' .and .strat(src, i+11) = '<' .and .strat(src, i+12) = '<' .and .strat(src, i+13) = '<' .and .strat(src, i+14) = '<' .and .strat(src, i+15) = '<' .and .strat(src, i+16) = '<' .and .strat(src, i+17) = '<' .and .strat(src, i+18) = '<' .and .strat(src, i+19) = '<'
                    jsr BF_decp20
                    bfSkipTill .set i+19
                .endif
            .endif
            .if (bfSkipTill = 0 .or i > bfSkipTill) .and i+9 < .strlen(src)
                ; additional if because ca65 macro tries to evaluate all parameters even if first condition
                ; is false resulting in range error
                .if .strat(src, i) = '+' .and .strat(src, i+1) = '+' .and .strat(src, i+2) = '+' .and .strat(src, i+3) = '+' .and .strat(src, i+4) = '+' .and .strat(src, i+5) = '+' .and .strat(src, i+6) = '+' .and .strat(src, i+7) = '+' .and .strat(src, i+8) = '+' .and .strat(src, i+9) = '+'
                    jsr BF_inc10
                    bfSkipTill .set i+9
                .elseif .strat(src, i) = '-' .and .strat(src, i+1) = '-' .and .strat(src, i+2) = '-' .and .strat(src, i+3) = '-' .and .strat(src, i+4) = '-' .and .strat(src, i+5) = '-' .and .strat(src, i+6) = '-' .and .strat(src, i+7) = '-' .and .strat(src, i+8) = '-' .and .strat(src, i+9) = '-'
                    jsr BF_dec10
                    bfSkipTill .set i+9
                .elseif .strat(src, i) = '>' .and .strat(src, i+1) = '>' .and .strat(src, i+2) = '>' .and .strat(src, i+3) = '>' .and .strat(src, i+4) = '>' .and .strat(src, i+5) = '>' .and .strat(src, i+6) = '>' .and .strat(src, i+7) = '>' .and .strat(src, i+8) = '>' .and .strat(src, i+9) = '>'
                    jsr BF_incp10
                    bfSkipTill .set i+9
                .elseif .strat(src, i) = '<' .and .strat(src, i+1) = '<' .and .strat(src, i+2) = '<' .and .strat(src, i+3) = '<' .and .strat(src, i+4) = '<' .and .strat(src, i+5) = '<' .and .strat(src, i+6) = '<' .and .strat(src, i+7) = '<' .and .strat(src, i+8) = '<' .and .strat(src, i+9) = '<'
                    jsr BF_decp10
                    bfSkipTill .set i+9
                .endif
            .endif
            .if (bfSkipTill = 0 .or i > bfSkipTill) .and i+4 < .strlen(src)
                ; additional if because ca65 macro tries to evaluate all parameters even if first condition
                ; is false resulting in range error
                .if .strat(src, i) = '+' .and .strat(src, i+1) = '+' .and .strat(src, i+2) = '+' .and .strat(src, i+3) = '+' .and .strat(src, i+4) = '+'
                    jsr BF_inc5
                    bfSkipTill .set i+4
                .elseif .strat(src, i) = '-' .and .strat(src, i+1) = '-' .and .strat(src, i+2) = '-' .and .strat(src, i+3) = '-' .and .strat(src, i+4) = '-'
                    jsr BF_dec5
                    bfSkipTill .set i+4
                .elseif .strat(src, i) = '>' .and .strat(src, i+1) = '>' .and .strat(src, i+2) = '>' .and .strat(src, i+3) = '>' .and .strat(src, i+4) = '>'
                    jsr BF_incp5
                    bfSkipTill .set i+4
                .elseif .strat(src, i) = '<' .and .strat(src, i+1) = '<' .and .strat(src, i+2) = '<' .and .strat(src, i+3) = '<' .and .strat(src, i+4) = '<'
                    jsr BF_decp5
                    bfSkipTill .set i+4
                .endif
            .endif
            .if (bfSkipTill = 0 .or i > bfSkipTill) .and i+1 < .strlen(src)
                ; additional if because ca65 macro tries to evaluate all parameters even if first condition
                ; is false resulting in range error
                .if .strat(src, i) = '+' .and .strat(src, i+1) = '+'
                    jsr BF_inc2
                    bfSkipTill .set i+1
                .elseif .strat(src, i) = '-' .and .strat(src, i+1) = '-'
                    jsr BF_dec2
                    bfSkipTill .set i+1
                .elseif .strat(src, i) = '>' .and .strat(src, i+1) = '>'
                    jsr BF_incp2
                    bfSkipTill .set i+1
                .elseif .strat(src, i) = '<' .and .strat(src, i+1) = '<'
                    jsr BF_decp2
                    bfSkipTill .set i+1
                .endif
            .endif
            .if bfSkipTill = 0 .or i > bfSkipTill
                .if .strat(src, i) = '>'
                    jsr BF_incp
                .elseif .strat(src, i) = '<'
                    jsr BF_decp
                .elseif .strat(src, i) = '+'
                    jsr BF_inc
                .elseif .strat(src, i) = '-'
                    jsr BF_dec
                .elseif .strat(src, i) = '.'
                    jsr BF_print
                .elseif .strat(src, i) = ','
                    jsr BF_read
                .elseif .strat(src, i) = '['
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
                .elseif .strat(src, i) = ']'
                    jmp .ident(.concat("BF_LABEL", .sprintf("%d", .ident(.concat("bfstack", .sprintf("%d", bfstack))))))
                    .ident(.concat("BF_LABEL_END", .sprintf("%d", .ident(.concat("bfstack", .sprintf("%d", bfstack)))))):
                    bfstack .set bfstack - 1
                .endif
            .endif
        .endif
    .endrep
    rts
    .out .sprintf("Brainfuck sucessfuly compiled. Size: %d bytes", * - bfbegin)
.endmacro

.endif