module putb
  #(
    parameter WIDTH= 32
    )
   (
    input wire [WIDTH-1:0]  opd,
    input wire [WIDTH-1:0]  opb,
    input wire [WIDTH-1:0]  byte_idx,
    output wire [WIDTH-1:0] res
    );

   assign res= (byte_idx==2'b00) ? { opd[31: 8], opb[ 7:0]            } :
	       (byte_idx==2'b01) ? { opd[31:16], opb[ 7:0], opd[ 7:0] } :
	       (byte_idx==2'b10) ? { opd[31:24], opb[ 7:0], opd[15:0] } :
	       (byte_idx==2'b11) ? { opb[ 7 :0], opd[23:0]            } :
	       0
	       ;
   
endmodule // putb
