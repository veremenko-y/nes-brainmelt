.ifndef LIB_MACROSES_INC
LIB_MACROSES_INC .set 1

; Enable negative constants
.feature force_range
.macpack longbranch

; -----------------------------------------------------------------------------
; Macroses

.macro pushseg
    pusha a, x, y
.endmacro

.macro popseg
    popa a, x, y
.endmacro

.macro stackalloc ident, size
    .ifdef _stackParamPos
        .error "stackalloc must be called before stackparam"
    .endif
    .if .blank ({size})
        stackalloc {ident}, 1
        .exitmac
    .endif

    .ifdef _stackVarPos
        _stackVarPos .set _stackVarPos + size
        _stackVarCount .set _stackVarCount + size
    .else
        _stackVarPos .set $101
        _stackVarCount .set size
    .endif
    ident := _stackVarPos
    pha
.endmacro

.macro stackfree
    .ifndef _stackVarCount
        .error "stackalloc was not used"
    .endif
    .repeat _stackVarCount
        pla
    .endrepeat
.endmacro

.macro stackparam ident
    .ifdef _stackParamPos
        _stackParamPos .set (_stackParamPos) + 1
    .else
        .ifdef _stackVarPos
            _stackParamPos .set (_stackVarPos) + 3 ; to preserve return address
        .else
            _stackParamPos .set $103
        .endif
    .endif
    ident := _stackParamPos
.endmacro

.macro decl type, ident
    .if (.not .match({type}, "stack")) .and (.not .match({type}, "reg"))
        .error "Incorrect call type"
    .endif
    ;calltype_{ident} .set {type}
    .if (.strat(type, 0) = 's')
        .ident(.concat("calltype_stack", .string(ident))) := 0
    .else
        .ident(.concat("calltype_reg", .string(ident))) := 0
    .endif
    .global ident
.endmacro

.macro call ident, p1, p2, p3, p4, p5, p6
    .ifdef .ident (.concat("calltype_stack", .string(ident)))
        stackcall {ident}, {p1}, {p2}, {p3}, {p4}, {p5}, {p6}
    .elseif .defined(.ident (.concat("calltype_reg", .string(ident))))
        regcall {ident}, {p1}, {p2}, {p3}, {p4}, {p5}, {p6}
    .else
        .error "calltype is not defined"
    .endif
.endmacro

.macro stackcall ident, p1, p2, p3, p4, p5, p6
    ; I don't know how to make .repeat with decreasing numbers
    .ifnblank p6
        pusha {p6}
    .endif
    .ifnblank p5
        pusha {p5}
    .endif
    .ifnblank p4
        pusha {p4}
    .endif
    .ifnblank p3
        pusha {p3}
    .endif
    .ifnblank p2
        pusha {p2}
    .endif
    .ifnblank p1
        pusha {p1}
    .endif
    jsr ident
    .ifnblank p6
        pla
    .endif
    .ifnblank p5
        pla
    .endif
    .ifnblank p4
        pla
    .endif
    .ifnblank p3
        pla
    .endif
    .ifnblank p2
        pla
    .endif
    .ifnblank p1
        pla
    .endif
.endmacro

.macro regcall ident, ar, xr, yr, p1, p2, p3
    .ifnblank p1
        lda p1
        sta r1
    .endif
    .ifnblank p2
        lda p2
        sta r1
    .endif
    .ifnblank p3
        lda p3
        sta r1
    .endif
    .ifnblank ar
        lda ar
    .endif
    .ifnblank xr
        ldx xr
    .endif
    .ifnblank yr
        ldy yr
    .endif
    jsr ident
.endmacro

; -----------------------------------------------------------------------------
; mov and push macroses
; SOURCE: https://forums.nesdev.com/viewtopic.php?f=2&t=11112&start=15#p127422

.macro mova dest, src
    lda src
    sta dest
.endmacro

.macro pusha a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
    .ifnblank a0
        .if .xmatch({a0},p) .or .xmatch({a0},P)
            php
        .else
            .if .match({a0},x)
                txa
            .elseif .match({a0},y)
                tya
            .elseif .match(.left(1,{a0}),=)
                lda #>(.right(.tcount({a0})-1,{a0}))
                pha
                lda #<(.right(.tcount({a0})-1,{a0}))
            .elseif !(.match({a0},a))
                lda a0
            .endif
            pha
        .endif
        pusha a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
    .endif
.endmacro

.macro popa a0, a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
    .ifnblank a0
        popa a1, a2, a3, a4, a5, a6, a7, a8, a9, a10, a11, a12, a13, a14, a15
        .if .xmatch({a0},p) .or .xmatch({a0},P)
            plp
        .else
            pla
            .if .match({a0},x)
                tax
            .elseif .match({a0},y)
                tay
            .elseif !(.match({a0},a))
                sta a0
            .endif
        .endif
    .endif
.endmacro

; -----------------------------------------------------------------------------

.macro movwa dest, src
    ;.local sepd, seps
    sepd .set 0
    seps .set 0

    .if .match({.right(2,{dest})},{,x}) .or .match({.right(2,{dest})},{,y})
        sepd .set 2
    .endif
    .if .match({.right(2,{src})},{,x}) .or .match({.right(2,{src})},{,y})
        seps .set 2
    .endif

    .if .match(.left(1, {src}),#)
        mova {.left(.tcount({dest})-sepd,dest)+0 .right(sepd,dest)}, #<(.right(.tcount({src})-1,{src}))
        mova {.left(.tcount({dest})-sepd,dest)+1 .right(sepd,dest)}, #>(.right(.tcount({src})-1,{src}))
    .else
        mova {.left(.tcount({dest})-sepd,dest)+0 .right(sepd,dest)}, {.left(.tcount({src})-seps,src)+0 .right(seps,src)}
        mova {.left(.tcount({dest})-sepd,dest)+1 .right(sepd,dest)}, {.left(.tcount({src})-seps,src)+1 .right(seps,src)}
    .endif
.endmacro

.macro  add     Arg     ; add without carry
    clc
    adc     Arg
.endmacro

.macro  sub     Arg     ; subtract without borrow
    sec
    sbc     Arg
.endmacro

.macro  bge     Arg     ; branch on greater-than or equal
    bcs     Arg
.endmacro

.macro  jge     Arg     ; branch on greater-than or equal
    jcs     Arg
.endmacro

.macro  blt     Arg     ; branch on less-than
    bcc     Arg
.endmacro

.macro  jlt     Arg     ; branch on less-than
    jcc     Arg
.endmacro

.macro  bgt     Arg     ; branch on greater-than
    .local @end
    beq     @end
    bcs     Arg
@end:
.endmacro

.macro  jgt     Arg     ; branch on greater-than
    beq     :+
    jcs     Arg
:
.endmacro

.macro  ble     Arg     ; branch on less-than or equal
    beq     Arg
    bcc     Arg
.endmacro

.macro  jle     Arg     ; branch on less-than or equal
    jeq     Arg
    jcc     Arg
.endmacro

.macro  bnz     Arg     ; branch on not zero
    bne     Arg
.endmacro

.macro  bze     Arg     ; branch on zero
    beq     Arg
.endmacro

.endif