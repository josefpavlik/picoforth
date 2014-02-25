0 [if]
-------------------------------------------------------------------------
   picoforth r-stack manipulation library
   
   r-stack grows from high to low address
   16bit words are stored in big-endian format (intel like)
     
   Written By -  Josef Pavlik <josef@pavlik.it>  (2010)

   This library is free software; you can redistribute it and/or
   modify it under the terms of the GNU Library General Public
   License as published by the Free Software Foundation; either
   version 2 of the License, or (at your option) any later version.

   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   Library General Public License for more details.

   http://www.opensource.org/licenses/lgpl-license.html

   In other words, you are welcome to use, share and improve this program.
   You are forbidden to forbid anyone else to use, share and improve
   what you give them.   Help stamp out software-hoarding!
-------------------------------------------------------------------------
[endif]


:pic >r asm
	movff	indf, tmp2 
	decf	fsr, f		
	movff	indf, tmp1 
	decf	fsr, w		
	movwf	spsave		
	decf	rsp, f	 	
	movff	rsp, fsr	
	movff	tmp2, indf 
	decf	fsr, f		
	decf	rsp, f		
	movff	tmp1, indf 
	movff	spsave, fsr
  clrf  spsave
endasm ;

\ DONT CALL IT DIRECTLY!!!, call with __R_AT offset
:pic r_at asm

__R_AT  macro offset
	movff	fsr, spsave	
	movff	rsp, fsr
  if  offset
    movlw offset
    addwf fsr, f
  endif
  __CALL 1,_WORD_r_at_1
  endm
  
	movff	indf, tmp1
	incf	fsr, f		
	movff	indf, tmp2
	incf	spsave, w	
	movwf	fsr		; 1
  clrf  spsave
	movff	tmp1, indf
	incf	fsr, f		
	movff	tmp2, indf
endasm ; 

:pic-inline rsp-drop-2 asm
  __RSP_DROP 2
endasm 
;  
:pc rsp-drop-2 ;

:pic-inline r@ asm
  __R_AT  0
endasm 
 requires-word r_at
;

:pic-inline r-4@ asm
  __R_AT  4
endasm 
 requires-word r_at
;
:pc r-4@ ;

:pic-inline r-8@ asm
  __R_AT  8
endasm 
 requires-word r_at
;
:pc r-8@ ;
                                  
:pic-inline r> 
  r@
  rsp-drop-2
;      
     
:pic r-add asm
  movff fsr, spsave
	movff	indf, tmp2
	decf	fsr, f
	movff	indf, tmp1
  movff rsp, fsr
  movf  tmp1, w
  addwf indf, f
  incf  fsr, f
  btfsc STATUS, C
  incf  indf, f
  movf  tmp2, w
  addwf indf, f
  movff spsave, fsr
  clrf  spsave
endasm ;
:pc r-add r> + >r ;

:pic r-inc asm
  movff fsr, spsave
  movff rsp, fsr
  incfsz  indf, f
  goto  r_inc_l1
  incf  fsr, f
  incf  indf, f
r_inc_l1  
  movff spsave, fsr
  clrf  spsave
endasm ;
:pc r-inc r> 1+ >r ;
 

