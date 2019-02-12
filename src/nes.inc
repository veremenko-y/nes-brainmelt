;
; NES definitions. By Groepaz/Hitmem & Yaroslav Veremenko (c) 2018
;

;; FIXME: optimize zeropage usage

SCREEN_PTR      = $62           ;2
CRAM_PTR        = $64           ;2
CHARCOLOR       = $66
BGCOLOR         = $67
RVS             = $68
CURS_X          = $69
CURS_Y          = $6a

tickcount       = $6b           ;2

VBLANK_FLAG     = $70

ringbuff        = $0200
ringwrite       = $71
ringread        = $72
ringcount       = $73

ppuhi           = $74
ppulo           = $75
ppuval          = $76

screenrows      = (30-1)
charsperline    = 32
xsize           = charsperline

;; PPU defines

PPU_CTRL        = $2000
; |||| ||||
; |||| ||++- Base nametable address
; |||| ||    (0 = $2000; 1 = $2400; 2 = $2800; 3 = $2C00)
; |||| |+--- VRAM address increment per CPU read/write of PPUDATA
; |||| |     (0: add 1, going across; 1: add 32, going down)
; |||| +---- Sprite pattern table address for 8x8 sprites
; ||||       (0: $0000; 1: $1000; ignored in 8x16 mode)
; |||+------ Background pattern table address (0: $0000; 1: $1000)
; ||+------- Sprite size (0: 8x8; 1: 8x16)
; |+-------- PPU master/slave select
; |          (0: read backdrop from EXT pins; 1: output color on EXT pins)
; +--------- Generate an NMI at the start of the
;            vertical blanking interval (0: off; 1: on)
    PPU_CTRL_INREMENT_V      = $04
    PPU_CTRL_INREMENT_H      = $00
    PPU_CTRL_SPR_ADDR_0      = $00
    PPU_CTRL_SPR_ADDR_1      = $08
    PPU_CTRL_BG_ADDR_0      = $00
    PPU_CTRL_BG_ADDR_1      = $10
    PPU_CTRL_SPR_8x8        = $00
    PPU_CTRL_SPR_8x16       = $40
    PPU_CTRL_NMI_ON         = $80
PPU_MASK        = $2001
    PPU_MASK_GREYSCALE            = $01 ;Greyscale (0: normal color, 1: produce a greyscale display)
    PPU_MASK_BG_LEFT_ON           = $02 ;Show background in leftmost 8 pixels of screen, 0: Hide
    PPU_MASK_SPR_LEFT_ON          = $04 ;Show sprites in leftmost 8 pixels of screen, 0: Hide
    PPU_MASK_BG_ON                = $08 ;Show background
    PPU_MASK_SPR_ON               = $10 ;Show sprites
    PPU_MASK_EMPH_RED             = $20 ;Emphasize red*
    PPU_MASK_EMPH_GREEN           = $40 ;Emphasize green*
    PPU_MASK_EMPH_BLUE            = $80 ;Emphasize blue*

PPU_STATUS      = $2002
    PPU_STATUS_VBLANK = %1000000
PPU_SPR_ADDR    = $2003
PPU_SPR_DATA    = $2004
PPU_SCROLL      = $2005
PPU_ADDR        = $2006
    PPU_ADDR_NAMETABLE1 = $2000
    PPU_ADDR_NAMETABLE2 = $2400
    PPU_ADDR_NAMETABLE3 = $2800
    PPU_ADDR_NAMETABLE4 = $2C00
    PPU_ADDR_ATTRIBUTE  = $C0
    PPU_ADDR_ATTRIBUTE1 = (PPU_ADDR_NAMETABLE1 + $300) | PPU_ADDR_ATTRIBUTE ; Attribute tables addresses
    PPU_ADDR_ATTRIBUTE2 = (PPU_ADDR_NAMETABLE2 + $300) | PPU_ADDR_ATTRIBUTE
    PPU_ADDR_ATTRIBUTE3 = (PPU_ADDR_NAMETABLE3 + $300) | PPU_ADDR_ATTRIBUTE
    PPU_ADDR_ATTRIBUTE4 = (PPU_ADDR_NAMETABLE4 + $300) | PPU_ADDR_ATTRIBUTE
    PPU_ADDR_PALETTE    = $3F00 ;Pallete address in PPU
