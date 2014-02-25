0 [if]
-------------------------------------------------------------------------
   picoforth library
     
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

0 ivariable pic-here-counter

: pic-here
  pic-here-counter inc
  pic-here-counter @
  dup ." __HERE_" .d cr
;

: pic-literal-label-ram ( label number )
  tab ." __LITERAL_LABEL_RAM" tab ." __HERE_" .d cr
;

: pic-literal-label-rom ( label number )
  tab ." __LITERAL_LABEL_ROM" tab ." __HERE_" .d cr
;

: pic-literal16 ( number -- )
  tab ." __LITERAL" tab ." 16, " .d cr
;
  
: pic-retlw8 ( u -- )
  tab ." retlw" tab 255 and .d cr
;
      
                                 
: pic-compile-data ( addr, count -- )
  over + swap 
  do
    i c@ pic-retlw8
  loop
;

: pic-c$, ( addr, count -- )
  dup pic-retlw8
  pic-compile-data
;

: pic-cliteral ( addr, count -- , runtime: -- addr )
  pic-ahead 
  pic-here -rot 
  dup pic-retlw8
  pic-compile-data
  pic-endif 
  pic-literal-label-rom
; 

: pic-sliteral ( addr, count -- , runtime: -- addr, count)
  pic-ahead 
  pic-here over 2swap
  pic-compile-data
  pic-endif
  swap
  pic-literal-label-rom
  pic-literal16
;

: pic-zliteral ( addr, count -- , runtime: -- addr)
  pic-ahead 
  pic-here -rot
  pic-compile-data
  0 pic-retlw8
  pic-endif
  pic-literal-label-rom
;

 
     
     
                      
variable parse-char-in            
variable parse-char-len
variable parse-char-ptr

: parse-char-init 
  >in @ parse-char-in ! 
  10 parse
  parse-char-len !
  parse-char-ptr !
;

: parse-char
  parse-char-len @ 0< 
  if
    refill drop
    10 parse 
    parse-char-len !
    parse-char-ptr !
    0 parse-char-in !
  endif
  parse-char-len @ 0=
  parse-char-len dec
  if
    10
  else
    parse-char-ptr @ c@
    parse-char-ptr inc
    parse-char-in inc
  endif
;
    
: parse-char-end
  parse-char-in @ >in !    
;
      
: hex-to-dec
  [char] 0 -
  dup 9 > if [ char A char 9 - 1+ ] literal - endif
  dup 9 > if [ char a char A - ] literal - endif
;
                        
: parse-hex
  parse-char hex-to-dec 16 *
  parse-char hex-to-dec +
;
                               
: prefixed-char
  parse-char
  case
    [char] n of 10 endof  
    [char] t of  9 endof
    [char] r of 13 endof
    [char] e of 27 endof
    [char] x of parse-hex endof
    dup
  endcase  
;       
                   
: z\" 
\  ." z immediate running" cr
  postpone ahead   
  here
  parse-char-init 
  begin
    parse-char
    dup [char] \ = 
    if
      drop
      prefixed-char
      true
    else  
      dup 34 <>
    endif
  while
    c,
  repeat
  drop
  0 c,
  >r
  postpone endif
  r>
  postpone literal
  parse-char-end
; immediate



: z\">asm 
\  ." z immediate running" cr
  pic-ahead   
  pic-here
  parse-char-init 
  begin
    parse-char
    dup [char] \ = 
    if
      drop
      prefixed-char
      true
    else  
      dup 34 <>
    endif
  while
    pic-retlw8
  repeat
  drop
  0 pic-retlw8
  >r
  pic-endif
  r>
  pic-literal-label-rom
  parse-char-end
; 

      
      
      
get-current
also pic-construct definitions
previous


: c" 34 parse ['] pic-cliteral >asm ; immediate

: s" 34 parse ['] pic-sliteral >asm ; immediate

: z" 34 parse ['] pic-zliteral >asm ; immediate

: z\" ['] z\">asm >asm ; immediate

     
set-current

