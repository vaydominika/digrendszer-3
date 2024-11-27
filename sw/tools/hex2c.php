<?php
  error_reporting(E_ALL);
  ini_set("display_errors", "On");
  
  $aw= 12;
  
  if (isset($argv[0]))
  {
    $fin= '';
    for ($i= 1; $i<$argc; $i++)
    {
      if ($argv[$i] == "-m")
      {
	$i++;
	$aw= $argv[$i];
      }
      else if ($argv[$i] == "-v")
      {
	$i++;
	$vf= $argv[$i];
	$ver= trim(file_get_contents($vf));
      }
      else
	$fin= $argv[$i];
    }
  }
  if ($fin=='')
  {
    echo "hex file missing\n";
    exit(1);
  }
  //echo "reading $fin...\n";
  $src= file_get_contents($fin);

  $lsep= "\n\r";
  $l= strtok($src, $lsep);
  $lines= array();
  $lines[]= $l;
  while ($l!==false)
    $lines[]= $l= strtok($lsep);
  $lnr= 0;
  $mem_size= 1 << $aw;
  $sep= " \r\t\v";
  echo "#include \"pmon.h\"\n";
  echo "\n";
  echo "const char * p12cpu_version= \"$ver\";\n";
  echo "\n";
  echo "t_mem pmon[]= {\n";
  foreach ($lines as $l)
  {
    //echo "$lnr procing line $l...\n";
    $li= $l;
    if (preg_match('/^[0-9a-fA-F]/', $l))
    {
      $w1= strtok($l, $sep);
      $w2= strtok($sep);
      $w3= strtok($sep);
      if (($w2=="//C") || ($w2=="//I"))
      {
	$a= intval($w3, 16);
	$d= intval($w1, 16);
	printf("0x%08x, 0x%08x, /* %s */\n", $a, $d, $li);
      }
      $lnr++;
    }
    //$l= strtok($lsep);
  }
  echo "0xffffffff, 0xffffffff\n";
  echo "};\n";

  //for ( ; $lnr < $mem_size; $lnr++)
    //echo "00000000\n";
?>
