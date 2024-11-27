module alu1 //(op,ci,zi,si,vi,ai,bi,res,co,vo,zo,so);
  #(
    parameter WIDTH=8,
    parameter op_add= 5'd0,
   parameter op_adc= 5'd1,
   parameter op_sub= 5'd2,
   parameter op_sbb= 5'd3,
   parameter op_inc= 5'd4,
   parameter op_dec= 5'd5,
   parameter op_and= 5'd6,
   parameter op_or = 5'd7,
   parameter op_xor= 5'd8,
   parameter op_shl= 5'd9,
   parameter op_shr= 5'd10,
   parameter op_rol= 5'd11,
   parameter op_ror= 5'd12,
   parameter op_mul= 5'd13,
   parameter op_div= 5'd14,
   parameter op_cmp= 5'd15,
   parameter op_sha= 5'd16,
   parameter op_stc= 5'd17,
   parameter op_clc= 5'd18,
   parameter op_muh= 5'd19
    )
   (
    input wire [5:0] 	    op,
   
    input wire 		    ci,
    input wire 		    vi,
    input wire 		    zi,
    input wire 		    si,
   
    input wire [WIDTH-1:0]  ai,
    input wire [WIDTH-1:0]  bi,
    input wire [WIDTH-1:0]  di,
    
    output wire [WIDTH-1:0] res,
    output wire 	    co,
    output wire 	    vo,
    output wire 	    zo,
    output wire 	    so
    );
   
   wire 		    cin;
   wire [WIDTH-1:0] 	    op1;
   wire [WIDTH-1:0] 	    op2;
   
   
   //parameter op_tst= 5'd8;

   assign op1= ai;

   assign cin= (op==op_add)?0:
	       (op==op_sub)?1:
	       (op==op_cmp)?1:
	       (op==op_inc)?1:
	       (op==op_dec)?0:
	       ci;

   assign op2= (op==op_sub)?~bi:
	       (op==op_sbb)?~bi:
	       (op==op_cmp)?~bi:
	       (op==op_inc)?0:
	       (op==op_dec)?~0:
	       bi;

   // classes of operations
   wire 		   op_arithmetic;
   wire 		   op_logical;
   wire 		   op_shift_rotate;
   wire 		   op_carry;

   assign op_arithmetic
     = (op==op_add) |
       (op==op_adc) |
       (op==op_sub) |
       (op==op_sbb) |
       (op==op_inc) |
       (op==op_dec) |
       (op==op_cmp) |
       (op==op_mul) |
       (op==op_muh) |
       (op==op_div);
   assign op_logical
     = (op==op_and) |
       (op==op_or)  |
       (op==op_xor);
   assign op_shift_rotate
     = (op==op_shl) |
       (op==op_shr) |
       (op==op_sha) |
       (op==op_rol) |
       (op==op_ror);
   assign op_carry
     = (op==op_stc) |
       (op==op_clc);
      
   // output of ADDRER
   wire [WIDTH-1:0] 	   ares;
   wire 		   aco;
   wire 		   avo;
   
   adder #(WIDTH) adder
     (
      .ci  (cin),
      .ai  (op1),
      .bi  (op2),
      .res (ares),
      .co  (aco),
      .vo  (avo)
      );

   assign so= op_arithmetic?res[WIDTH-1]:
	      si;
   assign zo= op_carry?zi:
	      (op==op_cmp)?~|(ares):
	      ~|(res);
   assign vo= op_arithmetic?avo:
	      vi;
   
   wire [WIDTH*2-1:0] 	   mres;
   assign mres= ai*bi;
   
   assign res= (op==op_add)?ares:
	       (op==op_adc)?ares:
	       (op==op_sub)?ares:
	       (op==op_sbb)?ares:
	       //(op==op_cmp)?ares:
	       (op==op_inc)?ares:
	       (op==op_dec)?ares:
	       (op==op_and)?ai&bi:
	       (op==op_or )?ai|bi:
	       (op==op_xor)?ai^bi:
	       (op==op_shl)?{ai[WIDTH-2:0],1'b0}:
	       (op==op_shr)?{1'b0,ai[WIDTH-1:1]}:
	       (op==op_sha)?{ai[WIDTH-1],ai[WIDTH-1:1]}:
	       (op==op_rol)?{ai[WIDTH-2:0],ci}:
	       (op==op_ror)?{ci,ai[WIDTH-1:1]}:
	       (op==op_mul)?mres[WIDTH-1:0]:
	       (op==op_muh)?mres[2*WIDTH-1:WIDTH]:
	       //(op==op_tst)?ai&bi:
	       di;

   assign co= (op==op_add)?aco:
	      (op==op_adc)?aco:
	      (op==op_sub)?aco:
	      (op==op_sbb)?aco:
	      (op==op_cmp)?aco:
	      (op==op_inc)?aco:
	      (op==op_dec)?aco:
	      //(op==op_and)?ai&bi:
	      //(op==op_or )?ai|bi:
	      //(op==op_xor)?ai^bi:
	      (op==op_shl)?ai[WIDTH-1]:
	      (op==op_shr)?ai[0]:
	      (op==op_sha)?ai[0]:
	      (op==op_rol)?ai[WIDTH-1]:
	      (op==op_ror)?ai[0]:
	      (op==op_stc)?1'b1:
	      (op==op_clc)?1'b0:
	      //(op==op_tst)?ai&bi:
	      ci;

endmodule // alu1
