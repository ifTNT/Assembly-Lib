;===================================================================================================
; Math Functions
;
; Written By: Oded Cnaan (oded.8bit@gmail.com)
; Site: http://odedc.net 
; Licence: GPLv3 (see LICENSE file)
; Package: UtilLib
;
; Description: 
; Several math related procedures
;
; For Linear congruential generator see
; https://en.wikipedia.org/wiki/Linear_congruential_generator#c.E2.89.A00
;
;===================================================================================================

bits 16

;----------------------------------------------------------
; make the functions global as the static library function
;----------------------------------------------------------
global RandomSeed, RandomWord, RandomByte

SECTION .data
    _SeedVal  dw     0

SECTION .text
;----------------------------------------------------------
; Creates a seed for calculating rand numbers
;----------------------------------------------------------
RandomSeed:
    push ax
    push dx
    mov     ah, 00h             ; interrupt to get system timer in CX:DX 
    int     1AH
    mov     word [_SeedVal], dx
    pop dx
    pop ax
    ret
;----------------------------------------------------------
; Gets a WORD random number
; Return result in ax
;----------------------------------------------------------
RandomWord:
    push dx
    mov     ax, 25173           ; LCG Multiplier
    mul     word [_SeedVal] ; DX:AX = LCG multiplier * seed
    add     ax, 13849           ; Add LCG increment value
    ; Modulo 65536, AX = (multiplier*seed+increment) mod 65536
    mov     word [_SeedVal], ax           ; Update seed = return value
    pop dx
    ret
    
;----------------------------------------------------------
; Gets a BYTE random number
; Return result in al
;----------------------------------------------------------
RandomByte:
    call RandomWord
    and  ax,00ffh
    ret

;=========================================================================
; Other math functions
;=========================================================================

;----------------------------------------------------------
; Calculates the abs value of a register
;
; gr_absolute cx
;----------------------------------------------------------
%macro gr_absolute 1
	cmp %1, 0
	jge absolute_l1
	neg %1
absolute_l1:
%endmacro
