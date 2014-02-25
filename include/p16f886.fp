\ this is a simple copy of p16f883
\ fixme - check against the include or documentation

hex

0000 def INDF
0001 def TMR0
0002 def PCL
0003 def STATUS
0004 def FSR
0005 def PORTA
0006 def PORTB
0007 def PORTC

0009 def PORTE
000A def PCLATH
000B def INTCON
000C def PIR1
000D def PIR2
000E def TMR1L
000F def TMR1H
0010 def T1CON
0011 def TMR2
0012 def T2CON
0013 def SSPBUF
0014 def SSPCON
0015 def CCPR1L
0016 def CCPR1H
0017 def CCP1CON
0018 def RCSTA
0019 def TXREG
001A def RCREG
001B def CCPR2L
001C def CCPR2H
001D def CCP2CON
001E def ADRESH
001F def ADCON0

0081 def OPTION_REG

0085 def TRISA
0086 def TRISB
0087 def TRISC

0089 def TRISE

008C def PIE1
008D def PIE2
008E def PCON
008F def OSCCON
0090 def OSCTUNE
0091 def SSPCON2
0092 def PR2
0093 def SSPADD
0093 def SSPMSK
0093 def MSK
0094 def SSPSTAT
0095 def WPUB
0096 def IOCB
0097 def VRCON
0098 def TXSTA
0099 def SPBRG
009A def SPBRGH
009B def PWM1CON
009C def ECCPAS
009D def PSTRCON
009E def ADRESL
009F def ADCON1

0105 def WDTCON

0107 def CM1CON0
0108 def CM2CON0
0109 def CM2CON1

010C def EEDATA
010C def EEDAT
010D def EEADR
010E def EEDATH
010F def EEADRH

0185 def SRCON

0187 def BAUDCTL
0188 def ANSEL
0189 def ANSELH

018C def EECON1
018D def EECON2

\ ----- BANK 0 REGISTER DEFINITIONS ----------------------------------------
\ ----- STATUS Bits --------------------------------------------------------

STATUS 7 defbit  IRP
STATUS 6 defbit  RP1
STATUS 5 defbit  RP0
STATUS 4 defbit  NOT_TO
STATUS 3 defbit  NOT_PD
STATUS 2 defbit  Z
STATUS 1 defbit  DC
STATUS 0 defbit  CY

\ ----- INTCON Bits --------------------------------------------------------

INTCON 7 defbit  GIE
INTCON 6 defbit  PEIE
INTCON 5 defbit  T0IE
INTCON 5 defbit  TMR0IE
INTCON 4 defbit  INTE
INTCON 3 defbit  RBIE
INTCON 2 defbit  T0IF
INTCON 2 defbit  TMR0IF
INTCON 1 defbit  INTF
INTCON 0 defbit  RBIF

\ ----- PIR1 Bits ----------------------------------------------------------

PIR1 6 defbit  ADIF
PIR1 5 defbit  RCIF
PIR1 4 defbit  TXIF
PIR1 3 defbit  SSPIF
PIR1 2 defbit  CCP1IF
PIR1 1 defbit  TMR2IF
PIR1 0 defbit  TMR1IF

\ ----- PIR2 Bits ----------------------------------------------------------

PIR2 7 defbit  OSFIF
PIR2 6 defbit  C2IF
PIR2 5 defbit  C1IF
PIR2 4 defbit  EEIF
PIR2 3 defbit  BCLIF
PIR2 2 defbit  ULPWUIF
PIR2 0 defbit  CCP2IF

\ ----- T1CON Bits ---------------------------------------------------------

T1CON 7 defbit  T1GIV
T1CON 6 defbit  TMR1GE
T1CON 5 defbit  T1CKPS1
T1CON 4 defbit  T1CKPS0
T1CON 3 defbit  T1OSCEN
T1CON 2 defbit  NOT_T1SYNC
T1CON 2 defbit  T1INSYNC    \  Backward compatibility only
T1CON 2 defbit  T1SYNC
T1CON 1 defbit  TMR1CS
T1CON 0 defbit  TMR1ON

\ ----- T2CON Bits ---------------------------------------------------------

