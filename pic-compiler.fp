0 [if]
-------------------------------------------------------------------------

   PicoForth - pic compiler for PIC12 and PIC16 families
  
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

require cstring.fp
require lib/kernel.fp
decimal

[undefined] outfile-execute [if]
    : outfile-execute ( ... xt file-id -- ... )
        \ unsafe replacement
        outfile-id >r to outfile-id execute r> to outfile-id ;
[then]

[undefined] infile-execute [if]
    : infile-execute ( ... xt file-id -- ... )
        \ unsafe replacement
        infile-id >r to infile-id execute r> to infile-id ;
[then]

variable -roll-rotates                         
: -roll ( x0 x1 .. xn n -- xn x0 x1 ... xn-1 )
  dup -roll-rotates !
  0 
  ?do
    -roll-rotates @
    roll
  loop
;


\ ------------------------------
\    pic compiler
\ ------------------------------
                 
get-current
get-order                             
also root definitions
vocabulary picc
vocabulary pic-target
vocabulary pic-construct
vocabulary pic-pc
vocabulary pic-defines
set-order
set-current

also picc definitions

: ivariable create , ;
: inc dup @ 1+ swap ! ;
: dec dup @ 1- swap ! ;

: << ( u-value u-shifts -- u-shifted )
  0 ?do 2* loop  
;

: >> ( u-value u-shifts -- u-shifted )
  0 ?do 2/ loop  
;


                 
256 cstring mkvar$

: s$-create ( s$-name u -- )
    also forth
    c" create " mkvar$ c$!
    mkvar$ s$+
\    ." evaluating " mkvar$ c$type cr
    mkvar$ count evaluate
    previous
;

: c$-create count s$-create ;
                            

: pic-target-check ( c$-name -- index ) 
\ ." ; checking "dup c$type cr
  >r
  get-current
  get-order
  pic-target definitions
  seal
  r>
  find \ only in pic-target
  0= if 
    drop 0
  else
    execute @ 
  endif
  >r
  set-order
  set-current
  r>
;

: pic-target-set ( calling-style, index, c$-name --  ) 
  -rot swap
  1000000 * +
  swap
  2>r
  get-current
  get-order
  pic-target definitions
  seal
  2r> 
  find \ only in pic-target
  drop
  execute ! 
  set-order
  set-current
;
                     
: pic-target-register ( calling-style, c$-name -- ) 
  2>r
  get-current
  get-order
  pic-target definitions
  seal
  2r>
  dup pic-target-check
  ?dup 0= if
    dup c$-create
    1 ,
    0
  endif
  1+
  swap
  pic-target-set
  set-order
  set-current
;                 


: pic-get-calling-style ( index -- raw index, style )
  1000000 /mod
;

: .d-without-space ( n -- )
 base @ swap decimal 
 s>d swap over dabs            \ leaves sign byte followed by unsigned double
 <<# #s rot sign #> type #>>
 base !
;

: .d .d-without-space space ;

: tab 9 emit ;


256 cstring lbl

: between ( x min max -- f )
  2 pick >=
  -rot
  >= and
;

: toLower ( char -- char )
  dup [char] A [char] Z between
  if [ char a char A - ] literal + endif
;

: isAllowed ( char -- f )
  false
  over [char] a [char] z between or
  over [char] 0 [char] 9 between or
  over [char] _ = or
  nip
;

: wl-convert ( buffer-ptr char -- buffer-ptr )
  base @ -rot hex
  tolower
  over -rot
  dup isAllowed  
  if 
    swap c! 1+
  else  
    0              \ convert to unsigned double
    <<#            \ start conversion
    [char] _ hold
    #s             \ convert all digits
    [char] _ hold
    #>             \ complete conversion
    dup             ( buffer-begin buffer-ptr buffer-ptr string-addr string-len string-len )
    2swap swap rot  ( buffer-begin buffer-ptr string-len string-addr buffer-ptr string-len)
    move
    +
    #>>            \ release hold area
  endif
  swap base !
;

