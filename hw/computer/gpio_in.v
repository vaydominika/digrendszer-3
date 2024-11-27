module gpio_in
  #(
    parameter WIDTH= 32
    )
   (
    input wire 		    clk,
    input wire 		    cs,
    input wire 		    wen,
    input wire [WIDTH-1:0]  din,

    output wire [WIDTH-1:0] dout,

    input wire [WIDTH-1:0]  io_in
    );

   reg [WIDTH-1:0] 	    sample;

   initial sample= 0;
   
   always @(posedge clk)
     begin
	if (cs)
	  sample<= io_in;
     end

   assign dout= sample;
   
endmodule // gpio_in