T2CON 6 defbit  TOUTPS3
T2CON 5 defbit  TOUTPS2
T2CON 4 defbit  TOUTPS1
T2CON 3 defbit  TOUTPS0
T2CON 2 defbit  TMR2ON
T2CON 1 defbit  T2CKPS1
T2CON 0 defbit  T2CKPS0

\ ----- SSPCON Bits --------------------------------------------------------

SSPCON 7 defbit  WCOL
SSPCON 6 defbit  SSPOV
SSPCON 5 defbit  SSPEN
SSPCON 4 defbit  CKP
SSPCON 3 defbit  SSPM3
SSPCON 2 defbit  SSPM2
SSPCON 1 defbit  SSPM1
SSPCON 0 defbit  SSPM0

\ ----- CCP1CON Bits -------------------------------------------------------

CCP1CON 7 defbit  P1M1
CCP1CON 6 defbit  P1M0
CCP1CON 5 defbit  DC1B1
CCP1CON 5 defbit  CCP1X  \  Backward compatibility only
CCP1CON 4 defbit  DC1B0
CCP1CON 4 defbit  CCP1Y  \  Backward compatibility only
CCP1CON 3 defbit  CCP1M3
CCP1CON 2 defbit  CCP1M2
CCP1CON 1 defbit  CCP1M1
CCP1CON 0 defbit  CCP1M0

\ ----- RCSTA Bits ---------------------------------------------------------

RCSTA 7 defbit  SPEN
RCSTA 6 defbit  RX9
RCSTA 6 defbit  RC9    \  Backward compatibility only
RCSTA 6 defbit  NOT_RC8    \  Backward compatibility only
RCSTA 6 defbit  RC8_9    \  Backward compatibility only
RCSTA 5 defbit  SREN
RCSTA 4 defbit  CREN
RCSTA 3 defbit  ADDEN
RCSTA 2 defbit  FERR
RCSTA 1 defbit  OERR
RCSTA 0 defbit  RX9D
RCSTA 0 defbit  RCD8    \  Backward compatibility only

\ ----- CCP2CON Bits -------------------------------------------------------

CCP2CON 5 defbit  CCP2X  \  Backward compatibility only
CCP2CON 5 defbit  DC2B1
CCP2CON 4 defbit  CCP2Y  \  Backward compatibility only
CCP2CON 4 defbit  DC2B0
CCP2CON 3 defbit  CCP2M3
CCP2CON 2 defbit  CCP2M2
CCP2CON 1 defbit  CCP2M1
CCP2CON 0 defbit  CCP2M0

\ ----- ADCON0 Bits --------------------------------------------------------

ADCON0 7 defbit  ADCS1
ADCON0 6 defbit  ADCS0
ADCON0 5 defbit  CHS3
ADCON0 4 defbit  CHS2
ADCON0 3 defbit  CHS1
ADCON0 2 defbit  CHS0
ADCON0 1 defbit  GO
ADCON0 1 defbit  NOT_DONE
ADCON0 1 defbit  GO_DONE
ADCON0 0 defbit  ADON

\ ----- BANK 1 REGISTER DEFINITIONS ----------------------------------------
\ ----- OPTION_REG Bits -----------------------------------------------------

OPTION_REG 7 defbit  NOT_RBPU
OPTION_REG 6 defbit  INTEDG
OPTION_REG 5 defbit  T0CS
OPTION_REG 4 defbit  T0SE
OPTION_REG 3 defbit  PSA
OPTION_REG 2 defbit  PS2
OPTION_REG 1 defbit  PS1
OPTION_REG 0 defbit  PS0

\ ----- PIE1 Bits ----------------------------------------------------------

PIE1 6 defbit  ADIE
PIE1 5 defbit  RCIE
PIE1 4 defbit  TXIE
PIE1 3 defbit  SSPIE
PIE1 2 defbit  CCP1IE
PIE1 1 defbit  TMR2IE
PIE1 0 defbit  TMR1IE

\ ----- PIE2 Bits ----------------------------------------------------------

PIE2 7 defbit  OSFIE
PIE2 6 defbit  C2IE
PIE2 5 defbit  C1IE
PIE2 4 defbit  EEIE
PIE2 3 defbit  BCLIE
PIE2 2 defbit  ULPWUIE
PIE2 0 defbit  CCP2IE

