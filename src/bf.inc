.ifndef BF_INC
.define BF_INC

; RAM
.globalzp BF_codePtr;, BF_ptr, BF_line, BF_char
; CODE
.global BF_run

OP_BF_INCP = 0
OP_BF_INCP2 = 1
OP_BF_INCP5 = 2
OP_BF_INCP10 = 3
OP_BF_INCP20 = 4
OP_BF_DECP = 5
OP_BF_DECP2 = 6
OP_BF_DECP5 = 7
OP_BF_DECP10 = 8
OP_BF_DECP20 = 9
OP_BF_INC = 10
OP_BF_INC2 = 11
OP_BF_INC5 = 12
OP_BF_INC10 = 13
OP_BF_INC20 = 14
OP_BF_DEC = 15
OP_BF_DEC2 = 16
OP_BF_DEC5 = 17
OP_BF_DEC10 = 18
OP_BF_DEC20 = 19
OP_BF_PRINT = 20
OP_BF_READ = 21
OP_BF_CONDITION = 22
OP_BF_JMP = 23
OP_BF_END = $FF

BF_MAX_SOURCE_LENGTH = 80000
BF_RAM_SIZE = $200
.define BF_OPTIMIZATON ; comment to disable optimization

bflabel .set 0
bfstack .set 0

