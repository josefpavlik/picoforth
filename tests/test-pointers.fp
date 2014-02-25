processor p16f648a

require checkstack.fp


var   var1
var16 var2 
var32 var3

var2 10 defbit bit10  
 

:pic test3
  254 >byte var1-c! 111  var1@         cs 111 254     $50      \
  253 var1! 222 var1@                  cs 222 253     $51      \
  $1234 var1! 222 var1@                cs 222 $34     $52      \
  $1234 var2! 2222 var2@ var2-c@ byte>word  cs 2222 $1234 $34  $53      \
  0 var2! bit10-set var2@              cs $400                 $54      \
  bit10-reset var2@                    cs 0                    $55      \
  11111 var2! 0 var2 @                 cs 0 11111              $56      \
  22222 var2 ! 0 var2@                 cs 0 22222              $57      \
  $aa00 var2! 3 >byte var2 c! 0 var2@  cs 0 $aa03              $58      \
  0 var2! -1 >byte var2 c! 0 var2@     cs 0 $ff                $59      \
  -1 >byte var2-c! 0 var2 @            cs 0 $ff              $5a      \
  bit10                                cs $400                 $5b      \

;  

:pic test4
  55 3 1  ?do 1+ loop                              cs 57        $61
  55 1 -1 ?do 1+ loop                              cs 57        $62
  55 1 -1 ?do 1+ loop                              cs 57        $63
  5 55 begin swap 1- swap over while 1+ repeat    cs 0 59       $64
  5 55 begin 1+ swap 1- swap over 0= until        cs 0 60       $65
  
  bit10-set   bit10-if 1 else 2 endif               cs 1          $66
  bit10-reset bit10-if 1 else 2 endif               cs 2          $67
  bit10-set   bit10-0-if 1 else 2 endif             cs 2          $68
  bit10-reset bit10-0-if 1 else 2 endif             cs 1          $69
  
  1 var2!  0 begin bit10-0-while 1+ var2@ 2* var2! repeat    cs 10        $71
  -1 var2! 0 begin bit10-while   1+ var2@ 2* var2! repeat    cs 11        $72
  1 var2!  0 begin  1+ var2@ 2* var2! bit10-until            cs 10        $73
  -1 var2! 0 begin  1+ var2@ 2* var2! bit10-0-until          cs 11        $74
  
;
  

$140 def16  testpole
$c8 def16   prvnipole
$45 def16   druhypole
  
:pic test5
  $1234  testpole ! $abcd testpole 2 + !
  testpole druhypole 4 move
  
  druhypole @ druhypole 2 + @ cs $1234 $abcd  $81
  
  
  druhypole@ 1+ druhypole!
  druhypole prvnipole 4 move 
  
  prvnipole @ prvnipole 2 + @ cs $1235 $abcd  $82
  
  s" ABCDEF" testpole swap move 
  testpole dup c@ c-rot
  1+ dup c@       c-rot
  1+ dup c@       c-rot
  1+ dup c@       c-rot
  1+ dup c@       c-rot
  1+ dup c@       c-rot
  1+ c@ 
  cs8 $41 $42 $43 $44 $45 $46 0                $83
;   
    
: populate-data
  10 0 ?do
    i 3 + c,
  loop
;
create data populate-data
    
: populate-data-int
  10 0 ?do
    i 1+ 1234 * ,
  loop
;

create data-int populate-data-int             

." pc data[0]=" data c@ . cr
." pc data-int[5]=" data-int 5 cells + @ . cr


4000000 constant32 quartz
50000 constant16 50k
30000 constant 30k
200 constant8 c200
            
:pic test6
  data c@ data 5 + c@             cs8 3 8         $90
  data-int @ data-int 5 2* + @    cs  1234 7404   $91 
  quartz                          cs  $0900 $003d $92
  30k                             cs  30000       $93
  c200                            cs8 200         $94
;

var v1
var16 v2
var32 v3

:pic test7
  $45 v1! $1234 v1+! v1@          cs $79          $c0
  -2 v1-and! v1@ $f0 v1-or! v1@   cs $78 $f8      $c1
  $f v1-xor! v1@                  cs $f7          $c2
  -1 v2! v1@ v2!    v2@           cs $f7          $c3
  $1234 v2! $1234 v2+! v2@        cs $2468        $c4
  [ $ff ]l8 v2+c!      v2@        cs $2567        $c5
  [ $ff ]l8 v2-cxor!   v2@        cs $2598        $c6
  $8000 v2-or!         v2@        cs $a598        $c7
  $f00f v2-and!        v2@        cs $a008        $c8
  $12ff v2! v2-inc v2@ v2-inc v2@ cs $1300 $1301  $c9
  v2-dec v2@ v2-dec v2@           cs $1300 $12ff  $ca
  $fe v1! v1-inc v1@ v1-inc v1@ v1-dec v1@ cs $ff $0 $ff   $cb
  
\  $1234 $5678 v3-d!
;  
  
:pic main
  0 trisa!
  0 porta!
  12345 
  
  test3
  test4
  test5
  test6
  test7
  
  cs 12345 254 \
  255 >byte show-error halt

;

pic-create only-pic 1 , 2 ,   \ this will be created only in pic
pc-create only-pc 123 c,      \ this will be created only in pc



create last-data-in-program
12345 ,
$abcd ,
1 ,
0 c,

\ end of program should close the definition                 
\ : end ;

