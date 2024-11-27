module schedm
  (
   input wire 	     clk,
   input wire 	     reset,

   output wire 	     phf,
   output wire 	     phe,
   output wire 	     phm,
   output wire 	     phw,

   output wire [2:0] clk_stat
   );

   parameter S_RESET1= 3'b000;
   parameter S_RESET2= 3'b001;
   parameter S_FETCH = 3'b010;
   parameter S_EXEC  = 3'b011;
   parameter S_MEM   = 3'b100;
   parameter S_WB    = 3'b101;
   
   reg [2:0] 	     s;

   always @(negedge clk/*, posedge reset*/)
     begin
	if (reset)
	  s<= S_RESET1;
	else
	  begin
	     case (s)
	       S_RESET1: s<= S_RESET2;
	       S_RESET2: s<= S_FETCH;
	       S_FETCH: s<= S_EXEC;
	       S_EXEC: s<= S_MEM;
	       S_MEM: s<= S_WB;
	       S_WB: s<= S_FETCH;
	       default: s<= S_RESET1;
	     endcase
	  end
     end
   assign phf= (s==S_FETCH) || (s==S_RESET2);
   assign phe= (s==S_EXEC);
   assign phm= (s==S_MEM);
   assign phw= (s==S_WB);
   /*
   assign clk_stat[0]= phe | phw;
   assign clk_stat[1]= phm | phw;
   assign clk_stat[2]= 1'b0;
   */
   assign clk_stat= s;
   
endmodule // schedm
