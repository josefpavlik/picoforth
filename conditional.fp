0 [if]
-------------------------------------------------------------------------
   picoforth conditionals
  
   Written By -  Josef Pavlik <josef@pavlik.it>  (2010)

   This program is free software; you can redistribute it and/or modify it
   under the terms of the GNU General Public License as published by the
   Free Software Foundation; either version 2, or (at your option) any
   later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   http://www.opensource.org/licenses/gpl-license.html
   http://www.gnu.org/copyleft/gpl.html
   
   In other words, you are welcome to use, share and improve this program.
   You are forbidden to forbid anyone else to use, share and improve
   what you give them.   Help stamp out software-hoarding!
-------------------------------------------------------------------------
[endif]


0 ivariable pic-cond-sequence
create pic-cond-stack 20 cells allot
-1 ivariable pic-cond-sp

: pic-cond-stack-push 
  pic-cond-sp inc
  pic-cond-sequence @ pic-cond-stack pic-cond-sp @ cells + !
;

: pic-cond-current
  pic-cond-sp @ 0< if s" conditional stack underflow" exception throw endif
  pic-cond-stack pic-cond-sp @ cells + 
;

: pic-cond-stack-pop
  pic-cond-sp @ 0< if s" conditional stack underflow" exception throw endif
  pic-cond-sp dec
;

: pic-cond-stack-swap
  pic-cond-stack-pop
  pic-cond-stack-pop
  swap
  pic-cond-stack-push
  pic-cond-stack-push
;

: .pic-cond-label ( -- )
  ." __COND_" pic-cond-current @ 1000000 /mod drop .d-without-space 
;

: pic-cond-has-else ( -- flag )
\ ." has else? " pic-cond-current @ . cr
  pic-cond-current @ 1000000 /
;

: pic-cond-set-else ( -- )
\  ." setting else"  cr
  pic-cond-current dup @ 1000000 + swap !
;  

: .pic-cond-def-label ( c$-postfix -- )
  pic-current-word-calling-style @ style_macro =
  if
    dup
    tab ." local" tab .pic-cond-label c$type cr
  endif
  .pic-cond-label c$type cr
;
     
: pic-if-prep
  pic-cond-sequence inc
  pic-cond-stack-push
  pagesel-current
;

: pic-if-goto-else
  tab ." goto" tab .pic-cond-label ." _else" cr
;
      
: pic-if  ( stack-width -- )
  ." ; IF" cr
  pic-if-prep
  tab ." __TEST" tab .d cr
  tab ." btfsc" tab ." STATUS, Z" cr
  pic-if-goto-else
;  

: pic-if-bit ( addr, bit, not -- )
  pic-if-prep
  tab ." __TEST_BIT" tab .d-without-space ." , " swap .varname-or-addr ." , " .d-without-space cr 
  pic-if-goto-else    
;

: pic-over=if  ( compile: stack-width -- exec: a b -- a )
  pic-if-prep
  tab ." __TEST_EQ_DROP" tab .d cr
  tab ." btfss" tab ." STATUS, Z" cr
  pic-if-goto-else
;  
  
: pic-ahead
  ." ; AHEAD" cr
  pic-if-prep
  pic-if-goto-else
;  

: pic-else
  ." ; ELSE" cr
  pagesel-current
  tab ." goto" tab .pic-cond-label ." _endif" cr
  cr
  c" _else" .pic-cond-def-label
  pic-cond-set-else
;

: pic-endif
  ." ; ENDIF" cr
  pic-cond-has-else 
  if
    c" _endif" .pic-cond-def-label
  else
    c" _else" .pic-cond-def-label
  endif
  pic-cond-stack-pop
;

: pic-endif-with-else
  c" _endif" .pic-cond-def-label
  pic-cond-stack-pop
;

\ -----------------------------
\ case
\ -----------------------------


0 constant pic-case

: pic-of 
  ." ; OF" cr
  1+
  16 pic-over=if 
  (pic-compile) drop
;

: pic-endof 
  ." ; ENDOF" cr
  pic-else
;

: pic-endcase
  ." ; ENDCASE"
  (pic-compile) drop
  0 ?do
    pic-endif-with-else
  loop
;

    

\ ----------------------- 
\ loops 
\ -----------------------
 
0 ivariable pic-loops-sequence
create pic-loops-stack 20 cells allot
-1 ivariable pic-loops-sp
0 ivariable pic-loop-stack-level

: pic-loops-stack-push 
  pic-loops-sp inc
  pic-loops-sequence @ pic-loops-stack pic-loops-sp @ cells + !
;

: pic-loops-current
  pic-loops-stack pic-loops-sp @ cells + @
;

: pic-loops-stack-pop
  pic-loops-sp @ 0< if -1 throw endif
  pic-loops-sp dec
;

: .pic-loops-label ( -- )
  ." __LOOP_" pic-loops-current .d-without-space 
;

: .pic-loops-def-label ( c$-postfix -- )
  pic-current-word-calling-style @ style_macro =
  if
    dup
    tab ." local" tab .pic-loops-label c$type cr
  endif
  .pic-loops-label c$type cr
;

       
: pic-begin
  pic-loops-sequence inc
  pic-loops-stack-push
  c" _begin" .pic-loops-def-label
;

: pic-end
  c" _end" .pic-loops-def-label
  pic-loops-stack-pop
