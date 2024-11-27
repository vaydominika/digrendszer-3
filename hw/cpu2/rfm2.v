module rfm2
  #(
    parameter WIDTH=32
    )
   (
    input wire 		    clk,
    input wire 		    reset,
    input wire [3:0] 	    ra,
    input wire [3:0] 	    rb,
    input wire [3:0] 	    rd,
    input wire [3:0] 	    rw,
    input wire [3:0] 	    rt,
    input wire 		    fn_inc_pc,
    input wire 		    fn_link,
    input wire 		    fn_ra_change,
    input wire 		    fn_wb,
    input wire [WIDTH-1:0]  wb_data,
    input wire [WIDTH-1:0]  ra_changed,
    output wire [WIDTH-1:0] da,
    output wire [WIDTH-1:0] db,
    output wire [WIDTH-1:0] dd,
    output wire [WIDTH-1:0] dt,
    output wire [WIDTH-1:0] pc
    );

   wire [WIDTH-1:0] 	    r0out;
   reg2in #(.WIDTH(WIDTH)) r0
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==0 & fn_wb),
      .wen2(ra==0 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r0out)
      );

   wire [WIDTH-1:0] 	    r1out;
   reg2in #(.WIDTH(WIDTH)) r1
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==1 & fn_wb),
      .wen2(ra==1 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r1out)
      );

   wire [WIDTH-1:0] 	    r2out;
   reg2in #(.WIDTH(WIDTH)) r2
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==2 & fn_wb),
      .wen2(ra==2 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r2out)
      );

   wire [WIDTH-1:0] 	    r3out;
   reg2in #(.WIDTH(WIDTH)) r3
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==3 & fn_wb),
      .wen2(ra==3 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r3out)
      );

   wire [WIDTH-1:0] 	    r4out;
   reg2in #(.WIDTH(WIDTH)) r4
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==4 & fn_wb),
      .wen2(ra==4 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r4out)
      );

   wire [WIDTH-1:0] 	    r5out;
   reg2in #(.WIDTH(WIDTH)) r5
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==5 & fn_wb),
      .wen2(ra==5 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r5out)
      );

   wire [WIDTH-1:0] 	    r6out;
   reg2in #(.WIDTH(WIDTH)) r6
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==6 & fn_wb),
      .wen2(ra==6 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r6out)
      );

   wire [WIDTH-1:0] 	    r7out;
   reg2in #(.WIDTH(WIDTH)) r7
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==7 & fn_wb),
      .wen2(ra==7 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r7out)
      );

   wire [WIDTH-1:0] 	    r8out;
   reg2in #(.WIDTH(WIDTH)) r8
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==8 & fn_wb),
      .wen2(ra==8 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r8out)
      );

   wire [WIDTH-1:0] 	    r9out;
   reg2in #(.WIDTH(WIDTH)) r9
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==9 & fn_wb),
      .wen2(ra==9 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r9out)
      );

   wire [WIDTH-1:0] 	    r10out;
   reg2in #(.WIDTH(WIDTH)) r10
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==10 & fn_wb),
      .wen2(ra==10 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r10out)
      );

   wire [WIDTH-1:0] 	    r11out;
   reg2in #(.WIDTH(WIDTH)) r11
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==11 & fn_wb),
      .wen2(ra==11 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r11out)
      );

   wire [WIDTH-1:0] 	    r12out;
   reg2in #(.WIDTH(WIDTH)) r12
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==12 & fn_wb),
      .wen2(ra==12 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r12out)
      );

   wire [WIDTH-1:0] 	    r13out;
   reg2in #(.WIDTH(WIDTH)) r13
     (
      .clk(clk),
      .reset(reset),
      .wen1(rw==13 & fn_wb),
      .wen2(ra==13 & fn_ra_change),
      .din1(wb_data),
      .din2(ra_changed),
      .dout(r13out)
      );

   wire [WIDTH-1:0] 	    r14out;
   wire [WIDTH-1:0] 	    r15out;
   reg2in #(.WIDTH(WIDTH)) r14
     (
      .clk(clk),
      .reset(reset),
      .wen1(fn_link | (rw==14 & fn_wb)),
      .wen2(ra==14 & fn_ra_change),
      .din1(fn_link?r15out:wb_data),
      .din2(ra_changed),
      .dout(r14out)
      );

   reg2in #(.WIDTH(WIDTH)) r15
     (
      .clk(clk),
      .reset(reset),
      .wen1(fn_inc_pc | (rw==15 & fn_wb)),
      .wen2(ra==15 & fn_ra_change),
      .din1(fn_inc_pc?(pc+1):wb_data),
      .din2(ra_changed),
      .dout(r15out)
      );
   assign pc= r15out;
   
   assign da= (ra==4'h0)?r0out:
	      (ra==4'h1)?r1out:
	      (ra==4'h2)?r2out:
	      (ra==4'h3)?r3out:
	      (ra==4'h4)?r4out:
	      (ra==4'h5)?r5out:
	      (ra==4'h6)?r6out:
	      (ra==4'h7)?r7out:
	      (ra==4'h8)?r8out:
	      (ra==4'h9)?r9out:
	      (ra==4'ha)?r10out:
	      (ra==4'hb)?r11out:
	      (ra==4'hc)?r12out:
	      (ra==4'hd)?r13out:
	      (ra==4'he)?r14out:
	      (ra==4'hf)?r15out:
	      0;
   
   assign db= (rb==4'h0)?r0out:
	      (rb==4'h1)?r1out:
	      (rb==4'h2)?r2out:
	      (rb==4'h3)?r3out:
	      (rb==4'h4)?r4out:
	      (rb==4'h5)?r5out:
	      (rb==4'h6)?r6out:
	      (rb==4'h7)?r7out:
	      (rb==4'h8)?r8out:
	      (rb==4'h9)?r9out:
	      (rb==4'ha)?r10out:
	      (rb==4'hb)?r11out:
	      (rb==4'hc)?r12out:
	      (rb==4'hd)?r13out:
	      (rb==4'he)?r14out:
	      (rb==4'hf)?r15out:
	      0;
   
   assign dd= (rd==4'h0)?r0out:
	      (rd==4'h1)?r1out:
	      (rd==4'h2)?r2out:
	      (rd==4'h3)?r3out:
	      (rd==4'h4)?r4out:
	      (rd==4'h5)?r5out:
	      (rd==4'h6)?r6out:
	      (rd==4'h7)?r7out:
	      (rd==4'h8)?r8out:
	      (rd==4'h9)?r9out:
	      (rd==4'ha)?r10out:
	      (rd==4'hb)?r11out:
	      (rd==4'hc)?r12out:
	      (rd==4'hd)?r13out:
	      (rd==4'he)?r14out:
	      (rd==4'hf)?r15out:
	      0;
   
   assign dt= (rt==4'h0)?r0out:
	      (rt==4'h1)?r1out:
	      (rt==4'h2)?r2out:
	      (rt==4'h3)?r3out:
	      (rt==4'h4)?r4out:
	      (rt==4'h5)?r5out:
	      (rt==4'h6)?r6out:
	      (rt==4'h7)?r7out:
	      (rt==4'h8)?r8out:
	      (rt==4'h9)?r9out:
	      (rt==4'ha)?r10out:
	      (rt==4'hb)?r11out:
	      (rt==4'hc)?r12out:
	      (rt==4'hd)?r13out:
	      (rt==4'he)?r14out:
	      (rt==4'hf)?r15out:
	      0;
   
endmodule // rfm2
