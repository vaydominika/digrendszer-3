module seg7
  (
   input wire	     clk,
   input wire [31:0] di,
   input wire [63:0] pixels,
   input wire	     direct,
   output wire [7:0] seg,
   output wire [7:0] an
   );
   
   parameter PRE=9;
   
   reg [31:0] 	     data;
   reg [2:0] 	     cnt;
   reg [PRE:0] 	     pre_cnt;
   wire [3:0] 	     digit;
   wire [7:0]	     nd_seg;
   wire [7:0]	     d_seg;
	     
   initial
     begin
	cnt<= 0;
	pre_cnt<= 0;
     end
   
   always @(posedge clk)
     begin
	pre_cnt<= pre_cnt + 1;
     end
   
   always @(posedge pre_cnt[PRE])
     begin
	cnt<= cnt+1;
	data<= di;
     end
   
   assign digit=
		(cnt==3'd0)?{data[ 3: 0]}:
		(cnt==3'd1)?{data[ 7: 4]}:
		(cnt==3'd2)?{data[11: 8]}:
		(cnt==3'd3)?{data[15:12]}:
		(cnt==3'd4)?{data[19:16]}:
		(cnt==3'd5)?{data[23:20]}:
		(cnt==3'd6)?{data[27:24]}:      
		(cnt==3'd7)?{data[31:28]}:
		0;      
   
   assign an[0]= ~(cnt == 0);
   assign an[1]= ~(cnt == 1);
   assign an[2]= ~(cnt == 2);
   assign an[3]= ~(cnt == 3);
   assign an[4]= ~(cnt == 4);
   assign an[5]= ~(cnt == 5);
   assign an[6]= ~(cnt == 6);
   assign an[7]= ~(cnt == 7);
   
   parameter A      = 8'b0000_0001;
   parameter B      = 8'b0000_0010;
   parameter C      = 8'b0000_0100;
   parameter D      = 8'b0000_1000;
   parameter E      = 8'b0001_0000;
   parameter F      = 8'b0010_0000;
   parameter G      = 8'b0100_0000;
   
   assign nd_seg = ~(
		  (digit[3:0] == 4'h0) ? A|B|C|D|E|F :
		  (digit[3:0] == 4'h1) ? B|C :
		  (digit[3:0] == 4'h2) ? A|B|G|E|D :
		  (digit[3:0] == 4'h3) ? A|B|C|D|G :
		  
		  (digit[3:0] == 4'h4) ? F|B|G|C :
		  (digit[3:0] == 4'h5) ? A|F|G|C|D : 
		  (digit[3:0] == 4'h6) ? A|F|G|C|D|E :
		  (digit[3:0] == 4'h7) ? A|B|C :
		  
		  (digit[3:0] == 4'h8) ? A|B|C|D|E|F|G :
		  (digit[3:0] == 4'h9) ? A|B|C|D|F|G :
		  (digit[3:0] == 4'ha) ? A|F|B|G|E|C :
		  (digit[3:0] == 4'hb) ? F|G|C|D|E :
		  
		  (digit[3:0] == 4'hc) ? G|E|D :
		  (digit[3:0] == 4'hd) ? B|C|G|E|D :
		  (digit[3:0] == 4'he) ? A|F|G|E|D :
		  (digit[3:0] == 4'hf) ? A|F|G|E :
		  8'b0000_0000
		  );

   assign d_seg= ~(
		   (cnt==3'd0)?pixels[63:56]:
		   (cnt==3'd1)?pixels[55:48]:
		   (cnt==3'd2)?pixels[47:40]:
		   (cnt==3'd3)?pixels[39:32]:
		   (cnt==3'd4)?pixels[31:24]:
		   (cnt==3'd5)?pixels[23:16]:
		   (cnt==3'd6)?pixels[15: 8]:
		   (cnt==3'd7)?pixels[ 7: 0]:
		   8'b0000_0000
		   );
		   
   assign seg= direct ? d_seg : nd_seg;
   
endmodule // seg7
