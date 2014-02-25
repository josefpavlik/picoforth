PICoForth is the compiler for PIC12 and PIC16 families of famous Microchip's microcontrollers

requires gForth and gputils

WARNING - this code is in (pre) alfpa state. It is usable, at least 1 simple project is done
using this compiler, but many features are missing.
See TODO

install script missing yet, no link to libraries etc, you should compile directly from this directory
try this:
./picoforth examples/servo.fp
you should found the .hex file and friends in example directory






CALLING STYLES

there are 3 styles of calling words:

1. inline - the word is compiled inline.
usesfull for simple words like dup, drop etc and for words that are called few times.
:pic-inline <name> .... ;

2. simple call - uses call and return instructions to call the word
there is hardware limit to 8 levels.
Many of library words consumes 1 level of stack. The interrupt consumes 1 level of stack too
:pic <name> ..... ;

3. return stack call
there is no limit to 8 levels of stack, the return address is stored in return stack.
This method is slower than simple call and consumes 2 bytes of ram (in return stack)
:pic-rcall <name> .... ;




FSR AND VARIABLES

fsr registers are defined by word def. 
<address> def <name>  	\ 8 bits
<address> def16 <name>	\ 16 bits

variables are in ram
variables cannot be placed on arbitrary address and cannot be initialized
var <name> 	\ 8 bit variable
var16 <name> 	\ 16 bit variable
var32 <name>	\ 32 bit variable

number in variables, stack and return stack are always stored in big endian - high byte on higher address

both fsr and variables defines the following words:

var foo
foo	\ returns address of variable (16 bit literal) 
foo@	\ fetch variable (16 bit) on stack             (not for 32bit vars)
foo-c@ 	\ fetch variable (8 bit) on stack
foo!	\ store variable (16 bit) from stack           (not for 32bit vars)
foo-c!	\ store variable (8 bit) from stack

32bits vars has different ! and @ style:
foo!, foo@     \ double (32bit) fetch and store
foo-s!, foo-s@ \ single (16bit) fetch and store (high bits of variable are ignored)
foo-c!, foo-c@ \ char (8bit) fetch and store    (high bits of variable are ignored)


foo+!	  	\ add 16 bit value on stack to variable (only 16 and 8 bit variables)
foo+c!    	\ add 8 bit value on stack to variable  (only 16 and 8 bit variables)
foo-and!        \ and 16/32 bit value on stack to variable
foo-cand!       \ and 8 bit value on stack to variable
foo-or!         \ or 16/32 bit value on stack to variable
foo-cor!        \ or 8 bit value on stack to variable
foo-xor!        \ xor 16/32 bit value on stack to variable
foo-cxor!       \ xor 8 bit value on stack to variable
foo-inc		\ increment
foo-dec		\ decrement

defining bits:
on both fsr and variables can be declared one or more bits
<variable> <bit number> defbit <name>

i.e.
intcon 7 defbit gie
defbit defines the following words:
gie	\ returns bitmask, in this case $80 (16 bits) \ fixme
gie-c	\ returns bitmask (8 bits)
gie@	\ places 16 bit boolean on stack
gie-c@	\ places 8 bit boolean on stack
gie!	\ set or clear the bit depends on stack (16 bit)
gie-c!	\ set or clear the bit depends on stack (8 bit)
gie-set	\ sets the bit
gie-reset \ resets the bit

the following words can be used in normal conditional and loop structures
gie-if		
gie-0-if 	 
gie-while 	 
gie-0-while	
gie-until
gie-0-until



NAMING FSR AND BITS
all bit and fsr names are got from original include
Only few bits are renamed because of conflict with forth words
bit C of STATUS is renamed to CY (conflicts with c@ c! and similar)
removed one letter only names of bits of SSPSTAT 
\ SSPSTAT 5 defbit  D
SSPSTAT 5 defbit  I2C_DATA
\ SSPSTAT 4 defbit  P
SSPSTAT 4 defbit  I2C_STOP
\ SSPSTAT 3 defbit  S
SSPSTAT 3 defbit  I2C_START
\ SSPSTAT 2 defbit  R
SSPSTAT 2 defbit  I2C_READ
however, all of these bits has longer aliases


DEPENDENCIES

During the compiling the tree of dependencies is maintained for deactivate pieces of unused code.
If you want call some word directly from assembly, you must declare the dependency manually using word 
'requires-word xxx'

:pic aaa  
asm
aaa_mylabel
.... some code .... 
endasm ;

:pic bbb
asm
	mypageselw aaa_mylabel
	call	aaa_mylabel
; or
	__CALL	STYLE_CALL, aaa_mylabel
; or
	__CALL	STYLE_CALL, _WORD_aaa_1	; note the sequence number		
endasm
requires-word aaa
;

you can declare word as required using word 'required'
:pic foo ... some code ... ; required
this word will be compiled even if it is not used by other words

you can declare in some point of program, that all following words will be required
(this is default for user program)
required-start
and put off this option with
required-stop

make sure that the words 'main' and 'interrupt' are required!



CONSTANTS
you can use the constants inside both pc and pic words. Every constant is defined for both targets
simultaneously.
You must specify the size of constant.
'constant8', 'constant16', 'constant32' and 'constant' compiling words are available
'constant' mades 16bits constants, exactly as 'constant16'.

If you does not plan to use some constant in pic program, you can ommit the size, the pc
constants are always 32 bits wide.

You can use word 'pc-constant' for defining pc only constants (does not produce any asm output).
PIC constants are defined using equ.


DATA
The word 'create' defines both pc and pic header, every following , or c, puts the word/byte to
both pc's memory and pic asm output.
You cannot use allot for allocate the space in pic program.
If you should define only pic data, you can use word 'pic-create', in this case every following , or c,
puts data only to asm output.
Simillary, if you define 'pc-create', ',' and 'c,' puts data in pc memory and you can use the allot too.


