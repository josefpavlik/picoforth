0 [if]
-------------------------------------------------------------------------
  picoforth 16bit library

  integer are stored in big endian (intel like) form
  so least significant byte in lower address
  and most significant byte in higher address
 
  data stack grows from low to high addr, so low byte is pushed first
  return stack grows from high to low, so high byte is pushed first
 
     
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


:pic-inline invert asm
  comf  indf, f
  decf  fsr, f
  comf  indf, f
  incf  fsr, f
endasm ;     

:pic 1+ asm
	incf  indf, w  
  decf  fsr, f
  incfsz  indf, f
  addlw -1  ; revert the initial increment
  push
endasm ;

:pic 1- asm
  decf  fsr, f
  decf  indf, f
  incfsz  indf, w
  goto  one_minus_l1
  incf  fsr, f
  decf  indf, f
  return  
one_minus_l1
  incf  fsr, f  
endasm ;

:pic-inline negate
  invert
  1+
;  

:pic-inline negate-nospsave
  negate
;  

:pic-inline abs 
  indf.7-if negate endif
;

:pic-inline (dinvert)
asm
  comf  indf, f
  decf  fsr, f
  comf  indf, f
  decf  fsr, f
  comf  indf, f
  decf  fsr, f
  comf  indf, f
endasm ;

:pic-inline dinvert-inline asm
  movff fsr, spsave
endasm
  (dinvert)
asm    
  movff spsave, fsr
  clrf  spsave
endasm ;     

:pic dinvert dinvert-inline ;

:pic-inline dinvert-nospsave-inline
  (dinvert)
asm    
  movlw 3
  addwf fsr, f
endasm ;     


:pic-inline (d1+) asm
  movlw -3
  addwf fsr, f
  incfsz  indf, f
  goto  d1plus_end
  incf  fsr, f
  incfsz  indf, f
  goto  d1plus_end
  incf  fsr, f
  incfsz  indf, f
  goto  d1plus_end
  incf  fsr, f
  incf  indf, f
  local d1plus_end
d1plus_end
endasm ;
       
:pic-inline d1+-inline asm
  movff fsr, spsave
endasm  
  (d1+)
asm  
  movff spsave, fsr
  clrf  spsave  
endasm ;

:pic d1+ d1+-inline ;

:pic-inline d1+-nospsave-inline
asm
  movff fsr, tmp3
endasm  
  (d1+)
asm  
  movff tmp3, fsr
endasm ;

           
:pic-inline dnegate
  dinvert
  d1+  
;

:pic-inline dnegate-nospsave-inline
  dinvert-nospsave-inline
  d1+-nospsave-inline
;

:pic-inline dnegate-inline
  dinvert-inline
  d1+-inline
;


:pic-inline d1- 
  dnegate
  dinvert
;
           


:pic + asm
  movff indf, tmp2  ; hi byte
	decf  fsr, f
  pop               ; low byte
  decf  fsr, f
  addwf indf, f
  incf  fsr, f
  btfsc STATUS, C
  incf  indf, f
  movf  tmp2, w
  addwf indf, f
endasm ;

:pic - asm
  movff indf, tmp2  ; hi byte
	decf  fsr, f
  pop               ; low byte
  decf  fsr, f
  subwf indf, f
  incf  fsr, f
  btfss STATUS, C
  decf  indf, f
  movf  tmp2, w
  subwf indf, f
endasm ;

:pic cy? asm
  movlw 255
  btfss STATUS, C                       
  movlw 0
  decf  fsr, f
  movwf indf
  incf  fsr, f
  movwf indf
endasm ;                
                  
:pic cy-not? asm
  movlw 0
  btfss STATUS, C                       
  movlw 255
  decf  fsr, f
  movwf indf
  incf  fsr, f
  movwf indf
endasm ;                
                  
:pic cy-nz? asm
  movlw 255
  btfsc STATUS, Z
  movlw 0
  btfss STATUS, C                       
  movlw 0
  decf  fsr, f
  movwf indf
  incf  fsr, f
  movwf indf
endasm ;                
                  
:pic cy-nz-not? asm
  movlw 0
  btfsc STATUS, Z
  movlw 255
  btfss STATUS, C                       
  movlw 255
  decf  fsr, f
  movwf indf
  incf  fsr, f
  movwf indf
endasm ;                
                  
:pic 0= asm
  movf  indf, w
  decf  fsr, f
  iorwf indf, w
  btfss STATUS, Z
  movlw 1
  addlw -1
  movwf indf
  push
endasm ;

:pic 0<> asm
  movf  indf, w
  decf  fsr, f
  iorwf indf, w
  btfss STATUS, Z
  movlw -1
  movwf indf
  push
endasm ;

