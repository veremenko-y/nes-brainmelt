.include "lib.inc"
.include "nes.inc"

.SEGMENT "ZEROPAGE"
    lib_seed: .res 2       ; initialize 16-bit seed to any value except 0
    controls_pad1: .res 1
    controls_pad1_pressed: .res 1
    ; P/Pointer pseudo 16-bit register
    p:
    pl: .res 1
    ph: .res 1

    r1: .res 1
    r2: .res 1

    r3: .res 1
    r4: .res 1

    ptr1:
    r5: .res 1
    r6: .res 1

    ptr2:
    r7: .res 1
    r8: .res 1

    ptr3:
    r9: .res 1
    r10: .res 1

    ptr4:
    r11: .res 1
    r12: .res 1

    ptr5:
    r13: .res 1
    r14: .res 1

    ptr6:
    r15: .res 1
    r16: .res 1

.SEGMENT "CODE"

; -----------------------------------------------------------------------------
; Initialize random generator SEED
; USE: A
.proc lib_Init
    ; Init random generator
    lda #$2F
    sta lib_seed
    lda #$C0
    sta lib_seed+1
    rts
.endproc

; -----------------------------------------------------------------------------
; Returns a random 8-bit number in A (0-255), clobbers X (0).
;   OUT: A - random number
;   USE: X
;
; Requires a 2-byte value on the zero page called "seed".
; Initialize seed to any value except 0 before the first call to prng.
; (A seed value of 0 will cause prng to always return 0.)
;
; This is a 16-bit Galois linear feedback shift register with polynomial $002D.
; The sequence of numbers it generates will repeat after 65535 calls.
;
; Execution time is an average of 125 cycles (excluding jsr and rts)
.proc lib_Rand
	ldx #8     ; iteration count (generates 8 bits)
	lda lib_seed+0
@loop:
	asl        ; shift the register
	rol lib_seed+1
	bcc @noFeedback
	eor #$2D   ; apply XOR feedback whenever a 1 bit is shifted out
@noFeedback:
	dex
	bne @loop
	sta lib_seed+0
	cmp #0     ; reload flags
	rts
.endproc

; -----------------------------------------------------------------------------
; Read Joystick 1
;   OUT: .zp controls_pad1
;   USE: A
.proc controls_ReadPad1
    ; save previous frame buttons
    mova controls_pad1_pressed, controls_pad1
    lda #$01
    ; While the strobe bit is set, buttons will be continuously reloaded.
    ; This means that reading from JOYPAD1 will only return the state of the
    ; first button: button A.
    sta APU_PAD1
    sta controls_pad1
    lsr a        ; now A is 0
    ; By storing 0 into APU_PAD1, the strobe bit is cleared and the reloading
    ; stops.
    ; This allows all 8 buttons (newly reloaded) to be read from APU_PAD1.
    sta APU_PAD1
    @loop:
        lda APU_PAD1
        lsr a	       ; bit0 -> Carry
        rol controls_pad1  ; Carry -> bit0; bit 7 -> Carry
        bcc @loop
    lda controls_pad1_pressed
    eor #$FF
    and controls_pad1
    sta controls_pad1_pressed
    rts
.endproc