\ ----- PCON Bits ----------------------------------------------------------

PCON 5 defbit  ULPWUE
PCON 4 defbit  SBOREN
PCON 1 defbit  NOT_POR
PCON 0 defbit  NOT_BO
PCON 0 defbit  NOT_BOR

\ ----- OSCCON Bits --------------------------------------------------------

OSCCON 6 defbit  IRCF2
OSCCON 5 defbit  IRCF1
OSCCON 4 defbit  IRCF0
OSCCON 3 defbit  OSTS
OSCCON 2 defbit  HTS
OSCCON 1 defbit  LTS
OSCCON 0 defbit  SCS

\ ----- OSCTUNE Bits -------------------------------------------------------

OSCTUNE 4 defbit  TUN4
OSCTUNE 3 defbit  TUN3
OSCTUNE 2 defbit  TUN2
OSCTUNE 1 defbit  TUN1
OSCTUNE 0 defbit  TUN0

\ ----- SSPCON2 Bits --------------------------------------------------------

SSPCON2 7 defbit  GCEN
SSPCON2 6 defbit  ACKSTAT
SSPCON2 5 defbit  ACKDT
SSPCON2 4 defbit  ACKEN
SSPCON2 3 defbit  RCEN
SSPCON2 2 defbit  PEN
SSPCON2 1 defbit  RSEN   
SSPCON2 0 defbit  SEN   

\ ----- SSPSTAT Bits -------------------------------------------------------

SSPSTAT 7 defbit  SMP
SSPSTAT 6 defbit  CKE
\ SSPSTAT 5 defbit  D
SSPSTAT 5 defbit  I2C_DATA
SSPSTAT 5 defbit  NOT_A
SSPSTAT 5 defbit  NOT_ADDRESS
SSPSTAT 5 defbit  D_A
SSPSTAT 5 defbit  DATA_ADDRESS
\ SSPSTAT 4 defbit  P
SSPSTAT 4 defbit  I2C_STOP
\ SSPSTAT 3 defbit  S
SSPSTAT 3 defbit  I2C_START
\ SSPSTAT 2 defbit  R
SSPSTAT 2 defbit  I2C_READ
SSPSTAT 2 defbit  NOT_W
SSPSTAT 2 defbit  NOT_WRITE
SSPSTAT 2 defbit  R_W
SSPSTAT 2 defbit  READ_WRITE
SSPSTAT 1 defbit  UA
SSPSTAT 0 defbit  BF

\ ----- WPUB Bits ----------------------------------------------------------

WPUB 7 defbit  WPUB7
WPUB 6 defbit  WPUB6
WPUB 5 defbit  WPUB5
WPUB 4 defbit  WPUB4
WPUB 3 defbit  WPUB3
WPUB 2 defbit  WPUB2
WPUB 1 defbit  WPUB1
WPUB 0 defbit  WPUB0

\ ----- IOCB Bits ----------------------------------------------------------

IOCB 7 defbit  IOCB7
IOCB 6 defbit  IOCB6
IOCB 5 defbit  IOCB5
IOCB 4 defbit  IOCB4
IOCB 3 defbit  IOCB3
IOCB 2 defbit  IOCB2
IOCB 1 defbit  IOCB1
IOCB 0 defbit  IOCB0

\ ----- VRCON Bits ---------------------------------------------------------

VRCON 7 defbit  VREN
VRCON 6 defbit  VROE
VRCON 5 defbit  VRR
VRCON 4 defbit  VRSS
VRCON 3 defbit  VR3
VRCON 2 defbit  VR2
VRCON 1 defbit  VR1
VRCON 0 defbit  VR0

\ ----- TXSTA Bits ---------------------------------------------------------

TXSTA 7 defbit  CSRC
TXSTA 6 defbit  TX9
TXSTA 6 defbit  NOT_TX8    \  Backward compatibility only
TXSTA 6 defbit  TX8_9    \  Backward compatibility only
TXSTA 5 defbit  TXEN
TXSTA 4 defbit  SYNC
TXSTA 3 defbit  SENDB
TXSTA 2 defbit  BRGH
TXSTA 1 defbit  TRMT
TXSTA 0 defbit  TX9D
TXSTA 0 defbit  TXD8    \  Backward compatibility only

