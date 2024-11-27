module seg7_2x4
  (
   input wire	     clk,
   input wire	     reset,
   input wire [31:0] di,
   input wire [63:0] pixels,
   input wire	     direct,
   output wire [7:0] segl,
   output wire [3:0] anl,
   output wire [7:0] segh,
   output wire [3:0] anh
   );
   
   seg7_1x4 dl
     (
      .clk(clk),
      .reset(reset),
      .di(di[15:0]),
      .pixels(pixels[63:32]),
      .direct(direct),
      .seg(segl),
      .an(anl)
      );
   
   seg7_1x4 dh
     (
      .clk(clk),
      .reset(reset),
      .di(di[31:16]),
      .pixels(pixels[31:0]),
      .direct(direct),
      .seg(segh),
      .an(anh)
      );
   
endmodule // seg7_2x4
