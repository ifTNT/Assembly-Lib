;===================================================================================================
; General Utilities
;
; Written By: Oded Cnaan (oded.8bit@gmail.com)
; Site: http://odedc.net 
; Licence: GPLv3 (see LICENSE file)
; Package: UtilLib
;
; Description: 
; General common utilities 
;===================================================================================================

bits 16

SECTION .data
  _dss         dw    0        ; Saved DS segment

SECTION .code
;------------------------------------------------------------------------
; Initialization - call at the beginning of your program
;------------------------------------------------------------------------
%MACRO	ut_init_lib	1-*
%DEFINE	%%freeMem	%1
  mov [_dss], ds
  cmp %%freeMem, FALSE
  je %%_out
  ; Free redundant memory take by program
  ; to allow using malloc
  call FreeProgramMem
%%_out:  
%ENDMACRO
;----------------------------------------------------------
; called at the beginnig of each PROC to store
; and set BP value
;----------------------------------------------------------
%MACRO	store_sp_bp	0
    push bp
	mov bp,sp
%ENDMACRO
;----------------------------------------------------------
; called at the end of each PROC to restore 
; SP and BP
;----------------------------------------------------------
%MACRO	restore_sp_bp	0
    mov sp,bp
    pop bp
%ENDMACRO
;----------------------------------------------------------
; Create 'num' local variables
;----------------------------------------------------------
%MACRO	define_local_vars	1-*
%DEFINE	%%num	%1
  sub sp, %%num*2
%ENDMACRO
;----------------------------------------------------------
; Toogles a boolean memory variable
;----------------------------------------------------------
%MACRO	toggle_bool_var	1-*
%DEFINE	%%mem	%1
  push ax
  mov ax, [%%mem]
  cmp ax, 0
  je %%_setone
  mov [%%mem], 0
  jmp %%_endtog
%%_setone:
  mov [%%mem],1
%%_endtog:  
  pop ax
%ENDMACRO
;----------------------------------------------------------
; Compare two memory variables
;----------------------------------------------------------
%MACRO	movv	2-*
%DEFINE	%%from	%1
%DEFINE	%%to	%2
  push WORD [%%from]
  pop WORD [%%to]
%ENDMACRO
;----------------------------------------------------------
; Compare two memory variables
;----------------------------------------------------------
%MACRO	cmpv	3-*
%DEFINE	%%var1	%1
%DEFINE	%%var2	%2
%DEFINE	%%register	%3
  mov %%register, %%var1
  cmp %%register, %%var2
%ENDMACRO
;----------------------------------------------------------
; Return control to DOS
; code = 0 is a normal exit
;----------------------------------------------------------
%MACRO	return	1-*
%DEFINE	%%code	%1
  mov ah, 4ch
  mov al, %%code
  int 21h
%ENDMACRO
;----------------------------------------------------------
; Gets the memory address of the specific (row,col) element
; in the 2d array of BYTES
;
; array2D[4][2] where 4 is the number of rows and 2 the 
; number of columns.
;
; Equivalent to a C# 2d array:
; byte[,] array2D = new byte[,] = {{1,2}, {3,4}, {5,6}, {7,8}}
;
; Input:
;   reg     - the register that will hold the result. Cannot be DX
;   address - offset of the 2d array (assuming ds segment)
;   row,col - of the required cell
;   rows_size - in the array
;
; Input cannot use AX or DX registers
;----------------------------------------------------------
%MACRO	getCellAddress2dArrayBytes	5-*
%DEFINE	%%reg	%1
%DEFINE	%%address	%2
%DEFINE	%%row	%3
%DEFINE	%%col	%4
%DEFINE	%%num_cols	%5
  push dx
  mov ax, %%num_cols
  mov dx, %%row
  mul dx
  add ax, %%col
  add ax, %%address
  mov %%reg, ax
  pop dx
%ENDMACRO
;----------------------------------------------------------
; Gets the memory address of the specific (row,col) element
; in the 2d array of WORDS
;----------------------------------------------------------
%MACRO	getCellAddress2dArrayWords	5-*
%DEFINE	%%reg	%1
%DEFINE	%%address	%2
%DEFINE	%%row	%3
%DEFINE	%%col	%4
%DEFINE	%%num_cols	%5
  mov ax, %%num_cols
  mov dx, %%row
  mul dx
  shl ax, 1       ; x2 for words
  add ax, %%col*2
  add ax, %%address
  mov %%reg, ax
%ENDMACRO
;----------------------------------------------------------
; Sets a byte value in the specific (row,col) element in the 
; 2d array
;----------------------------------------------------------
%MACRO	setByteValue2dArray	5-*
%DEFINE	%%value	%1
%DEFINE	%%address	%2
%DEFINE	%%row	%3
%DEFINE	%%col	%4
%DEFINE	%%num_cols	%5
  push si
  getCellAddress2dArrayBytes si, %%address, %%row, %%col, %%num_cols
  mov byte [si], %%value
  pop si
%ENDMACRO
;----------------------------------------------------------
; Sets a word value in the specific (row,col) element in the 
; 2d array
;----------------------------------------------------------
%MACRO	setWordValue2dArray	5-*
%DEFINE	%%value	%1
%DEFINE	%%address	%2
%DEFINE	%%row	%3
%DEFINE	%%col	%4
%DEFINE	%%num_cols	%5
  push si
  getCellAddress2dArrayWords si, %%address, %%row, %%col, %%num_cols
  mov word [si], %%value
  pop si
%ENDMACRO
;----------------------------------------------------------
; Gets a byte value in the specific (row,col) element in the 
; 2d array
;----------------------------------------------------------
%MACRO	getByteValue2dArray	4-*
%DEFINE	%%address	%1
%DEFINE	%%row	%2
%DEFINE	%%col	%3
%DEFINE	%%num_cols	%4
  push si
  getCellAddress2dArrayBytes si, %%address, %%row, %%col, %%num_cols
  mov ax, byte [si]
  pop si
%ENDMACRO
;----------------------------------------------------------
; Gets a word value in the specific (row,col) element in the 
; 2d array
;----------------------------------------------------------
%MACRO	getWordValue2dArray	4-*
%DEFINE	%%address	%1
%DEFINE	%%row	%2
%DEFINE	%%col	%3
%DEFINE	%%num_cols	%4
  push si
  getCellAddress2dArrayWords si, %%address, %%row, %%col, %%num_cols
  mov ax, word [si]
  pop si
%ENDMACRO