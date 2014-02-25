0 [if]
-------------------------------------------------------------------------
   picoforth 8bit library
     
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

:pic-inline cinvert asm
  comf indf, f
endasm ;     
:pc cinvert invert ;

:pic-inline c1+ asm
  incf  indf, f
endasm ;
:pc c1+ 1+ ;

:pic-inline c1- asm
  decf  indf,f
endasm ;
:pc c1- 1- ;

:pic-inline cnegate 
  cinvert
  c1+
;  
:pc cnegate negate ;

:pic-inline c+ asm
	pop
	addwf	indf, f
endasm ;
:pc c+ + ;

:pic-inline c- asm
	pop
	subwf	indf, f
endasm ;
:pc c- - ;

:pic-inline ccy? asm
  clrf  indf
  btfsc STATUS, C                       
  decf  indf, f
endasm ;                
                  
:pic-inline ccy-not? asm
  clrf  indf
  btfss STATUS, C                       
  decf  indf, f
endasm ;                
                  
:pic ccy-nz? asm
  movlw 255
  movwf indf
  btfsc STATUS, Z
  clrf  indf
  btfss STATUS, C                       
  clrf  indf
endasm ;                
                  
:pic ccy-nz-not? asm
  movlw 0
  btfsc STATUS, Z
  movlw 255
  btfss STATUS, C                       
  movlw 255
  movwf indf
endasm ;                


:pic-inline c0= asm
  movf  indf, w
  btfss STATUS, Z
  movlw 1
  addlw -1
  movwf indf
endasm ;
:pc c0= 0= ;

:pic-inline c0<> asm
  movf  indf, w
  btfss STATUS, Z
  movlw -1
  movwf indf
endasm ;
:pc c0<> 0<> ;

:pic-inline c0< asm
  movlw -1
  btfss indf, 7
  movlw 0
  movwf indf
endasm ;
:pc c0< 0< ;

:pic-inline c0> asm
  movlw -1
  btfsc indf, 7
  movlw 0
  movf  indf, f
  btfsc STATUS, Z
  movlw 0
  movwf indf
endasm ;
:pc c0> 0> ;

:pic-inline c0<= asm
  movlw 0
  btfsc indf, 7
  movlw -1
  movf  indf, f
  btfsc STATUS, Z
  movlw -1
  movwf indf
endasm ; 
:pc c0<= 0<= ;
      
:pic-inline c0>= asm
  movlw 0
  btfss indf, 7
  movlw -1
  movwf indf
endasm ; 
:pc c0>= 0>= ;
      
:pic-inline c= c- c0= ;
:pc c= = ;
           
:pic-inline c<> c- c0<> ;
:pc c<> <> ;
           
:pic-inline c> c- c0> ;
:pc c> > ;
           
:pic-inline c>= c- c0>= ;
:pc c>= >= ;
           
:pic-inline c< c- c0< ;
:pc c< < ;
           
:pic-inline c<= c- c0<= ;
:pc c<= <= ;
           
:pic-inline uc>= c- ccy? ;
:pc uc>= u>= ;

:pic-inline uc<  c- ccy-not? ;
:pc uc< u< ;

:pic-inline uc>  c- ccy-nz? ;
:pc uc> u> ;

:pic-inline uc<= c- ccy-nz-not? ;
:pc uc<= u<= ; 
           

:pic-inline c2* asm
	movf	indf, w
	addwf	indf, f
endasm ;
:pc c2* 2* ;

:pic-inline c2/ asm
	rlf	indf, w
	rrf	indf, f
endasm ;
:pc c2/ 2/ ; 

:pic-inline cdrop asm
	decf	fsr, f
endasm ;
:pc cdrop drop ;

:pic-inline cnip asm
	pop
	movwf	indf
endasm ;
:pc cnip nip ;
	
:pic-inline cdup asm
	movf	indf, w
	push
endasm ;
:pc cdup dup ;

:pic cswap asm
	movf	indf, w
	decf	fsr, f
	xorwf	indf, w
	xorwf	indf, f
	incf	fsr, f
	xorwf	indf, f
endasm ;
:pc cswap swap ;

:pic-inline cover asm
	decf	fsr, f
	movf	indf, w
	incf	fsr, f
	push
endasm ;
:pc cover over ;

:pic-inline ctuck
	cswap
	cover
;
:pc ctuck tuck ;		

                     
:pic crot asm
  movff fsr, spsave
  decf  fsr, f
  decf  fsr, f
  movff indf, tmp1
  incf  fsr, f
  movf  indf, w
  decf  fsr, f
  movwf indf
  incf  fsr, f
  incf  fsr, f
  movf  indf, w
  decf  fsr, f
  movwf indf
  incf  fsr, f
  movff tmp1, indf
  clrf  spsave
endasm ;  
:pc crot rot ;
      
:pic c-rot asm
  movff fsr, spsave
  movff indf, tmp1
  decf  fsr, f
  movf  indf, w
  incf  fsr, f
  movwf indf
  decf  fsr, f
  decf  fsr, f
  swapff  tmp1, indf
  incf  fsr, f
  movff tmp1, indf
  incf  fsr, f
  clrf  spsave
endasm ;
:pc c-rot -rot ;
                         