: word>label ( word-addr buffer-begin -- )
  dup 1+ dup s" _WORD_" ( word-addr buffer-begin buffer-ptr buffer-ptr str-addr str-len )
  -rot swap 2 pick move +
  rot count ( buffer-begin buffer-ptr word-addr+1 word-len )
  over + swap
  ?do
    i c@            ( buffer-begin buffer-ptr char )
    wl-convert
  loop
  over - 1- swap c!
;

   
0 constant compile-pc
1 constant compile-combined

0 ivariable compile-style
false ivariable pic-compiling
false ivariable pic-compile-abort
false ivariable pc-compiling

16 ivariable width

0 ivariable pic-asm-file
s" /dev/null" w/o open-file throw ivariable nullfile
 
: compile-to ( s-string -- )
 pic-asm-file @ ?dup if close-file throw endif
 2dup delete-file drop
 w/o create-file throw 
 pic-asm-file !
;



: redir-to-asm-execute ( xt -- )
  pic-asm-file @ outfile-execute
;

: >asm  ( ... xt -- ... )
  pic-compiling @
  if 
    redir-to-asm-execute
  else
    nullfile @ outfile-execute
  endif
;                        

: >pc  ( ... xt -- ... )
  pc-compiling @
  if 
    >name name>comp postpone,
  else
    drop
  endif
;           

