`timescale 1ns / 1ps

`include "defs.v"
`include "hwconf.v"

`define PRG "sw/progs2/counter3.asc"

module bool_top
  (
   input wire	      CLK,
   //input wire 	      RESET,
   input wire [15:0]  SW,
   input wire [3:0]   BTN,
   output wire [15:0] LED,
   output wire [7:0]  SEGL,
   output wire [3:0]  ANL,
   output wire [7:0]  SEGH,
   output wire [3:0]  ANH,
 
   input wire	      RxD,
   output wire	      TxD
   );
   
   wire		      RESET;
   wire [15:0]	      LEDS= LED;
   wire		      res;

   wire 	      f100MHz;
   wire 	      f50MHz;
   wire 	      f25MHz;
   wire 	      f20MHz;
   wire 	      f10MHz;
   wire 	      f1MHz;
   wire 	      f100kHz;
   wire 	      f10kHz;
   wire 	      f1kHz;
   wire 	      f100Hz;
   wire 	      f10Hz;
   wire 	      f1Hz;
   
   reg [3:0]	      btn;
   reg [15:0] 	      switches;
   
   wire [31:0]	      brd_ctrl;
   wire [3:0]	      clk_select;
   wire [3:0]	      display_select;
   wire [3:0]	      test_reg_select;
   wire [3:0]	      test_out_select;
   
   wire		      display_by_comp= brd_ctrl[0];
   
   assign clk_select     = switches[15:12];
   assign test_out_select= switches[11: 8];
   assign display_select = display_by_comp?brd_ctrl[7:4]:switches[ 7: 4];
   assign test_reg_select= switches[ 3: 0];
   
   assign f100MHz= CLK;
   clk_gen clock_generator
     (
      .f100MHz(f100MHz),
      .f50MHz(f50MHz),
      .f25MHz(f25MHz),
      .f20MHz(f20MHz),
      .f10MHz(f10MHz),
      .f1MHz(f1MHz),
      .f100kHz(f100kHz),
      .f10kHz(f10kHz),
      .f1kHz(f1kHz),
      .f100Hz(f100Hz),
      .f10Hz(f10Hz),
      .f1Hz(f1Hz)
      );
   
   wire 	      selected_clk;
   wire sel_clk;
   reg [31:0] 	      clk_test;
   mux16 #(.WIDTH(1)) clkmx(
        .sel(/*clk_select*/4'd9),
        .out(sel_clk),
        .in0(f1Hz),
        .in1(f10Hz),
        .in2(f100Hz),
        .in3(f1kHz),
        .in4(f10kHz),
        .in5(f100kHz),
        .in6(f1MHz),
        .in7(f10MHz),
        .in8(f20MHz),
        .in9(f25MHz),
        .in10(f50MHz),
        .in11(f100MHz),
        .in12(btn[3]),
        .in13(btn[3]),
        .in14(btn[3]),
        .in15(btn[3]));
   
BUFG clkg(.I(sel_clk), .O(selected_clk));

   always @(posedge selected_clk, posedge res)
     if (res)
       clk_test<= 0;
     else
       clk_test<= clk_test+1;
   
   
   always @(posedge f100Hz)
     begin
        btn<= BTN;
        switches<= SW;
     end
   
   reg res_syncer;
   reset_2btn res_by_btn(
    .clk(f1MHz),
    .b0(btn[0]),
    .b1(btn[1]),
    .res(RESET)
   );
   //assign RESET= ~btn[0];
   initial
     res_syncer= 1'd0;
   always @(posedge selected_clk)
     begin
	res_syncer<= RESET;
     end
   assign res= res_syncer;
   
   wire [31:0] porta;
   wire [31:0] portb;
   wire [31:0] portc;
   wire [31:0] portd;
   wire [31:0] tmr;
   wire [31:0] ctr;
   wire [31:0] arr;
   wire        ar_reached;
   wire [31:0] test_out;
   wire [31:0] test_reg;
   wire [31:0] mdi;
   wire [31:0] mdo;
   wire [31:0] addr;
   
   wire [31:0] irqs;
   wire [31:0] porti;
   wire [31:0] portj;
   
   wire [2:0]  clk_stat;
   
   assign porti= {28'd0, btn};
   assign portj= {16'd0, switches};
   comp
     #(
       .PMON_CONTENT   ( "./sw/pmon/pmon_chip.asc" ),
       .PROGRAM        ( `PRG ),
       .CPU_TYPE       ( `CPU_TYPE ),
       .COMP_TYPE      ( `COMP_TYPE ),
       .MEM_ADDR_SIZE  ( /*`AW*/16 ),
       .LOMEM_SIZE     ( 65536 ),
       .HIMEM_SIZE     ( 0 )
       )
   computer
     (
      .clk            (selected_clk),
      .reset          (res),
      .clk10m         (f1MHz),
      
      .PORTI          (porti),
      .PORTJ          (portj),
      .PORTA          (porta),
      .PORTB          (portb),
      .PORTC          (portc),
      .PORTD          (portd),
      .BRD_CTRL       (brd_ctrl),
      .RxD            (RxD),
      .TxD            (TxD),
      
      .test_sel       (test_out_select),
      .test_out       (test_out),
      .test_rsel      (test_reg_select),
      .test_reg       (test_reg),
      .CLKstat        (clk_stat),
      
      .ADDR           (addr),
      .MDO            (mdo),
      .MDI            (mdi),
      .MWE            (),
      .tmr            (tmr),
      .ctr            (ctr),
      .arr	      (arr),
      .ar_reached     (ar_reached),
      .irqs           (irqs)
      );
   
   wire [31:0] display_data;
   wire [3:0]  display_sel;
   mux16 dspmx(
        .sel(display_select),
        .in0(porta),
        .in1(portb),
        .in2(portc),
        .in3(portd),
        .in4(clk_test),
        .in5(arr),
        .in6(tmr),
        .in7(ctr),
        .in8(test_out),
        .in9(test_reg),
        .in10(0),
        .in11(brd_ctrl),
        .in12(irqs),
        .in13(mdi),
        .in14(mdo),
        .in15(addr),
        .out(display_data));
   
   seg7_2x4 seg7drv
     (
      .clk            (f25MHz),
      .reset          (res),
      .di             (display_data),
      .pixels         ({portd,portc}),
      .direct         (display_select==10),
      .segl           (SEGL),
      .anl            (ANL),
      .segh           (SEGH),
      .anh            (ANH)
      );
   
   assign LEDS[15:0]= portb[15:0];
   //assign LEDS[15]= RESET;
   /*
		{
		 clk_stat,
		 irqs[0],
		 ar_reached,
		 portb[0],
		 selected_clk,
		 f1MHz,
		 portc[7:0]
		 };
   */
   
endmodule // bool_top
