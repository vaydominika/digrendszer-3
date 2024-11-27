module pc1 //(clk, reset, cen, wen, din, dout);
  #(
    parameter WIDTH= 32
   )
   (
    input wire 		    clk,
    input wire 		    reset,
    input wire 		    cen,
    input wire 		    wen,
    input wire [WIDTH-1:0]  din,
    output wire [WIDTH-1:0] dout
    );
   
   reg [WIDTH-1:0] 	    r;
   
   always @(posedge clk, posedge reset)
     begin
	if (reset)
	  r <= 0;
	else
	  begin
	     if (cen)
	       r <= r+1;
	     else if (wen)
	       r <= din;
	  end
     end

   assign dout= r;
   
endmodule // pc1