: pagesel-current
  s\" \tmypageselw\t$\n" ['] type >asm
;
                        
0 ivariable pic-word-count
256 cstring pic-current-word$     \ label name
256 cstring pic-current-word-idx$
256 cstring pic-current-word-raw$ \ real name
variable pic-current-word-calling-style

1 constant style_call
2 constant style_rcall
3 constant style_interrupt
4 constant style_data

8 constant style_constant_flag
8 constant style_constant8
9 constant style_constant16
10 constant style_constant32

16 constant style_inline_flag                              
16 constant style_macro
17 constant style_define

0 [if]
: make-pic-current-word-idx 
 pic-current-word-idx$ 
 pic-current-word$ over c$!
 c" _" over c$+
 pic-word-count @ pic-get-calling-style drop 
 swap d$+ 
;
[endif]

: make-string-idx ( buffer, label, index -- )
  -rot
  over c$!
  c" _" over c$+
  d$+
;

: pic-word-to-indexed-label ( c-addr-word c-addr-buffer -- )      
  2dup word>label
  swap pic-target-check pic-get-calling-style drop
  over swap
  make-string-idx 
;


: make-pic-current-word-idx 
  pic-current-word-idx$ 
  pic-current-word$ 
  pic-word-count @ pic-get-calling-style drop
  make-string-idx
;
 
require depend.fp             

: .pic-current-word-raw pic-current-word-raw$ c$type ;
: .pic-current-word pic-current-word$ c$type ;
: .pic-current-word-idx pic-current-word-idx$ c$type ;
: .pic-current-word-calling-style pic-current-word-calling-style @ .d-without-space ;
: pic-compile-section ( -- )
  .pic-current-word-idx ." _section" 
;

: pic-compile-header-common  ( -- )
  cr ." ; word " .pic-current-word-raw space .pic-current-word ." (" .pic-current-word-idx ." )" cr cr
;

: pic-compile-header-redirected ( -- )
  pic-compile-header-common
  pic-current-word-calling-style @ style_interrupt <> if
    ." #ifdef " .pic-current-word-idx ." _REQ" cr
  endif  
  tab ." __CREATE_WORD" tab .pic-current-word-calling-style ." , " .pic-current-word-idx cr
;

: pic-compile-header-macro-redirected ( -- )
  pic-compile-header-common
  .pic-current-word-idx tab ." macro" cr
;

: pic-compile-header-define-redirected ( -- )
\  pic-compile-header-common
\  ." #define " .pic-current-word-idx ."  "
;

: pic-compile-header-constant-redirected ( value -- )
  .pic-current-word-idx tab ." equ" tab .d cr
;

256 cstring tmpword

: pic-compile-word-redirected  ( c-addr-word real-name-with-index calling-style -- )
  tab 
  dup style_inline_flag and 0= 
  if
    ." __CALL" tab .d-without-space ." , "
  else
    drop  
  endif  
  c$type tab ." ;" c$type cr
;

: pic-compile-define-redirected ( c-addr-word real-name-with-index calling-style -- )
\  pic-compile-word-redirected
  drop
  also pic-defines
  tab count evaluate z$type tab ." ;" c$type cr
  previous
;

0 [if]
: pic-compile-define-redirected ( c-addr-word real-name-with-index calling-style -- )
  drop
  also pic-defines 
  \ word, real-name-with-index
  count evaluate 
  tab c$type tab ." ;" c$type cr
  previous  
;
[endif]

: pic-compile-constant-redirected  ( c-addr-word real-name-with-index calling-style -- )
  case 
    style_constant8  of 8 endof
    style_constant32 of 32 endof
    16 swap
  endcase
  tab ." __LITERAL" tab .d-without-space ." , " c$type tab ." ;" c$type cr
;

: pic-compile-number-redirected  ( number -- )
  tab ." __LITERAL" tab width @ .d-without-space ." , " .d cr
;

\ :  pic-compile-epilog-undef
\  ." #ifdef "    .pic-current-word cr
\  ." #undefine " .pic-current-word cr
\  ." #endif" cr
\ ;

: pic-compile-epilog-redirected  ( -- )
  tab ." __CLOSE_WORD" tab .pic-current-word-calling-style ." , " .pic-current-word-idx cr
  pic-current-word-calling-style @ style_interrupt <> if
    ." #endif" cr
  endif  
\  pic-compile-epilog-undef
\  ." #define " .pic-current-word tab ." __CALL " .pic-current-word-idx ." , " .pic-current-word-calling-style cr
  cr
;


: pic-compile-epilog-macro-redirected  ( -- )
  tab ." endm" cr
\  pic-compile-epilog-undef
\  ." #define " .pic-current-word space .pic-current-word-idx cr
  cr
;

: pic-compile-epilog-define-redirected  ( -- )
\  cr
;

false ivariable create-is-open  

: create-close-redirected
  ." #endif" cr cr
;
                                            
: create-close
  create-is-open @ if 
    ['] create-close-redirected redir-to-asm-execute
    false create-is-open !
  endif
;  

: pic-compile-header  ( c-addr -- )
  create-close
\  ." ;compiling pic header " dup c$type  .s cr
  dup pic-current-word-raw$ c$! 
  dup pic-current-word$ word>label
\  pic-word-count inc

  pic-target-check pic-get-calling-style drop 1+ pic-word-count !
  make-pic-current-word-idx
  depend-new
  pic-current-word-calling-style @ style_macro =
  if    ['] pic-compile-header-macro-redirected
  else  
    pic-current-word-calling-style @ style_define =
    if  ['] pic-compile-header-define-redirected
    else
      pic-current-word-calling-style @ style_constant_flag and
      if 
        ['] pic-compile-header-constant-redirected
      else
        ['] pic-compile-header-redirected
      endif
    endif  
  endif
  redir-to-asm-execute
;

: pic-current-word-register
  pic-current-word-calling-style @ pic-current-word-raw$ pic-target-register 
  pic-current-word-idx$ depend-close
;                  
     
: pc-constant constant ;

: pic-constant ( value, style -- )
  pic-current-word-calling-style !
  bl word
  pic-compile-header
  pic-current-word-register
;
     
: both-constant ( value, style -- )
  >in @ 2 pick pc-constant >in !
  pic-constant
;

: constant8  style_constant8  both-constant ;
: constant16 style_constant16 both-constant ;
: constant32 style_constant32 both-constant ;

0 ivariable create-mode
      
: pc-create 1 create-mode ! create ;

: pic-create
  2 create-mode !
  style_data pic-current-word-calling-style !
  bl word          
  pic-compile-header
  true create-is-open !
  pic-current-word-register
;  

: both-create 
  >in @ pic-create >in !
  pc-create
  3 create-mode !
; 

: pic,-redirected ( value, bits -- )
  tab ." __DATA" tab .d ." , " .d cr
;

: pcc, c, ;

: picc,                 
  8 ['] pic,-redirected redir-to-asm-execute
;

: both-c, 
  create-mode @ 1 and if
    dup pcc, 
  endif
  create-mode @ 2 and if
    dup picc, 
  endif
  drop  
;  

: pc, , ;

: pic,                 
  16 ['] pic,-redirected redir-to-asm-execute
;

: both-, 
  create-mode @ 1 and if
    dup pc, 
  endif
  create-mode @ 2 and if
    dup pic, 
  endif
  drop  
;


: pic-compile-word  ( c-addr -- )
\  ." ;compiling pic word " dup count type cr
  dup tmpword word>label
  dup pic-target-check pic-get-calling-style swap \ real-name, style, index
  tmpword dup rot make-string-idx  
  tmpword depend-add-name
  tmpword
  swap 
\  ." ;" .s cr
\ c-addr-word real-name-with-index calling-style
  dup style_constant_flag and 
  if
    ['] pic-compile-constant-redirected >asm
  else
    dup style_define =
    if
      ['] pic-compile-define-redirected >asm
    else  
      ['] pic-compile-word-redirected >asm
    endif  
  endif  
;


: (pic-compile)
  bl word dup c@ 1+ tmpword swap move  
  postpone ahead 
  here tmpword count  
  s, 
  >r 
  postpone then 
  r> 
  postpone literal 
  postpone pic-compile-word
; immediate

           
: pic-compile-number  ( value -- )
\  ." ;compiling pic number " dup count type cr
  ['] pic-compile-number-redirected >asm
;

: pic-compile-epilog  ( -- )
\  ." ;compiling pic epilog" cr
  pic-current-word-calling-style @
  case 
    style_macro  of ['] pic-compile-epilog-macro-redirected endof
    style_define of ['] pic-compile-epilog-define-redirected endof
    ['] pic-compile-epilog-redirected swap
  endcase
  redir-to-asm-execute
  pic-current-word-register

;



: :pc 0 compile-style ! true pc-compiling ! : ;


: ; 
  pic-compiling @ 
  if 
\       ." end of pic compiling"
    false pic-compiling ! 
    pic-compile-epilog
  else 
    postpone ; ( ." normal ;" )
  endif 
  false pc-compiling !
; immediate

: [ 
  pic-compiling @ 
  if 
    true pic-compile-abort ! 
  else
    postpone [
  endif  
; immediate
 

: word-safety-check ( c-addr-word-address )
  dup count nip 0= if -1 throw endif
;

: check-for-main ( c-addr-word -- ) \ forces simple call word main and interrupt

  dup  count s" main" str= 
  if 
   style_macro pic-current-word-calling-style ! 
  endif
  swap count s" interrupt" str= 
  if 
   style_interrupt pic-current-word-calling-style ! 
  endif \ main and interrupt must not be inline          
; 
 
: ]pic
  also pic-construct
  0 pic-compile-abort !
  begin
    bl word dup c@
    0= if 
      drop ( ." end of stream" ) refill drop
    else
\      ."   searching " dup c$type
      dup pic-target-check
      if 
        pic-compile-word 
      else
        dup find  
        1 = if
          nip
          execute
        else
          drop
          number?
          -1 = if 
            pic-compile-number
          else
            s" unknown word" exception throw
          endif  
        endif
      endif  
    endif
    
    pic-compiling @ 0=
    pic-compile-abort @ or
  until
  previous
  \ ." end of loop"
;
 
      
: pic-literal ( lit width -- )
  tab ." __LITERAL" tab  .d-without-space ." , " .d-without-space cr
;  
              
: pic-postpone ( c$ -- )
\  drop
\  ." pic postpone " .s ."  " c$type cr
\  ['] c$type >asm
  ['] pic-compile-word >asm
;
 
: pc-literal postpone literal ; immediate
                            
: literal8
  dup 8 ['] pic-literal >asm
  postpone pc-literal
; immediate   

: literal16
  dup 16 ['] pic-literal >asm
  postpone pc-literal
; immediate   

: literal32 
  dup 32 ['] pic-literal >asm
  postpone pc-literal
; immediate   

: literal postpone literal16 ; immediate
       
256 cstring tmppostpone
              
: pc-postpone
  bl word find drop >pc
; immediate
   
: postpone
  >in @
  postpone postpone
  >in !
  bl word 
  dup find nip -1 =
  if 
    tmppostpone c$!
    tmppostpone count postpone cliteral
    postpone pic-postpone
  else
    drop \ dont postpone immediate words like if, literal etc
  endif  
; immediate              
 
: :(pic) 
  2 compile-style !
  true pic-compiling !
  bl word word-safety-check ( ." defining: " dup count type cr ) 
  dup check-for-main
\  ." defining header " .s cr
  pic-compile-header
  ]pic
;

: ] pic-compiling @ if ]pic else ] endif ;
     
: :both
  3 compile-style !
  true pic-compiling !
  true pc-compiling !
  >in @
  bl word word-safety-check
  swap
  >in !
  >r : r>
  dup check-for-main
  pic-compile-header
  ]
;
                  
: asm 
  s" endasm" ['] cat<<$ redir-to-asm-execute \ copy source to asm file up to the word 'endasm'
; immediate

: movlw-asm ( u -- )
  tab ." movlw" tab .d-without-space cr
;

: movlw 
  ['] movlw-asm >asm
;

: nop s\" \tnop\n" ['] type >asm ;
           
: :pic-inline style_macro pic-current-word-calling-style ! :(pic) ;
: :pic-call style_call pic-current-word-calling-style ! :(pic) ;
: :pic-rstack style_rcall pic-current-word-calling-style ! :(pic) ;

defer :pic
' :pic-call is :pic
           

   
\ libraries must be compiled to include file that will be included after the processor's header
\ because in this point we dont know the processor type
\


\ ----------------------------------
\ keywords per header processing
\ ----------------------------------

256 cstring processor$
256 cstring include-req$

: processor-asm
  tab ." PROCESSOR" tab  dup c$type cr cr
  tab ." include " [char] " emit c$type ." .inc" [char] " emit cr
  pic-asm-prolog$ z$type
  tab .\" include \"/tmp/forthlib.inc\"\n"
;
              
: processor 
  bl word 
  dup processor$ c$! 
  dup ['] processor-asm redir-to-asm-execute
  c" require " include-req$ tuck c$!
  tuck c$+
  c" .fp" over c$+
\  dup ." processor evaluating " c$type cr
  count evaluate
  s" inline  LIST x=ON" evaluate
  required-start
  decimal
;

 
: inline
  fetchline
  ['] type redir-to-asm-execute
  ['] cr redir-to-asm-execute
; immediate
      

256 cstring deffsr-buffer
256 cstring deffsr-word
variable deffsr-addr
1024 ivariable var-idx

0 [if]
: deffsr-asm  ( addr c-addr-word-name -- )
  dup c$type tab ." equ" tab swap . cr
  deffsr-buffer over c$!
  c" @"         over c$+
  over lbl word>label
  lbl c$type tab ." macro" cr
  tab ." mov
  ." 
;
[endif]

: compile-to-target
  get-current
  get-order
  also pic-target definitions
;
: restore-vocs
  set-order
  set-current
;

: create-in-target
  compile-to-target
  create
  restore-vocs
;


: deffsr-prolog ( c-addr-word c-addr-suffix c-addr-macro -- c-addr-macro c-addr-word )
  rot dup deffsr-buffer c$!
  rot deffsr-buffer c$+               ( c-addr-macro c-addr-word  )
  deffsr-buffer pic-compile-header
;
 
0 [if]                                         
: deffsr-asm-macro ( addr c-addr-word c-addr-suffix c-addr-macro -- addr c-addr-word)
  deffsr-prolog
  tab swap c$type ." __FSR_" dup c$type cr
  pic-compile-epilog
\  ." takhle by mel vypadat stack: " .s cr
;
[endif]


256 cstring deffsr-create$  

: deffsr-asm-macro ( addr c-addr-word c-addr-suffix c-addr-macro -- addr c-addr-word)
  deffsr-prolog
  get-current >r
  also pic-defines definitions
  
  c" pc-create " deffsr-create$ c$! 
  pic-current-word-idx$ deffsr-create$ c$+
  deffsr-create$ count evaluate
  
  swap c$, 
  c" __FSR_" c$,
  dup c$,
  0 c,
  previous
  r> set-current
  pic-compile-epilog
;


: addr-to-real  
  dup 0 3000 between invert if  @ endif
;

: .varname-or-addr
  dup 1024 >= if 1024 - ." __VAR_" endif .d-without-space                                               
;

0 [if]
: deffsr-asm-macro2 ( addr bit c-addr-word c-addr-suffix c-addr-macro -- addr bit c-addr-word )
  deffsr-prolog
  tab swap c$type 2 pick addr-to-real 
  .varname-or-addr ." , " over .d cr
  pic-compile-epilog
;
[endif]

: deffsr-asm-macro2 ( addr bit c-addr-word c-addr-suffix c-addr-macro -- addr bit c-addr-word)
  deffsr-prolog
  get-current >r
  also pic-defines definitions
  
  c" pc-create " deffsr-create$ c$! 
  pic-current-word-idx$ deffsr-create$ c$+
  deffsr-create$ count evaluate
  
  swap count here swap dup allot move 
  2 pick addr-to-real
  dup 1024 >= 
  if 
    1024 - 
    c" __VAR_" c$,
  endif 
  deffsr-create$ tuck d$! c$,
  c" , " c$,
  over deffsr-create$ tuck d$! c$,
  0 c,
  previous
  r> set-current
  pic-compile-epilog
;

       
: deffsr-asm ( addr width c-addr-word-name -- addr width )
  2>r >r  compile-to-target r> 2r>
  style_define pic-current-word-calling-style !
\  style_macro pic-current-word-calling-style !
  2 pick 1024 >= if
    ." __FSR_" dup c$type ." _section" tab ." udata" cr
    ." __VAR_" 2 pick 1024 - .d cr
    ." __FSR_" dup c$type tab ." res" tab over 8 / .d cr
  else  
    ." __FSR_" dup c$type tab ." equ" tab 2 pick .d cr
  endif
  c" "    c" __LITERAL_LABEL_RAM "      deffsr-asm-macro
  over \ variable width
  case
    8 of  
      c" @"      c\" __FETCH  \t8, 16, "    deffsr-asm-macro
      c" !"      c\" __STORE  \t8, 16, "    deffsr-asm-macro
      c" -c@"    c\" __FETCH  \t8, 8, "     deffsr-asm-macro
      c" -c!"    c\" __STORE  \t8, 8, "     deffsr-asm-macro
      c" +!"     c\" __PLUS_STORE\t8, 16, " deffsr-asm-macro
      c" +c!"    c\" __PLUS_STORE\t8, 8, "  deffsr-asm-macro
      c" -and!"  c\" __AND_STORE\t8, 16, "  deffsr-asm-macro
      c" -cand!" c\" __AND_STORE\t8, 8, "   deffsr-asm-macro
      c" -or!"   c\" __OR_STORE\t8, 16, "   deffsr-asm-macro
      c" -cor!"  c\" __OR_STORE\t8, 8, "    deffsr-asm-macro
      c" -xor!"  c\" __XOR_STORE\t8, 16, "  deffsr-asm-macro
      c" -cxor!" c\" __XOR_STORE\t8, 8, "   deffsr-asm-macro
      c" -inc"   c\" __INC_STORE\t8, "      deffsr-asm-macro
      c" -dec"   c\" __DEC_STORE\t8, "      deffsr-asm-macro
    endof
    16 of
      c" @"      c\" __FETCH  \t16, 16, "    deffsr-asm-macro
      c" !"      c\" __STORE  \t16, 16, "    deffsr-asm-macro
      c" -c@"    c\" __FETCH  \t16, 8, "     deffsr-asm-macro
      c" -c!"    c\" __STORE  \t16, 8, "     deffsr-asm-macro
      c" +!"     c\" __PLUS_STORE\t16, 16, " deffsr-asm-macro
      c" +c!"    c\" __PLUS_STORE\t16, 8, "  deffsr-asm-macro
      c" -and!"  c\" __AND_STORE\t16, 16, "  deffsr-asm-macro
      c" -cand!" c\" __AND_STORE\t16, 8, "   deffsr-asm-macro
      c" -or!"   c\" __OR_STORE\t16, 16, "   deffsr-asm-macro
      c" -cor!"  c\" __OR_STORE\t16, 8, "    deffsr-asm-macro
      c" -xor!"  c\" __XOR_STORE\t16, 16, "  deffsr-asm-macro
      c" -cxor!" c\" __XOR_STORE\t16, 8, "   deffsr-asm-macro
      c" -inc"   c\" __INC_STORE\t16, "      deffsr-asm-macro
      c" -dec"   c\" __DEC_STORE\t16, "      deffsr-asm-macro
    endof
    32 of
      c" @"      c\" __FETCH  \t32, 32, "   deffsr-asm-macro
      c" !"      c\" __STORE  \t32, 32, "   deffsr-asm-macro
      c" -s@"    c\" __FETCH  \t32, 16, "   deffsr-asm-macro
      c" -s!"    c\" __STORE  \t32, 16, "   deffsr-asm-macro
      c" -c@"    c\" __FETCH  \t32, 8, "    deffsr-asm-macro
      c" -c!"    c\" __STORE  \t32, 8, "    deffsr-asm-macro
      c" -and!"  c\" __AND_STORE\t32, 16, " deffsr-asm-macro
      c" -cand!" c\" __AND_STORE\t32, 8, "  deffsr-asm-macro
      c" -or!"   c\" __OR_STORE\t32, 16, "  deffsr-asm-macro
      c" -cor!"  c\" __OR_STORE\t32, 8, "   deffsr-asm-macro
      c" -xor!"  c\" __XOR_STORE\t32, 16, " deffsr-asm-macro
      c" -cxor!" c\" __XOR_STORE\t32, 8, "  deffsr-asm-macro
      c" -inc"   c\" __INC_STORE\t32, "     deffsr-asm-macro
      c" -dec"   c\" __DEC_STORE\t32, "     deffsr-asm-macro
    endof
  endcase  
  drop
  2>r restore-vocs 2r>
;

: defbit-asm ( addr bit c-addr-word-name -- )
  2>r >r  compile-to-target r> 2r>
  style_define pic-current-word-calling-style !
\  style_macro pic-current-word-calling-style !
   
  c" "        c\" __LITERAL_BIT\t16, " deffsr-asm-macro2
  c" -c"      c\" __LITERAL_BIT\t8, "  deffsr-asm-macro2
  c" @"       c\" __FETCH_BIT\t16, "   deffsr-asm-macro2
  c" !"       c\" __STORE_BIT\t16, "   deffsr-asm-macro2
  c" -c@"     c\" __FETCH_BIT\t8, "    deffsr-asm-macro2
  c" -c!"     c\" __STORE_BIT\t8, "    deffsr-asm-macro2
  c" -set"    c\" __SET_BIT\t"         deffsr-asm-macro2
  c" -reset"  c\" __RESET_BIT\t"       deffsr-asm-macro2
  drop
  2>r restore-vocs 2r>
;

: deffsr-func2 ( c-addr-word c-addr-postfix c-addr-command -- )
  swap
  deffsr-buffer 
   c" : "      over c$!
   deffsr-word over c$+
   swap        over c$+
   c"  "       over c$+
   2 pick      over c$+
   c"  "       over c$+
   swap        over c$+
   c"  ;"      over c$+
\  ." evaluating " deffsr-buffer c$type cr
  count evaluate 
  drop
;

: deffsr-func ( c-addr-postfix c-addr-command -- )
  deffsr-word -rot deffsr-func2
;
             
\ defines fsr register in both forth vocabulary and pic.asm
: defvar  ( addr width -- )
  >in @ 
  bl word deffsr-word c$!
  >in !
  over 
  create , \ creates the variable and stores the value
  deffsr-word ['] deffsr-asm redir-to-asm-execute
  c" @"   c" @" deffsr-func
  c" !"   c" !" deffsr-func
  c" -c@" c" @" deffsr-func
  c" -c!" c" !" deffsr-func
  2drop
;  

: def 8 defvar ;
: def16 16 defvar ;
: var var-idx dup inc @ def ;
: var16 var-idx dup inc @ def16 ;       
: var32 var-idx dup inc @ 32 defvar ;

variable defbit-mask
variable defbit-ref
variable defbit-parms

: bit! ( value, addr, mask -- )
  rot 0<> over and -rot ( masked-value, addr, mask -- )
  invert
  over @
  and ( masked-value, addr, masked-orig-value )
  rot or swap !
;

: bit-parms-get ( base-addr -- bit-addr, bit-nr )
  1 cells + @
  $1000 /mod
;
                 
: deffsr-func-ref
  c" [ defbit-ref @ ] literal " -rot deffsr-func2
;  

: deffsr-func-par
  c" [ defbit-parms @ $1000 /mod swap ] literal literal " -rot deffsr-func2
;
                                                                      
\ defines bit variable in both forth and pic        
: defbit ( addr bit -- )
  bl word deffsr-word c$!
  2dup $1000 * swap addr-to-real + defbit-parms !
  deffsr-word ['] defbit-asm redir-to-asm-execute
  1 swap << defbit-mask ! 
  defbit-ref !
  c" "        c" [ defbit-mask @ ] literal" c" " -rot deffsr-func2
  c" -c"      c" [ defbit-mask @ ] literal" c" " -rot deffsr-func2
  c" @"       c" @ [ defbit-mask @ ] literal and" deffsr-func-ref
  c" -c@"     c" @ [ defbit-mask @ ] literal and" deffsr-func-ref
  c" !"       c" [ defbit-mask @ ] literal bit!" deffsr-func-ref 
  c" -c!"     c" [ defbit-mask @ ] literal bit!" deffsr-func-ref 
  c" -set"    c" true swap [ defbit-mask @ ] literal bit!" deffsr-func-ref
  c" -reset"  c" false swap [ defbit-mask @ ] literal bit!" deffsr-func-ref 

\ fixme - compile for pc
  c" -if"        c"  0 [ ' pic-if-bit ] literal >asm" deffsr-func-par immediate
  c" -0-if"      c"  1 [ ' pic-if-bit ] literal >asm" deffsr-func-par immediate
  c" -while"     c"  0 [ ' pic-while-bit ] literal >asm" deffsr-func-par immediate
  c" -0-while"   c"  1 [ ' pic-while-bit ] literal >asm" deffsr-func-par immediate
  c" -until"     c"  0 [ ' pic-until-bit ] literal >asm" deffsr-func-par immediate
  c" -0-until"   c"  1 [ ' pic-until-bit ] literal >asm" deffsr-func-par immediate
;

: pic-compile-end-redirected
  pic-asm-epilog$ z$type
;

: end 
  create-close
  ['] pic-compile-end-redirected redir-to-asm-execute
  s" /tmp/depends.inc" compile-to
\  depend-main
  depend-required
  bye 
;

: ]l8 postpone literal8 ] ;
: ]l16 postpone literal16 ] ;
: ]l32 postpone literal32 ] ;
: ]l postpone literal ] ;

s" /tmp/forthlib.inc" compile-to
    
  
require lib/char.fp    
require lib/rstack.fp            
require conditional.fp  \ requires some char-aritmetic

$80 7 defbit indf.7     \ addreses $80 and $83 is tested to NOT change bank (and not corrupt rp0 and rp1)
$83 0 defbit carry
$83 6 defbit rp1
$83 5 defbit rp0

get-current                              
also pic-construct definitions

: constant constant16 ;
: create both-create ;
: , both-, ;
: c, both-c, ;

set-current
previous

require lib/int.fp   
require lib/various.fp
require lib/memory.fp

s" /tmp/pic.asm" compile-to



also pic-pc definitions   
also pic-construct

                         
