`include "version.v"

module sfr
  #(
    parameter WIDTH= 32
    )
   (
    input wire		    clk,
    input wire		    reset,
    input wire [3:0]	    addr,
    input wire		    cen,
    input wire [WIDTH-1:0]  din,
    output wire [WIDTH-1:0] dout
    );

   localparam		    SFR_VERSION= 4'h1;
   localparam		    SFR_FEAT1  = 4'h2;
   localparam		    SFR_FEAT2  = 4'h3;

   localparam		    FEAT1_GETB_EXT= 32'h0000_0001;
   localparam		    FEAT1_SFR     = 32'h0000_0002;
   localparam		    FEAT1_FLAG32  = 32'h0000_0004;
   localparam		    FEAT1_CES     = 32'h0000_0008;
   
   wire [WIDTH-1:0]	    sf1;
   assign sf1= FEAT1_GETB_EXT |
	       FEAT1_SFR |
	       FEAT1_FLAG32 |
	       FEAT1_CES;
   
   assign dout= (addr==SFR_VERSION) ? { 8'd0,
					8'd`VER_MAIN,
					8'd`VER_SUB,
					8'd`VER_REL } :
		(addr==SFR_FEAT1) ? sf1	:
		(addr==SFR_FEAT2) ? 0 :
		0;
   
endmodule // sfr
