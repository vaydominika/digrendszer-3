# p12dev Development Environment

**p12dev** is a hardware and sofware development environment for
**p1516** and **p2223** soft processors. It includes verilog models of
the processors, implementation ready code for a microcomputer equipped
with a monitor program, and software development tools, including an
assembler and function library.


## Required tools

- 64 bit operating system (Windows or *nix like OS)
- GNU Make
- Icarus verilog
- GtkWave (on windows inlcuded in Icarus)
- PHP-CLI
- uCsim
- TeraTerm (on windows), xfce4-terminal and telnet (on *nix)
- Vivado


## Starting new project

Open `prj.mk` file with a text editor and set project parameters:

- `PRG` name of the assembly source file, without .asm extension. If
  it is in a subdirectory, path must be used.
  
- `INSTS` number of instructions to simulate.


## Develop software

Create a file with name used in `PRG` parameter and with **.asm**
extension and develop your software. Use CPU instructions documented in

[pcpu](https://danieldrotos.github.io/p12dev/p2223.html)

and use assembler features and directives according to

[pasm](https://danieldrotos.github.io/p12dev/asm.html)


## Compiling and simulating

Open a command window, navigate to development system root directory,
and issue

```
make
```

command. It will

- compile your assembly source
- compile hardware model
- run verilog simulation and generate VCD file
- open VCD file viewer (gtkwave).

The compilation finishes when you close gtkwave window, then you will
got the command prompt back.


## Other operations

```
make progs        ; compile monitor and examples
make sw           ; compile your app only
make hw           ; compile hardware model only
make sim          ; run simulation
make show         ; open gtkwave and show VCD file
make clean        ; delete compiled files
```


## Instruction set simulation

Besides hardware simulation, the system can be simulated in software
level using uCsim simulator. It can be started with

```
make iss
```

command. It starts the simulation and opens three terminal windows,
titled with **UART**, **cmd1**, and **cmd2**. The UART window is
connected to simulated uart, press ENTER in this window to get the
monitor prompt. To start your program, issue

```
g startaddress
```

monitor command, using hexadecimal address. cmd1 and cmd2 windows can
be used to control the simulator, documentation can be found at:

http://www.ucsim.hu


## FPGA implementation

See documentation for detailed instructions how to compile and
download system to an FPGA board.
