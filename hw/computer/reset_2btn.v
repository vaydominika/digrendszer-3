module reset_2btn
  (
   input wire  clk,
   input wire  b0, // btn[0]
   input wire  b1, // btn[1]
   output wire res,
   output wire [2:0] state
   );

   localparam A= 3'b000; // 00
   localparam B= 3'b001; // 10
   localparam C= 3'b010; // 11
   localparam D= 3'b011; // 01
   localparam E= 3'b100; // 11
   localparam F= 3'b101; // 10

   localparam B00= 2'b00;
   localparam B01= 2'b01;
   localparam B10= 2'b10;
   localparam B11= 2'b11;

   localparam B0= 2'b00;
   localparam B1= 2'b01;
   localparam B2= 2'b10;
   localparam B3= 2'b11;

   reg [2:0]   s= 3'b000;

   wire [1:0]  b= { b1, b0 };
   
   always @(posedge clk)
     begin
	case (s)
	  A: begin case (b)
		     B0: s<= A;
		     B1: s<= D;
		     B2: s<= B;
		     B3: s<= E;
		     default: s<= A;
		   endcase // case (b)
	  end
	  B: begin case (b)
		     B0: s<= A;
		     B1: s<= D;
		     B2: s<= B;
		     B3: s<= C;
		     default: s<= B;
		   endcase // case (b)
	  end
	  C: begin case (b)
		     B0: s<= A;
		     B1: s<= D;
		     B2: s<= F;
		     B3: s<= C;
		     default: s<= C;
		   endcase // case (b)
	  end
	  D: begin case (b)
		     B0: s<= A;
		     B1: s<= D;
		     B2: s<= F;
		     B3: s<= E;
		     default: s<= D;
		   endcase // case (b)
	  end
	  E: begin case (b)
		     B0: s<= A;
		     B1: s<= D;
		     B2: s<= F;
		     B3: s<= E;
		     default: s<= E;
		   endcase // case (b)
	  end
	  F: begin case (b)
		     B0: s<= A;
		     B1: s<= D;
		     B2: s<= F;
		     B3: s<= E;
		     default: s<= E;
		   endcase // case (b)
	  end
	  default:
	    s<= A;
	endcase
     end

   assign res= s==C;
   assign state= s;
   
endmodule // reset_2btn
