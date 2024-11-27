<?php

echo "<h3>Memory symbol generator for Proc1516 project</h3>\n";
ini_set("display_errors", "On");

$asm= '';
if (isset($_REQUEST['get']) && ($_REQUEST['get']!=''))
    $asm= file_get_contents($_REQUEST['get']);

echo <<<EOF
Examples:
[<a href="asm.php?get=examples/array_sum.asm">array_sum</a>]
[<a href="asm.php?get=examples/counter.asm">counter</a>]
[<a href="asm.php?get=examples/light1.asm">light1</a>]
[<a href="asm.php?get=examples/light2.asm">light2</a>]
[<a href="asm.php?get=examples/led.asm">led</a>]
[<a href="asm.php?get=examples/led2.asm">led2</a>]
[<a href="asm.php?get=examples/dim.asm">dim</a>]
<p><form name="f" enctype="multipart/form-data" action="assembler.php" 
method="post">
<textarea rows="30" cols="80" name="src">
$asm
</textarea>
<br>
<input type="submit" name="submit" value="Download verilog file">
<input type="submit" name="submit" value="View verilog file">
<input type="submit" name="submit" value="View hex">
</form>
EOF;

echo <<<EOF
<p><h4>Instruction summary</h4>
<b>Conditions:</b> <TT>S0,S1,C0,C1,Z0,Z1,O0,O1, Z,NZ</tt>
<br><b>Instructions:</b> <tt>NOP [Rd[,Ra[,Rb]]]; LD Rd,Ra; ST Rd,Ra; MOV Rd,Ra; LDL0 Rd,D; LDL Rd,D; LDH Rd,D; CALL D</tt>
<br><b>Arithmetic</b> <tt>ADD Rd,Ra,Rb; ADC Rd,Ra,Rb; SUB Rd,Ra,Rd; SBB Rd,Ra,Rb; MUL Rd,Ra,Rb; DIV Rd,Ra,Rb</tt>
<br><b>Increment:</b> <tt>INC Rd[,Ra]; DEC Rd[,Ra]</tt>
<br><b>Logic:</b> <tt>AND Rd,Ra,Rb; OR Rd,Ra,Rb; XOR Rd,Ra,Rb</tt>
<br><b>Shift:</b> <tt>SHL Rd[,Ra]; SHR Rd[,Ra]; SHA Rd[,Ra]; ROL Rd[,Ra]; ROR Rd[,Ra]</tt>
<br><b>Other:</b> <tt>CMP Rd,Ra,Rb; SETC; CLRC</tt>
EOF;
?>
