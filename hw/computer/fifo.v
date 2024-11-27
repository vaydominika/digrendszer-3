
module fifo
  #(
    parameter WIDTH= 8,
    parameter ADDR_WIDTH= 7
    )
   (
    input wire		    clk,
    input wire		    reset,
    input wire		    rd,
    input wire		    wr,
    input wire [WIDTH-1:0]  din,
    output wire [WIDTH-1:0] dout,
    output wire		    empty,
    output wire		    full,

    output [ADDR_WIDTH-1:0] raddr,
    output [ADDR_WIDTH-1:0] waddr
    );

   reg [ADDR_WIDTH-1:0]	    rd_addr;
   reg [ADDR_WIDTH-1:0]	    wr_addr;

   reg [WIDTH-1:0]	    mem [0:2**ADDR_WIDTH-1];

   wire [ADDR_WIDTH-1:0]    raddr1;
   wire [ADDR_WIDTH-1:0]    waddr1;
   assign raddr1= rd_addr+1;
   assign waddr1= wr_addr+1;
   
   assign empty= rd_addr == wr_addr;
   assign full = rd_addr == waddr1;

   integer		    i;
   initial
     begin
	for (i=0;i<2**ADDR_WIDTH;i=i+1)
	  mem[i]= 0;
     end
   
   /*
   always @(posedge clk)
     begin
	if (reset)
	  rd_addr<= 0;
	else if (rd & ~empty)
	  rd_addr<= raddr1;
     end
    */
   always @(negedge rd, posedge reset)
     begin
	if (reset)
	  rd_addr<= 0;
	else if (~empty)
	  rd_addr<= raddr1;
     end
   
   always @(posedge clk)
     begin
	if (reset)
	  wr_addr<= 0;
	else if (wr & ~full)
	  wr_addr<= waddr1;
     end


   always @(posedge clk)
     begin
	if (wr & ~full)
	  mem[wr_addr]<= din;
     end


   assign dout= mem[rd_addr];
   assign raddr= rd_addr;
   assign waddr= wr_addr;
   
endmodule // fifo