PPU_DATA        = $2007
PPU_SPR_DMA     = $2014
PPU_SPR_FLIP_H      = $40

;; APU defines

APU_PULSE1CTRL  = $4000         ; Pulse #1 Control Register (W)
APU_PULSE1RAMP  = $4001         ; Pulse #1 Ramp Control Register (W)
APU_PULSE1FTUNE = $4002         ; Pulse #1 Fine Tune (FT) Register (W)
APU_PULSE1CTUNE = $4003         ; Pulse #1 Coarse Tune (CT) Register (W)
APU_PULSE2CTRL  = $4004         ; Pulse #2 Control Register (W)
APU_PULSE2RAMP  = $4005         ; Pulse #2 Ramp Control Register (W)
APU_PULSE2FTUNE = $4006         ; Pulse #2 Fine Tune Register (W)
APU_PULSE2STUNE = $4007         ; Pulse #2 Coarse Tune Register (W)
APU_TRICTRL1    = $4008         ; Triangle Control Register #1 (W)
APU_TRICTRL2    = $4009         ; Triangle Control Register #2 (?)
APU_TRIFREQ1    = $400A         ; Triangle Frequency Register #1 (W)
APU_TRIFREQ2    = $400B         ; Triangle Frequency Register #2 (W)
APU_NOISECTRL   = $400C         ; Noise Control Register #1 (W)
APU_RESERVER    = $400D         ; Unused (???)
APU_NOISEFREQ1  = $400E         ; Noise Frequency Register #1 (W)
APU_NOISEFREQ2  = $400F         ; Noise Frequency Register #2 (W)
APU_MODCTRL     = $4010         ; Delta Modulation Control Register (W)
APU_MODDA       = $4011         ; Delta Modulation D/A Register (W)
APU_MODADDR     = $4012         ; Delta Modulation Address Register (W)
APU_MODLEN      = $4013         ; Delta Modulation Data Length Register (W)
APU_SPR_DMA     = $4014         ; Sprite DMA Register (W)
APU_CHANCTRL    = $4015         ; Sound/Vertical Clock Signal Register (R)
APU_PAD1        = $4016         ; Joypad #1 (RW)
APU_PAD2        = $4017         ; Joypad #2/SOFTCLK (RW)
    PAD_A       = $80
    PAD_B       = $40
    PAD_SELECT  = $20
    PAD_START   = $10
    PAD_UP      = $08
    PAD_DOWN    = $04
    PAD_LEFT    = $02
    PAD_RIGHT   = $01
APU_FRAMECT     = $4017         ; APU Frame Counter (W)
    APU_FRAMECT_IRQ_DISABLE = $40   ; Disable IRQ Interrupt
    APU_FRAMECT_MODE4 = $00         ; Sequencer mode - 4 step sequence
    APU_FRAMECT_MODE5 = $80         ; Sequencer mode - 5 step sequence


CH_HLINE        = 11
CH_VLINE        = 14
CH_ULCORNER     = 176
CH_URCORNER     = 174
CH_LLCORNER     = 173
CH_LRCORNER     = 189
CH_TTEE         = 178
CH_RTEE         = 179
CH_BTEE         = 177
CH_LTEE         = 171
CH_CROSS        = 123
CH_CURS_UP      = 145
CH_CURS_DOWN    = 17
CH_CURS_LEFT    = 157
CH_CURS_RIGHT   = 29
CH_PI           = 126
CH_DEL          = 20
CH_INS          = 148
CH_ENTER        = 10
CH_STOP         = 3
CH_ESC          = 27

