#!/usr/bin/perl

#	__LITERAL	16, -2 
#	__AND_STORE	8, 16, __FSR_v1	;v1-and!
#can be optimized as
#	__LITERAL	8, -2 
#	__AND_STORE	8, 8, __FSR_v1	;v1-and!
#	
#
#
#	__FETCH  	8, 16, __FSR_v1	;v1@
#	__STORE  	8, 16, __FSR_v2	;v2!
#can be optimized as
#	__FETCH  	8, 8, __FSR_v1	;v1@
#	__STORE  	8, 8, __FSR_v2	;v2!
#
#
#	__LITERAL	16, 255 
#	_WORD__3E_byte_1	;>byte
#can be optimized as
#	__LITERAL	8, 255 
#
#
#	__FETCH  	xx, 16, __FSR_v1	;v1@
#	_WORD__3E_byte_1	;>byte
#can be optimized as
#	__FETCH  	xx, 8, __FSR_v1	;v1@
#	
#
#sources:
#	__LITERAL	<STACK_WIDTH>, xxx 
#	__FETCH  	<VAR_WIDTH>, <STACK_WIDTH>, xxx
#
#destinations:
#	__STORE  	<VAR_WIDTH>, <STACK_WIDTH>, xxx
#	__PLUS_STORE  	<VAR_WIDTH>, <STACK_WIDTH>, xxx
#	__AND_STORE  	<VAR_WIDTH>, <STACK_WIDTH>, xxx
#	__OR_STORE  	<VAR_WIDTH>, <STACK_WIDTH>, xxx
#	__XOR_STORE  	<VAR_WIDTH>, <STACK_WIDTH>, xxx


sub splitline 
{
   $line=@_[0];
   ($data,@comment)=split(/;/,$line);
   ($label,$command,$par1,$par2,$par3)=split(/[, \t]+/,$data);
}

sub modifiedLine 
{
   if ($par3) 
   {
      return "$label\t$command\t$par1, $par2, $par3\t;@comment  OPTIMIZED";
   }
   else
   {
      return "$label\t$command\t$par1, $par2\t;@comment  OPTIMIZED";
   }
}
  
sub is_tobyte() 
{
   return $command=~/_WORD__3E_byte_1/;
}

sub is_store() 
{
   return $command=~/__([A-Z]+_)?STORE/;
}
sub is_literal 
{
   return $command=~/__LITERAL/
}

sub optimize_literal 
{
   $literal_width=$par1;
   if ($literal_width<16) { return; }

   splitline($currentLine);
   $x=is_tobyte();
   if (is_tobyte() && $literal_width==16) 
   {
      splitline($prevLine);
      $par1=8;
      $prevLine=modifiedLine();
      $currentLine="##";
   }
   if (is_store() && $par1<$literal_width) 
   {
      $var_width=$par1;
      splitline($prevLine);
      $par1=$var_width;
      $prevLine=modifiedLine();
      splitline($currentLine);
      $par2=$var_width;
      $currentLine=modifiedLine();
   }
}

sub optimize_fetch
{
   $fetch_var=$par1;
   $fetch_width=$par2;
   if ($fetch_width<16) { return; }

   splitline($currentLine);
   if (is_tobyte() && $fetch_width==16) 
   {
      splitline($prevLine);
      $par2=8;
      $prevLine=modifiedLine();
      $currentLine="##";
   }
   if (is_store() && $par1<$par2) 
   {
      $var_width=$par1;
      splitline($prevLine);
      $par2=$var_width;
      $prevLine=modifiedLine();
      splitline($currentLine);
      $par2=$var_width;
      $currentLine=modifiedLine();
   }
}

sub printline
{
   $l=@_[0];
   if ($l!~/##/) 
   {
     print "$l\n";
     splitline($l);
     if (is_literal()) 
     {
        if (  $par1==8  && ($par2>255 || $par2<-128)
           || $par1==16 && ($par2>65536 || $par2<-32768)
           ) 
        {
           print " MESSG \"Warning: literal out of range\"\n";
        }
     }
   }
}

$prevLine="##";  
$command="";
while (<STDIN>) 
{ 
  chomp($_);
  $currentLine=$_;
  if (is_literal())
  {
     optimize_literal();
  }
  if ($command=~/__FETCH/)
  {
     optimize_fetch();
  }
  printline($prevLine);
  
  splitline($currentLine);
  $prevLine=$currentLine;
}
printline($prevLine);



