`include "defs.v"

module alu2
  #(
    parameter WIDTH=32,
    parameter IWIDTH=16
    )
   (
    input wire [5:0]	    op, // operation code
    
    input wire [WIDTH-1:0]  fi, // input flags
    input wire [WIDTH-1:0]  bi, // Rb content
    input wire [WIDTH-1:0]  di, // Rd content
    input wire [IWIDTH-1:0] im, // immediate value
    
    output wire [WIDTH-1:0] res, // result
    output wire [WIDTH-1:0] fo,  // output flags

    output wire		    wb_en,  // enable write-back
    output wire		    flag_en // enable flags write 
    );

   // input flags
   wire 		    ci= fi[`CIDX];
   wire 		    vi= fi[`VIDX];
   wire 		    zi= fi[`ZIDX];
   wire 		    si= fi[`SIDX];
   
   // classes of inst sets
   wire 		    op_2reg;
   wire 		    op_2im;
   wire 		    op_1;
   assign op_1= op[5];
   assign op_2im= !op_1 & op[4];
   assign op_2reg= !op_1 & !op[4];

   // second operand
   wire [WIDTH-1:0] 	    op2;
   wire [WIDTH-1:0] 	    zex_im;
   wire [WIDTH-1:0] 	    sex_im;
   wire [WIDTH-1:0] 	    oex_im;
   assign zex_im= {16'h0, im};
   assign sex_im= {
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im[15],
		   im
		   };
   assign oex_im= {16'hffff, im};
   assign op2= op_2reg?bi:
	       (op[3:0]=={4'b1011})? zex_im :
	       (op[3:0]=={4'b1111})? oex_im :
	       (op[3:2]=={2'b00})? zex_im :
	       (op[3:2]=={2'b11})? zex_im :
	       sex_im;

   // central adder
   wire 		    cin;
   assign cin= (op[3:0]==4'h4)?  0 : // add
	       (op[3:0]==4'h5)? ci : // adc
	       (op[3:0]==4'h6)?  1 : // sub
	       (op[3:0]==4'h7)? ci : // sbb
	       (op[3:0]==4'h8)?  1 : // cmp
	       (op[3:0]==4'ha)?  0 : // plus
	       ci;
   wire [WIDTH-1:0] 	    adder_op2;
   assign adder_op2= (op[3:0]==4'h4)?  op2 : // add
		     (op[3:0]==4'h5)?  op2 : // adc
		     (op[3:0]==4'h6)? ~op2 : // sub
		     (op[3:0]==4'h7)? ~op2 : // sbb
		     (op[3:0]==4'h8)? ~op2 : // cmp
		     (op[3:0]==4'ha)?  op2 : // plus
		     op2;
   
   wire [WIDTH-1:0] 	    res_adder;
   wire 		    c_adder;
   wire 		    v_adder;
   adder #(.WIDTH(WIDTH)) adder
     (
      .ci((op[5:0]==6'b100101)?1'b1:cin),
      .ai((op[5:0]==6'b100101)?32'h0:di),
      .bi((op[5:0]==6'b100101)?~di:adder_op2),
      .res(res_adder),
      .co(c_adder),
      .vo(v_adder)
      );
   
   // results
   wire [WIDTH-1:0] 	    res_2im;
   wire [WIDTH-1:0] 	    res_2reg;
   wire [WIDTH-1:0] 	    res_2;
   wire [WIDTH-1:0] 	    res_1;

   wire [WIDTH-1:0] 	    res_sed;
   assign res_sed= {
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31],
		    op2[31]
		    };
   
   assign res_2reg= (op[3:0]==4'h0)? op2 :
		    (op[3:0]==4'h1)? di :
		    (op[3:0]==4'h2)? di :
		    (op[3:0]==4'h3)? res_sed :
		    di;
   
   wire [WIDTH-1:0] 	    res_mvl;
   wire [WIDTH-1:0] 	    res_mvh;
   wire [WIDTH-1:0] 	    res_mvzl;
   wire [WIDTH-1:0] 	    res_mvs;
   assign res_mvl = { di[31:16], op2[15:0] };
   assign res_mvh = { op2[15:0], di[15:0] };
   assign res_mvzl= { 16'd0, op2[15:0] };
   assign res_mvs = { res_sed };		     
   assign res_2im=  (op[3:0]==4'h0)? res_mvl :
		    (op[3:0]==4'h1)? res_mvh :
		    (op[3:0]==4'h2)? res_mvzl :
		    (op[3:0]==4'h3)? res_mvs :
		    di;

   assign res_2= (op[3:2]==2'b00)? ((op_2reg?res_2reg:res_2im)) :
		 (op[3:0]==4'h4)? res_adder :
		 (op[3:0]==4'h5)? res_adder :
		 (op[3:0]==4'h6)? res_adder :
		 (op[3:0]==4'h7)? res_adder :
		 (op[3:0]==4'h8)? res_adder :
		 (op[3:0]==4'h9)? di * op2 :
		 (op[3:0]==4'ha)? res_adder :
		 (op[3:0]==4'hb)? di & op2 : // BTST: AND zex
		 (op[3:0]==4'hc)? di & op2 : // TEST: AND zex (no BW)
		 (op[3:0]==4'hd)? di | op2 :
		 (op[3:0]==4'he)? di ^ op2 :
		 (op[3:0]==4'hf)? di & op2 : // AND : AND oex
		 di;

   wire [WIDTH-1:0] 	    res_zeb;
   wire [WIDTH-1:0] 	    res_seb;
   wire [WIDTH-1:0] 	    res_zew;
   wire [WIDTH-1:0] 	    res_sew;
   assign res_zeb= { 24'd0, di[7:0] };
   assign res_zew= { 16'd0, di[15:0] };
   assign res_seb= {
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7],
		    di[7:0]
		    };
   assign res_sew= {
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15],
		    di[15:0]
		    };
   wire [WIDTH-1:0] 	    res_ror;
   wire [WIDTH-1:0] 	    res_rol;
   wire [WIDTH-1:0] 	    res_shl;
   wire [WIDTH-1:0] 	    res_shr;
   wire [WIDTH-1:0] 	    res_sha;
   assign res_ror= { ci, di[WIDTH-1:1] };
   assign res_rol= { di[WIDTH-2:0], ci };
   assign res_shl= { di[WIDTH-2:0], 1'b0 };
   assign res_shr= { 1'b0, di[WIDTH-1:1] };
   assign res_sha= { di[WIDTH-1], di[WIDTH-1:1] };
   assign res_1= (op[3:0]==4'h0)? res_zeb :
		 (op[3:0]==4'h1)? res_zew :
		 (op[3:0]==4'h2)? res_seb :
		 (op[3:0]==4'h3)? res_sew :
		 (op[3:0]==4'h4)? ~di :
		 (op[3:0]==4'h5)? res_adder :
		 (op[3:0]==4'h6)? res_ror :
		 (op[3:0]==4'h7)? res_rol :
		 (op[3:0]==4'h8)? res_shl :
		 (op[3:0]==4'h9)? res_shr :
		 (op[3:0]==4'ha)? res_sha :
		 (op[3:0]==4'hb)? di :
		 (op[3:0]==4'hc)? di :
		 (op[3:0]==4'hd)? di :
		 (op[3:0]==4'he)? fi :
		 (op[3:0]==4'hf)? di :
		 di;

   // Calculate flags
   wire 		    co, zo, so, vo;
   assign zo= (op[5:0]==6'b101111)?di[`ZIDX]:	// setf
	      (op[5:0]==6'b101100)?zi:		// sec
	      (op[5:0]==6'b101101)?zi:		// clc
	      ~|res;
   assign so= (op[5:0]==6'b101111)?di[`SIDX]:	// setf
	      (op[5:0]==6'b101100)?si:		// sec
	      (op[5:0]==6'b101101)?si:		// clc
	      res[WIDTH-1];
   wire 		    co_reg, co_im, co_1;
   assign co_reg= (op[3:0]==4'h0)? ci :
		  (op[3:0]==4'h1)? ci :
		  (op[3:0]==4'h2)? ci :
		  (op[3:0]==4'h3)? ci :
		  (op[3:0]==4'h4)? c_adder :
		  (op[3:0]==4'h5)? c_adder :
		  (op[3:0]==4'h6)? c_adder :
		  (op[3:0]==4'h7)? c_adder :
		  (op[3:0]==4'h8)? c_adder :
		  (op[3:0]==4'h9)? ci :
		  (op[3:0]==4'ha)? ci :
		  (op[3:0]==4'hb)? ci :
		  (op[3:0]==4'hc)? ci :
		  (op[3:0]==4'hd)? ci :
		  (op[3:0]==4'he)? ci :
		  (op[3:0]==4'hf)? ci :
		  ci;
   assign co_im = co_reg;
   assign co_1  = (op[3:0]==4'h0)? ci :
		  (op[3:0]==4'h1)? ci :
		  (op[3:0]==4'h2)? ci :
		  (op[3:0]==4'h3)? ci :
		  (op[3:0]==4'h4)? ci :
		  (op[3:0]==4'h5)? c_adder :
		  (op[3:0]==4'h6)? di[0] :
		  (op[3:0]==4'h7)? di[WIDTH-1] :
		  (op[3:0]==4'h8)? di[WIDTH-1] :
		  (op[3:0]==4'h9)? di[0] :
		  (op[3:0]==4'ha)? di[0] :
		  (op[3:0]==4'hb)? ci :
		  (op[3:0]==4'hc)? 1'b1 :
		  (op[3:0]==4'hd)? 1'b0 :
		  (op[3:0]==4'he)? ci :
		  (op[3:0]==4'hf)? di[`CIDX] :
		  ci;
   assign co= (op[5:4]==2'b00)? co_reg :
	      (op[5:4]==2'b01)? co_im :
	      (op[5:4]==2'b10)? co_1 :
	      ci;

   wire 		    vo_reg, vo_im, vo_1;
   assign vo_reg= (op[3:0]==4'h0)? vi :
		  (op[3:0]==4'h1)? vi :
		  (op[3:0]==4'h2)? vi :
		  (op[3:0]==4'h3)? vi :
		  (op[3:0]==4'h4)? v_adder :
		  (op[3:0]==4'h5)? v_adder :
		  (op[3:0]==4'h6)? v_adder :
		  (op[3:0]==4'h7)? v_adder :
		  (op[3:0]==4'h8)? v_adder :
		  (op[3:0]==4'h9)? vi :
		  (op[3:0]==4'ha)? vi :
		  (op[3:0]==4'hb)? vi :
		  (op[3:0]==4'hc)? vi :
		  (op[3:0]==4'hd)? vi :
		  (op[3:0]==4'he)? vi :
		  (op[3:0]==4'hf)? vi :
		  vi;
   assign vo_im= vo_reg;
   assign vo_1= (op[5:0]==6'b101111)?di[`VIDX]:vi;
   assign vo= (op[5:4]==2'b00)? vo_reg :
	      (op[5:4]==2'b01)? vo_im :
	      (op[5:4]==2'b10)? vo_1 :
	      vi;
   // combined flags
   wire [WIDTH-1:0]	    res_flags;
   assign res_flags[`CIDX]= co;
   assign res_flags[`SIDX]= so;
   assign res_flags[`ZIDX]= zo;
   assign res_flags[`VIDX]= vo;
   assign res_flags[`PIDX]= (op[5:0]==6'b101111)?di[`PIDX]:fi[`PIDX];
   assign res_flags[`UIDX]= (op[5:0]==6'b101111)?di[`UIDX]:fi[`UIDX];
   assign res_flags[`N1IDX]= (op[5:0]==6'b101111)?di[`N1IDX]:fi[`N1IDX];
   assign res_flags[`N2IDX]= (op[5:0]==6'b101111)?di[`N2IDX]:fi[`N2IDX];
   assign res_flags[WIDTH-1:8]= fi[WIDTH-1:8];
   
   // Produce outputs
   assign res= (op_1)? res_1 :
	       res_2;
   wire 		    wb_en_reg, wb_en_im, wb_en_1;
   assign wb_en_reg= op_2reg &
		     (op[2]&!op[3] |
		      !op[0]&!op[3]&!op[1] |
		      op[2]&op[1] |
		      op[0]&op[1] |
		      op[0]&op[3] |
		      op[3]&op[1]
		      );
   assign wb_en_im= op_2im &
		    (!op[3] |
		     op[1] |
		     op[0]
		     );
   assign wb_en_1= op_1 &
		   (!op[3] |
		    !op[1]&!op[2] |
		    !op[0]&!op[2] |
		    !op[0]&op[1]
		    );
   assign wb_en= wb_en_reg | wb_en_im | wb_en_1;
   assign fo= (op_1 & op[3:0]==4'hf) ? di : res_flags;

   wire 		    flag_en_reg, flag_en_im, flag_en_1;
   assign flag_en_reg= op_2reg &
		       (op[2] |
			op[3]&!op[1] |
			op[0]&op[3]
			);
   assign flag_en_im= op_2im &
		      (op[2] |
			op[3]&!op[1] |
			op[0]&op[3]
			);
   assign flag_en_1= op_1 &
		     ((op[3]^op[2]) |
		      op[3]&!op[1] |
		      op[2]&op[0]);
   assign flag_en= flag_en_reg | flag_en_im | flag_en_1;
   
endmodule // alu2
