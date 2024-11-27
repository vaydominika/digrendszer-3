module cpu1
  #(
    parameter WIDTH= 32,
    parameter ADDR_SIZE= 32
    )
  (
   // basic inputs
   input wire 		       clk,
   input wire 		       reset,
   // bus
   output wire [ADDR_SIZE-1:0] mbus_aout,
   input wire [WIDTH-1:0]      mbus_din,
   output wire [WIDTH-1:0]     mbus_dout,
   output wire 		       mbus_wen,
   // test
   input wire [3:0] 	       test_sel,
   output wire [WIDTH-1:0]     test_out,
   input wire [3:0] 	       test_rsel,
   output wire [WIDTH-1:0]     test_reg,
   output wire [2:0] 	       clk_stat
   );

   // internal signals
   wire [WIDTH-1:0] 	       ic;	// output of IC register
   wire [WIDTH-1:0] 	       pc;	// output of PC register 
   wire [WIDTH-1:0] 	       r14;	// output of Link register 
   wire [WIDTH-1:0] 	       r13;	// output of SP register 
   // phase signals
   wire 		       phf;	// fetch
   wire 		       phe;	// PC increment; execute
   wire 		       phm;	// memory r/w; link
   wire 		       phw;	// writeback
   // selected data as parameteres
   wire [WIDTH-1:0] 	       opa;
   wire [WIDTH-1:0] 	       opb;
   wire [WIDTH-1:0] 	       opd;
   // output sources
   wire [WIDTH-1:0] 	       alu_res;
   wire 		       c_res;
   wire 		       z_res;
   wire 		       s_res;
   wire 		       v_res;
   // selected data to use in writeback
   wire [3:0] 		       wb_address;
   wire [WIDTH-1:0] 	       wb_data;	// writeback data
   // decoded instructions
   wire 		       inst_call;
   wire 		       inst_nop;
   wire 		       inst_ld;
   wire 		       inst_st;
   wire 		       inst_mov;
   wire 		       inst_ldl0;
   wire 		       inst_ldl;
   wire 		       inst_ldh;
   wire 		       inst_op;
   wire 		       inst_wb;
   wire 		       inst_br;
   // some parts of IC
   wire [3:0] 		       ra;
   wire [3:0] 		       rb;
   wire [3:0] 		       rd;
   wire [4:0] 		       op_code;
   wire [1:0] 		       cond_flag;
   wire 		       cond_value;
   wire 		       cond_always;
   // result of condition check
   wire 		       ena;

   // latched data read from memory
   reg [WIDTH-1:0] 	       mr_data;

   // scheduler generates phase signals
   schedm scheduler
     (
      .clk(clk),
      .reset(reset),
      .phf(phf),	// phase 1: FETCH (stores fetched code into IC reg)
      .phe(phe),	// phase 2: EXEC (signals go through ALU)
      .phm(phm),	// phase 3: MEM (LD/ST read/write)
      .phw(phw),	// phase 4: WRITEBACK (store back result to register)
      .clk_stat(clk_stat)
      );
   
   // FLAG register
   wire 		       flag_c;
   wire 		       flag_s;
   wire 		       flag_z;
   wire 		       flag_v;
   wire 		       flagwb_en;
   assign flagwb_en= ena & inst_op & phw;
   
   defparam reg_flag.WIDTH=4;
   regm reg_flag
     (
      .clk(clk),
      .reset(reset/*1'b0*/),
      .cen(flagwb_en),
      .din ({v_res ,z_res ,s_res ,c_res }),
      .dout({flag_v,flag_z,flag_s,flag_c})
      );
   
   // Instruction Register contains instruction code
   defparam reg_ic.WIDTH= WIDTH;
   regm reg_ic
     (
      .clk(clk),
      .reset(reset),
      .cen(phf), // phe?
      .din(mbus_din),
      .dout(ic)
      );

   // pick parts of IC
   assign ra= ic[19:16];
   assign rb= ic[15:12];
   assign rd= ic[23:20];
   assign op_code= ic[11:7];
   assign cond_flag= ic[31:30];
   assign cond_value= ic[29];
   assign cond_always= ic[28];
   
   // decode instructions
   assign inst_call= ic[27];
   assign inst_nop = ~inst_call & (ic[26:24]==3'd0);
   assign inst_ld  = ~inst_call & (ic[26:24]==3'd1);
   assign inst_st  = ~inst_call & (ic[26:24]==3'd2);
   assign inst_mov = ~inst_call & (ic[26:24]==3'd3);
   assign inst_ldl0= ~inst_call & (ic[26:24]==3'd4);
   assign inst_ldl = ~inst_call & (ic[26:24]==3'd5);
   assign inst_ldh = ~inst_call & (ic[26:24]==3'd6);
   assign inst_op  = ~inst_call & (ic[26:24]==3'd7);
   assign inst_wb  = ~inst_nop & ~inst_st;
   assign inst_br  = inst_call | (inst_wb & (rd==4'd15));
   
   // decode condition
   assign ena= !cond_always |
	       (
		(cond_flag==2'b00)?(cond_value==flag_s):
		(cond_flag==2'b01)?(cond_value==flag_c):
		(cond_flag==2'b10)?(cond_value==flag_z):
		(cond_flag==2'b11)?(cond_value==flag_v):
		1'b1
		);
   
   // ALU
   defparam alu.WIDTH= WIDTH;
   alu1 alu
     (
      .op({1'b0,op_code}),
      .ci(flag_c),
      .zi(flag_z),
      .si(flag_s),
      .vi(flag_v),
      .ai(opa),
      .bi(opb),
      .di(opd),
      .res(alu_res),
      .co(c_res),
      .vo(v_res),
      .zo(z_res),
      .so(s_res)
      );

   // select data for writeback
   wire [WIDTH-1:0] 	       inst_res;
   assign inst_res= inst_nop?32'd0:
		    inst_ld?/*mbus_din*/mr_data:
		    inst_st?32'd0:
		    inst_mov?opa:
		    inst_ldl0?{16'b0,ic[15:0]}:
		    inst_ldl?{opd[31:16],ic[15:0]}:
		    inst_ldh?{ic[15:0],opd[15:0]}:
		    inst_op?alu_res:
		    32'd0; 
   assign wb_data= inst_call?{5'd0,ic[26:0]}:
		   inst_res;
   assign wb_address= inst_call?4'd15:
		      rd;

   wire 		       wb_en;
   wire 		       link_en;
   assign wb_en= ena & inst_wb & phw;
   assign link_en= ena & inst_call & phe;
   
   // Register file: R0..R15 (R14=Link,R15=PC)
   defparam regs.WIDTH= WIDTH;
   defparam regs.ADDR_SIZE= 4;
   rfm1 regs
     (
      .clk(clk),
      .reset(reset),
      .cen(phe),			// phf? Increment of R15 (PC)
      .wen(wb_en),			// Writeback: puts din to R[wr]
      .link(link_en),			// link: writes R15 into R14
      .wa(wb_address),			// Rd part of code
      .din(wb_data),
      .ra(ra),				// Ra part of code
      .da(opa),				// value of Ra
      .rb(rb),				// Rb part of code
      .db(opb),				// value of Rb
      .rd(rd),				// Rd part of code
      .dd(opd),				// value of Rd
      .rt(test_rsel),
      .dt(test_reg),
      .last(pc),
      .r14(r14),
      .r13(r13)
      );

   // memory interface
   wire 		       en_mr_data;
   assign en_mr_data= phm & inst_ld;
   always @(posedge clk)
     begin
	if (en_mr_data)
	  mr_data<= mbus_din;
     end

   wire [WIDTH-1:0] addr_phf;
   wire [WIDTH-1:0] addr_phe;
   wire [WIDTH-1:0] addr_phm;
   wire [WIDTH-1:0] addr_phw;

   assign addr_phf= pc;
   assign addr_phe= inst_ld?opa:pc;
   assign addr_phm= (inst_ld|inst_st)?opa:pc;
   assign addr_phw= (inst_br&ena)?wb_data:pc;
   
   assign mbus_dout= opd;
   assign mbus_aout= phf?addr_phf:
		     phe?addr_phe:
		     phm?addr_phm:
		     phw?addr_phw:
		     pc;
   assign mbus_wen = ena & (phm/*|phe*/) & inst_st;

   assign test_out
     = (test_sel==4'h0)?pc:
       (test_sel==4'h1)?r14:
       (test_sel==4'h2)?r13:
       (test_sel==4'h3)?ic:
       (test_sel==4'h4)?alu_res:
       (test_sel==4'h5)?inst_res:
       (test_sel==4'h6)?wb_data:
       (test_sel==4'h7)?{19'b0,ena,rd,ra,rb}:
       (test_sel==4'h8)?opd:
       (test_sel==4'h9)?opa:
       (test_sel==4'ha)?opb:
       (test_sel==4'hb)?{3'b0,flag_v,
			 3'b0,flag_z,
			 3'b0,flag_s,
			 3'b0,flag_c,
			 2'b0,cond_flag,
			 3'b0,cond_value,
			 3'b0,cond_always,
			 3'b0,ena
			 }:
       (test_sel==4'hc)?{3'b0,phw,
			 3'b0,phm,
			 3'b0,phe,
			 3'b0,phf,
			 phf,phw,phm,phe,
			 wb_en,ena,inst_wb,phw,
			 mbus_wen,ena,phm,inst_st,
			 1'b0,clk_stat
			 }:
       (test_sel==4'hd)?mbus_aout:
       (test_sel==4'he)?mbus_dout:
       (test_sel==4'hf)?mbus_din:
       0;

endmodule // cpu1
