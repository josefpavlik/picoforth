0 [if]
-------------------------------------------------------------------------
   string manipulation words 
     
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

\ c-string is pascal like string - s[0]=length, s[1...] is content
\ s-string is string represented by addr and length in 2 cells of stack - result of s" xxx"
\ z-string is c like string (null terminated)

                           
\  create empty c-string, allocate given length
: cstring  ( len )
  create 0 c, allot 
does> 
; 

\ initialized c-string, allocates only needed length
\ example s" my string content" icstring mystring    

: icstring ( addr len ) 
  create dup c, 
  tuck
  here swap ( len addr here len )
  move
  allot
does>
; 

\ compile s$
: s$, here swap dup allot move ;

\ compile c$
: c$, count s$, ;
 
\ copy c-string to c-string
: c$! ( c-addr string-addr -- )
  over c@ 1+ move 
;

\ copy s-string to c-string
: s$! ( c-addr u  string-addr -- )
 2dup c!
 1+ swap move
;

\ type c-string                      
: c$type count type ;


\ append c-string to c-string
: c$+ ( tail-addr string-addr -- )
  dup count + ( tail-addr string-addr end-of-orig-string )
  2 pick count -rot swap rot move \ copy the tail to the string
  swap count nip ( string-addr tail-len )
  swap count rot +
  swap 1- c!
;
        
\ append s-string to c-string
: s$+ ( tail-addr tail-len string-addr )
  dup count + ( tail-addr tail-len string-addr end-of-orig-string )
  3 roll swap 3 pick ( tail-len string-addr tail-addr end-of-orig-string  tail-len )
  move ( tail-len string-addr )
  swap over c@ + swap c!
;  

\ store decimal number to cstring      
: d$! ( number string-addr -- )
 base @ >r >r 
 decimal 
 s>d swap over dabs            \ leaves sign byte followed by unsigned double
 <<# #s rot sign #> r> s$! #>>
 r> base !
;

\ append decimal number to cstring      
: d$+ ( number string-addr -- )
 base @ >r >r
 decimal 
 s>d swap over dabs            \ leaves sign byte followed by unsigned double
 <<# #s rot sign #> r> s$+ #>>
 r> base !
;

\ store hex number to cstring      
: h$! ( number string-addr -- )
 base @ >r >r
 hex 
 s>d swap over dabs            \ leaves sign byte followed by unsigned double
 <<# #s rot sign #> r> s$! #>>
 r> base !
;

\ append hex number to cstring      
: h$+ ( number string-addr -- )
 base @ >r >r
 hex
 s>d swap over dabs            \ leaves sign byte followed by unsigned double
 <<# #s rot sign #> r> s$+ #>>
 r> base !
;



              
              
\ gets 1 word from input stream delimited by char, result as s-string

: fetch  ( char -- c-addr u )
  begin
    dup parse 
    dup 0=
  while 
    2drop
    refill drop
  repeat
\    2dup ." got " type cr
  rot drop
;


\ returns s-string                
: fetchline 10 parse ;


256 cstring cat-end$ 

\ copy all until delimiting word from input stream to stdout   
: cat<<$  ( c-addr u -- )
  cat-end$ s$!
  begin
    fetchline 2dup cat-end$ count string-prefix? 0=
  while 
    type cr
    refill drop
  repeat
\  refill drop
  2drop
  cat-end$ count nip >in !
;

\ compile all until delimiting word, skips the rest of line
: compile<<  ( "delimiting word" -- )
  bl word count
  cat-end$ s$!
  refill drop
  begin
    fetchline 2dup cat-end$ count string-prefix? 0=
  while 
    ( line-addr len )
    tuck
    here swap move
    allot
    10 c,
    refill drop
  repeat
\  refill drop
  2drop
  cat-end$ count nip >in !
;

\ copy from input stream to stdout like bash's cat << EOF .... EOF
: cat<<
  bl word count
  cat<<$
;

\ creates multiline z-string ignoring rest of the first line
\ example:
\ multiline-z$ mystring EOF
\ first line of z$
\ second line
\ EOF
                                   
: multiline-z$ create compile<< 0 c, ;


\ convert z$ to s$
: z$count ( c-addr -- c-addr u )
  dup dup
  begin
    dup c@
  while
    1+
  repeat
  swap -
;

\ types z$
: z$type ( c-addr )
  z$count type
;  
 

256 cstring tmpc\"                                  
: c\" \"-parse tmpc\" s$! tmpc\" count postpone cliteral ; immediate

      
 
