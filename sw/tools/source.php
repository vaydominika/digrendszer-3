<?php
  $SRC='';
  if (isset($argv[1]))
    $SRC= $argv[1]."\n";
  if ($SRC!='')
  {
    $src= file_get_contents("source.txt");
    if ($src!=$SRC)
      {
	$h= fopen("source.txt", "w");
	fwrite($h, $SRC);
	fclose($h);
      }
  }
?>