;  

: pic-again
  pagesel-current
  tab ." goto" tab .pic-loops-label ." _begin" tab ." ; again/repeat" cr
  pic-end
;

: pic-while ( stack-width -- )
  pagesel-current
  tab ." __TEST" tab .d-without-space cr
  tab ." btfsc" tab ." STATUS, Z" cr
  tab ." goto" tab .pic-loops-label ." _end" cr
;           

: pic-while-bit ( addr, bit, not -- )
  pagesel-current
  tab ." __TEST_BIT" tab .d-without-space ." , " swap .varname-or-addr ." , " .d cr 
  tab ." goto" tab .pic-loops-label ." _end" cr
;

: pic-repeat pic-again ;

: pic-until ( stack-width -- )
  ." ; until" cr
  pagesel-current
  tab ." __TEST" tab .d-without-space cr
  tab ." btfsc" tab ." STATUS, Z" cr
  tab ." goto" tab .pic-loops-label ." _begin" cr
;

: pic-until-bit ( addr, bit, not -- )
  pagesel-current
  tab ." __TEST_BIT" tab .d-without-space ." , " swap .varname-or-addr ." , " .d cr 
  tab ." goto" tab .pic-loops-label ." _begin" cr
;


( R-limit, R-value -- R-limit, R-value,   CARRY when R-value<R-limit = loop should continue )
:pic pic-do-test-16 asm 
  movff fsr, spsave
  incf  rsp, w
  movwf fsr
  movf  indf, w
  incf  fsr, f
  incf  fsr, f
  subwf indf, w  ; hibyte value-limit
  btfss STATUS, Z
  goto  pic_do_test_16_Z
  movlw -3
  addwf fsr, f
  movf  indf, w
  incf  fsr, f
  incf  fsr, f
  subwf indf, w  ; lowbyte value-limit  
  btfsc STATUS, Z
  bcf   STATUS, C
  goto  pic_do_test_16_end
pic_do_test_16_Z
  addlw 128
  addlw 128       ; not sign flag -> CY  
pic_do_test_16_end
  movff spsave, fsr
  clrf  spsave
endasm ;
: pic-do-test-16 ; \ only for internal
         
: pic-?do
  ." ; ?do" cr
  (pic-compile) swap
  (pic-compile) >r
  (pic-compile) >r
  pic-loop-stack-level dup @ 4 + swap ! \ loop level is in bytes
  pic-begin
  (pic-compile) pic-do-test-16
  pagesel-current
  tab ." btfss STATUS, C" cr
\  tab ." btfsc  INDF, 7" cr
  tab ." goto" tab .pic-loops-label ." _end" cr
;        

: pic-unloop
  tab ." __RSP_DROP" tab pic-loop-stack-level @ .d-without-space   tab ." ; unloop " cr
;
  
: pic-leave
  pagesel-current
  tab ." goto" tab .pic-loops-label ." _end" tab ." ; leave" cr
;
  
: pic-loop2  
  pic-again
  tab ." __RSP_DROP" tab ." 4" cr
  pic-loop-stack-level dup @ 4 - swap !
;                 

: pic-loop
  ." ; loop" cr
  (pic-compile) r-inc
  pic-loop2
;

: pic-+loop
  ." ; +loop" cr
  (pic-compile) r-add
  pic-loop2
;        

:pic-inline i
  r@
;           

:pic-inline j
  r-4@
;

:pic-inline k
  r-8@
;
  





get-current                              
also pic-construct definitions
: : :pc ;

: if
  pc-compiling @ if postpone if endif
  16 ['] pic-if >asm
; immediate

: c-if
  pc-compiling @ if postpone if endif
  8 ['] pic-if >asm
; immediate

: ahead
  pc-compiling @ if postpone ahead endif
  ['] pic-ahead >asm
; immediate
                  
: else
  pc-compiling @ if postpone else endif
  ['] pic-else >asm
; immediate

: endif
  pc-compiling @ if postpone endif endif
  ['] pic-endif >asm
; immediate
               
: then
  postpone endif
; immediate

               
: begin  
  pc-compiling @ if postpone begin endif
  ['] pic-begin >asm
; immediate

: again
  pc-compiling @ if postpone again endif
  ['] pic-again >asm
; immediate

: while
  pc-compiling @ if postpone while endif
  16 ['] pic-while >asm
; immediate

: c-while
  pc-compiling @ if postpone while endif
  8 ['] pic-while >asm
; immediate

: repeat
  pc-compiling @ if postpone repeat endif
  ['] pic-repeat >asm
; immediate

: until
  pc-compiling @ if postpone until endif
  16 ['] pic-until >asm
; immediate

: c-until
  pc-compiling @ if postpone until endif
  8 ['] pic-until >asm
; immediate

: ?do
  pc-compiling @ if postpone ?do endif
\ ." executing pic-?do " cr
  ['] pic-?do >asm
; immediate

: unloop
  pc-compiling @ if postpone unloop endif
  ['] pic-unloop >asm
; immediate

: leave
  pc-compiling @ if postpone leave endif
  ['] pic-leave >asm
; immediate

: loop
  pc-compiling @ if postpone loop endif
  ['] pic-loop >asm
; immediate

: +loop
  pc-compiling @ if postpone +loop endif
  ['] pic-+loop >asm
; immediate

set-current
previous
           

   
