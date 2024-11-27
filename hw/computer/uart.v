module uart
  #(
    parameter WIDTH=32,
    parameter SIM_PRINT=1
    )
   (
    input wire		   clk,
    input wire		   reset,
    input wire		   cs,
    input wire		   wen,
    input wire [3:0]	   addr,
    input wire [WIDTH-1:0] din,

    output [WIDTH-1:0]	   dout,

    input wire		   RxD,
    output wire		   TxD
    );

   // Addresses of registers
   localparam		   REG_DR	= 4'd0; // data
   localparam		   REG_CTRL	= 4'd1; // Control
   localparam		   REG_RSTAT	= 4'd2; // Receive Status
   localparam		   REG_TSTAT	= 4'd3; // Transmit Status
   localparam		   REG_CPB	= 4'd4; // Cycles per bit
   localparam		   REG_QUEUE 	= 4'd5; // Rx fifo read
   localparam		   REG_INC_RADDR= 4'd6;
   localparam		   REG_CHAR_COUNT= 4'd7;
   localparam		   REG_FIFO_WR_COUNT= 4'd8;
   localparam		   REG_FIFO_FULL_COUNT= 4'd9;
					  
   // Bits of RX status register
   localparam		   STAT_RXNE= 0;
   localparam		   STAT_BREAK= 1;
   localparam		   STAT_RXVALID= 2;
   // Bits of TX status register
   localparam		   STAT_TC= 0;
   
   // Bits of control register
   localparam		   CTRL_RX_EN= 0;
   localparam		   CTRL_TX_EN= 1;

   wire			   wr= cs & wen;
   wire 		   addr_is_ira= (addr==REG_INC_RADDR);
   wire 		   wr_ira= wr & addr_is_ira;
   
   wire			   rd= cs & ~wen;
   wire			   addr_is_queue= (addr==REG_QUEUE);
   wire			   addr_is_dr= (addr==REG_DR);
   wire			   rd_data= rd & (addr_is_queue | addr_is_dr);
   
   // CONTROL register
   reg [WIDTH-1:0]	   control;
   always @(posedge clk)
     begin
	if (reset) control<= 0;
	else if (wr & (addr==REG_CTRL))
	  control<= din;
     end

   
   // Parameter registers
   reg [WIDTH-1:0] cycles_per_bit;
   always @(posedge clk)
     begin
	if (reset)
	  cycles_per_bit<=
`ifdef IVERILOG
			  32'd39;
`else
	32'd216; // 25MHz -> 115200 Baud
