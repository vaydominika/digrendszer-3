module drs
  (
   input wire c,
   input wire d,
   input wire s,
   input wire r,
   output reg q
   );

   always @(posedge c, posedge s, posedge r)
     begin
	if (s)
	  q<= 1;
	else if (r)
	  q<= 0;
	else
	  q<= d;
     end
   
endmodule // drs

module dli
  (
   input wire c,
   input wire d,
   input wire l,
   input wire di,
   output wire q
   );

   drs ff
     (
      .c(c),
      .d(d),
      .s(l & di),
      .r(l & !di),
      .q(q)
      );
   
endmodule // dli

module rl
  #(
    parameter WIDTH=32
    )
  (
   input wire 		   c,
   input wire [WIDTH-1:0]  d,
   input wire 		   l,
   input wire [WIDTH-1:0]  di,
   output wire [WIDTH-1:0] q
   );

   dli ff[WIDTH-1:0](.c(c), .d(d), .l(l), .di(di), .q(q));

endmodule // rl

module timer
  #(
    parameter WIDTH= 32,
    parameter REG_CTRL= 3'd0,
    parameter REG_AR  = 3'd1,
    parameter REG_CNTR= 3'd2,
    parameter REG_STAT= 3'd3
    )
   (
    input wire 		    reset,
    input wire 		    clk,
    input wire [WIDTH-1:0]  din,
    input wire 		    cs,
    input wire [2:0] 	    addr,
    input wire 		    wen,
    input wire 		    io_clk,
    output wire [WIDTH-1:0] dout,
    output wire 	    irq,
    output wire [WIDTH-1:0] tmr,
    output wire [WIDTH-1:0] ctr,
    output wire [WIDTH-1:0] arr,
    output wire 	    ar_reached
    );

   reg [WIDTH-1:0] 	    control;
   reg [WIDTH-1:0] 	    ar;
   
   reg [WIDTH-1:0] 	    obuf;

   wire			    ovf;
   wire [WIDTH-1:0] 	    counter;
   wire [WIDTH-1:0] 	    cnt_next;
   wire [WIDTH-1:0] 	    cnt_set;
   wire 		    cnt_load;
   wire 		    eq_ar;
   wire [WIDTH-1:0]	    stat_value;

   assign ar_reached= (counter == ar);
   assign stat_value= {{(WIDTH-2){1'b0}},ovf,control[0]};
		      
   assign cnt_next
     =
      (control[0])?
      (ar_reached?0:counter+1):
      (counter);
   
   assign cnt_set= reset?0:din;
   
   assign cnt_load= reset | (wen & cs & (addr==REG_CNTR));
   
   rl
     #(
       .WIDTH(WIDTH)
       )
   cnt
     (
      .c(io_clk),
      .d(cnt_next),
      .l(cnt_load),
      .di(cnt_set),
      .q(counter)
      );
   
   always @(posedge clk, posedge reset)
     begin
	if (reset)
	  begin
	     control<= 0;
	     ar<= 0;
	  end
	else if (cs)
	  begin
	     if (wen)
	       begin
		  case (addr)
		    REG_CTRL: control<= din;
		    REG_AR  : ar<= din;
		    default: ;
		  endcase
	       end
	     else //if (cs & ~wen)
	       begin
		  obuf<= (addr==REG_CTRL)?control:
			 (addr==REG_AR  )?ar:
			 (addr==REG_CNTR)?counter:
			 (addr==REG_STAT)?stat_value:
			 counter;
	       end // else: !if(wen)
	  end
     end
   
   wire ovf_clr;
   assign ovf_clr= reset | (cs & wen & (addr==REG_STAT) & din[1]);
   
   drs ovff
     (
      .c(1'b0),
      .d(1'b0),
      .q(ovf),
      .s(ar_reached),
      .r(ovf_clr)
      );
   
   assign dout= obuf;
   assign irq= ovf & control[1];
   assign tmr= counter;
   assign ctr= control;
   assign arr= ar;
   
endmodule // timer
