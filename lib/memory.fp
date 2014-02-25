0 [if]
-------------------------------------------------------------------------
   picoforth memory manipulation library
   
  all pointers are 16 bits
  if pointer >=$c000, it is pointer to ram
  pointers <$c000 are pointers to rom (so you could not use pointers pointing to rom area over 48k)

  these words works correctly only on PIC12 and PIC16F ( max four banks, bank select in status register ) 

  fixme - PIC18F version 
     
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

 
  
:pic pointers-common asm
c_fetch_rom
  movwf PCLATH
  movff tmp1, PCL ; goto to retlw

; in case of rom, returns C=0 and addr in w(high) and tmp1(low)
; in case of ram, returns C=1 and fetched byte in w           
; fsr is decremented
prep_fetch 
  movlw 64
  addwf indf, w
  btfss STATUS, C
  goto  prep_fetch_rom
; ram
  btfss STATUS, Z
  goto  prep_fetch_ram_h
; low part of ram  
  decf  fsr, f
  movff fsr, spsave
  movff indf, fsr
  bcf STATUS, IRP
  movff indf, tmp1
	bankisel  STACK_BEGIN
  movff spsave, fsr
  clrf  spsave
  movff tmp1, indf
  return

; low part of ram  
prep_fetch_ram_h
  decf  fsr, f
  movff fsr, spsave
  movff indf, fsr
  bsf STATUS, IRP
  movff indf, tmp1
	bankisel  STACK_BEGIN
  movff spsave, fsr
  clrf  spsave
  movff tmp1, indf
  return
  
prep_fetch_rom
  decf  fsr, f
  movff indf, tmp1
  incf  fsr, f
  movf  indf, w
  decf  fsr, f
  return
endasm ;     


:pic-inline c@ asm
  mypageselw prep_fetch
  call  prep_fetch
  btfss STATUS, C
  call  c_fetch_rom  
  movwf indf
endasm 
  requires-word pointers-common  
;  

:pic dup1+ dup 1+ ;  
:pc dup1+ dup 1+ ;

:pic-inline @ 
  dup1+
  c@
asm
  pop
  movwf tmp2
endasm
  c@
asm
  incf  fsr, f
  movff tmp2, indf  
endasm
;

:pic c! asm
  btfsc indf, 0
  goto  c_store_ram_h
  decf  fsr, f
  decf  fsr, f
  movff indf, tmp1
  movff fsr, spsave
  incf  fsr, f
  movff indf, fsr
  bcf STATUS, IRP
  movff tmp1, indf
  goto  c_store_ram_end

c_store_ram_h
  decf  fsr, f
  decf  fsr, f
  movff indf, tmp1
  movff fsr, spsave
  incf  fsr, f
  movff indf, fsr
  bsf STATUS, IRP
  movff tmp1, indf
c_store_ram_end  
  decf  spsave, w
  movwf fsr
  clrf  spsave
	bankisel  STACK_BEGIN
endasm ;                     

:pic ! asm
  btfsc indf, 0
  goto  store_ram_h
  decf  fsr, f
  decf  fsr, f
  movff indf, tmp2
  decf  fsr, f
  movff indf, tmp1
  decf  fsr, w
  movwf spsave
  incf  fsr, f
  incf  fsr, f
  movff indf, fsr
  bcf STATUS, IRP
  movff tmp1, indf
  incf  fsr, f
  movff tmp2, indf
  goto  store_ram_end

store_ram_h
  decf  fsr, f
  decf  fsr, f
  movff indf, tmp2
  decf  fsr, f
  movff indf, tmp1
  decf  fsr, w
  movwf spsave
  incf  fsr, f
  incf  fsr, f
  movff indf, fsr
  bsf STATUS, IRP
  movff tmp1, indf
  incf  fsr, f
  movff tmp2, indf
store_ram_end  
  movff spsave, fsr
  clrf  spsave
	bankisel  STACK_BEGIN
endasm ;                     



:pic move ( source-addr, dest-addr, len -- )
asm
  decf  fsr, f      ; ignore high byte of length
  movff indf, tmp3  ; len in tmp3
  decf fsr, w
  movwf spsave
  movlw -3
  addwf fsr, f
  movf  indf, w
  addlw 64
  btfss STATUS, C
  goto  move_from_rom
  
  decf  fsr, f
  movf  indf, w
  movwf tmp2      ; source addr
  incf  fsr, f
  incf  fsr, f
  subwf indf, w   ; 
  movwf tmp1      ; dest - source -> tmp1
  
#ifdef IBANK2 
  incf  fsr, f
  movf  indf, w
  decf  fsr, f  
  decf  fsr, f
  xorwf indf, w
  andlw 1
  rrf   indf, w
  rrf   STATUS, f   ; src bank select bit to IRP  
  btfsc STATUS, Z-1
  goto  move_in_the_same_bank

move_accross_banks
  movff tmp2, fsr ; src addr
move2_loop
  movff indf, tmp2
  movf  tmp1, w
  addwf fsr, f
  movlw 128
  xorwf STATUS, f
  movff tmp2, indf
  movf  tmp1, w
  subwf fsr, f
  movlw 128
  xorwf STATUS, f
  incf  fsr, f
  decfsz  tmp3, f
  goto  move2_loop
  goto  move_end
#endif

move_in_the_same_bank
  movff tmp2, fsr ; src addr
move1_loop
  movff indf, tmp2
  movf  tmp1, w
  addwf fsr, f
  movff tmp2, indf
  movf  tmp1, w
  subwf fsr, f
  incf  fsr, f
  decfsz  tmp3, f
  goto  move1_loop
  goto  move_end
  

move_get_byte  
  movff tmp2, PCLATH
  movff tmp1, PCL 
  

move_from_rom
  movff indf, tmp2  ; hi byte of rom addr
  decf  fsr, f 
  movff indf, tmp1  ; low byte of rom addr
  incf  fsr, f
  incf  fsr, f
  movf  indf, w     ; low byte of dest addr
#ifdef IBANK2
  incf  fsr, f
  rrf indf, f
  rrf STATUS, f     ; dest bank to IRP
#endif  
  movwf fsr         ; dest addr to fsr
move3_loop
  call  move_get_byte
  movwf indf
  incf  fsr, f
  incf  tmp2, f
  incfsz  tmp1, f
  decf  tmp2, f
  mypageselw  $
  decfsz  tmp3, f
  goto  move3_loop

move_end
  bankisel  STACK_BEGIN  
  movf  spsave, w
  addlw -4
  movwf fsr
  clrf  spsave
endasm
;  
  
  
  
  
