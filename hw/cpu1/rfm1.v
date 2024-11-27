module rfm1
#(
   parameter WIDTH= 32,
   parameter ADDR_SIZE= 4
  )
(
   input wire 		      clk,
   input wire 		      reset,
   input wire 		      wen,
   input wire 		      cen,
   input wire 		      link,
   input wire [ADDR_SIZE-1:0] wa,
   input wire [WIDTH-1:0]     din,
   input wire [ADDR_SIZE-1:0] ra,
   output wire [WIDTH-1:0]    da,
   input wire [ADDR_SIZE-1:0] rb,
   output wire [WIDTH-1:0]    db,
   input wire [ADDR_SIZE-1:0] rd,
   output wire [WIDTH-1:0]    dd,
   input wire [ADDR_SIZE-1:0] rt,
   output wire [WIDTH-1:0]    dt,
   output [WIDTH-1:0] 	      last,
   output [WIDTH-1:0] 	      r14,
   output [WIDTH-1:0] 	      r13
);

   wire [WIDTH-1:0] 	   pc_out;
   reg [WIDTH-1:0] 	   reg_array[0:(1<<ADDR_SIZE)-1-1];
   pc1 pc_reg
     (
      .clk(clk),
      .reset(reset),
      .cen(cen),
      .wen(wen & (wa==((1<<ADDR_SIZE)-1))),
      .din(din),
      .dout(pc_out)
      );
   
   integer 		   i;
   initial
     begin
	for (i= 0; i < (1<<ADDR_SIZE)-1; i= i+1)
	  reg_array[i]= 0;
     end
   
   always @(posedge clk)
     begin
	if (link)
	  begin
	     reg_array[(1<<ADDR_SIZE)-1-1]<= pc_out+1;
	  end
	else if (wen)
	  begin
	     reg_array[wa]<= din;
	  end
     end
   /*   
   mx16wp mx(ra,
	     ro0,
	     ro1,
	     ro2,
	     ro3,
	     ro4,
	     ro5,
	     ro6,
	     ro7,
	     ro8,
	     ro9,
	     ro10,
	     ro11,
	     ro12,
	     ro13,
	     ro14,
	     ro15,
	     dout);
   defparam mx.WIDTH=32;
   */
   assign da= (ra==((1<<ADDR_SIZE)-1))?pc_out:reg_array[ra];
   assign db= (rb==((1<<ADDR_SIZE)-1))?pc_out:reg_array[rb];
   assign dd= (rd==((1<<ADDR_SIZE)-1))?pc_out:reg_array[rd];
   assign dt= (rt==((1<<ADDR_SIZE)-1))?pc_out:reg_array[rt];
   assign last= pc_out;
   assign r14= reg_array[4'd14];
   assign r13= reg_array[4'd13];

   wire [31:0] r0, r1,  r2,  r3;
   wire [31:0] r4, r5,  r6,  r7;
   wire [31:0] r8, r9, r10, r11;
   wire [31:0] r12;
   assign  r0= reg_array[4'd0];
   assign  r1= reg_array[4'd1];
   assign  r2= reg_array[4'd2];
   assign  r3= reg_array[4'd3];
   assign  r4= reg_array[4'd4];
   assign  r5= reg_array[4'd5];
   assign  r6= reg_array[4'd6];
   assign  r7= reg_array[4'd7];
   assign  r8= reg_array[4'd8];
   assign  r9= reg_array[4'd9];
   assign r10= reg_array[4'd10];
   assign r11= reg_array[4'd11];
   assign r12= reg_array[4'd12];
   
endmodule // rfm1
