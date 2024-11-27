`include "defs.v"

module memory_1in_1out
  #(
    parameter WIDTH	= 32,	// cell size in bits
    parameter ADDR_SIZE	= 10,	// in bits
    parameter CONTENT	= ""	// name of hex file
    )
   (
    input wire 		       clk,
    input wire [WIDTH-1:0]     din,
    input wire 		       wen,
    input wire [ADDR_SIZE-1:0] ra,
    input wire 		       cs,
    
    output reg [WIDTH-1:0]     dout
    );

   reg [WIDTH-1:0] 	      mem_array[0:(1<<ADDR_SIZE)-1];

   integer 		      i;
   reg [128*8:1] 	      string;
   initial
     begin
	// Initialize memory content to zero
	//for (i= 0; i < (1<<ADDR_SIZE); i= i+1)
	  //mem_array[i]= 0;
	if (CONTENT != "")
	  begin
	     $display("Memory CONTENT=%s", CONTENT);		      
	     string= { `SW_PATH, "/", CONTENT };
	     $display("Init memory with %s", string);
	     $display("Mem addr width %d", ADDR_SIZE);
	     $readmemh(string, mem_array);
	     for (i=0;i<5;i=i+1)
	       $display("Mem[%x]=%x",i,mem_array[i]);
	  end
	//dout= 0;	
     end
  
   always @(posedge clk)
     begin
	if (cs & wen)
	  mem_array[/*wa*/ra]<= din;
     end

   //assign dout= mem_array[ra];
   always @(posedge clk)
     if (cs)
       dout<= mem_array[ra];
   
endmodule // memory_1in_1out




module memory_bysize
  #(
    parameter WIDTH = 32, // cell size in bits
    //parameter AW = 16, // bits of address bus
    parameter SIZE = 65536, // in words
    parameter CONTENT = ""	// name of hex file
    )
   (
    input wire		   clk,
    input wire [WIDTH-1:0] din,
    input wire		   wen,
    input wire [31:0]	   addr,
    input wire		   cs,
    
    output reg [WIDTH-1:0] dout
    );
   
   
   function [31:0] size2aw;
      input [31:0]	       size;
      reg [31:0]	       aw, s;
      reg [31:0]	       ret;
      begin
	 if (size==0)
	   size2aw= 0;
	 else
	   begin
	      s= 32'hffffffff;
	      for (aw=32; aw>=1; s= s>>1)
		begin
		   //$display("checking aw=%d for s=%h (size=%h)",aw,s,size);
		   if (size<=s+1)
		     begin
			//$display("ret=%d",aw);
			ret= aw;
		     end
		   aw= aw-1;
		end
	      size2aw= ret;
	   end
      end
   endfunction // size2aw

   
   reg [WIDTH-1:0] 	      mem_array[0:SIZE-1];

   integer 		      i, aw, mask;
   reg [128*8:1] 	      string;
   
   initial
     begin
	// Initialize memory content to zero
	//for (i= 0; i < (1<<ADDR_SIZE); i= i+1)
	  //mem_array[i]= 0;
	aw= size2aw(SIZE);
	//$display("aw for size=40000", size2aw(40000));
	//$display("aw for size=32769", size2aw(32769));
	//$display("aw for size=32768", size2aw(32768));
	//$display("aw for size=32767", size2aw(32767));
	mask= (1<<aw)-1;
	if (CONTENT != "")
	  begin
	     $display("Memory CONTENT=%s", CONTENT);		      
	     string= { `SW_PATH, "/", CONTENT };
	     $display("Init memory with %s", string);
	     $display("Mem addr width %d size %d, mask=%h", aw, SIZE, mask);
	     $readmemh(string, mem_array);
	     for (i=0;i<5;i=i+1)
	       $display("Mem[%x]=%x",i,mem_array[i]);
	  end
	//dout= 0;	
     end
  
   always @(posedge clk)
     begin
	if (cs & wen)
	  mem_array[addr & mask]<= din;
     end

   //assign dout= mem_array[ra];
   always @(posedge clk)
     if (cs)
       dout<= mem_array[addr & mask];
   
endmodule // memory_bysize
