<?php

if (isset($argv[0]))
    {}
else
    {
        if ($_REQUEST['submit'] == "Download verilog file")
            {
                header("Content-Type: application/octet-stream");
                header('Content-Disposition: attachment; filename="mem.v"');
            }
        else
            echo "<pre>";
    }

$hex= $_REQUEST['hex'];
//echo "hex=$hex\n";
$t[0]= "";
$n= 0;
$i= 0;

function print_init($t, $i, $n)
{
    //echo "Printing ".$n."th record, i=$i\n";
    printf("      .INIT_%02X(256'h", $n);
    if ($i < 7)
        for ($j= $i; $j < 8; $j++)
            printf("00000000");
    for ($j= $i-1; $j >= 0; $j--)
        {
            if ($j!=$i-1) printf("_");
            printf("%s", $t[$j]);
        }
    printf("),\n");
}

function proc($l)
{
    global $t, $n, $i;
    $l= preg_replace("/[^0-9a-fA-F]/", "", $l);
    //echo "n=$n i=$i 1. l=$l\n";
    while (strlen($l) < 8)
        $l= "0".$l;
    if (strlen($l) > 8)
        $l= substr($l, -8);
    //echo "n=$n i=$i 2. l=$l\n";
    $t[$i]= $l;
    $i++;
    if ($i == 8)
        {
            if ($n < 64)
                print_init($t, $i, $n);
            $i= 0;
            $n++;
        }
}

echo <<<EOF
`timescale 1ns / 1ps

module mem(A, 
           CLK, 
           CS, 
           I, 
           WR, 
           CSO, 
           O);

    input [31:0] A;
    input CLK;
    input CS;
    input [31:0] I;
    input WR;
   output CSO;
   output [31:0] O;
   
   wire H;
   wire L;
   
   RAMB16_S36 #( 
      .INIT(36'h000000000), 

EOF;

$sep= "\r\n";
$l= strtok($hex, $sep);
while ($l !== false)
    {
        echo "// $l\n";
        $l= trim(preg_replace("/\/\/;.*$/", "", $l));
        if ($l != '')
            proc($l);
        $l= strtok($sep);
    }
//echo "i=$i n=$n\n";

while ($i!=0)
    {
        proc("0");
        //echo "filling last chank $i\n";
    }

for ($j= 0; $j < 8; $j++)
    $t[$j]= "00000000";

for ( ; $n < 64; $n++)
    {
        print_init($t, 8, $n);
        //echo "producing reminding chanks $n\n";
    }

echo <<<EOF

      .INITP_00(256'h0000000000000000000000000000000000000000000000000000000000000000), 
      .INITP_01(256'h0000000000000000000000000000000000000000000000000000000000000000), 
      .INITP_02(256'h0000000000000000000000000000000000000000000000000000000000000000), 
      .INITP_03(256'h0000000000000000000000000000000000000000000000000000000000000000), 
      .INITP_04(256'h0000000000000000000000000000000000000000000000000000000000000000), 
      .INITP_05(256'h0000000000000000000000000000000000000000000000000000000000000000), 
      .INITP_06(256'h0000000000000000000000000000000000000000000000000000000000000000), 
      .INITP_07(256'h0000000000000000000000000000000000000000000000000000000000000000), 
      .SRVAL(36'h000000000), .WRITE_MODE("WRITE_FIRST") ) RAM_L 
      (.ADDR(A[8:0]), 
                  .CLK(CLK), 
                  .DI(I[31:0]), 
                  .DIP({4'd0/*L, L, L, L*/}), 
                  .EN(CS), 
                  .SSR(1'b0/*L*/), 
                  .WE(WR), 
                  .DO(O[31:0]), 
                  .DOP());
   //GND  XLXI_7 (.G(L));
   //VCC  XLXI_9 (.P(H));
   //BUF  XLXI_10 (.I(CS), 
   //             .O(CSO));
endmodule
EOF;
?>
