module comp //(clk, reset, test_sel, test_out);
  #(
    parameter WIDTH= 32,
    parameter PROGRAM= "",
    parameter PMON_CONTENT= "",
    parameter MEM_ADDR_SIZE= 12,
    parameter LOMEM_SIZE= 65536,
    parameter HIMEM_SIZE= 65536,
    parameter CPU_TYPE= 2,
    parameter COMP_TYPE= 1
    )
   (
    // base signals
    input wire		    clk,
    input wire		    reset,
    // ports
    input wire [WIDTH-1:0]  PORTI,
    input wire [WIDTH-1:0]  PORTJ,
    output wire [WIDTH-1:0] PORTA,
    output wire [WIDTH-1:0] PORTB,
    output wire [WIDTH-1:0] PORTC,
    output wire [WIDTH-1:0] PORTD,
    output wire [WIDTH-1:0] BRD_CTRL,
    input wire		    RxD,
    output wire		    TxD,
    
    // test the CPU
    input wire [3:0]	    test_sel,
    output wire [WIDTH-1:0] test_out,
    input wire [3:0]	    test_rsel,
    output wire [WIDTH-1:0] test_reg,
    output wire [2:0]	    CLKstat,
    //output wire [WIDTH-1:0] dummy
    output wire [WIDTH-1:0] ADDR,
    output wire [WIDTH-1:0] MDO,
    output wire [WIDTH-1:0] MDI,
    output wire		    MWE,
    output wire [WIDTH-1:0] tmr,
    output wire [WIDTH-1:0] ctr,
    output wire [WIDTH-1:0] arr,
    output wire		    ar_reached,
    
    input wire		    clk10m,
    output wire [31:0]	    irqs 
    );
  
   // Memory bus
   wire [WIDTH-1:0] 	    bus_data_in;
   wire [WIDTH-1:0] 	    bus_data_out;
   wire [WIDTH-1:0] 	    bus_mem_code_out;
   wire [WIDTH-1:0] 	    bus_mem_data_out;
   wire [WIDTH-1:0] 	    bus_timer_out;
   wire [WIDTH-1:0] 	    bus_porti_out;
   wire [WIDTH-1:0] 	    bus_portj_out;
   wire [WIDTH-1:0] 	    bus_portabcd_out;
   wire [WIDTH-1:0]	    bus_brd_ctrl;
   wire [WIDTH-1:0] 	    bus_uart_out;
   wire [WIDTH-1:0]	    bus_simif_out;	    
   wire [WIDTH-1:0]	    bus_clock_out;
   wire [WIDTH-1:0] 	    bus_address;
   wire 		    bus_wen;
   
   wire irq_timer;
   
   generate
      case (CPU_TYPE)
	1: cpu1
	  #(.WIDTH(WIDTH)) cpu
	    (
	     .clk(clk),
	     .reset(reset),
	     .mbus_aout(bus_address),
	     .mbus_din(bus_data_in),
	     .mbus_dout(bus_data_out),
	     .mbus_wen(bus_wen),
	     .test_sel(test_sel),
	     .test_out(test_out),
	     .test_rsel(test_rsel),
	     .test_reg(test_reg),
	     .clk_stat(CLKstat)
	     );
	2: cpu2
	  #(.WIDTH(WIDTH)) cpu
	    (
	     .clk(clk),
	     .reset(reset),
	     .mbus_aout(bus_address),
	     .mbus_din(bus_data_in),
	     .mbus_dout(bus_data_out),
	     .mbus_wen(bus_wen),
	     .test_sel(test_sel),
	     .test_out(test_out),
	     .test_rsel(test_rsel),
	     .test_reg(test_reg),
	     .clk_stat(CLKstat)
	     );
      endcase // case (CPU_TYPE)
   endgenerate

                                         //   v1         v2 
   wire 		    cs_mem;      // 0x0fff     0x1ffff
   wire 		    cs_portabcd; // 0xf000     0xff00
   wire 		    cs_portj;    // 0xd000     0xff10
   wire 		    cs_porti;    // 0xe000     0xff20
   wire 		    cs_timer;    // 0xc000     0xff30
   wire 		    cs_uart;     // -          0xff40
   wire			    cs_clock;    // -          0xff50
   wire			    cs_brd_ctrl; // -          0xfff0
   wire 		    cs_simif;    // 0xffff     0xffff
   wire [15:0] 		    cs_io;

   wire			    cs_lomem;
   wire			    cs_pmon;
   wire			    cs_himem;
   
   generate
      case (COMP_TYPE)
	1: addrdec1 adec
	  (
	   .addr(bus_address),
	   .cs_mem(cs_mem),
	   .cs_io(cs_io),
	   .cs_simif(cs_simif)
	   );
	2: addrdec2
	  #( .AW(WIDTH), .LOMEM_SIZE(LOMEM_SIZE), .HIMEM_SIZE(HIMEM_SIZE) )
	adec
	  (
	   .addr(bus_address),
	   .cs_mem(cs_mem),
	   .cs_io(cs_io),
	   .cs_simif(cs_simif),
	   .cs_lomem(cs_lomem),
	   .cs_pmon(cs_pmon),
	   .cs_himem(cs_himem)
	   );
      endcase // case (COMP_TYPE)
   endgenerate
   
   assign cs_portabcd= cs_io[0];
   assign cs_portj= cs_io[1];
   assign cs_porti= cs_io[2];
   assign cs_timer= cs_io[3];
   assign cs_uart= cs_io[4];
   assign cs_clock= cs_io[5];
   assign cs_brd_ctrl= cs_io[15];
   
   /*
   memory_1in_1out
     #(
       .WIDTH(WIDTH),
       .ADDR_SIZE(MEM_ADDR_SIZE),
       .CONTENT(PROGRAM)
       )
   mem
     (
      .clk(clk),
      .cs(cs_mem),
      .din(bus_data_out),
      .wen(bus_wen),
      .ra(bus_address[MEM_ADDR_SIZE-1:0]),
      .dout(bus_mem_code_out)//,
      );
    */
   mems
     #(
       //.AW(17),
       .WIDTH(WIDTH),
       .LOMEM_SIZE(LOMEM_SIZE),
       .HIMEM_SIZE(HIMEM_SIZE),
       .LOMEM_CONTENT(PROGRAM),
       .PMON_CONTENT(PMON_CONTENT)
       )
   mem
     (
      .clk(clk),
      .cs_lomem(cs_lomem),
      .cs_pmon(cs_pmon),
      .cs_himem(cs_himem),
      .din(bus_data_out),
      .wen(bus_wen),
      .addr(bus_address),
      .dout(bus_mem_code_out)//,
      );
   
   timer #(.WIDTH(32)) tmr1
     (
      .clk(clk),
      .reset(reset),
      .din(bus_data_out),
      .wen(bus_wen),
      .cs(cs_timer),
      .addr(bus_address[2:0]),

      .io_clk(clk10m),
      .dout(bus_timer_out),
      .irq(irq_timer),
      .tmr(tmr),
      .ctr(ctr),
      .arr(arr),
      .ar_reached(ar_reached)
      );
   
   gpio_in #(.WIDTH(WIDTH)) gpio_ini
     (
      .clk(clk),
      .cs(cs_porti),
      .wen(bus_wen),
      .din(bus_data_out),
      .dout(bus_porti_out),
      .io_in(PORTI)
      );
   
   gpio_in #(.WIDTH(WIDTH)) gpio_inj
     (
      .clk(clk),
      .cs(cs_portj),
      .wen(bus_wen),
      .din(bus_data_out),
      .dout(bus_portj_out),
      .io_in(PORTJ)
      );

   gpio_out4 #(.WIDTH(WIDTH)) gpio_out
     (
      .clk(clk),
      .reset(reset),
      .cs(cs_portabcd),
      .wen(bus_wen),
      .addr(bus_address[1:0]),
      .din(bus_data_out),
      .dout(bus_portabcd_out),
      .porta(PORTA),
      .portb(PORTB),
      .portc(PORTC),
      .portd(PORTD)
      );

   brd_ctrl #(.WIDTH(WIDTH)) board_control
     (
      .clk(clk),
      .reset(reset),
      .cs(cs_brd_ctrl),
      .wen(bus_wen),
      .din(bus_data_out),
      .dout(bus_brd_ctrl),
      .ctrl_out(BRD_CTRL)
      );
   
   uart io_uart
     (
      .clk(clk),
      .reset(reset),
      .cs(cs_uart),
      .wen(bus_wen),
      .addr(bus_address[3:0]),
      .din(bus_data_out),
      .dout(bus_uart_out),
      .RxD (RxD),
      .TxD (TxD)
      );
     
   // write only, no data out
   simif #(.WIDTH(WIDTH)) sim_interface
     (
      .clk(clk),
      .reset(reset),
      .cs(cs_simif),
      .wen(bus_wen),
      .addr(bus_address[0:0]),
      .din(bus_data_out),
      .dout(bus_simif_out)
      );

   clock #(.WIDTH(32)) ms_clock
     (
      .clk(clk),
      .reset(reset),
      .cs(cs_clock),
      .wen(bus_wen),
      .addr(bus_address),
      .din(bus_data_out),
      .dout(bus_clock_out)
      );
   
   assign bus_data_in
     = cs_mem?bus_mem_code_out:
       cs_timer?bus_timer_out:
       cs_porti?bus_porti_out:
       cs_portj?bus_portj_out:
       cs_portabcd?bus_portabcd_out:
       cs_brd_ctrl?bus_brd_ctrl:
       cs_uart?bus_uart_out:
       cs_simif?bus_simif_out:
       cs_clock?bus_clock_out:
       
       bus_mem_code_out
       ;
   
   assign ADDR= bus_address;
   assign MDO= bus_data_out;
   assign MDI= bus_data_in;
   assign MWE= bus_wen;
   assign irqs= { 30'd0, irq_timer };
   
endmodule // computer
