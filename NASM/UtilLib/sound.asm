;===================================================================================================
; Sound
;
; Written By: Oded Cnaan (oded.8bit@gmail.com)
; Site: http://odedc.net 
; Licence: GPLv3 (see LICENSE file)
; Package: UtilLib
;
; Description: 
; Allows playing sounds
;===================================================================================================

%include "util.asm"

bits 16

;----------------------------------------------------------
; make the functions global as the static library function
;----------------------------------------------------------
global Beep,StopBeep

;----------------------------------------------------------------------
; Plays a beep sound based on the given frequency
; Credit: http://www.edaboard.com/thread182595.html
;
; push FREQUENCY IN HERTZ
; call Beep
;----------------------------------------------------------------------
Beep:	
    store_sp_bp
    push ax
    push dx
    push cx

    mov cx,[bp+4]
    cmp cx, 014H
    jb .STARTSOUND_DONE
    ;CALL STOPSOUND
    in al, 061H
    ;AND AL, 0FEH
    ;OR AL, 002H
    or al, 003H
    dec ax
    out 061H, al	;TURN AND GATE ON; TURN TIMER OFF
    mov dx, 00012H	;HIGH WORD OF 1193180
    mov ax, 034DCH	;LOW WORD OF 1193180
    div cx
    mov dx,ax
    mov al, 0B6H
    pushf
    cli	;!!!
    out 043H, al
    mov al, dl
    out 042H, al
    mov al, DH
    out 042H, al
    popf
    in al, 061H
    or al, 003H
    out 061H, AL
.STARTSOUND_DONE:
    pop cx
    pop dx
    pop ax
    restore_sp_bp
    retn 2

;----------------------------------------------------------------------
; Stop beep by destroying AL
;----------------------------------------------------------------------
StopBeep:
    push ax
    in al, 061H
    and al, 0FCH
    out 061H, al
    pop ax
    retn

;////////////////////////////////////////////////////////////////////////////
; FUNCTION LIKE MACROS
;////////////////////////////////////////////////////////////////////////////

;----------------------------------------------------------------------
; Plays a beep sound based on the given frequency
;
; grm_Beep (freq)
;----------------------------------------------------------------------
%MACRO	utm_Beep	1-*
%DEFINE	%%freq	%1
    push %%freq
    call Beep
%ENDMACRO    
;----------------------------------------------------------------------
; Stop beep by destroying AL
;
; grm_StopBeep()
;----------------------------------------------------------------------
%MACRO	utm_StopBeep	0
    call StopBeep
%ENDMACRO
