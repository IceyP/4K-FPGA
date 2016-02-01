`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    17:11:53 12/10/2015 
// Design Name: 
// Module Name:    eypt_test 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module pkt_eypt(
	clk,
	rst,
	ts_i_valid,
	ts_i_sop,
	ts_i_eop,
	ts_i_index,
	chacha_enable,
	
	pkt_encypt_ena
    );
parameter				PKTBIT			=	7;
parameter				INDEXBIT			=	7;
input											clk;
input											rst;

input											ts_i_valid;
input											ts_i_sop;
input											ts_i_eop;
input		[11:0]							ts_i_index;
input											chacha_enable;

output										pkt_encypt_ena;

reg      [7:0]                      byte_cnt;
reg											pkt_encypt_flag;
wire		[6:0]								pid_index;

reg											eyptram_wren;
reg		[PKTBIT-1:0]					eyptram_wdata;
wire		[INDEXBIT-1:0]					eyptram_waddr;
wire		[INDEXBIT-1:0]					eyptram_raddr;
wire		[PKTBIT-1:0]					eyptram_rdata;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        byte_cnt    <=  {8{1'b0}};
    end
    else if(ts_i_sop==1'b1)
    begin
        byte_cnt    <=  8'h01;
    end
    else if(ts_i_eop==1'b1)
    begin
        byte_cnt    <=  {8{1'b0}};
    end
    else if((ts_i_valid==1'b1) && (|byte_cnt==1'b1))
    begin
        byte_cnt    <=  byte_cnt + 8'h01;
    end
end

always@(posedge clk or posedge rst)
begin
	if(rst==1'b1)
	begin
		eyptram_wren     			<=  1'b0;
		eyptram_wdata    			<=  {PKTBIT{1'b0}};
   end
   else if(ts_i_eop == 1'b1)
   begin
		eyptram_wdata    			<=  eyptram_rdata + 'h1;
		eyptram_wren     			<=  1'b1;
   end
	else
	begin
		eyptram_wren     			<=  1'b0;
	end
end

always@(posedge clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		pkt_encypt_flag 		<=	1'b0;
	end
	else if((ts_i_valid==1'b1) && ((&eyptram_rdata) == 1'b1))
	begin
		pkt_encypt_flag		<=	 1'b1;
   end
   else 
   begin
		pkt_encypt_flag		<=	 1'b0;
   end
end

assign  eyptram_waddr   =   pid_index;
assign  eyptram_raddr   =   pid_index;
assign  pkt_encypt_ena  =   pkt_encypt_flag	?	chacha_enable : 0;

u0_encypt_ram encypt_ramw8d128(
  .clka										( clk ), 									// input clka
  .wea										( eyptram_wren ), 						// input [0 : 0] wea
  .addra										( eyptram_waddr ), 						// input [6 : 0] addra
  .dina										( eyptram_wdata ), 						// input [7 : 0] dina
  .clkb										( clk ), 									// input clkb
  .addrb										( eyptram_raddr ), 						// input [6 : 0] addrb
  .doutb										( eyptram_rdata ) 						// output [7 : 0] doutb
);
endmodule
