module decoder //(addr, sel);
  #(
    parameter ADDR_SIZE= 4
    )
   (
    input wire [ADDR_SIZE-1:0] 	     addr,
    output wire [(1<<ADDR_SIZE)-1:0] sel
    );
   
   genvar 			     i;

   generate
      for (i= 0; i < (1<<ADDR_SIZE); i= i+1)
	begin:g
	   assign sel[i]= addr==i;
	end
   endgenerate
   
endmodule // decoder

module decoder_en //(addr, sel);
  #(
    parameter ADDR_SIZE= 4
    )
   (
    input wire			     en,
    input wire [ADDR_SIZE-1:0]	     addr,
    output wire [(1<<ADDR_SIZE)-1:0] sel
    );
   
   genvar 			     i;

   generate
      for (i= 0; i < (1<<ADDR_SIZE); i= i+1)
	begin:g
	   assign sel[i]= en & (addr==i);
	end
   endgenerate
   
endmodule // decoder
