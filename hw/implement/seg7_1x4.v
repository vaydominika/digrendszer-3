module seg7_1x4
  (
   input wire	     clk,
   input wire	     reset,
   input wire [15:0] di,
   input wire [31:0] pixels,
   input wire	     direct,
   output wire [7:0] seg,
   output wire [3:0] an
   );
   
   parameter PRE=14;
   
   reg [31:0] 	     data;
   reg [1:0] 	     cnt;
   reg [PRE:0] 	     pre_cnt;
   wire [3:0] 	     digit;
   
   always @(posedge clk)
     begin
	if (pre_cnt[PRE] | reset)
	  pre_cnt<= 0;
	else
	  pre_cnt<= pre_cnt + 1;
     end
   
   always @(posedge clk)
     begin
	if (reset)
	  cnt<= 0;
	else if (pre_cnt[PRE])
	  begin
	     cnt<= cnt+1;
	     data<= di;
	  end
     end
   
   assign digit=
   
		(cnt==3'd0)?{data[ 3: 0]}:
		(cnt==3'd1)?{data[ 7: 4]}:
		(cnt==3'd2)?{data[11: 8]}:
		(cnt==3'd3)?{data[15:12]}:
		
		0;      
   
   assign an[0]= ~(cnt == 0);
   assign an[1]= ~(cnt == 1);
   assign an[2]= ~(cnt == 2);
   assign an[3]= ~(cnt == 3);
   
   parameter A      = 8'b0000_0001;
   parameter B      = 8'b0000_0010;
   parameter C      = 8'b0000_0100;
   parameter D      = 8'b0000_1000;
   parameter E      = 8'b0001_0000;
   parameter F      = 8'b0010_0000;
   parameter G      = 8'b0100_0000;
   
   wire [7:0] nd_sego;
   assign nd_sego= ~(
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

   wire [7:0] d_sego;
   assign d_sego= ~(
		    (cnt==0)?pixels[31:24]:
		    (cnt==1)?pixels[23:16]:
		    (cnt==2)?pixels[15: 8]:
		    (cnt==3)?pixels[ 7: 0]:
		    8'b0000_0000
		    );
   
   wire [7:0] sego;
   assign sego= direct ? d_sego : nd_sego;
   
   assign seg= reset?8'hff:sego;
   
endmodule // seg7_1x4