`endif
	else
	  if (wr & (addr==REG_CPB))
	    cycles_per_bit<= din;
     end
   
   
   // Storage registers
   reg [WIDTH-1:0] regs [3:0];
   wire		   regs_wen;
   assign regs_wen= wr & addr[3:2]==2'b11;
   
   initial
     begin
	regs[0]= 0;
	regs[1]= 0;
	regs[2]= 0;
	regs[3]= 0;
     end
   
   always @(posedge clk)
     begin
	if (reset)
	  begin
	     regs[0]<= 0;
	     regs[1]<= 0;
	     regs[2]<= 0;
	     regs[3]<= 0;
	  end
	else if (regs_wen)
	  begin
	     regs[addr[1:0]]<= din;
	  end
     end

   wire utx_wen;
   assign utx_wen= control[CTRL_TX_EN]
		   & cs
		   & wen
		   & (addr==REG_DR);
   wire tx_busy;
   
   uart_tx #(.SIM_PRINT(SIM_PRINT))
   utx
     (
      .clk (clk),
      .resetn (!reset),
      .uart_txd (TxD),
      .uart_tx_busy (tx_busy),
      .uart_tx_en (utx_wen),
      .uart_tx_data (din[7:0]),
      .data_bits (32'd8),
      .cycles_per_bit (cycles_per_bit)
      );

   
   wire rx_en;
   wire rx_break;
   wire rx_valid;
   wire [7:0] rx_data;
   wire [31:0] rx_char_count;
   assign rx_en= control[CTRL_RX_EN];

   uart_rx urx
     (
      .clk (clk),
      .resetn (!reset),
      .uart_rxd (RxD),
      .uart_rx_en (rx_en),
      .uart_rx_break(rx_break),
      .uart_rx_valid(rx_valid),
      .uart_rx_data (rx_data),
      .cycles_per_bit (cycles_per_bit),
      .uart_rx_char_count (rx_char_count)
      );

   localparam FSM_IDLE		= 2'b00;
   localparam FSM_GOT		= 2'b01;
   localparam FSM_QUEUE		= 2'b10;
   localparam FSM_READOUT	= 2'b11;
   
   reg [1:0]  rx_fsm= FSM_IDLE;
   wire       rx_readout;
   wire       rx_not_empty;
   assign rx_readout= rd_data; 
   
   always @(posedge clk)
     begin
	if (reset)
	  rx_fsm<= FSM_IDLE;
	else
	  case (rx_fsm)
	    FSM_IDLE   : rx_fsm<= rx_valid   ? FSM_QUEUE   : FSM_IDLE;
	    FSM_QUEUE  : rx_fsm<= FSM_IDLE;//FSM_GOT;
	    FSM_GOT    : rx_fsm<= rx_readout ? FSM_READOUT : FSM_GOT;
	    FSM_READOUT: rx_fsm<= !rx_valid  ? FSM_IDLE    : FSM_READOUT;
	    //default    : rx_fsm<= FSM_IDLE;
	  endcase
     end
   assign rx_not_empty= rx_fsm==FSM_GOT;

   localparam QFSM_IDLE= 1'b0;
   localparam QFSM_READ= 1'b1;
   reg	      qfsm= QFSM_IDLE;

   always @(posedge clk)
     begin
	if (reset)
	  qfsm<= QFSM_IDLE;
	else
	  case (qfsm)
	    QFSM_IDLE: qfsm<=  rd_data ? QFSM_READ : QFSM_IDLE;
	    QFSM_READ: qfsm<= !rd_data ? QFSM_IDLE : QFSM_READ;
	    //default: qfsm<= FSM_IDLE;
	  endcase
     end
   
   reg [31:0] fifo_wr_count;
   always @(posedge clk)
     if (reset)
       fifo_wr_count<= 0;
     else
       if (rx_fsm==FSM_QUEUE)
	 fifo_wr_count<= fifo_wr_count+1;

   // Receive FIFO
   wire [7:0]	    queue_out;
   wire		    queue_empty;
   wire		    queue_full;
   wire [3:0]	    queue_raddr;
   wire [3:0]	    queue_waddr;
   wire		    queue_wen;
   
   assign queue_wen= rx_fsm == FSM_QUEUE;
   
/* -----\/----- EXCLUDED -----\/-----
   fifo #(.WIDTH(8), .ADDR_WIDTH(7)) ufifo
     (
      .clk(clk),
      .reset(reset),
      .rd(/-*rd_data*-/wr_ira),
      .wr(rx_fsm == FSM_QUEUE),
      .din(rx_data),
      .dout(queue_out),
      .empty(queue_empty),
      .full(queue_full),
      .raddr(queue_raddr),
      .waddr(queue_waddr)
      );
 -----/\----- EXCLUDED -----/\----- */

   FIFO #(.DWIDTH(8), .AWIDTH(4)) ufifo
     (
      .clk(clk),
      .resetn(!reset),
      .rd(rd_data/*wr_ira*/),
      .wr(queue_wen),
      .w_data(rx_data),
      .empty(queue_empty),
      .full(queue_full),
      .r_data(queue_out),
      .r_ptr(queue_raddr),
      .w_ptr(queue_waddr)
      );

   reg [WIDTH-1:0]  queue_bufout;

   always @(posedge clk)
     if (reset)
       queue_bufout<= 0;
     else
       if (qfsm == QFSM_IDLE)
	 queue_bufout<= queue_out;

   
   reg [31:0] 	    fifo_full_count;
   always @(posedge clk)
     if (reset)
       fifo_full_count<= 0;
     else
       if ((rx_fsm==FSM_QUEUE) & queue_full)
	 fifo_full_count<= fifo_full_count+1;

   
   wire [WIDTH-1:0] rstat_value;
   wire [WIDTH-1:0] tstat_value;
   assign rstat_value= {/* xx00 0000 */ {4'b0,queue_raddr},
			/* 00xx 0000 */ {4'b0,queue_waddr},
			/* 0000 xx00 */ queue_out,
			/* 0000 0080 */ rx_fsm,
			/* 0000 0040 */ 
			/* 0000 0020 */ queue_full,
			/* 0000 0010 */ queue_empty,
			/* 0000 0008 */ rx_not_empty,
			/* 0000 0004 */ rx_valid,
			/* 0000 0002 */ rx_break,
			/* 0000 0001 */~queue_empty
			};
   assign tstat_value= {31'd0,
			!tx_busy
			};
   
   // Output data
   assign dout= (addr==REG_DR)?{24'd0,/*rx_data*/queue_bufout}:
		(addr==REG_CTRL)?control:
		(addr==REG_RSTAT)?rstat_value:
		(addr==REG_TSTAT)?tstat_value:
		(addr==REG_CPB)?cycles_per_bit:
		(addr==REG_QUEUE)?{24'b0,queue_bufout}:
		(addr==REG_CHAR_COUNT)?rx_char_count:
		(addr==REG_FIFO_WR_COUNT)?fifo_wr_count:
		(addr==REG_FIFO_FULL_COUNT)?fifo_full_count:
		(addr[3:2]==2'b11)?regs[addr[1:0]]:
		0;
   
endmodule // uart
