`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   11:13:26 09/08/2015
// Design Name:   rt21_top
// Module Name:   D:/svn_work/03.src/par/top_tb.v
// Project Name:  rt21
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: rt21_top
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module top_tb;

	// Inputs
	reg rst_n;
	reg clk_27m;
	reg [2:0] tuner_tsclk;
	reg [2:0] tuner_tsdata;
	reg [2:0] tuner_tssync;
	reg [2:0] tuner_tsvadlid;
	reg spi_clk;
	reg spi_mosi;
	reg spi_csn;
	reg [1:0] sl_flag;
	reg tuner_rst_i;
	reg [2:0] gpif_ctrl;

	// Outputs
	wire spi_miso;
	wire sc_xtali;
	wire sc_rstin;
	wire sc_cmdvcc;
	wire sc_sel5v3v;
	wire clk_if;
	wire sl_rd;
	wire sl_wr;
	wire sl_oe;
	wire [1:0] sl_fifo_adr;
	wire sl_pkt_end;
	wire sl_cs_n;
	wire tport;
	wire ram_full;
	wire all_cfg;
	wire tuner_rst_o;
	wire gpio_led;

	// Bidirs
	wire sc_data;
	wire [7:0] sl_data;
	wire [7:0] gpif_ad;

	// Instantiate the Unit Under Test (UUT)
	rt21_top uut (
		.rst_n(rst_n), 
		.clk_27m(clk_27m), 
		.tuner_tsclk(tuner_tsclk), 
		.tuner_tsdata(tuner_tsdata), 
		.tuner_tssync(tuner_tssync), 
		.tuner_tsvadlid(tuner_tsvadlid), 
		.spi_clk(spi_clk), 
		.spi_mosi(spi_mosi), 
		.spi_miso(spi_miso), 
		.spi_csn(spi_csn), 
		.sc_data(sc_data), 
		.sc_xtali(sc_xtali), 
		.sc_rstin(sc_rstin), 
		.sc_cmdvcc(sc_cmdvcc), 
		.sc_sel5v3v(sc_sel5v3v), 
		.clk_if(clk_if), 
		.sl_rd(sl_rd), 
		.sl_wr(sl_wr), 
		.sl_oe(sl_oe), 
		.sl_fifo_adr(sl_fifo_adr), 
		.sl_pkt_end(sl_pkt_end), 
		.sl_data(sl_data), 
		.sl_flag(sl_flag), 
		.sl_cs_n(sl_cs_n), 
		.tport(tport), 
		.ram_full(ram_full), 
		.all_cfg(all_cfg), 
		.tuner_rst_i(tuner_rst_i), 
		.tuner_rst_o(tuner_rst_o), 
		.gpif_ad(gpif_ad), 
		.gpif_ctrl(gpif_ctrl), 
		.gpio_led(gpio_led)
	);

	initial begin
		// Initialize Inputs
		rst_n = 0;
		clk_27m = 0;
		tuner_tsclk = 0;
		tuner_tsdata = 0;
		tuner_tssync = 0;
		tuner_tsvadlid = 0;
		spi_clk = 0;
		spi_mosi = 0;
		spi_csn = 0;
		sl_flag = 0;
		tuner_rst_i = 0;
		gpif_ctrl = 0;

		// Wait 100 ns for global reset to finish
		#100;
        
		// Add stimulus here

	end
	always #20 tuner_rst_i = ~tuner_rst_i;
      
endmodule

