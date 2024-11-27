<?php

  $max_cath= 5;
  for ($i=0;$i<=$max_cath;$i++)
  $cnt[$i]= 0;
  $nr= 0;
  $bt[0]= 4;
  $bt[1]= 5;
  $bt[2]= 7;
  $bt[3]= 8;
  $bt[4]= 16;
  $bt[5]= 32;
  
  while (($l= fgets(STDIN)) !== false)
  {
    $l= trim($l);
    if ($l == '')
      continue;
    $lorg= $l;
    $w= strtok($l, " \t");
    while ($w != '')
    {
      if ($w == '//I')
      {
	$ts= strtok(" \t");
	$vs= strtok(" \t");
	$v= hexdec($vs);
	if (($v & 0xfffffff0) == 0)
	  $cat= 0;
	else if (($v & 0xffffffe0) == 0)
	$cat = 1;
	else if (($v & 0xffffff80) == 0)
	$cat = 2;
	else if (($v & 0xffffff00) == 0)
	$cat = 3;
	else if (($v & 0xffff0000) == 0)
	$cat = 4;
	else if (($v & 0xffff0000) != 0)
	$cat = 5;
	//echo "$v $cat  ;$lorg\n";
	$cnt[$cat]++;
	$nr++;
      }
      $w= strtok(" \t");
    }
  }
  for ($i=0;$i<=$max_cath;$i++)
  {
    $v= $cnt[$i];
    $p= intval(($v*100)/$nr);
    printf("%-3s %5d %3d ", "#".$bt[$i], $v, $p);
    $l= intval($p*(65/100));
    while ($l--) echo "*";
    echo "\n";
  }
?>
