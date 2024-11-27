start "UART" "%ProgramFiles(x86)%\teraterm\ttermpro.exe" /W=UART /T=1 telnet://localhost:5555
start "cmd1" "%ProgramFiles(x86)%\teraterm\ttermpro.exe" /W=cmd1 /T=1 telnet://localhost:6666
start "cmd2" "%ProgramFiles(x86)%\teraterm\ttermpro.exe" /W=cmd2 /T=1 telnet://localhost:6666

set arg1=%1

ucsim_p1516 -t2 -Z6666 -S uart=0,port=5555 -I if=rom[0xffff] -g -e "uart0_check_often=1" sw/pmon/pmon %arg1%
