#!/bin/bash

cat hex2v_tmpl1.txt

sed 's/[^0-9a-fA-F]//g' $@ |\
    gawk 'BEGIN {
  n=0;
  i=0;

}
{
  while (length($1) < 8)
    $1= $1 "0";
  t[i]= $1;
  i++;
  if (i==8)
  {
    printf("    .INIT_%02X(256'"'"'h", n);
    for (j=8;j>=0;j--)
      printf("%s",t[j]);
    printf("),\n");
    i= 0;
    n++;
  }
}

END {
  for (i=0;i<8;i++)
    t[i]= "00000000";
  while (n<64)
  {
    printf("    .INIT_%02X(256'"'"'h", n);
    for (j=8;j>=0;j--)
      printf("%s",t[j]);
    printf("),\n");
    n++;
  }
}'

cat hex2v_tmpl2.txt
