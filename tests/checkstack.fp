\ processor p16f883

var errorcode
 
:pic halt begin again ;

:pic show-error ( char-errorcode -- )
  
\ ." ERROR " . cr
\ -1 throw
  
  porta-c!
;        

: show-error ." error" . -1 throw ;

:pic halt-flash
 begin
  10000 0 ?do  loop
  [ 0 ]l8 show-error
  10000 0 ?do  loop
  errorcode-c@ show-error
 again 
; 

       
: check-it      ( stack-value, expected-value -- )
  <> if ." ERROR " errorcode-c@ . endif
;
: c-check-it check-it ;

:pic check-it ( stack-value, expected-value --  )
  errorcode-c@ show-error 
  <> if halt-flash endif
;

:pic c-check-it ( stack-value, expected-value -- )
  errorcode-c@ show-error
  c<> c-if halt-flash endif
;

: cs
  0
  begin
    >in @
    bl word 
    dup c@
    if
      number?
    else
      false  
    endif  
  while 
    >r
    drop \ in@
    1+
  repeat
  drop \ word
  >in !
  r> \ error number
  postpone literal8
  postpone errorcode-c!
  1-  
  0 ?do
    2r> r> -rot 2>r 
    postpone literal 
    postpone check-it 
  loop
; immediate

: cs8
  0
  begin
    >in @
    bl word 
    dup c@
    if
      number?
    else
      false  
    endif  
  while 
    >r
    drop \ in@
    1+
  repeat
  drop \ word
  >in !
  r> \ error number
  postpone literal8
  postpone errorcode-c!
  1-             
  0 ?do
    2r> r> -rot 2>r 
    postpone literal8 
    postpone c-check-it 
  loop
; immediate


