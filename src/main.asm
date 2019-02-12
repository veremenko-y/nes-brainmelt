.include "nes.inc"
.include "ppu.inc"
.include "lib.inc"
.include "bf.inc"

.global main

BF_run:
; Hello World
; BF_compile "++++++++[>++++[>++>+++>+++>+<<<<-]>+>+>->>+[<]<-]>>.>---.+++++++..+++.>>.<-.<.+++.------.--------.>>+.>++."

; Factorial
BF_compile "+++++++++++++++++++++++++++++++++>+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++>++++++++++>+++++++>>+<<[>++++++++++++++++++++++++++++++++++++++++++++++++.------------------------------------------------<<<<.-.>.<.+>>>>>>>++++++++++<<[->+>-[>+>>]>[+[-<+>]>+>>]<<<<<<]>[<+>-]>[-]>>>++++++++++<[->-[>+>>]>[+[-<+>]>+>>]<<<<<]>[-]>>[++++++++++++++++++++++++++++++++++++++++++++++++.[-]]<[++++++++++++++++++++++++++++++++++++++++++++++++.[-]]<<<++++++++++++++++++++++++++++++++++++++++++++++++.[-]<<<<<<.>>+>[>>+<<-]>>[<<<[>+>+<<-]>>[<<+>>-]>-]<<<<-]"

.proc main
    jsr ppu_Off
    jsr lib_Init
    lda #(PPU_CTRL_NMI_ON | PPU_CTRL_BG_ADDR_0 | PPU_CTRL_SPR_ADDR_1)
    sta ppu_ctrl
    lda #(PPU_MASK_SPR_ON | PPU_MASK_SPR_LEFT_ON | PPU_MASK_BG_ON | PPU_MASK_BG_LEFT_ON)
    sta ppu_mask

    call ppu_LoadPallete, #<Palette, #>Palette

    jsr BF_run
    jsr ppu_ClearSprites
    jsr ppu_On
@loop:
    jmp @loop
.endproc

.segment "RODATA"
    ; Build info
    ; started this project on Mon 2019-02-12
    BUILDDAY = (.TIME / 86400) - 17939
    .out .sprintf("Build(0): Info: %d days since beginning of the project", BUILDDAY)
Palette:
    .incbin "assets/palette.pal"
    .incbin "assets/palette.pal"
.segment "CHR"
    .incbin "assets/tiles.chr"