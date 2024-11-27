#!/usr/bin/php
<?php
error_reporting(E_ALL);
ini_set("display_errors", "On");
  
$aw= 12;
$as_size= 0;
$chip_at= 0;
$chip_size= false;
$get_last= false;
$limit= 0;

if (isset($argv[0]))
{
    $fin= array();
    for ($i= 1; $i<$argc; $i++)
    {
        if ($argv[$i] == "-m")
        {
            $i++;
            $aw= intval($argv[$i], 0);
        }
        else if ($argv[$i] == "-c")
        {
            $i++;
            $chip_at= intval($argv[$i], 0);
        }
        else if ($argv[$i] == "-cs")
        {
            $i++;
            $chip_size= intval($argv[$i], 0);
        }
        else if ($argv[$i] == "-gl")
        {
            $get_last= true;
        }
        else if ($argv[$i] == "-l")
        {
            $i++;
            $limit= intval($argv[$i], 0);
        }
        else
            $fin[]= $argv[$i];
    }
}

$as_size= 1 << (0+$aw);
if ($chip_size === false)
    $chip_size= $as_size;
$mem= array();
for ($i= 0; $i<$as_size; $i++)
    $mem[$i]= 0;

if (count($fin)==0)
{
    echo "hex,h2p file missing\n";
    exit(1);
}
//echo "reading $fin...\n";
$max_a= 0;
$src= '';
foreach ($fin as $f)
{
    $src= file_get_contents($f);
    $lines= preg_split("/\r\n|\n|\r/", $src);
    
    foreach ($lines as $l)
    {
        //echo "procing line $l... of $f\n";
        $w1= strtok($l, " ");
        $w2= strtok(" ");
        $w3= strtok(" ");
        //echo " w1=$w1 w2=$w2 w3=$w3\n";
        $p1= preg_match('/^[0-9a-fA-F]+$/', $w1);
        $p2= ($w2=='//C') || ($w2=='//I');
        $p3= preg_match('/^[0-9a-fA-F]+$/', $w3);
        //echo " p1=$p1 p2=$p2 p3=$p3\n";
        if ($p1 && $p2 && $p3)
        {
            $a= 0 + intval($w3, 16);
            $v= 0 + intval($w1, 16);
            $mem[$a]= $v;
            //echo "\n CC w1=$w1 w3=$w3 a=$a v=$v m={$mem[$a]}\n\n";
            //printf(" MM %08x %05x\n", $mem[$a], $a);
            if ($a > $max_a)
                $max_a= $a;
        }
    }
}

if ($get_last)
{
    printf("%x\n", $max_a);
}
else
{
    $last_a= $chip_at + $chip_size - 1;
    for ($a= $chip_at; $a <= $last_a; $a++)
    {
        printf("%08x", $mem[$a]);
        //printf(" %05x", $a); echo " {$mem[$a]}";
        echo "\n";
    }
}
if ($limit > 0)
{
    if ($max_a >= $limit)
    {
        $s= sprintf("Memory overrun: %x >= %x\n", $max_a, $limit);
        fwrite(STDERR, $s);
    }
}

exit(0);
?>
