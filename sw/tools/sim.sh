#!/bin/bash

if [ -d $HOME/prj/ucsim_main ]; then
    SIM=$HOME/prj/ucsim_main/src/sims/p1516.src/ucsim_p1516
else
    SIM=ucsim_p1516
fi

function tt()
{
    sleep 1
    xfce4-terminal -T "$1" -x telnet localhost "$2" &
}

i=0
P=$(pwd)
while [ ! -f ${P}/.version -a $i -lt 10 ]; do
    P=${P}/..
done
echo P=$P
PMON=${P}/sw/pmon

tt "UART" 5555 &
tt "cmd1" 6666 &
tt "cmd2" 6666 &

#xfce4-terminal -T "UART" -e "./sw/tools/tnto 5555" &
#xfce4-terminal -T "cmd1" -e "./sw/tools/tnto 6666" &
#xfce4-terminal -T "cmd2" -e "./sw/tools/tnto 6666" &

I="-I if=rom[0xffff]"
$SIM -t2 -Z6666 -S uart=0,port=5555 $I -g -e "uart0_check_often=1" $1 ${PMON}/pmon.p2h
