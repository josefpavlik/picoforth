processor p12f629

4000000 constant quartz


0 ivariable tmr0-prescaller

: tmr0-calc-prescaller ( max-time-us -- ) \ sets tmr0-prescaller variable
  quartz 4 / 256 / 1000000 */ 1+
\  dup ." requested prescaller " .d cr
  0
  begin
    2dup 2 swap << >
  while 
    1+
  repeat
  nip
\  dup ." prescaller value=" .d cr 
  dup 7 > if abort" timer0 prescaller value out of range" endif
      
  tmr0-prescaller !
;

: tmr0-prescaller-divide 2 tmr0-prescaller @ << ;

: tmr0-value  ( requested-time-us -- value-to-register-tmr0 )                   
  quartz 4 / tmr0-prescaller-divide / 1000000  */ 256 swap - 255 and
;

                      
: tmr0-prescaller-init
  postpone option_reg-c@ 
  T0CS T0SE or PSA or PS2 or PS1 or  PS0 or invert  postpone literal8 
  postpone cand
  tmr0-prescaller @ postpone literal8 postpone cor postpone option_reg-c!                                      
; immediate





0 ivariable tmr1-prescaller

: tmr1-calc-prescaller ( max-time-us -- ) \ sets tmr1-prescaller variable
  quartz 4 / 65536 / 1000000 */ 1+
\  dup ." requested prescaller 1 " .d cr
  0
  begin
    2dup 1 swap << >
  while 
    1+
  repeat
  nip
\  dup ." prescaller value 1 =" .d cr 
  dup 3 > if abort" timer1 prescaller value out of range" endif
      
  tmr1-prescaller !
;

: tmr1-prescaller-divide 1 tmr1-prescaller @ << ;

: tmr1-value  ( requested-time-us -- value-to-register-tmr1 )                   
  quartz 4 / tmr1-prescaller-divide / 1000000  */ 65536 swap - 65535 and
;

                      
: tmr1-prescaller-init
  tmr1-prescaller @ 4 << postpone literal8 postpone t1con-c!                                      
; immediate


:pic-inline tmr1-write ( 16bit-value -- )
  tmr1on-reset
  tmr1!
  tmr1on-set
;
   
:pic tmr1-read ( -- 16bit-value )
  tmr1h-c@
  begin
    tmr1l-c@
    tmr1h-c@
    crot cover c<>
  while   
    nip
  repeat
;         


:pic calibrate-osc
asm
  banksel OSCCAL
  pageselw  h'3ff'
  call  h'3ff'
  movwf OSCCAL
endasm  
;
 
 
 

  
 1250 constant servo_min_us            
 1750 constant servo_max_us
20000 constant period_us
5000000 constant rail-to-rail_us  
                           
servo_max_us 101 100 */ ( to avoid 0 in timer0 value ) tmr0-calc-prescaller  
period_us tmr1-calc-prescaller
  
  
gpio 0 defbit rail
gpio 1 defbit key-down
gpio 2 defbit key-up
gpio 4 defbit pwm-out  

6 constant tris

var servo_value
servo_min_us tmr0-value constant servo_min
servo_max_us tmr0-value constant servo_max
servo_min_us servo_max_us + 2/ tmr0-value constant servo_initial

servo_min ." servo min " . cr
servo_initial ." servo initial " . cr
servo_max ." servo max " . cr
      
servo_max servo_min - abs constant steps
rail-to-rail_us steps / period_us / constant periods_per_step

var key_press_time

                  
:pic test-key-counter
  key_press_time-c@ c1+ cdup key_press_time-c! 
  [ periods_per_step ]l8 c>= 
;


:pic-inline handle-key-down
  test-key-counter
  c-if
    servo_value-c@ [ servo_min ]l8 uc< 
    c-if
      servo_value-c@ c1+ servo_value-c!
      rail-reset
    else
      rail-set  
    endif
    [ 0 ]l8 key_press_time-c!
  endif
;

:pic-inline handle-key-up
  test-key-counter
  c-if
    servo_value-c@ [ servo_max ]l8 uc>
    c-if
      servo_value-c@ c1- servo_value-c!
      rail-reset
    else
      rail-set
    endif  
    [ 0 ]l8 key_press_time-c!
  endif
;

:pic-inline handle-key-both
  test-key-counter
  c-if
    [ servo_initial ]l8 servo_value-c!
    rail-reset
    [ 0 ]l8 key_press_time-c!
  endif
;
                               
:pic-inline handle-keys
  key-down-0-if
    key-up-0-if
      handle-key-both
    else  
      handle-key-down
    endif  
  else
    key-up-0-if
      handle-key-up
    else
      [ 0 ]l8 key_press_time-c!
    endif
  endif
;
            
:pic interrupt
  t1if-if
    t1if-reset
    servo_value-c@ tmr0-c!
    pwm-out-set
    t0if-reset
    t0ie-set
    [ period_us tmr1-value ]l16 tmr1-write
  endif
  t0if-if
    t0if-reset
    pwm-out-reset
    t0ie-reset
    handle-keys
  endif
;
            
                        
            
:pic main
  calibrate-osc
  7 cmcon!
  [ tris ]l8 wpu-c! 
  [ tris ]l8 trisio-c!
  [ 0 ]l8 gpio-c!
  tmr0-prescaller-init
  tmr1-prescaller-init
  0 key_press_time!
  [ servo_initial ]l8 servo_value-c!
  tmr1ie-set
  peie-set
  gie-set
  -1 tmr1-write
  begin 
  again
  
;
  
    
inline  __CONFIG _CPD_ON & _CP_ON & _BODEN_OFF & _MCLRE_OFF & _PWRTE_ON & _WDT_OFF & _INTRC_OSC_NOCLKOUT

                                      
                                      
                                      
