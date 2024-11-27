module reg2in
  #(
    parameter WIDTH=32
    )
   (
    input wire 	       clk,
    input wire 	       reset,
    input wire 	       wen1,
    input wire 	       wen2,
    input [WIDTH-1:0]  din1,
    input [WIDTH-1:0]  din2,
    output [WIDTH-1:0] dout
    );

   reg [WIDTH-1:0]     r;

   always @(posedge clk/*, posedge reset*/)
     begin
	if (reset)
	  r<= 0;
	else if (wen1)
	  r<= din1;
	else if (wen2)
	  r<= din2;
     end

   assign dout= r;
   
endmodule // reg2in
