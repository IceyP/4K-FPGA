`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   15:16:54 08/26/2015
// Design Name:   pktmux_slfifo
// Module Name:   D:/svn_work/03.src/par/pktmux_tb.v
// Project Name:  rt21
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: pktmux_slfifo
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module pktmux_tb;

	// Inputs
	reg clk;
	reg rst;
	reg tsa_valid;
	reg [7:0] tsa_data;
	reg tsa_eop;
	reg tsa_rdy;
	reg tsb_valid;
	reg [7:0] tsb_data;
	reg tsb_eop;
	reg tsb_rdy;
	reg sl_bp;

	// Outputs
	wire tsa_ack;
	wire tsb_ack;
	wire sl_wr;
	wire [7:0] sl_data;
	wire [1:0] sl_fifo_adr;
	wire sl_pkt_end;

	// Instantiate the Unit Under Test (UUT)
	pktmux_slfifo uut (
		.clk(clk), 
		.rst(rst), 
		.tsa_valid(tsa_valid), 
		.tsa_data(tsa_data), 
		.tsa_eop(tsa_eop), 
		.tsa_rdy(tsa_rdy), 
		.tsa_ack(tsa_ack), 
		.tsb_valid(tsb_valid), 
		.tsb_data(tsb_data), 
		.tsb_eop(tsb_eop), 
		.tsb_rdy(tsb_rdy), 
		.tsb_ack(tsb_ack), 
		.sl_wr(sl_wr), 
		.sl_data(sl_data), 
		.sl_bp(sl_bp), 
		.sl_fifo_adr(sl_fifo_adr), 
		.sl_pkt_end(sl_pkt_end)
	);

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
		tsa_valid = 0;
		tsa_data = 0;
		tsa_eop = 0;
		tsa_rdy = 0;
		tsb_valid = 0;
		tsb_data = 0;
		tsb_eop = 0;
		tsb_rdy = 0;
		sl_bp = 0;

		// Wait 100 ns for global reset to finish
		#100;
		rst = 0;
		tsa_valid = 1;
		tsa_data = 8'b11110010;
		tsa_eop = 1;
		tsa_rdy = 1;
		sl_bp = 1;
		#500;
		tsa_valid = 0;
		tsa_data = 8'b11110010;
		tsa_eop = 0;
		tsa_rdy = 0;
		sl_bp = 1;
		#500
		tsb_valid = 1;
		tsb_data = 8'b00101111;
		tsb_eop = 1;
		tsb_rdy = 1;
		sl_bp = 1;
		#500
		tsb_valid = 0;
		tsb_data = 0;
		tsb_eop = 0;
		tsb_rdy = 0;
		sl_bp = 1;
		// Add stimulus here

	end
   always #10 clk = ~clk;   
endmodule

