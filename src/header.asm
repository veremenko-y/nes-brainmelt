.segment "HEADER"
    ; iNES header
    ; see http://wiki.nesdev.com/w/index.php/INES
    .byte $4e, $45, $53, $1a ; "NES" followed by MS-DOS EOF
    .byte $02                ; size of PRG ROM in 16 KiB units
    .byte $01                ; size of CHR ROM in 8 KiB units
    .byte $00                ; horizontal mirroring, mapper 003 (CNROM)
    .byte $00                ; mapper 003 (CNROM)

    .byte $00                ; size of PRG RAM in 8 KiB units
    .byte $00                ; NTSC
    .byte $00                ; unused
    .res 5, $00