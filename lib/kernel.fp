0 [if]
-------------------------------------------------------------------------
   picoforth kernel
     
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

multiline-z$ pic-asm-prolog$ EOF
  include "/tmp/depends.inc"
  radix dec
fsr equ 4
indf  equ 0          

STYLE_CALL    equ   1
STYLE_RCALL   equ   2
STYLE_INTERRUPT equ 3
STYLE_DATA    equ   4

STYLE_MACRO   equ   16
STYLE_DEFINE  equ   17

#define IBANK2  ; fixme
          
cnt set 0
inc_cnt macro
cnt set cnt+1
  endm
  
; fixme - make test if this is neccessary      
mypageselw  macro lbl
  movlw high  lbl
  movwf PCLATH
  endm
                    
; some usesfull macro

drop macro
	decf	fsr, f
	endm
  
pop	macro
	movf	indf, w
	drop
	endm	

push	macro
	incf	fsr, f
	movwf	indf
	endm

push0 macro
	incf  fsr, f
	clrf  indf
	endm  

pushreg macro reg
  movf  reg, w
  push
  endm
  
popreg  macro reg
  pop
  movwf reg
  endm    
  

swapff	macro	A, B    ; 4 cycles
	movf	B, w
	xorwf	A, w	; w = A xor B
	xorwf	A, f
	xorwf	B, f
	endm

movff	macro 	A, B
	movf	A, w
	movwf	B
	endm


; variables

piccvars  udata_shr

rsp     res 1 
spsave  res 1           
tmp1    res 1
tmp2    res 1
tmp3    res 1
  

interrupt_data  udata_shr
intw      res 1
intstatus res 1
intsp     res 1


      
__PUSHBYTE  macro number
    if number==0
      push0
    else
		  movlw	number
		  push
    endif  
  endm

__PUSHBYTE_LABEL  macro number
    movlw	number
	  push
  endm
  
__LITERAL	macro	stack_width, number	
	if stack_width==8
    __PUSHBYTE low number
	endif
	if stack_width==16
		__PUSHBYTE low  number 
		__PUSHBYTE high number
	endif   
	if stack_width==32
		__PUSHBYTE low number
		__PUSHBYTE (number / 256) & 255
		__PUSHBYTE (number / 65536) & 255
		__PUSHBYTE (number / (256*65536))
	endif   
	endm

__LITERAL_LABEL	macro	stack_width, number	
	if stack_width==8
    __PUSHBYTE_LABEL number
	endif
	if stack_width==16
		__PUSHBYTE_LABEL low  number 
		__PUSHBYTE_LABEL high number
	endif   
	if stack_width==32
		__PUSHBYTE_LABEL low number
		__PUSHBYTE_LABEL high number
		__PUSHBYTE 0
		__PUSHBYTE 0
	endif   
	endm
  
__LITERAL_LABEL_RAM  macro lbl
  __LITERAL_LABEL 16, lbl + H'c000'
  endm  

__LITERAL_LABEL_ROM  macro lbl
  __LITERAL_LABEL 16, lbl
  endm  

;__SET_GOTO  macro
;__GOTO_FLAG set 1
;	endm
  
;__SET_CALL  macro
;__GOTO_FLAG set 0
;	endm
  
;	__SET_CALL  
         
;__GOTO  macro lbl
;__GOTO_FLAG set 1
;	__CALL  lbl
;__GOTO_FLAG set 0  
;	endm


__RETURN macro	
	return
	endm

          
__RETURN_RSTACK macro
  mypageselw __return_rstack
  goto  __return_rstack
  endm
  
__CALL_RSTACK macro lbl
  local retlabel
  mypageselw __call_rstack
  movlw low retlabel
  movwf tmp1
  movlw high retlabel
  call  __call_rstack
  mypageselw lbl
  goto  lbl
retlabel
  endm  
  
__CALL	macro	style, lbl
  if style==STYLE_CALL
    mypageselw lbl
		call  lbl
  endif
  if style==STYLE_DATA
    __LITERAL_LABEL_ROM lbl
  endif
  if style==STYLE_RCALL
    __CALL_RSTACK lbl
	endif    
	endm


                  
__call_rstack_section code

__call_rstack ; w - hi byte of return, tmp1 - low byte of return
  movwf tmp2  
  movff fsr, spsave
  decf  rsp, f
  movff rsp, fsr
  movff tmp2, indf
  decf  fsr, f
  decf  rsp, f
  movff tmp1, indf
  movff spsave, fsr
  clrf  spsave
  return


__return_rstack
  movff fsr, spsave
  movff rsp, fsr  
  movff indf, tmp1
  incf  fsr, f
  movff indf, PCLATH
  incf  rsp, f
  incf  rsp, f
  movff spsave, fsr
  clrf  spsave
  movff tmp1, PCL
       


