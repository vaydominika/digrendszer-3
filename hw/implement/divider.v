module divider
  #(
    WIDTH=32
    )
   (
    input wire 		   i,
    input wire [WIDTH-1:0] n,
    input wire 		   reset,
    output wire 	   o
    );

   reg [WIDTH-1:0] 	   cnt;
   wire [WIDTH-1:0] 	   n2;
   assign n2= {1'b0,n[WIDTH-2:1]};
   
   initial cnt=0;

   wire 		   last= cnt==n2-1;
   always @(posedge i)
     begin
	
     end
   
endmodule // divider
