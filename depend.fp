0 [if]
-------------------------------------------------------------------------
   picoforth dependency resolver
  
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


\ vocabulary depend contains all words of the pic program
\ words are named by label name, every word's name is unique (with sequence number)
\ words are simple array, the first cell contains flag
\ other cells contains links (xt) to words called from current word
\ links points to this vocabulary
\ the list is null terminated
\
\ the array required contains list of all words that are flagged as required.
\ generally all user defined words comes to this list, but every word can be flagged
\ as required or not-required individually
\
\ after all words of program are defined, the word depend-required is called
\ and the tree of dependencies for every required word are walked and list of 
\ required library words is printed


vocabulary depend

1024 cells constant depend-current-len  \ max words in one word's definition
16384 cells constant require-list-len   \ max definitions in program (libs aside)


create depend-current depend-current-len cell+ allot
variable depend-current-ptr
create require-list require-list-len cell+ allot
require-list ivariable require-list-ptr
0 ivariable last-depend-word
false ivariable is-required-all

                            
: require-ptr-inc
  require-list-ptr dup @ cell+ swap !
  require-list-ptr @ require-list - require-list-len >= 
  if s" picoforth: too many 'required' words" exception throw endif

;

: required 
  last-depend-word @  
  if
    last-depend-word @  
    require-list-ptr @ ! 
    require-ptr-inc
  endif
;


: non-required
  require-list-ptr require-list > if require-list-ptr dup @ cell - swap ! endif
;

: required-start true is-required-all ! ;
: required-stop false is-required-all ! ;


: depend-current-inc
  depend-current-ptr dup @ cell+ swap !
;

: depend-current-rewind
  depend-current depend-current-ptr !
;

: depend-current-get
  depend-current-ptr @ @
  depend-current-inc
;
  
: depend-addword ( xt -- )
\  ." ; addword " dup .d cr
  depend-current-ptr @ !
  depend-current-inc
  depend-current-ptr @ depend-current - depend-current-len > 
  if s" picoforth: word too long" exception throw endif
;

: depend-add-name ( c$-name -- )
\  ." ;adding " dup c$type cr
  >r
  get-order
  only depend
  r> find
  if
    depend-addword
  else
    drop
  endif
  set-order
;

256 cstring tmpreqword
: requires-word ( compile: word -- )
  bl word tmpreqword pic-word-to-indexed-label
\ ." forcing required word " tmpreqword c$type cr  
  tmpreqword depend-add-name
; immediate
        
: depend-new  ( -- )
  depend-current-rewind
;

: depend-close  ( c$-word-name -- )
  >r
  0 depend-addword
  depend-current-rewind
  get-current
  also depend definitions
  r> 
\  ." ; closing " dup c$type ."  "
  c$-create
\  here >r
  0 , \ flag 'was printed'
  begin
    depend-current-get
    ?dup
  while
    ,
  repeat
  0 , \ terminator  
\  r> here swap - .d cr
  previous
  set-current
  lastxt last-depend-word ! 
  is-required-all @ if required endif

;

: depend-print ( xt -- )
  >name ?dup 
  if
    name>string
    ." #define " type ." _REQ" cr
  endif
;

: depend-walk-through-xt recursive ( xt -- )
  dup
\  dup >name name>string ." analyzing " type cr
\  ." xt=" dup .d cr
  execute \ got address of flag and list
\  ." addr=" dup .d cr
  dup @ 0= 
  if
    1 over !
    over ['] depend-print redir-to-asm-execute
\    over depend-print
    begin
      cell+
      dup @ ?dup
    while  
      depend-walk-through-xt
    repeat  
  endif
  drop \ ptr
  drop \ xt  
;
                          
: depend-walk-through-word ( c$-name -- )
  >r
  get-order
  only depend
  r> find
  if 
    depend-walk-through-xt
  else
    drop
  endif  
  set-order
;           

\ : depend-main
\   c" _WORD_main_1" depend-walk-through-word
\ ;

: depend-required
  require-list-ptr @ require-list
  ?do
    i @ depend-walk-through-xt
  cell +loop
;  