__CREATE_INTERRUPT  macro
interrupt_section code 4
  movwf intw
  movff STATUS, intstatus
  movff fsr, intsp
  movf  spsave, w
  btfsc STATUS, Z
  incf  fsr, w
  movwf fsr
	bankisel  STACK_BEGIN
  
; save registers to stack
  pushreg PCLATH  
  pushreg spsave
  pushreg tmp1
  pushreg tmp2
  pushreg tmp3
  endm
  
__CLOSE_INTERRUPT macro
  popreg  tmp3
  popreg  tmp2
  popreg  tmp1
  popreg  spsave
  popreg  PCLATH
  movff intsp, fsr
  movff intstatus, STATUS
  swapf intw, f
  swapf intw, w
  retfie
  endm  


__CREATE_WORD_SIMPLE  macro name
name#v(0)_section code
name
  endm

__CREATE_WORD macro style, name
  if style==STYLE_INTERRUPT
    __CREATE_INTERRUPT
  else
    __CREATE_WORD_SIMPLE  name
  endif
  endm
  
    
__CLOSE_WORD  macro style, name
  if style==STYLE_INTERRUPT
    __CLOSE_INTERRUPT
  else
    if style==STYLE_CALL
      __RETURN
    else
      __RETURN_RSTACK
    endif
  endif    
  endm  
                   

__DATA  macro width, value
  if width==8
    retlw value
  endif
  if width==16
    retlw low value
    retlw high value
  endif
  if width==32
    retlw low value
    retlw low (value>>8)
    retlw low (value>>16)
    retlw low (value>>24)
  endif
  endm



                 
; conversions

getsign macro
	movlw 0
	btfsc indf, 7
	movlw 255
	endm
           
byte_to_word macro
	push0
	endm
  
byte_to_double macro
	push0
	push0
	push0
	endm         

char_to_word macro
	getsign
	push
	endm

char_to_double macro
	getsign
	push
	push
	push
	endm
  
uword_to_double macro
	push0
	push0
	endm

word_to_double macro
	getsign
	push
	push
	endm

double_to_word  macro
	drop
	drop
	endm
  
double_to_byte  macro
  movlw -3
  addwf fsr, f
	endm
  
word_to_byte  macro
	drop
	endm  

banksel_if_need macro addr 
  if addr!=STATUS && addr!=h'80' && addr!=h'83'; dont select bank for status register, this corrupts bank bits
    banksel addr
  endif  
  endm
  
       
__FETCH macro var_width, stack_width, lbl
	banksel_if_need lbl
	movf  lbl,w
	push
	if var_width==8
		if stack_width==16
			byte_to_word
		endif
		if stack_width==32
			byte_to_double
		endif  
	endif
	if var_width==16
		if stack_width==16
			movf  lbl+1,w
			push
		endif
		if stack_width==32
			uword_to_double
		endif
	endif
	if var_width==32
		if stack_width==16
			movf  lbl+1,w
			push
		endif
		if stack_width==32    
			movf  lbl+2,w
			push
			movf  lbl+3,w
			push
		endif
	endif    
	endm

__STORE macro var_width, stack_width, lbl
	banksel_if_need lbl
	if var_width==32
		if stack_width==32
			pop
			movwf lbl+3
			pop
			movwf lbl+2
		else
			clrf  lbl+3
			clrf  lbl+2
		endif
		if stack_width>8
			pop
			movwf lbl+1
		else
			clrf  lbl+1
		endif
	endif
	if var_width==16
		if stack_width==32
		  double_to_word
		endif
		if stack_width>8
			pop
			movwf lbl+1
		else
			clrf  lbl+1  
		endif
	endif    
	if var_width==8
		if stack_width==32
      double_to_byte
		endif
		if stack_width==16
			word_to_byte
		endif
	endif              
	pop
	movwf lbl
	endm
       
__PLUS_STORE macro var_width, stack_width, lbl
	banksel_if_need lbl
	if var_width==16
		if stack_width==32
		  double_to_word
		endif
		if stack_width>8
      decf fsr, f
    endif  
    movf  indf, w
    addwf lbl, f
    btfsc STATUS, C
    incf  lbl+1, f
		if stack_width>8
      incf  fsr, f
      pop
      addwf lbl+1, f
    endif
    decf  fsr, f
	endif    
	if var_width==8
		if stack_width==32
      double_to_byte
		endif
		if stack_width==16
			word_to_byte
		endif
    pop
	  addwf lbl, f
	endif              
	endm
       
__INC_STORE macro var_width, lbl
	banksel_if_need lbl
  if var_width==8
    incf  lbl, f
  endif
  if var_width==16
    incf  lbl+1, f
    incfsz  lbl, f
    decf  lbl+1, f
  endif
  if var_width==32  
    local inc_end
    mypageselw  $
    incfsz  lbl, f
    goto  inc_end
    incfsz  lbl+1, f
    goto  inc_end
    incf  lbl+3, f
    incfsz  lbl+2, f
    decf  lbl+3, f
inc_end    
  endif    
  endm    

