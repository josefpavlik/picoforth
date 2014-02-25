
\ processor p12f629
processor p16f883

require checkstack.fp
 
             
: b0 0 postpone literal8 ; immediate          
: b1 1 postpone literal8 ; immediate          
: b2 2 postpone literal8 ; immediate          
: b3 3 postpone literal8 ; immediate          
: b4 4 postpone literal8 ; immediate   
: b-3 -3 postpone literal8 ; immediate
: b-10 -10 postpone literal8 ; immediate
: b10 10 postpone literal8 ; immediate
: b254 254 postpone literal8 ; immediate
: b15 15 postpone literal8 ; immediate
: b5 5 postpone literal8 ; immediate
: b-15 -15 postpone literal8 ; immediate
: b-5 -5 postpone literal8 ; immediate
: b-4 -4 postpone literal8 ; immediate
: b-2 -2 postpone literal8 ; immediate

       
: ]l8 postpone literal8 ] ;  
           

:pic test1  
 
  b1                cdup   cs8 1 1        $11 \
  b1 b2             cswap  cs8 2 1        $12 \
  b1 b2 b3          crot   cs8 2 3 1      $13 \
  b1 b2 b3          c-rot  cs8 3 1 2      $14 \
  b1 b2 b3 b4 b3    croll  cs8 2 3 4 1    $15 \
  b1 b2 b3 b4 b3    c-roll cs8 4 1 2 3    $16 \
  b1 b2 b3 b4 b3    cpick  cs8 1 2 3 4 1  $17 \
  b1 b2             cnip   cs8 2          $18 \
  b1 b2             ctuck  cs8 2 1 2      $19 \
  b3                cinvert cs8 $fc       $1a \
  b3                cnegate cs8 -3        $1b \
  b10               c2/     cs8 5         $1c \
  b-10              c2/     cs8 -5        $1d \
  b10               c2*     cs8 20        $1e \
  b-10              c2*     cs8 -20       $1f \

  b10 b4            c*      cs8 40        $20 \
  b-10 b4           c*      cs8 -40       $21 \
  [ -1 ]l8 b-10     c*      cs8 10        $22 \  
  
  b4 b2 c- b2 b4 c-         cs8 2 -2      $24 \
  b4 b2             c+      cs8 6         $25 \
  
  b2 b2 c=    b2 b-3 c=     cs8 -1 0      $26 \
  b2 b2 c<>   b2 b-3 c<>    cs8 0 -1      $27 \
  
  b2 b2 c<   b2 b-3 c<   b2 b3 c<   cs8 0  0  -1  $28 \
  b2 b2 c<=  b2 b-3 c<=  b2 b3 c<=  cs8 -1 0  -1  $29 \
  b2 b2 c>   b2 b-3 c>   b2 b3 c>   cs8 0 -1  0   $2a \
  b2 b2 c>=  b2 b-3 c>=  b2 b3 c>=  cs8 -1 -1 0   $2b \
  
  b2 c0=  b0 c0=  b-3 c0=              cs8 0  -1 0  $2c \
  b2 c0<> b0 c0<> b-3 c0<>             cs8 -1 0 -1  $2d \
  b2 c0>= b0 c0>= b-3 c0>=             cs8 -1 -1 0  $2e \
  b2 c0<= b0 c0<= b-3 c0<=             cs8 0  -1 -1 $2f \
  b2 c0>  b0 c0>  b-3 c0>              cs8 -1 0  0  $30 \
  b2 c0<  b0 c0<  b-3 c0<              cs8 0  0 -1  $31 \
  
  b2 char>word  b-3 char>word          cs8 2 0 -3 $ff         $32 \
  2 >byte -2 >byte                     cs8 2 -2               $33 \
  b2 byte>word [ $fe ]l8  byte>word    cs8 2 0 $fe 0          $34 \
  
  b3 b2 c>r b4 c>r                     cs8 3                  $35 \
  cr@                                  cs8 4                  $36 \
  cr>                                  cs8 4                  $37 \ 
  cr>                                  cs8 2                  $38 \ 
;

:pic test2  
  [ $a3 ]l8 [ $3e ]l8 cand             cs8 $22                $39 \
  [ $a3 ]l8 [ $3e ]l8 cor              cs8 $bf                $3a \
  [ $a3 ]l8 [ $3e ]l8 cxor             cs8 $9d                $3b \
  
  b3 cabs b-10 cabs                    cs8 3 10               $40 \
  b-10 b3 cmax b3 b-10 cmax            cs8 3 3                $41 \
  b-10 b3 cmin b3 b-10 cmin            cs8 -10 -10            $42 \
  b254 b3 ucmax b3 b254 ucmax          cs8 254 254            $43 \
  b254 b3 ucmin b3 b254 ucmin          cs8 3 3                $44 \
  
  b254 b10 uc/ b254 b10 ucmod                          cs8 25 4           $45 \
  b254 b10 uc/mod                                      cs8 4 25           $46 \
  b15 b5 c/ b-15 b5 c/ b15 b-5 c/ b-15 b-5 c/          cs8 3 -3 -3 3      $47 \
  b15 b2 cmod b-15 b2 cmod b15 b-2 cmod b-15 b-2 cmod  cs8 1 -1 1 -1      $48 \
  b15 b2 c/mod b-15 b2 c/mod                           cs8 1 7 -1 -7      $49 \
  b15 b-2 c/mod b-15 b-2 c/mod                         cs8 1 -7 -1 7      $4a \ 
  
  b254 b10 uc<  b254 b254 uc<  b10 b254 uc<            cs8 0  0  -1       $50 \
  b254 b10 uc<= b254 b254 uc<= b10 b254 uc<=           cs8 0  -1 -1       $51 \
  b254 b10 uc>  b254 b254 uc>  b10 b254 uc>            cs8 -1 0   0       $52 \
  b254 b10 uc>= b254 b254 uc>= b10 b254 uc>=           cs8 -1 -1  0       $53 \
;


:pic main 
  0 trisa!
  0 porta!
  
  12345 
  test1
  test2
  
  
  cs 12345 254 \

  255 >byte show-error halt
;


                       