:pic cpick asm                     
  movff fsr, spsave
  pop
  subwf fsr, f
  movff indf, tmp1
  movff spsave, fsr
  movff tmp1, indf
  clrf  spsave
endasm ;
:pc cpick pick ;

:pic croll asm
  incf  indf, w
  decf  fsr, f
  movwf tmp2
  movff fsr, spsave
croll_l1
  swapff  indf, tmp1
  decf  fsr, f
  decfsz  tmp2, f
  goto  croll_l1
  movff spsave, fsr
  movff tmp1, indf    
  clrf  spsave
endasm ;
:pc croll roll ;

:pic c-roll asm
  incf  indf, w
  decf  fsr, f
  movwf tmp2
  movff fsr, spsave
  movff indf, tmp1
  movf  tmp2, w
  subwf fsr, f
cmroll_l1
  incf  fsr, f
  swapff  indf, tmp1
  decfsz  tmp2, f
  goto  cmroll_l1
  clrf  spsave
endasm ;
:pc c-roll -roll ;

:pic cabs asm
  btfss indf, 7
  return
endasm  
  cnegate
;     
:pc cabs abs ;

:pic cmin asm
  pop
  subwf indf, w
  btfsc indf, 7
  return
  incf  fsr, f
  pop
  movwf indf
endasm ;  
:pc cmin min ;
                
:pic cmax asm
  pop
  subwf indf, w
  btfss indf, 7
  return
  incf  fsr, f
  pop
  movwf indf
endasm ;  
:pc cmax max ;

:pic ucmin asm
  pop
  subwf indf, w
  btfss STATUS, C
  return
  incf  fsr, f
  pop
  movwf indf
endasm ;  
:pc ucmin min ;
                
:pic ucmax asm
  pop
  subwf indf, w
  btfsc STATUS, C
  return
  incf  fsr, f
  pop
  movwf indf
endasm ;  
:pc ucmax max ;

                
:pic uc*w asm
  clrf  tmp1
  clrf  tmp2
  movlw 8
  movwf tmp3
  pop
uc_starw_l1  
  bcf STATUS, C
  rlf tmp1, f
  rlf tmp2, f
  btfsc indf, 7
  addwf tmp1, f
  btfsc STATUS, C
  incf  tmp2, f
  rlf indf, f
  decfsz  tmp3, f
  goto  uc_starw_l1
  movff tmp1, indf
  movf  tmp2, w
  push
endasm ;
:pc uc*w * ;                

       
:pic c* asm
  clrf  tmp1
  movlw 8
  movwf tmp3
  pop
c_star_l1  
  bcf STATUS, C
  rlf tmp1, f
  btfsc indf, 7
  addwf tmp1, f
  rlf indf, f
  decfsz  tmp3, f
  goto  c_star_l1
  movff tmp1, indf
endasm ;
:pc c* * ;                

  
:pic uc/   ( a b -- a/b; mod in tmp2)
asm
  movlw 8
  movwf tmp3
  movff indf, tmp1
  clrf  tmp2
  decf  fsr, f
uc_div_mod_loop1
  rlf indf, f
  rlf tmp2, f
  movf  tmp1, w
  subwf tmp2, w
  btfsc STATUS, C
  movwf tmp2
  decfsz  tmp3, f
  goto  uc_div_mod_loop1
  rlf indf, f
endasm ;         
:pc uc/ / ;       

:pic uc/-restore-mod
asm
  movf  indf, w
  incf  fsr, f
  movwf indf
  decf  fsr, f
  movff tmp2, indf
  incf  fsr, f
endasm ;                
           
:pic-inline uc/mod ( a b -- mod a/b )
  uc/
  uc/-restore-mod
;
:pc uc/mod /mod ;

:pic-inline ucmod ( a b -- mod )
  uc/
asm
  movff tmp2, indf
endasm ;                
:pc ucmod mod ; 
 
           
:pic-inline cand asm
	pop
	andwf	indf, f
endasm ;
:pc cand and ;
                
:pic-inline cor asm
	pop
	iorwf	indf, f
endasm ;
:pc cor or ;

:pic-inline cxor asm
	pop
	xorwf	indf, f
endasm ;
:pc cxor xor ;	

:pic c>r asm
	movff	indf, tmp1	; 2
	decf	fsr, w		; 1
	movwf	spsave		; 1
	decf	rsp, f	 	; 1
	movff	rsp, fsr	; 2
	movff	tmp1, indf	; 2 
	movff	spsave, fsr	; 2 = 11
  clrf  spsave
endasm ;
:pc c>r >r ;

:pic cr@ asm
	movff	fsr, spsave	; 2
	movff	rsp, fsr	; 2
	movff	indf, tmp1	; 2
	incf	spsave, w		; 1
	movwf	fsr		; 1
  clrf  spsave
	movff	tmp1, indf	; 2 = 10
endasm ;
:pc cr@ r@ ;

:pic-inline crdrop asm
  __RSP_DROP  1
endasm ;
:pc crdrop rdrop ;
            
:pic-inline cr>
  cr@             
	crdrop
;
:pc cr> r> ;
 
    

:pic-inline >byte asm
  word_to_byte
endasm ;  
:pc >byte ;

:pic-inline byte>word asm 
  byte_to_word
endasm ;
:pc byte>word ;  

:pic-inline char>word asm 
  char_to_word
endasm ;
:pc char>word ;  
 