__DEC_STORE macro var_width, lbl
	banksel_if_need lbl
  if var_width==8
    decf  lbl, f
  endif
  if var_width==16
    movlw -1
    addwf lbl, f
    btfss STATUS, C
    decf  lbl+1, f
  endif
  if var_width==32  
    local dec_end
    mypageselw  $
    movlw -1
    addwf lbl, f
    btfsc STATUS, C
    goto  dec_end
    addwf lbl+1, f
    btfsc STATUS, C
    goto  dec_end
    addwf lbl+2, f
    btfss STATUS, C
    decf  lbl+3, f
dec_end    
  endif    
  endm    


       
__BOOL_STORE macro var_width, stack_width, lbl, oper
	banksel_if_need lbl
	if var_width==32
		if stack_width==32
			pop
			oper  lbl+3, f
			pop
			oper  lbl+2, f
		endif
		if stack_width>8
			pop
			oper  lbl+1, f
		endif
	endif
	if var_width==16
		if stack_width==32
		  double_to_word
		endif
		if stack_width>8
			pop
			oper  lbl+1, f
		endif
	endif    
	if var_width==8
		if stack_width==32
      double_to_byte
		endif
		if stack_width==16
			word_to_byte
		endif
	endif              
	pop
	oper  lbl, f
	endm

__AND_STORE macro var_width, stack_width, lbl
  __BOOL_STORE  var_width, stack_width, lbl, andwf
  endm

__OR_STORE macro var_width, stack_width, lbl
  __BOOL_STORE  var_width, stack_width, lbl, iorwf
  endm
  
__XOR_STORE macro var_width, stack_width, lbl
  __BOOL_STORE  var_width, stack_width, lbl, xorwf
  endm
  

__LITERAL_BIT macro width, addr, bit
  __LITERAL width, 1<<bit
  endm
        
__SET_BIT macro addr, bit
  banksel_if_need addr
  bsf addr+bit/8, bit & 7
  endm
  
__RESET_BIT macro addr, bit
  banksel_if_need addr
  bcf addr+bit/8, bit & 7
  endm
  
__FETCH_BIT macro width, addr, bit
  banksel_if_need addr
  push0
  btfsc addr+bit/8, bit & 7
  decf  indf, f
  if width>8
    movf  indf, w
    incf  fsr, f
    movwf indf
  endif
  if width==32
    incf  fsr, f
    movwf indf
    incf  fsr, f
    movwf indf
  endif  
  endm

__STORE_BIT macro width, addr, bit
  banksel_if_need addr
  movf  indf, w
  if width>8
    decf  fsr, f
    iorwf indf, w
  endif
  if width==32
    decf  fsr, f
    iorwf indf, w
    decf  fsr, f
    iorwf indf, w
  endif
  btfsc STATUS, Z
  bcf addr+bit/8, bit & 7  
  btfss STATUS, Z
  bsf addr+bit/8, bit & 7
  decf  fsr, f
  endm
  
__TEST_BIT macro neg, addr, bit
  banksel_if_need addr
  if neg!=0
    btfsc addr+bit/8, bit & 7
  else  
    btfss addr+bit/8, bit & 7
  endif  
  endm
  
             
             
; returns Z if TOS==0
; false -> Z                         
__TEST  macro stack_width
  pop
  if stack_width>8
    iorwf indf, w
    drop
  endif
  if stack_width==32
    iorwf indf, w
    drop
    iorwf indf, w
    drop
  endif
  iorlw 0
  endm             


  
; returns Z if EQUAL    
; dischards TOS

__TEST_EQ_DROP macro stack_width
  if stack_width==8
    pop
    xorwf indf, w
  endif
  if stack_width==16  
    __CALL  _test_eq_drop16
  endif
  if stack_width==32
    __CALL  _test_eq_drop32
  endif
  endm
            
_test_eq_drop16_section code
_test_eq_drop16
  pop
  decf  fsr, f
  xorwf indf, w
  btfss STATUS, Z
  return
  incf  fsr, f
  pop
  decf  fsr, f
  xorwf indf, w
  incf  fsr, f
  iorlw 0 ; restore Zero flag
  return
      
; fixme - add _test_eq_drop32


__RSP_DROP  macro bytes
  if bytes==1
    incf  rsp, f
  endif  
  if bytes>1
    movlw bytes
    addwf rsp, f  
  endif
  endm

            
            
EOF


multiline-z$ pic-asm-epilog$ EOF

stacks  udata
STACK_BEGIN
			res STACK_LENGTH
RSTACK_BEGIN        
              
                  
main_section	code
init_stacks: 	
  clrf  spsave
	bankisel  STACK_BEGIN
	movlw 	RSTACK_BEGIN
	movwf	rsp
	movlw	STACK_BEGIN-1
	movwf	fsr
	return

start:
mainloop:
	call 	init_stacks
	_WORD_main_1
  goto  mainloop

                   


reset_section code  0
  mypageselw  start
  goto  start

	end
EOF