:pic (0>)   
asm
  btfss indf, 7
  goto  zero_gt_l1
  decf  fsr, f
  clrf  indf
  incf  fsr, f
  clrf  indf
zero_gt_l1  
endasm ;

:pic-inline 0> (0>) 0<> ;

:pic 0>= asm
  movlw 0
  btfss indf, 7
  movlw -1
  decf  fsr, f
  movwf indf
  incf  fsr, f
  movwf indf
endasm ;

:pic 0< asm
  movlw 0
  btfsc indf, 7
  movlw -1
  decf  fsr, f
  movwf indf
  incf  fsr, f
  movwf indf
endasm ;

:pic-inline 0<= 0> invert ;

:pic-inline =   - 0=  ;
:pic-inline <>  - 0<> ;
:pic-inline >   - 0>  ;
:pic-inline >=  - 0>= ;
:pic-inline <   - 0<  ;
:pic-inline <=  - 0<= ;

:pic-inline u>= - cy? ;
:pic-inline u<  - cy-not? ;
:pic-inline u>  - cy-nz? ;
:pic-inline u<= - cy-nz-not? ;

                  
                  
:pic-inline 2* asm
  decf  fsr, f
	movf	indf, w
	addwf	indf, f
  incf  fsr, f
  rlf indf, f
endasm ;

:pic-inline 2/ asm
	rlf	indf, w
	rrf	indf, f
  decf  fsr, f
  rrf indf, f
  incf  fsr, f
endasm ;

:pic-inline drop asm
	decf	fsr, f
	decf	fsr, f
endasm ;

:pic-inline 2drop asm
  movlw -4
  addwf fsr, f
endasm ;

:pic nip asm
	pop
  decf  fsr, f
	movwf	indf
  incf  fsr, f
  movf  indf, w
  decf  fsr, f
  decf  fsr, f
  movwf indf
  incf  fsr, f
endasm ;
	
:pic dup asm
  decf  fsr, f
	movf	indf, w
  incf  fsr, f
	push
  decf  fsr, f
  movf  indf, w
  incf  fsr, f
  push
endasm ;


:pic swap asm
  pop
  movwf tmp2
  pop
  movwf tmp1
  swapff  indf, tmp2
  movff fsr, spsave
  decf  fsr, f
  swapff  indf, tmp1
  incf  fsr, f
  clrf  spsave
  movf  tmp1, w
  push
  movf  tmp2, w
  push
endasm ;  
                    

:pic over asm
  incf  fsr, w
  movwf spsave
  movlw -3
  addwf fsr, f
  movff indf, tmp1
  incf  fsr, f
  movf  indf, w
  incf  fsr, f
  incf  fsr, f
  incf  fsr, f
  clrf  spsave
  incf  fsr, f
  movwf indf
  decf  fsr, f
  movff tmp1, indf
  incf  fsr, f
endasm ;


:pic-inline tuck
	swap
	over
;

:pic-inline 2dup
  over
  over
;

:pic-inline min
  2dup > if swap endif drop
;  

:pic-inline max
  2dup < if swap endif drop
;  
    
:pic roll asm
  decf  fsr, f  ; ignore high byte of depth
  incf  indf, w
  decf  fsr, f
roll_literal  
  movwf tmp3
  movff fsr, spsave
roll_l1
  swapff  indf, tmp2
  decf  fsr, f
  swapff  indf, tmp1
  decf  fsr, f
  decfsz  tmp3, f
  goto  roll_l1
  decf  spsave, w
  movwf fsr
  clrf  spsave
  movff tmp1, indf
  incf  fsr, f
  movff tmp2, indf
endasm ;

:pic rot asm
  mypageselw  roll_literal
  movlw 3
  goto  roll_literal
endasm
requires-word roll
; 
            
:pic -roll asm
  decf  fsr, f  ; ignore high byte of depth
  incf  indf, w
  decf  fsr, f
mroll_literal  
  movwf tmp3
  movff fsr, spsave
  movff indf, tmp2
  decf  fsr, f
  movff indf, tmp1
  decf  tmp3, w
  addwf tmp3, w
  subwf fsr, f
mroll_l1
  incf  fsr, f
  swapff  indf, tmp1
  incf  fsr, f
  swapff  indf, tmp2
  decfsz  tmp3, f
  goto  mroll_l1
  clrf  spsave
endasm ;
 
:pic -rot asm
  mypageselw  mroll_literal
  movlw 3
  goto  mroll_literal
endasm
requires-word -roll
; 
            

:pic pick asm
  decf  fsr, f  ; ignore high byte of depth
  movff fsr, spsave
  incf  indf, w
  addwf indf, w
  subwf fsr, f
  movff indf, tmp2
  decf  fsr, f
  movff indf, tmp1
  movff spsave, fsr
  clrf  spsave
  movff tmp1, indf
  incf  fsr, f
  movff tmp2, indf
