module mux16
  #(
    parameter WIDTH=32
    )
   (
    input wire [3:0] sel,
    input wire [WIDTH-1:0] in0,
    input wire [WIDTH-1:0] in1,
    input wire [WIDTH-1:0] in2,
    input wire [WIDTH-1:0] in3,
    input wire [WIDTH-1:0] in4,
    input wire [WIDTH-1:0] in5,
    input wire [WIDTH-1:0] in6,
    input wire [WIDTH-1:0] in7,
    input wire [WIDTH-1:0] in8,
    input wire [WIDTH-1:0] in9,
    input wire [WIDTH-1:0] in10,
    input wire [WIDTH-1:0] in11,
    input wire [WIDTH-1:0] in12,
    input wire [WIDTH-1:0] in13,
    input wire [WIDTH-1:0] in14,
    input wire [WIDTH-1:0] in15,
    output wire [WIDTH-1:0] out
    );
   
   assign out=(sel==4'h0)?in0:
	      (sel==4'h1)?in1:
	      (sel==4'h2)?in2:
	      (sel==4'h3)?in3:
	      (sel==4'h4)?in4:
	      (sel==4'h5)?in5:
	      (sel==4'h6)?in6:
	      (sel==4'h7)?in7:
	      (sel==4'h8)?in8:
	      (sel==4'h9)?in9:
	      (sel==4'ha)?in10:
	      (sel==4'hb)?in11:
	      (sel==4'hc)?in12:
	      (sel==4'hd)?in13:
	      (sel==4'he)?in14:
	      (sel==4'hf)?in15:
	      0;
	      
endmodule // mux16
