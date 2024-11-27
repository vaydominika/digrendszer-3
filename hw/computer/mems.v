`include "defs.v"

// Container for memory chuncks

module mems
  #(
    //parameter AW= 17, // address width in bits
    parameter WIDTH = 32, // cell size in bits
    parameter LOMEM_SIZE= 65536, // in words
    parameter HIMEM_SIZE= 65536, // in words
    parameter LOMEM_CONTENT = "", // name of hex file
    parameter PMON_CONTENT= ""
    )
   (
    input wire		    clk,
    input wire [WIDTH-1:0]  din,
    input wire		    wen,
    input wire [31:0]	    addr,
    input wire		    cs_lomem,
    input wire		    cs_pmon,
    input wire		    cs_himem,
    
    output wire [WIDTH-1:0] dout
    );

   wire [WIDTH-1:0]	   dout_lomem, dout_pmon, dout_himem;

   memory_bysize
     #( .WIDTH(WIDTH),
	//.AW(AW),
	.SIZE(LOMEM_SIZE),
	.CONTENT(LOMEM_CONTENT)
	)
   lomem
     (
      .clk(clk),
      .din(din),
      .wen(wen),
      .addr(addr),
      .cs(cs_lomem),
      .dout(dout_lomem)
      );
   
   memory_bysize
     #( .WIDTH(WIDTH),
	//.AW(12/*AW*/),
	.SIZE(4096),
	.CONTENT(PMON_CONTENT)
	)
   pmonmem
     (
      .clk(clk),
      .din(din),
      .wen(wen),
      .addr(addr),
      .cs(cs_pmon),
      .dout(dout_pmon)
      );

   generate
      case (HIMEM_SIZE)
	0: assign dout_himem= 0;
	default:
	  memory_bysize
	  #( .WIDTH(WIDTH),
	     //.AW(AW),
	     .SIZE(HIMEM_SIZE)
	     )
	himem
	  (
	   .clk(clk),
	   .din(din),
	   .wen(wen),
	   .addr(addr),
	   .cs(cs_himem),
	   .dout(dout_himem)
	   );
      endcase
   endgenerate
   
   assign dout=	
		cs_pmon ?dout_pmon :
		cs_lomem?dout_lomem:
		cs_himem?dout_himem:
		0;
   
endmodule // mems
