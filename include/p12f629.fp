\ this file was converted from header file p12f629.inc (gputils)

hex
       
0000 def INDF
0001 def TMR0
0002 def PCL
0003 def STATUS
0004 def FSR
0005 def GPIO

000a def PCLATH      
000b def INTCON      
000c def PIR1			   

000e def16 TMR1                  
000e def TMR1L			 
000f def TMR1H			 
0010 def T1CON			 

0019 def CMCON			 

0081 def OPTION_REG	 

0085 def TRISIO			 

008c def PIE1			   

008e def PCON			   

0090 def OSCCAL			 

0095 def WPU			   
0096 def IOCB			   
0096 def IOC			   

0099 def VRCON			 
009a def EEDATA			 
009a def EEDAT			 
009b def EEADR			 
009c def EECON1			 
009d def EECON2			 


STATUS 7 defbit IRP
STATUS 6 defbit RP1    
STATUS 5 defbit RP0    
STATUS 4 defbit NOT_TO 
STATUS 3 defbit NOT_PD 
STATUS 2 defbit Z      
STATUS 1 defbit DC     
STATUS 0 defbit CY      
 
GPIO 5 defbit GP5		
GPIO 5 defbit GPIO5	
GPIO 4 defbit GP4		
GPIO 4 defbit GPIO4	
GPIO 3 defbit GP3		
GPIO 3 defbit GPIO3	
GPIO 2 defbit GP2		
GPIO 2 defbit GPIO2	
GPIO 1 defbit GP1		
GPIO 1 defbit GPIO1	
GPIO 0 defbit GP0		
GPIO 0 defbit GPIO0	

TRISIO 5 defbit TRIS5		
TRISIO 5 defbit TRISIO5	
TRISIO 4 defbit TRIS4		
TRISIO 4 defbit TRISIO4	
TRISIO 3 defbit TRIS3		
TRISIO 3 defbit TRISIO3	
TRISIO 2 defbit TRIS2		
TRISIO 2 defbit TRISIO2	
TRISIO 1 defbit TRIS1		
TRISIO 1 defbit TRISIO1	
TRISIO 0 defbit TRIS0		
TRISIO 0 defbit TRISIO0	

INTCON 7 defbit GIE  
INTCON 6 defbit PEIE 
INTCON 5 defbit T0IE 
INTCON 4 defbit INTE 
INTCON 3 defbit GPIE 
INTCON 2 defbit T0IF 
INTCON 1 defbit INTF 
INTCON 0 defbit GPIF 

PIR1 7 defbit EEIF  
PIR1 6 defbit ADIF  
PIR1 3 defbit CMIF  
PIR1 0 defbit T1IF  
PIR1 0 defbit TMR1IF

T1CON 6 defbit TMR1GE     
T1CON 5 defbit T1CKPS1    
T1CON 4 defbit T1CKPS0    
T1CON 3 defbit T1OSCEN    
T1CON 2 defbit NOT_T1SYNC 
T1CON 1 defbit TMR1CS     
T1CON 0 defbit TMR1ON     

CMCON 6 defbit COUT 
CMCON 4 defbit CINV 
CMCON 3 defbit CIS  
CMCON 2 defbit CM2  
CMCON 1 defbit CM1  
CMCON 0 defbit CM0  

OPTION_REG 7 defbit NOT_GPPU 
OPTION_REG 6 defbit INTEDG   
OPTION_REG 5 defbit T0CS     
OPTION_REG 4 defbit T0SE     
OPTION_REG 3 defbit PSA      
OPTION_REG 2 defbit PS2      
OPTION_REG 1 defbit PS1      
OPTION_REG 0 defbit PS0      

PIE1 7 defbit EEIE   
PIE1 6 defbit ADIE   
PIE1 3 defbit CMIE   
PIE1 0 defbit T1IE   
PIE1 0 defbit TMR1IE 

PCON 1 defbit NOT_POR 
PCON 0 defbit NOT_BOD 

OSCCAL 7 defbit CAL5 
OSCCAL 6 defbit CAL4 
OSCCAL 5 defbit CAL3 
OSCCAL 4 defbit CAL2 
OSCCAL 3 defbit CAL1 
OSCCAL 2 defbit CAL0 

IOCB 5 defbit IOCB5 
IOCB 4 defbit IOCB4 
IOCB 3 defbit IOCB3 
IOCB 2 defbit IOCB2 
IOCB 1 defbit IOCB1 
IOCB 0 defbit IOCB0 

IOC 5 defbit IOC5 
IOC 4 defbit IOC4 
IOC 3 defbit IOC3 
IOC 2 defbit IOC2 
IOC 1 defbit IOC1 
IOC 0 defbit IOC0 

VRCON 7 defbit VREN 
VRCON 6 defbit VRR  
VRCON 3 defbit VR3  
VRCON 2 defbit VR2  
VRCON 1 defbit VR1  
VRCON 0 defbit VR0  

EECON1 3 defbit WRERR 
EECON1 2 defbit WREN  
EECON1 1 defbit WR    
EECON1 0 defbit RD    
                     
\ fixme - add configuration bits definitions

 
inline #define STACK_LENGTH 20