.macro BF_compile src
    .local bfbegin
    bfbegin = *
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
                    .byte OP_BF_INC20
                    bfSkipTill .set i+19
                .elseif .strat(src, i) = '-' .and .strat(src, i+1) = '-' .and .strat(src, i+2) = '-' .and .strat(src, i+3) = '-' .and .strat(src, i+4) = '-' .and .strat(src, i+5) = '-' .and .strat(src, i+6) = '-' .and .strat(src, i+7) = '-' .and .strat(src, i+8) = '-' .and .strat(src, i+9) = '-' .and .strat(src, i+10) = '-' .and .strat(src, i+11) = '-' .and .strat(src, i+12) = '-' .and .strat(src, i+13) = '-' .and .strat(src, i+14) = '-' .and .strat(src, i+15) = '-' .and .strat(src, i+16) = '-' .and .strat(src, i+17) = '-' .and .strat(src, i+18) = '-' .and .strat(src, i+19) = '-'
                    .byte OP_BF_DEC20
                    bfSkipTill .set i+19
                .elseif .strat(src, i) = '>' .and .strat(src, i+1) = '>' .and .strat(src, i+2) = '>' .and .strat(src, i+3) = '>' .and .strat(src, i+4) = '>' .and .strat(src, i+5) = '>' .and .strat(src, i+6) = '>' .and .strat(src, i+7) = '>' .and .strat(src, i+8) = '>' .and .strat(src, i+9) = '>' .and .strat(src, i+10) = '>' .and .strat(src, i+11) = '>' .and .strat(src, i+12) = '>' .and .strat(src, i+13) = '>' .and .strat(src, i+14) = '>' .and .strat(src, i+15) = '>' .and .strat(src, i+16) = '>' .and .strat(src, i+17) = '>' .and .strat(src, i+18) = '>' .and .strat(src, i+19) = '>'
                    .byte OP_BF_INCP20
                    bfSkipTill .set i+19
                .elseif .strat(src, i) = '<' .and .strat(src, i+1) = '<' .and .strat(src, i+2) = '<' .and .strat(src, i+3) = '<' .and .strat(src, i+4) = '<' .and .strat(src, i+5) = '<' .and .strat(src, i+6) = '<' .and .strat(src, i+7) = '<' .and .strat(src, i+8) = '<' .and .strat(src, i+9) = '<' .and .strat(src, i+10) = '<' .and .strat(src, i+11) = '<' .and .strat(src, i+12) = '<' .and .strat(src, i+13) = '<' .and .strat(src, i+14) = '<' .and .strat(src, i+15) = '<' .and .strat(src, i+16) = '<' .and .strat(src, i+17) = '<' .and .strat(src, i+18) = '<' .and .strat(src, i+19) = '<'
                    .byte OP_BF_DECP20
                    bfSkipTill .set i+19
                .endif
            .endif
            .if (bfSkipTill = 0 .or i > bfSkipTill) .and i+9 < .strlen(src)
                ; additional if because ca65 macro tries to evaluate all parameters even if first condition
                ; is false resulting in range error
                .if .strat(src, i) = '+' .and .strat(src, i+1) = '+' .and .strat(src, i+2) = '+' .and .strat(src, i+3) = '+' .and .strat(src, i+4) = '+' .and .strat(src, i+5) = '+' .and .strat(src, i+6) = '+' .and .strat(src, i+7) = '+' .and .strat(src, i+8) = '+' .and .strat(src, i+9) = '+'
                    .byte OP_BF_INC10
                    bfSkipTill .set i+9
                .elseif .strat(src, i) = '-' .and .strat(src, i+1) = '-' .and .strat(src, i+2) = '-' .and .strat(src, i+3) = '-' .and .strat(src, i+4) = '-' .and .strat(src, i+5) = '-' .and .strat(src, i+6) = '-' .and .strat(src, i+7) = '-' .and .strat(src, i+8) = '-' .and .strat(src, i+9) = '-'
                    .byte OP_BF_DEC10
                    bfSkipTill .set i+9
                .elseif .strat(src, i) = '>' .and .strat(src, i+1) = '>' .and .strat(src, i+2) = '>' .and .strat(src, i+3) = '>' .and .strat(src, i+4) = '>' .and .strat(src, i+5) = '>' .and .strat(src, i+6) = '>' .and .strat(src, i+7) = '>' .and .strat(src, i+8) = '>' .and .strat(src, i+9) = '>'
                    .byte OP_BF_INCP10
                    bfSkipTill .set i+9
                .elseif .strat(src, i) = '<' .and .strat(src, i+1) = '<' .and .strat(src, i+2) = '<' .and .strat(src, i+3) = '<' .and .strat(src, i+4) = '<' .and .strat(src, i+5) = '<' .and .strat(src, i+6) = '<' .and .strat(src, i+7) = '<' .and .strat(src, i+8) = '<' .and .strat(src, i+9) = '<'
                    .byte OP_BF_DECP10
                    bfSkipTill .set i+9
                .endif
            .endif
            .if (bfSkipTill = 0 .or i > bfSkipTill) .and i+4 < .strlen(src)
                ; additional if because ca65 macro tries to evaluate all parameters even if first condition
                ; is false resulting in range error
                .if .strat(src, i) = '+' .and .strat(src, i+1) = '+' .and .strat(src, i+2) = '+' .and .strat(src, i+3) = '+' .and .strat(src, i+4) = '+'
                    .byte OP_BF_INC5
                    bfSkipTill .set i+4
                .elseif .strat(src, i) = '-' .and .strat(src, i+1) = '-' .and .strat(src, i+2) = '-' .and .strat(src, i+3) = '-' .and .strat(src, i+4) = '-'
                    .byte OP_BF_DEC5
                    bfSkipTill .set i+4
                .elseif .strat(src, i) = '>' .and .strat(src, i+1) = '>' .and .strat(src, i+2) = '>' .and .strat(src, i+3) = '>' .and .strat(src, i+4) = '>'
                    .byte OP_BF_INCP5
                    bfSkipTill .set i+4
                .elseif .strat(src, i) = '<' .and .strat(src, i+1) = '<' .and .strat(src, i+2) = '<' .and .strat(src, i+3) = '<' .and .strat(src, i+4) = '<'
                    .byte OP_BF_DECP5
                    bfSkipTill .set i+4
                .endif
            .endif
            .if (bfSkipTill = 0 .or i > bfSkipTill) .and i+1 < .strlen(src)
                ; additional if because ca65 macro tries to evaluate all parameters even if first condition
                ; is false resulting in range error
                .if .strat(src, i) = '+' .and .strat(src, i+1) = '+'
                    .byte OP_BF_INC2
                    bfSkipTill .set i+1
                .elseif .strat(src, i) = '-' .and .strat(src, i+1) = '-'
                    .byte OP_BF_DEC2
                    bfSkipTill .set i+1
                .elseif .strat(src, i) = '>' .and .strat(src, i+1) = '>'
                    .byte OP_BF_INCP2
                    bfSkipTill .set i+1
                .elseif .strat(src, i) = '<' .and .strat(src, i+1) = '<'
                    .byte OP_BF_DECP2
                    bfSkipTill .set i+1
                .endif
            .endif
            .if bfSkipTill = 0 .or i > bfSkipTill
                .if .strat(src, i) = '>'
                    .byte OP_BF_INCP
                .elseif .strat(src, i) = '<'
                    .byte OP_BF_DECP
                .elseif .strat(src, i) = '+'
                    .byte OP_BF_INC
                .elseif .strat(src, i) = '-'
                    .byte OP_BF_DEC
                .elseif .strat(src, i) = '.'
                    .byte OP_BF_PRINT
                .elseif .strat(src, i) = ','
                    .byte OP_BF_READ
                .elseif .strat(src, i) = '['
                    .ident(.concat("BF_LABEL", .sprintf("%d", bflabel))):
                    .byte OP_BF_CONDITION
                    ; ldy #0
                    ; lda (BF_ptr),y
                    ; bne :+
                    .word .ident(.concat("BF_LABEL_END", .sprintf("%d", bflabel)))
                    ; :
                    ; put label onto stack
                    bfstack .set bfstack + 1
                    .ident(.concat("bfstack", .sprintf("%d", bfstack))) .set bflabel
                    bflabel .set bflabel + 1
                .elseif .strat(src, i) = ']'
                    .byte OP_BF_JMP
                    .word .ident(.concat("BF_LABEL", .sprintf("%d", .ident(.concat("bfstack", .sprintf("%d", bfstack))))))
                    .ident(.concat("BF_LABEL_END", .sprintf("%d", .ident(.concat("bfstack", .sprintf("%d", bfstack)))))):
                    bfstack .set bfstack - 1
                .endif
            .endif
        .endif
    .endrep
    .byte OP_BF_END
    .out .sprintf("Brainfuck sucessfuly compiled. Size: %d bytes", * - bfbegin)
.endmacro

.endif