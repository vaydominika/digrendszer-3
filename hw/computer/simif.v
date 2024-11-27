module simif
  #(
    parameter WIDTH= 32
    )
   (
    input wire		    clk,
    input wire		    reset,
    input wire		    cs,
    input wire		    wen,
    input wire [0:0]	    addr,
    input [WIDTH-1:0]	    din,
    output wire [WIDTH-1:0] dout
    );

   localparam		    CMD_PRINT= 8'h70; // p
   localparam		    CMD_DETECT= 8'h5f; // _
   localparam		    ANS_PRESENT= 8'h21; // !
   
   reg [7:0] 	       cmd;
   reg [7:0] 	       param;
   wire		       need_param;

   assign need_param= (cmd == CMD_PRINT);
   
   always @(posedge clk)
     begin
	if (cs & wen)
	  begin
	     if (need_param)
	       begin
		  param<= din[7:0];
		  if (cmd==CMD_PRINT)
		    begin
`ifdef IVERILOG
		       $write("%c", din[7:0]);
		       $fflush();
`endif
		    end
	       end
	  end
     end
   
   always @(posedge clk)
     begin
	if (cs & wen)
	  begin
	     if (need_param)
	       cmd<= 0;
	     else
	       cmd<= din[7:0];
	  end
     end

   assign dout= (cmd==CMD_DETECT)?
`ifdef IVERILOG
		ANS_PRESENT
`else
		cmd
`endif
		:cmd;
   
   initial
     begin
	cmd= 0;
	param= 0;
     end
	
endmodule // simif

     