\ ----- SPBRG Bits -------------------------------------------------------

SPBRG 7 defbit  BRG7
SPBRG 6 defbit  BRG6
SPBRG 5 defbit  BRG5
SPBRG 4 defbit  BRG4
SPBRG 3 defbit  BRG3
SPBRG 2 defbit  BRG2
SPBRG 1 defbit  BRG1
SPBRG 0 defbit  BRG0

\ ----- SPBRGH Bits -------------------------------------------------------

SPBRGH 7 defbit  BRG15
SPBRGH 6 defbit  BRG14
SPBRGH 5 defbit  BRG13
SPBRGH 4 defbit  BRG12
SPBRGH 3 defbit  BRG11
SPBRGH 2 defbit  BRG10
SPBRGH 1 defbit  BRG9
SPBRGH 0 defbit  BRG8

\ ----- PWM1CON Bits -------------------------------------------------------

PWM1CON 7 defbit  PRSEN
PWM1CON 6 defbit  PDC6
PWM1CON 5 defbit  PDC5
PWM1CON 4 defbit  PDC4
PWM1CON 3 defbit  PDC3
PWM1CON 2 defbit  PDC2
PWM1CON 1 defbit  PDC1
PWM1CON 0 defbit  PDC0

\ ----- ECCPAS Bits --------------------------------------------------------

ECCPAS 7 defbit  ECCPASE
ECCPAS 6 defbit  ECCPAS2
ECCPAS 5 defbit  ECCPAS1
ECCPAS 4 defbit  ECCPAS0
ECCPAS 3 defbit  PSSAC1
ECCPAS 2 defbit  PSSAC0
ECCPAS 1 defbit  PSSBD1
ECCPAS 0 defbit  PSSBD0

\ ----- PSTRCON Bits --------------------------------------------------------

PSTRCON 4 defbit  STRSYNC
PSTRCON 3 defbit  STRD
PSTRCON 2 defbit  STRC
PSTRCON 1 defbit  STRB
PSTRCON 0 defbit  STRA

\ ----- ADCON1 Bits --------------------------------------------------------

ADCON1 7 defbit  ADFM
ADCON1 5 defbit  VCFG1
ADCON1 4 defbit  VCFG0

\ ----- BANK 2 REGISTER DEFINITIONS ----------------------------------------
\ ----- WDTCON Bits --------------------------------------------------------

WDTCON 4 defbit  WDTPS3
WDTCON 3 defbit  WDTPS2
WDTCON 2 defbit  WDTPS1
WDTCON 1 defbit  WDTPS0
WDTCON 0 defbit  SWDTEN

\ ----- CM1CON0 Bits -------------------------------------------------------

CM1CON0 7 defbit  C1ON
CM1CON0 6 defbit  C1OUT
CM1CON0 5 defbit  C1OE
CM1CON0 4 defbit  C1POL

CM1CON0 2 defbit  C1R
CM1CON0 1 defbit  C1CH1
CM1CON0 0 defbit  C1CH0

\ ----- CM2CON0 Bits -------------------------------------------------------

CM2CON0 7 defbit  C2ON
CM2CON0 6 defbit  C2OUT
CM2CON0 5 defbit  C2OE
CM2CON0 4 defbit  C2POL

CM2CON0 2 defbit  C2R
CM2CON0 1 defbit  C2CH1
CM2CON0 0 defbit  C2CH0

\ ----- CM2CON1 Bits -------------------------------------------------------

CM2CON1 7 defbit  MC1OUT
CM2CON1 6 defbit  MC2OUT
CM2CON1 5 defbit  C1RSEL
CM2CON1 4 defbit  C2RSEL

CM2CON1 1 defbit  T1GSS
CM2CON1 0 defbit  C2SYNC

\ ----- BANK 3 REGISTER DEFINITIONS ----------------------------------------
\ ----- SRCON Bits ----------------------------------------------------------

SRCON 7 defbit  SR1
SRCON 6 defbit  SR0
SRCON 5 defbit  C1SEN
SRCON 4 defbit  C2REN
SRCON 3 defbit  PULSS
SRCON 2 defbit  PULSR

SRCON 0 defbit  FVREN

