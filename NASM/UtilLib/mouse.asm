;===================================================================================================
; Mouse Handling
;
; Written By: Oded Cnaan (oded.8bit@gmail.com)
; Site: http://odedc.net 
; Licence: GPLv3 (see LICENSE file)
; Package: UtilLib
;
; Description: 
; Managing input from the mouse
;===================================================================================================

bits 16

;----------------------------------------------------------
; make the functions global as the static library function
;----------------------------------------------------------
global InstallMouseInterrupt, UninstallMouseInterrupt

;----------------------------------------------------------------------
; Show the mouse pointer
;----------------------------------------------------------------------
%MACRO	ShowMouse	0
    mov ax,01
    int 33h
%ENDMACRO
;----------------------------------------------------------------------
; Hide the mouse pointer
;----------------------------------------------------------------------
%MACRO	HideMouse	0
    mov ax,02
    int 33h
%ENDMACRO
;----------------------------------------------------------------------
; Get Mouse Position and Button Status
;
; on return:
;	CX = horizontal (X) position  (0..639)
;	DX = vertical (Y) position  (0..199)
;	BX = button status:
;
;		|F-8|7|6|5|4|3|2|1|0|  Button Status
;		  |  | | | | | | | `---- left button (1 = pressed)
;		  |  | | | | | | `----- right button (1 = pressed)
;		  `------------------- unused
;
;
;	- values returned in CX, DX are the same regardless of video mode
;----------------------------------------------------------------------
%MACRO	GetMouseStatus	0
    mov ax, 03
    int 33h
%ENDMACRO
;-----------------------------------------------------------------------
; Input:
;   CX = horizontal position
;   DX = vertical position
;-----------------------------------------------------------------------
%MACRO	SetMousePosition	0
    mov ax, 4
    int 33h
%ENDMACRO
;----------------------------------------------------------------------- 
; cx = x (0..639)
; dx = y (0..199)
;-----------------------------------------------------------------------
%MACRO	TranslateMouseCoords	0
    inc cx
    shr cx, 1
%ENDMACRO
;------------------------------------------------------------------------
; push ISR address
; push ISR segment
; push mask
; call InstallMouseInterrupt
;------------------------------------------------------------------------
InstallMouseInterrupt:
    push ax
    push cx
    push dx
    push es
    cli

    ; now the stack is
	; bp+0 => old base pointer
	; bp+2 => return address
	; bp+4 => mask
	; bp+6 => ISR segment
	; bp+8 => ISR address
	; saved registers  
    ;{
        %DEFINE	_mask	word [bp+4]
        %DEFINE	_isr_addr	word [bp+6]
        %DEFINE	_isr_seg	word [bp+8]
    ;}

    ; Mouse Reset/Get Mouse Installed Flag
    xor ax, ax
    int 33h
    cmp ax,0        
    je .InstallMouseInterrupt_end                ; mouse not installed

    ShowMouse

    ; Set Mouse User Defined Subroutine and Input Mask
    mov ax, 0Ch
    mov cx, _mask
    push _isr_seg
    pop es
    mov dx, _isr_addr
    int 33h 
.end:
    sti
    pop es
    pop dx
    pop cx
    pop ax
    retn 6
;------------------------------------------------------------------------
; call UninstallMouseInterrupt
;------------------------------------------------------------------------
UninstallMouseInterrupt:
    cli
    push ax
    push cx
    push dx

    mov ax, 0Ch
    xor cx, cx
    xor dx, dx
    int 33h

.end:
    pop dx
    pop cx
    pop ax
    sti
    retn
