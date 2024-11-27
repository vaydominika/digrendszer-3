`timescale 10ns/1ns

module clock
  #(
    parameter WIDTH=32
    )
   (
    input wire		    clk,
    input wire		    reset,
    input wire [WIDTH-1:0]  addr,
    input wire [WIDTH-1:0]  din,
    input wire		    wen,
    input wire		    cs,
    output wire [WIDTH-1:0] dout
   );

   reg [WIDTH-1:0]	    pre;
   reg [WIDTH-1:0]	    precnt;
   reg [WIDTH-1:0]	    clock;

   wire			    en;
   assign en= |pre;

   wire [15:0]		    sel;
   decoder #(.ADDR_SIZE(4)) dc(.addr(addr[3:0]), .sel(sel));


   /* PRE register to hold cycle number */
   always @(posedge clk)
     begin
	if (reset)
	  pre<= 0;
	else if (cs & wen & sel[1])
	  pre<= din;
     end

   wire reached;
   assign reached= precnt == pre;


   /* Pre counter: freq divider */
   always @(posedge clk)
     begin
	if (reset | reached | (cs & wen & sel[1]))
	  precnt<= 0;
	else if (en)
	  precnt<= precnt+1;
     end


   /* CLOCK register is the actual counter */
   always @(posedge clk)
     begin
	if (reset)
	  clock<= 0;
	else if (reached & en)
	  clock<= clock+1;
	else if (cs & wen & sel[0])
	  clock<= din;
     end


   /* Backward counters */
   reg [WIDTH-1:0] bcnt[2:15];
   genvar	   i;
   generate
      for (i=2;i<16;i=i+1)
        begin
          always @(posedge clk)
	    begin
	      if (reset) bcnt[i]<= 0;
	      else if (reached & en & |bcnt[i]) bcnt[i]<= bcnt[i]-1;
	      else if (cs & wen & sel[i])       bcnt[i]<= din;
	    end
	end
   endgenerate
   
   assign dout= sel[0]?clock:
		sel[1]?pre:
		sel[2]?bcnt[2]:
		sel[3]?bcnt[3]:
		sel[4]?bcnt[4]:
		sel[5]?bcnt[5]:
		sel[6]?bcnt[6]:
		sel[7]?bcnt[7]:
		sel[8]?bcnt[8]:
		sel[9]?bcnt[9]:
		sel[10]?bcnt[10]:
		sel[11]?bcnt[11]:
		sel[12]?bcnt[12]:
		sel[13]?bcnt[13]:
		sel[14]?bcnt[14]:
		sel[15]?bcnt[15]:
		0;
   
endmodule // clock
