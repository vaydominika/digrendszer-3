module brd_ctrl
  #(
    parameter WIDTH= 32
    )
   (
    input wire	       clk,
    input wire	       reset,
    input wire	       cs,
    input wire	       wen,
    input wire [WIDTH-1:0]  din,

    output wire [WIDTH-1:0] dout,
    
    output reg [WIDTH-1:0] ctrl_out
    );
   

   initial
     begin
	ctrl_out= 0;
     end

   always @(posedge clk, posedge reset)
     begin
	if (reset)
	  begin
	     ctrl_out<= 0;
	  end
	else if (cs & wen)
	  begin
	     ctrl_out<= din;
	  end
     end

   assign dout= ctrl_out;
   
endmodule // brd_ctrl
