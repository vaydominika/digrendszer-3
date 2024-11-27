module gpio_out4 //(clk, reset, cs, we, addr, din, dout);
  #(
    parameter WIDTH= 32
    )
   (
    input wire 	       clk,
    input wire 	       reset,
    input wire 	       cs,
    input wire 	       wen,
    input wire [1:0]   addr,
    input [WIDTH-1:0]  din,

    output [WIDTH-1:0] dout,
    
    output [WIDTH-1:0] porta,
    output [WIDTH-1:0] portb,
    output [WIDTH-1:0] portc,
    output [WIDTH-1:0] portd
    );
   
   reg [WIDTH-1:0]     regs [3:0];

   initial
     begin
	regs[0]= 0;
	regs[1]= 0;
	regs[2]= 0;
	regs[3]= 0;
     end

   always @(posedge clk, posedge reset)
     begin
	if (reset)
	  begin
	     regs[0]<= 0;
	     regs[1]<= 0;
	     regs[2]<= 0;
	     regs[3]<= 0;
	  end
	else if (cs & wen)
	  begin
	     regs[addr]<= din;
	  end
     end

   assign dout= regs[addr];

   assign porta= regs[0];
   assign portb= regs[1];
   assign portc= regs[2];
   assign portd= regs[3];
   
endmodule // gpio_out4
