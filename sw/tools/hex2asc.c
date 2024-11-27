#include <stdio.h>
#include <ctype.h>
#include <unistd.h>
#include <stdlib.h>

int main(int argc, char *argv[])
{
  int mema_size= 12;
  char buf[1024];
  int msize= 1<<mema_size;
  int a= 0;
  char c;
  
  while ((c= getopt(argc, argv,
		    "m:")) >= 0)
    {
      switch (c)
	{
	case 'm':
	  mema_size= strtol(optarg, 0, 0);
	  msize= 1<<mema_size;
	  break;
	}
    }
  
  while (fgets(buf, 1023, stdin))
    {
      if (isxdigit(buf[0]))
	{
	  int i, ok= 1;
	  for (i=0; i<8; i++)
	    ok= ok && isxdigit(buf[i]);
	  if (ok)
	    {
	      buf[8]= 0;
	      printf("%s\n", buf);
	      a++;
	    }
	}
    }
  for ( ; a < msize; a++)
    printf("00000000\n");    
}
