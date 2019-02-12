.ifndef LIB_INC
LIB_INC .set 1

.include "lib_macroses.inc"

; -----------------------------------------------------------------------------
; Exports

.global lib_Rand
.global lib_Init
.global controls_ReadPad1, controls_ReadPad2

.globalzp lib_seed
.globalzp controls_pad1, controls_pad1_pressed
.globalzp p, pl, ph

.globalzp r1
.globalzp r2

.globalzp r3
.globalzp r4

.globalzp ptr1
.globalzp r5
.globalzp r6

.globalzp ptr2
.globalzp r7
.globalzp r8

.globalzp ptr3
.globalzp r9
.globalzp r10

.globalzp ptr4
.globalzp r11
.globalzp r12

.globalzp ptr5
.globalzp r13
.globalzp r14

.globalzp ptr6
.globalzp r15
.globalzp r16

.endif