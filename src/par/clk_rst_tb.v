`timescale 1ns / 1ps

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:21:39 08/20/2015
// Design Name:   clk_rst
// Module Name:   D:/svn_work/03.src/par/clk_rst_tb.v
// Project Name:  rt21
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: clk_rst
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module clk_rst_tb;

	// Inputs
	reg rstn_in;
	reg clk_if;

	// Outputs
	wire clk_ebi;
	wire clk_ebi_3x;
	wire clk_ebi_4x;
	wire rst_ebi_4x;
	wire rst_ebi_3x;
	wire rst_out;

	// Instantiate the Unit Under Test (UUT)
	clk_rst uut (
		.rstn_in(rstn_in), 
		.clk_if(clk_if), 
		.clk_ebi(clk_ebi), 
		.clk_ebi_3x(clk_ebi_3x), 
		.clk_ebi_4x(clk_ebi_4x), 
		.rst_ebi_4x(rst_ebi_4x), 
		.rst_ebi_3x(rst_ebi_3x), 
		.rst_out(rst_out)
	);

	initial begin
		// Initialize Inputs
		rstn_in = 0;
		clk_if = 0;

		// Wait 100 ns for global reset to finish
		#100;
      rstn_in = 1;
		#50000;
		rstn_in = 0;
		#50000;
		rstn_in = 1;		
		// Add stimulus here

	end
   always #10   clk_if = ~clk_if; 
endmodule

