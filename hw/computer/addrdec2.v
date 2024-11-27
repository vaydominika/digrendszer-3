module addrdec2
  #(
    parameter AW= 32,
    parameter LOMEM_SIZE= 65536,
    parameter HIMEM_SIZE= 65536
    )
   (
    input wire [AW-1:0]	addr,
    output wire		cs_mem,
    output wire [15:0]	cs_io,
    output wire		cs_simif,

    output wire		cs_lomem,
    output wire		cs_pmon,
    output wire		cs_himem
    );

   wire [15:0]		chip_selects;
   wire			top_256;
	
   decoder_en #(.ADDR_SIZE(4)) addr_decoder
     (
      .en(top_256),
      .addr(addr[7:4]),
      .sel(chip_selects)
      );

   wire			addr_64k, addr_pmon;
   assign addr_64k= ~|addr[AW-1:16];

   assign top_256= addr_64k & (addr[15:8] == 8'hff);
   assign cs_simif= top_256 & (addr[7:0]==8'hff);
   assign cs_io[14:0]= chip_selects[14:0];
   assign cs_io[15]= chip_selects[15] & !cs_simif;

   assign cs_mem= !top_256;

   assign addr_pmon= addr_64k & (addr[15:12]==4'hf);
   assign cs_lomem= cs_mem & (addr < LOMEM_SIZE) & ~addr_pmon;
   assign cs_pmon = cs_mem & addr_pmon;
   assign cs_himem= cs_mem & ~addr_64k & (addr < 32'h10000 + HIMEM_SIZE);

endmodule // addrdec1
