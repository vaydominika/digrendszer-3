module cpu2
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
   // phase signals
   wire 		       phf;	// fetch
   wire 		       phe;	// PC increment; execute
   wire 		       phm;	// memory r/w; link
   wire 		       phw;	// writeback
   wire 		       ena;
   // selected data as parameteres
   wire [WIDTH-1:0] 	       opa;
   wire [WIDTH-1:0] 	       opb;
   wire [WIDTH-1:0] 	       opd;
   // results
   wire [WIDTH-1:0] 	       res_alu;
   wire [WIDTH-1:0]	       alu_res_flags;
   wire [WIDTH-1:0] 	       res_call;
   wire [WIDTH-1:0] 	       res_ld;
   // selected data to use in writeback
   wire [3:0] 		       wb_address;
   wire [WIDTH-1:0] 	       wb_data;	// writeback data
   wire 		       wb_en;
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
   wire [WIDTH-1:0]	       flags;
   wire [WIDTH-1:0]	       flags_din;
   wire 		       flag_c;
   wire 		       flag_s, flag_n;
   wire 		       flag_z;
   wire 		       flag_v, flag_o;
   wire 		       flag_p;
   wire 		       flag_u;
   wire 		       flag_wb_en;
   wire 		       alu_flag_en;
   wire 		       alu_wb_en;
   wire 		       inst_alu;
   wire			       inst_ext_gpb;
   wire			       inst_ext_sfr;
   
   regm #(.WIDTH(WIDTH)) reg_flag
     (
      .clk(clk),
      .reset(reset/*1'b0*/),
      .cen(flag_wb_en),
      .din(flags_din),
      .dout(flags)
      );
   assign flag_c= flags[`CIDX];
   assign flag_s= flags[`SIDX];
   assign flag_z= flags[`ZIDX];
   assign flag_v= flags[`VIDX];
   assign flag_p= flags[`PIDX];
   assign flag_u= flags[`UIDX];
   assign flag_o= flag_v;
   assign flag_n= flag_s;
   assign flag_wb_en= ena & phw &
		      (inst_alu & alu_flag_en) |
		      (inst_ext_wrs && (rb==4'd0));

   // Instruction Register contains instruction code
   regm #(.WIDTH(WIDTH)) reg_ic
     (
      .clk(clk),
      .reset(reset),
      .cen(phf), // phe?
      .din(mbus_din),
      .dout(ic)
      );

   // pick parts of the IC
   wire [3:0]		       cond= ic[31:28];
   wire [2:0]		       inst= ic[27:25];

   wire			       uncond= (cond==4'hf);
   
   wire 		       inst_alu2= (inst==0) & !uncond;
   wire 		       inst_alu1= (inst==1) & !uncond;
   wire 		       inst_call= (inst==2);
   wire 		       inst_ext = (inst==3) & !uncond;
   wire 		       inst_st_r= (inst==4) & !uncond;
   wire 		       inst_ld_r= (inst==5) & !uncond;
   wire 		       inst_st_i= (inst==6) & !uncond;

   wire 		       inst_param= ic[24];
   wire [5:0] 		       alu_op= {ic[25:24],ic[19:16]};
   wire [3:0] 		       ra= (inst_ext_gpb) ? ic[3:0] : ic[19:16];
   wire [3:0] 		       rb= ic[11:8];
   wire [3:0] 		       rd= ic[23:20];
   wire [15:0] 		       im16= ic[15:0];
   wire [23:0] 		       im24= ic[23:0];
   wire [19:0] 		       im20= ic[19:0];
   wire [3:0] 		       ext_code= ic[19:16];
   wire 		       u= ic[15];
   wire 		       p= ic[14];
   wire 		       w= ic[24] & !inst_ext;
   
   // decode instructions
   wire 		       inst_ld_i= inst==7;
   wire 		       inst_st_ext= inst_ext_mem & ~ic[24];
   wire 		       inst_ld_ext= inst_ext_mem & ic[24];
   wire			       inst_ext_getb= inst_ext_gpb & ~ic[24];
   wire			       inst_ext_putb= inst_ext_gpb & ic[24];
   wire			       inst_ext_rds= inst_ext_sfr & ~ic[24];
   wire			       inst_ext_wrs= inst_ext_sfr & ic[24];
   wire 		       inst_ld;
   wire 		       inst_st;
   wire 		       inst_mem;
   wire 		       inst_ext_mem;
   wire 		       inst_br;
   wire 		       inst_wb;
   assign inst_ld= inst_ld_r | inst_ld_i | inst_ld_ext;
   assign inst_st= inst_st_r | inst_st_i | inst_st_ext;
   assign inst_ext_mem= inst_ext & (ext_code==4'd0);
   assign inst_ext_gpb= inst_ext & (ext_code==4'd1);
   assign inst_ext_sfr= inst_ext & (ext_code==4'd2);
   assign inst_mem= inst_st | inst_ld;
   assign inst_alu= inst_alu1 | inst_alu2;
   assign inst_br= inst_call | ((inst_alu | inst_ld) & (rd==4'd15));
   assign inst_wb= (inst_alu & alu_wb_en) |
		   inst_br |
		   inst_ld |
		   inst_ext_gpb |
		   inst_ext_rds;

   // decode condition
   assign ena= (cond==4'h0)? 1 : // always
	       (cond==4'h1)? flag_z : // EQ
		     (cond==4'h2)? !flag_z : // NE
		     (cond==4'h3)? flag_c : // CS HS
		     (cond==4'h4)? !flag_c : // CC LO
		     (cond==4'h5)? flag_s : // MI
		     (cond==4'h6)? !flag_s : // PL
		     (cond==4'h7)? flag_o : // VS
		     (cond==4'h8)? !flag_o : // VC
		     // Unsigned compares
		     (cond==4'h9)? flag_c & !flag_z : // HI op1>op2
		     (cond==4'ha)? !flag_c | flag_z : // LS op1<=op2
		     // Signed compares
		     (cond==4'hb)? !(flag_s ^ flag_o): // GE
		     (cond==4'hc)? flag_s ^ flag_o : // LT
		     (cond==4'hd)? !flag_z & !(flag_s ^ flag_o) : // GT
		     (cond==4'he)? flag_z | (flag_s ^ flag_o): // LE
		     (cond==4'hf)? 1 : // uncond
		     0;
   
   // ALU inst
   alu2 alu
     (
      // inputs
      .op(alu_op),
      .fi(flags),
      .bi(opb),
      .di(opd),
      .im(im16),
      // outputs
      .res(res_alu),
      .fo(alu_res_flags),
      .wb_en(alu_wb_en),
      .flag_en(alu_flag_en)
      );

   assign flags_din= inst_alu ? alu_res_flags :
		     inst_ext_wrs ? opd :
		     flags;

   
   // CALL inst
   wire 		       inst_call_idx;
   wire [WIDTH-1:0] 	       aof_call_abs;
   wire [WIDTH-1:0] 	       aof_call_idx;
   wire [WIDTH-1:0] 	       sex_im20;
   wire 		       sof_im20= im20[19];
   assign sex_im20= {sof_im20,sof_im20,sof_im20,sof_im20,sof_im20,sof_im20,sof_im20,sof_im20,sof_im20,sof_im20,sof_im20,sof_im20,im20};
   assign aof_call_abs= {8'b0, im24};
   assign aof_call_idx= opd+sex_im20;
   assign inst_call_idx= inst_call & ic[24];
   assign res_call= /*ic[24]*/inst_call_idx?aof_call_idx:aof_call_abs;

   // Extented instructions
   wire [WIDTH-1:0]	       res_ext_getb;
   getb #(.WIDTH(WIDTH)) mod_ext_getb
     (
      .opd(opd),
      .opb(opb),
      .byte_idx( ic[15] ? {30'b0,ic[1:0]} : {30'b0,opa[1:0]} ),
      .ex_mode( ic[14:13] ),
      .res(res_ext_getb)
      );
   
   wire [WIDTH-1:0]	       res_ext_putb;
   putb #(.WIDTH(WIDTH)) mod_ext_putb
     (
      .opd(opd),
      .opb(opb),
      .byte_idx( ic[15] ? {30'b0,ic[1:0]} : {30'b0,opa[1:0]} ),
      .res(res_ext_putb)
      );

   wire [WIDTH-1:0]	       res_ext_rds;
   wire [WIDTH-1:0]	       sfr_dout;
   sfr #(.WIDTH(WIDTH)) mod_ext_sfr
     (
      .clk(clk),
      .reset(reset),
      .addr(rb),
      .cen(ena & inst_ext_wrs & phw),
      .din(wb_data),
      .dout(sfr_dout)
      );
   assign res_ext_rds= (rb==4'd0) ? flags : sfr_dout;
   
   // Select data for write back
   assign wb_data= inst_alu      ? res_alu:
		   inst_call     ? res_call:
		   inst_ld       ? mr_data:
		   inst_ext_getb ? res_ext_getb:
		   inst_ext_putb ? res_ext_putb:
		   inst_ext_rds  ? res_ext_rds:
		   inst_ext_wrs  ? opd:
		   inst_st       ? 0:
		   0;
   assign wb_address= inst_call?4'd15:
		      rd;
   assign wb_en= ena & inst_wb & phw;

   // MEM inst (ld/st)
   wire [WIDTH-1:0] 	       mem_im_offset;
   assign mem_im_offset= {
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16[15],
			  im16
			  };
   wire [WIDTH-1:0] 	       mem_direct_address;
   assign mem_direct_address= {16'd0,im16};
   
   wire [WIDTH-1:0] 	       aof_ldst;
   wire [WIDTH-1:0] 	       base_offset;
   wire [WIDTH-1:0] 	       opa_offset;
   wire [WIDTH-1:0] 	       ldst_base;
   wire [WIDTH-1:0] 	       ldst_mod;
   wire [WIDTH-1:0] 	       opa_changed;
   wire [WIDTH-1:0] 	       ldst_offset;
   wire 		       up_down, pre_post;
   wire 		       use_u, use_p;
   assign up_down= ic[26]?flag_u:u;
   assign pre_post= ic[26]?flag_p:p;
   assign use_u= inst_ld_i ^ up_down;
   assign use_p= inst_ld_i ^ pre_post;
   assign ldst_mod= use_u?32'd1:32'hffffffff;
   assign opa_changed= opa+ldst_mod;
   assign ldst_base= use_p?opa_changed:opa;
   assign ldst_offset= ic[26]?mem_im_offset:opb;
   assign base_offset= ldst_base+ldst_offset;
   assign opa_offset= opa+ldst_offset;
   assign aof_ldst= inst_ext_mem?mem_direct_address:
		    w?base_offset:opa_offset;
   
   // Register file
   rfm2 #(.WIDTH(WIDTH)) regs
     (
      .clk(clk),
      .reset(reset),
      .ra(ra),
      .rb(rb),
      .rd(rd),
      .rw(inst_call?4'd15:rd),
      .rt(test_rsel),
      .fn_inc_pc(phe),
      .fn_link(ena & inst_call & phm),
      .fn_ra_change(ena & inst_mem & w & phm),
      .fn_wb(ena & inst_wb & phw),
      .wb_data(wb_data),
      .ra_changed(opa_changed),
      .da(opa),
      .db(opb),
      .dd(opd),
      .dt(test_reg),
      .pc(pc)
      );
   
   // memory interface
   
   // handle input data lines
   wire 		       en_mr_data;
   assign en_mr_data= phm & inst_ld;
   // latched data read from memory
   always @(posedge clk)
     begin
	if (en_mr_data)
	  mr_data<= mbus_din;
     end

   // produce address outputs
   wire [WIDTH-1:0] addr_phf;
   wire [WIDTH-1:0] addr_phe;
   wire [WIDTH-1:0] addr_phm;
   wire [WIDTH-1:0] addr_phw;

   assign addr_phf= pc;
   assign addr_phe= (inst_ld&ena)?aof_ldst:pc;
   assign addr_phm= ((inst_ld|inst_st)&ena)?aof_ldst:pc;
   assign addr_phw= (inst_br&ena)?wb_data:pc;
   assign mbus_aout= phf?addr_phf:
		     phe?addr_phe:
		     phm?addr_phm:
		     phw?addr_phw:
		     pc;

   // produce data outpouts   
   assign mbus_dout= opd;
   assign mbus_wen = ena & (phm/*|phe*/) & inst_st;

   reg [WIDTH-1:0]  dbg_reg= 0;
   always @(posedge clk)
     begin
	if (phf & flags[7])
	  begin
	     dbg_reg<= mbus_din;
	     $write("F: %x %x %x\n", pc, mbus_din, {25'b0,flags[6:0]});
	  end
     end
   
endmodule // cpu2