\ ----- BAUDCTL Bits -------------------------------------------------------

BAUDCTL 7 defbit  ABDOVF
BAUDCTL 6 defbit  RCIDL

BAUDCTL 4 defbit  SCKP
BAUDCTL 3 defbit  BRG16

BAUDCTL 1 defbit  WUE
BAUDCTL 0 defbit  ABDEN

\ ----- ANSEL Bits ---------------------------------------------------------

ANSEL 4 defbit  ANS4
ANSEL 3 defbit  ANS3
ANSEL 2 defbit  ANS2
ANSEL 1 defbit  ANS1
ANSEL 0 defbit  ANS0

\ ----- ANSELH Bits --------------------------------------------------------

ANSELH 5 defbit  ANS13
ANSELH 4 defbit  ANS12
ANSELH 3 defbit  ANS11
ANSELH 2 defbit  ANS10
ANSELH 1 defbit  ANS9
ANSELH 0 defbit  ANS8

\ ----- EECON1 Bits --------------------------------------------------------

EECON1 7 defbit  EEPGD

EECON1 3 defbit  WRERR
EECON1 2 defbit  WREN
EECON1 1 defbit  WR
EECON1 0 defbit  RD


inline #define STACK_LENGTH 80
   

0 [IF]
;==========================================================================
;
;       RAM Definition
;
;==========================================================================

        __MAXRAM H'1FF'
        __BADRAM H'110'-H'11F'
        __BADRAM H'18E'-H'1EF'
       
;==========================================================================
;
;       Configuration Bits
;
;==========================================================================
_CONFIG1                     EQU     H'2007'
_CONFIG2                     EQU     H'2008'

;----- Configuration Word1 ------------------------------------------------

_DEBUG_ON                    EQU     H'1FFF'
_DEBUG_OFF                   EQU     H'3FFF'
_LVP_ON          EQU     H'3FFF'
_LVP_OFF         EQU     H'2FFF'
_FCMEN_ON                    EQU     H'3FFF'
_FCMEN_OFF                   EQU     H'37FF'
_IESO_ON                     EQU     H'3FFF'
_IESO_OFF                    EQU     H'3BFF'
_BOR_ON                      EQU     H'3FFF'
_BOR_NSLEEP                  EQU     H'3EFF'
_BOR_SBODEN                  EQU     H'3DFF'
_BOR_OFF                     EQU     H'3CFF'
_CPD_ON                      EQU     H'3F7F'
_CPD_OFF                     EQU     H'3FFF'
_CP_ON                       EQU     H'3FBF'
_CP_OFF                      EQU     H'3FFF'
_MCLRE_ON                    EQU     H'3FFF'
_MCLRE_OFF                   EQU     H'3FDF'
_PWRTE_ON                    EQU     H'3FEF'
_PWRTE_OFF                   EQU     H'3FFF'
_WDT_ON                      EQU     H'3FFF'
_WDT_OFF                     EQU     H'3FF7'
_LP_OSC                      EQU     H'3FF8'
_XT_OSC                      EQU     H'3FF9'
_HS_OSC                      EQU     H'3FFA'
_EC_OSC                      EQU     H'3FFB'
_INTRC_OSC_NOCLKOUT          EQU     H'3FFC'
_INTRC_OSC_CLKOUT            EQU     H'3FFD'
_EXTRC_OSC_NOCLKOUT          EQU     H'3FFE'
_EXTRC_OSC_CLKOUT            EQU     H'3FFF'
_INTOSCIO                    EQU     H'3FFC'
_INTOSC                      EQU     H'3FFD'
_EXTRCIO                     EQU     H'3FFE'
_EXTRC                       EQU     H'3FFF'

;----- Configuration Word2 ------------------------------------------------

_WRT_OFF                     EQU     H'3FFF'    ; No prog memmory write protection
_WRT_256                     EQU     H'3DFF'    ; First 256 prog memmory write protected
_WRT_1FOURTH                 EQU     H'3BFF'    ; First quarter prog memmory write protected
_WRT_HALF                    EQU     H'39FF'    ; First half memmory write protected

_BOR21V              EQU     H'3EFF'
_BOR40V              EQU     H'3FFF'

[ENDIF]