endasm ;

  
:pic and asm
	pop
  decf  fsr, f
	andwf	indf, f
  incf  fsr, f
  pop
  decf  fsr, f
  andwf indf, f
  incf  fsr, f
endasm ;

:pic or asm
	pop
  decf  fsr, f
	iorwf	indf, f
  incf  fsr, f
  pop
  decf  fsr, f
  iorwf indf, f
  incf  fsr, f
endasm ;

:pic xor asm
	pop
  decf  fsr, f
  xorwf	indf, f
  incf  fsr, f
  pop
  decf  fsr, f
  xorwf indf, f
  incf  fsr, f
endasm ;


:pic um* asm
  incf  fsr, w
  movwf spsave
  incf  spsave, f
  incf  spsave, f
  movlw -3
  addwf fsr, f
  movff indf, tmp2
  clrf  indf
  incf  fsr, f
  movff indf, tmp3
  clrf  indf
  incf  fsr, f
  movff indf, tmp1
  clrf  indf
  incf  fsr, f
  movf  indf, w
  clrf  indf
  incf  fsr, f
  incf  fsr, f
  movwf indf
  incf  fsr, f
  movlw 8
  movwf indf
  decf  fsr, f
  decf  fsr, f
  movff tmp1, indf
  clrf  tmp1
  movff spsave, fsr
  
umstar_loop1
  bcf STATUS, C
  rrf tmp3, f
  rrf tmp2, f
  rrf tmp1, f
  
  decf  fsr, f
  btfss indf, 7
  goto  umstar_l1
  
  movlw -4
  addwf fsr, f
  movf  tmp1, w
  addwf indf, f
  incf  fsr, f
  btfsc STATUS, C  
  incf  indf, f
  movf  tmp2, w
  addwf indf, f
  incf  fsr, f
  btfsc STATUS, C
  incf  indf, f
  movf  tmp3, w
  addwf indf, f
  incf  fsr, f    
  incf  fsr, f
umstar_l1
  decf  fsr, f

  btfss indf, 7
  goto  umstar_l2
  
  movlw -4
  addwf fsr, f
  movf  tmp1, w
  addwf indf, f
  incf  fsr, f
  btfsc STATUS, C  
  incf  indf, f
  movf  tmp2, w
  addwf indf, f
  incf  fsr, f
  btfsc STATUS, C
  incf  indf, f
  movf  tmp3, w
  addwf indf, f
  incf  fsr, f    
  btfsc STATUS, C
  incf  indf, f
  incf  fsr, f
umstar_l2

  rlf indf, f
  incf  fsr, f
  rlf indf, f
  incf  fsr, f
  decfsz  indf, f
  goto  umstar_loop1
  movlw -3
  addwf fsr, f
  clrf  spsave
endasm ;


:pic-inline *
  um*
  drop
;  

:pic abs-and-check-sign ( a b -- abs-a abs-b ; rp0=1 if result negative, rp1=1 if mod negative )
asm
  movff fsr, spsave
  movf  indf, w
  decf  fsr, f
  decf  fsr, f
  xorwf indf, w
  movwf tmp3
endasm
  rp1-reset
  indf.7-if negate rp1-set endif
asm
  incf  fsr, f
  incf  fsr, f
  clrf  spsave
endasm
  indf.7-if negate endif  
asm
  bcf STATUS, RP0
  btfsc tmp3, 7
  bsf STATUS, RP0
endasm       
;

:pic m-abs-and-check-sign ( a32 b16 -- abs-a abs-b ; rp0=1 if result negative, rp1=1 if mod negative )
asm
  movff fsr, spsave
  movf  indf, w
  decf  fsr, f
  decf  fsr, f
  xorwf indf, w
  movwf tmp2
endasm
  rp1-reset
  indf.7-if dnegate-nospsave-inline rp1-set endif
asm
  incf  fsr, f
  incf  fsr, f
  clrf  spsave
endasm
  indf.7-if negate endif  
asm
  bcf STATUS, RP0
  btfsc tmp2, 7
  bsf STATUS, RP0
endasm       
;

  

:pic c-abs-and-check-sign \ ( a b -- abs-a abs-b ; rp0=1 if result negative, rp1=sign a (mod negative) )
asm
  bcf STATUS, RP0
  bcf STATUS, RP1
  movf  indf, w
  btfss indf, 7
  goto  c_slash_check1
  comf indf, f
  incf indf, f
c_slash_check1
  decf  fsr, f
  xorwf indf, w
  btfss indf, 7
  goto  c_slash_check2
  bsf STATUS, RP1
  comf indf, f
  incf indf, f
c_slash_check2
  incf  fsr, f
  addlw 128 ; CY when result should be negative
  btfsc STATUS, C
  bsf STATUS, RP0
