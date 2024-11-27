`include "defs.v"
`include "hwconf.v"

`unconnected_drive pull0
`ifndef PRG
 `define PRG "sw/progs2/counter3.asc"
`endif

`ifndef AW
 `define AW 17
`endif

`ifndef INSTS
 `define INSTS 1000
`endif

`ifndef CPU_TYPE
 `define CPU_TYPE 1
`endif

`ifdef IVERILOG
module BUFG
(
 input wire I,
 output wire O
 );
   assign O=I;
endmodule
`endif

module tm
  (
   input wire  i,
   output wire o
   );
   reg 	       clk= 0;
   reg 	       ioclk= 0;
   reg 	       reset= 0;
   reg [3:0]   test_sel;
   reg [3:0]   test_rsel;
   reg [31:0]  btn= 0;
   reg [31:0]  sw= 0;
   wire [31:0] test_out, test_reg;
   wire [31:0] porta, portb, portc, portd, brd_ctrl;

   // 1 instruction takes 8 ticks (4 clock period)
   always #1 clk= !clk;
   always #20 ioclk= ~ioclk;

   /* UART connected to computer RxD */
   reg	       ucs= 0;
   reg	       uwen= 1;
   reg [3:0]   uaddr= 0;
   reg [7:0]   udin= 0;
   wire	       utx;
   uart #(.SIM_PRINT(0))
   sender(.clk(clk),.reset(reset),
	  .cs(ucs),
	  .wen(uwen),
	  .addr(uaddr),
	  .din({24'b0,udin}),
	  .RxD(1'b1),
	  .TxD(utx));

   /* Send one character on UART to computer */
   task send;
      input [7:0] char;
      begin
	 udin=char;
	 uaddr=0;
	 ucs=1;
	 #2 ucs=0;
      end
   endtask // send

    // Setup UART
   initial
     begin
	#1000 udin=8'd3; uaddr=1; ucs=1; #2 ucs=0;
     end

   // Send test signals to computer via UART   
   initial
     begin
	#151000 send(8'd109); // Send "m 0" command
	#2500   send(8'h20);
	#2500   send(8'h30);
	#2500   send(8'ha);
	#27000  send(8'd103); // wait answer, then send "g 1" command
	#2500   send(8'h20);
	#2500   send(8'h31);
	#2500   send(8'ha);
     end

   // Computer under test   
   comp
     #(
       .WIDTH(32),
       .MEM_ADDR_SIZE(`AW),
       .PROGRAM( `PRG ),
       .CPU_TYPE(`CPU_TYPE),
       .COMP_TYPE(`COMP_TYPE),
       .PMON_CONTENT("./sw/pmon/pmon_chip.asc")
       )
   comp
     (
      .clk(clk),
      .reset(reset),
      .PORTI(btn),
      .PORTJ(sw),
      .PORTA(porta),
      .PORTB(portb),
      .PORTC(portc),
      .PORTD(portd),
      .BRD_CTRL(brd_ctrl),
      .test_sel(test_sel),
      .test_out(test_out),
      .test_rsel(test_rsel),
      .test_reg(test_reg),
      .clk10m(ioclk),
      .RxD(utx)
      );

   // Select signals for computer test outputs
   initial
     begin
	test_sel= 4'd3;
	test_rsel= 4'd12;
     end

   // Generate RESET at start
   initial
     begin
	reset= 1;
	#10 reset= 0;
     end

   // Simulate button presses (and releases)
   initial
     begin
	#5000 btn= 4;
	#100 btn= 0;
	#100000 btn= 2;
	#10000 btn= 0;
     end

   // Simulate switch ON/OFF
   initial
     begin
	#500 sw= 2;
	#100 sw= 0;
     end
   
   // Produce output DUMP file
   // Stop after simulating INSTS cpu instructions
   initial
     begin
	$dumpfile("hw/tm.vcd");
	$dumpvars;
	#(`INSTS*8 + 14) $finish;
     end
   
endmodule // tm
