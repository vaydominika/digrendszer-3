module getb
  #(
    parameter WIDTH= 32
    )
   (
    input wire [WIDTH-1:0]  opd,
    input wire [WIDTH-1:0]  opb,
    input wire [WIDTH-1:0]  byte_idx,
    input wire [1:0] 	    ex_mode,
    output wire [WIDTH-1:0] res
    );

   wire [7:0]		    g_byte;
   assign g_byte= (byte_idx==2'b00)?opb[7:0]:
		  (byte_idx==2'b01)?opb[15:8]:
		  (byte_idx==2'b10)?opb[23:16]:
		  (byte_idx==2'b11)?opb[31:24]:
		  7'b0;
   wire [WIDTH-8:0] 	    ex;
   assign ex= (ex_mode == 2'b00) ? opd[WIDTH-1:8] : // NEX
	      (ex_mode == 2'b10) ? {(WIDTH-8){1'b0}} : // ZEX
	      (ex_mode == 2'b11) ? {(WIDTH-8){g_byte[7]}} : // SEX
	      opd[WIDTH-1:8];
   
   assign res= {ex, g_byte};
   
endmodule // getb
