module addrdec1
  #(
    parameter MEM_ADDR_SIZE= 32
    )
   (
    input wire [MEM_ADDR_SIZE-1:0] addr,
    output wire cs_mem,
    output wire [15:0] cs_io,
    output wire cs_simif
    );

   wire [MEM_ADDR_SIZE-1:0]    bus_address;
   assign bus_address= addr;
   
   wire [15:0] 		    chip_selects;
	
   decoder #(.ADDR_SIZE(4)) addr_decoder
     (
      .addr(bus_address[15:12]),
      .sel(chip_selects)
      );

   wire addr_64k;
   assign addr_64k= (bus_address[MEM_ADDR_SIZE-1:16] == 0);

   wire 		    cs_mem_code;
   wire 		    cs_timer;
   wire 		    cs_porti;
   wire 		    cs_portj;
   wire 		    cs_portabcd;

   assign cs_timer= addr_64k & chip_selects[12]; // 0xc000
   assign cs_portj= addr_64k & chip_selects[13]; // 0xd000
   assign cs_porti= addr_64k & chip_selects[14]; // 0xe000
   assign cs_portabcd= addr_64k & chip_selects[15]; // 0xf000
   assign cs_simif= addr_64k & (bus_address[15:0]==16'hffff); // 0xffff

   assign cs_io[0]= cs_portabcd;
   assign cs_io[1]= cs_portj;
   assign cs_io[2]= cs_porti;
   assign cs_io[3]= cs_timer;

   assign cs_mem_code= addr_64k &
		       (chip_selects[0]|
			chip_selects[1]|
			chip_selects[2]|
			chip_selects[3]);
   assign cs_mem= cs_mem_code;
   
endmodule // addrdec1