endasm    
;

    
:pic m*-repare-sign rp0-if dnegate-inline endif ;
    
:pic-inline m*  
  abs-and-check-sign 
  um*
  m*-repare-sign
;    

:pic c/-repare-sign rp0-if cnegate endif ;

:pic-inline c/
  c-abs-and-check-sign
  uc/ 
  c/-repare-sign
;           
:pc c/ / ;

:pic cmod-repare-sign rp1-if cnegate endif ;

:pic-inline cmod
  c-abs-and-check-sign
  ucmod 
  cmod-repare-sign
;
:pc cmod mod ;     

:pic c/mod-repare-signs
  rp0-if cnegate endif
  rp1-if 
asm
  decf fsr, f
endasm    
    cnegate 
asm
  incf fsr, f
endasm
  endif    
;

:pic-inline c/mod
  c-abs-and-check-sign
  uc/mod 
  c/mod-repare-signs
;
:pc c/mod /mod ;



:pic um/mod1 ( a32 b16 --  a/b16 mod16 )
asm
  movff indf, tmp2
  decf  fsr, f
  movff indf, tmp1
  decf  fsr, f
umslash_entry2  
  movff fsr, spsave
  movlw 16
  movwf tmp3
umslash_loop1  
  movlw -3
  addwf fsr, f
umslash_loop2
  bcf STATUS, C
  rlf indf, f
  incf  fsr, f
  rlf indf, f
  incf  fsr, f  
  rlf indf, f
  incf  fsr, f
  rlf indf, f
  btfsc STATUS, C
  goto  umslash_lsub
      
  movf  tmp2, w
  subwf indf, w
  btfss STATUS, C
  goto  umslash_lnosub
  btfss STATUS, Z
  goto  umslash_lsub
  decf  fsr, f
  movf  tmp1, w
  subwf indf, w
  incf  fsr, f
  btfss STATUS, C
  goto  umslash_lnosub
umslash_lsub  
  decf  fsr, f
  movf  tmp1, w
  subwf indf, f
  incf  fsr, f
  btfss STATUS, C
  decf  indf, f
  movf  tmp2, w
  subwf indf, f  

  movlw -3
  addwf fsr, f
  bsf indf, 0
  decfsz  tmp3, f
  goto  umslash_loop2
  movlw 3
  addwf fsr, f
  goto  umslash_end  

umslash_lnosub
  decfsz  tmp3, f
  goto  umslash_loop1
  
umslash_end    
  clrf  spsave
endasm ;

:pic u/mod1 ( a16 b16 --  a/b16 mod16 )
asm
  movff indf, tmp2
  decf  fsr, f
  movff indf, tmp1
  clrf  indf
  incf  fsr, f
  clrf  indf
  mypageselw  umslash_entry2
  goto  umslash_entry2
endasm
requires-word um/mod1
;  


:pic-inline um/mod ( a32 b16 --  mod16 a/b16 )
  um/mod1 swap
;

:pic-inline um/ ( a32 b16 --  a/b16 )
  um/mod1 drop
;

:pic-inline ummod ( a32 b16 --  mod16 )
  um/mod1 nip
;

:pic-inline u/mod ( a16 b16 --  mod16 a/b16 )
  u/mod1 swap
;

:pic-inline u/ ( a16 b16 --  a/b16 )
  u/mod1 drop
;

:pic-inline umod
  u/mod1 nip
;

  
:pic /mod-repare-signs
  rp0-if negate endif
  rp1-if 
asm
  movff fsr, spsave
  decf fsr, f
  decf fsr, f
endasm    
    negate-nospsave
asm
  movff spsave, fsr
  clrf  spsave
endasm
  endif    
;

:pic /-repare-sign
  rp0-if negate endif
;

:pic mod-repare-sign
  rp1-if negate endif
;

:pic-inline m/mod  
  m-abs-and-check-sign 
  um/mod
  /mod-repare-signs
;

:pic-inline m/ 
  m-abs-and-check-sign 
  um/
  /-repare-sign
;
 
:pic-inline mmod
  m-abs-and-check-sign 
  ummod
  mod-repare-sign
;
 
:pic-inline /mod  
  abs-and-check-sign 
  u/mod
  /mod-repare-signs
;

:pic-inline / 
  abs-and-check-sign 
  u/
  /-repare-sign
;
  
:pic-inline mod 
  abs-and-check-sign 
  umod
  mod-repare-sign
;
                

0 [if]  
  movff indf, tmp2
  decf  fsr, f
  movff indf, tmp1
  movlw -2
  addwf fsr, f
  swapff  indf, tmp1
  incf  fsr, f
  swapff  indf, tmp2
  incf  fsr, f
  movff tmp1, indf
  incf  fsr, f
  movff tmp2, indf
  clrf  spsave
endasm ;

[endif]
