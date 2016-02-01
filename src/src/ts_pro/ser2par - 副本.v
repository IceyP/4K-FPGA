/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  ser2par.v
    Author       :  huangrui/1480
    ==================================================================================
    Description  :  
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-12-24  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :  ser2par.v
    File tree    :  ser2par.v                        
\************************************************************************************/

`timescale 1ns/100ps

module ser2par(
    ts_i_clk                    ,
    ts_i_data                   ,
    ts_i_sync                   ,
    ts_i_valid                  ,
    
    clk                         ,
    rst                         ,
    ts_pkt_rdy                  ,
    ts_pkt_ack                  ,
    
    ts_o_data                   ,
    ts_o_valid                  ,
    ts_o_sop                    ,
    ts_o_eop
    );

parameter   TUNER_INDEX                 = 0                         ;

input                                   ts_i_clk                    ;
input                                   ts_i_data                   ;
input                                   ts_i_sync                   ;
input                                   ts_i_valid                  ;

input                                   clk                         ;
input                                   rst                         ;
input                                   ts_pkt_ack                  ;
output                                  ts_pkt_rdy                  ;

output  [7:0]                           ts_o_data                   ;
output                                  ts_o_valid                  ;
output                                  ts_o_sop                    ;
output                                  ts_o_eop                    ;

reg     [2:0]                           bit_cnt                     ;
reg     [7:0]                           byte_cnt                    ;
reg                                     d_1dly                      ;
reg                                     d_2dly                      ;
reg                                     sync_1dly                   ;
reg                                     sync_2dly                   ;
reg                                     valid_1dly                  ;
reg                                     valid_2dly                  ;
reg                                     is_ts_pkt                   ;
reg     [2:0]                           ts_head_cnt                 ;
wire                                    ts_head                     ;

reg                                     valid_out_buf               ;
reg                                     sync_out_buf                ;
reg     [7:0]                           d_out_buf                   ;

reg                                     ts_valid                    ;
reg                                     ts_sync                     ;
reg     [7:0]                           ts_data                     ;
reg                                     ts_end                      ;

reg     [9:0]                           ram_start_addr              ;
wire    [9:0]                           start_addr                  ;
wire    [1:0]                           tuner_num                   ;
wire    [7:0]                           pkt_len                     ;
reg                                     fifo_rden_1dly              ;
reg     [7:0]                           word_cnt                    ;

wire                                    ram_wren                    ;
wire    [7:0]                           ram_din                     ;
reg     [9:0]                           ram_waddr                   ;
reg     [9:0]                           ram_raddr                   ;
wire    [7:0]                           ram_dout                    ;

reg                                     fifo_wren                   ;
reg     [15:0]                          fifo_din                    ;
wire                                    fifo_rden                   ;
wire    [15:0]                          fifo_dout                   ;
wire    [3:0]                           fifo_rd_cnt                 ;

wire    [7:0]                           ts_o_data                   ;
reg                                     ts_o_valid                  ;
reg                                     ts_o_sop                    ;
reg                                     ts_o_eop                    ;
reg                                     ts_pkt_rdy                  ;

assign  mclk        =   ts_i_clk;
assign  mrst        =   rst;
    
//interface sync
always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        d_1dly      <=  1'b0;
        d_2dly      <=  1'b0;
        sync_1dly   <=  1'b0;
        sync_2dly   <=  1'b0;
        valid_1dly  <=  1'b0;
        valid_2dly  <=  1'b0;
    end
    else
    begin
        d_1dly      <=  ts_i_data;
        d_2dly      <=  d_1dly;
        sync_1dly   <=  ts_i_sync;
        sync_2dly   <=  sync_1dly;
        valid_1dly  <=  ts_i_valid;
        valid_2dly  <=  valid_1dly;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        ts_head_cnt <=  3'b000;
    end
    else if((sync_2dly==1'b1) && (valid_2dly==1'b1))
    begin
        ts_head_cnt <=  3'b001;
    end
    else if((&ts_head_cnt==1'b1) && (valid_2dly==1'b1))
    begin
        ts_head_cnt <=  3'b000;
    end
    else if((|ts_head_cnt==1'b1) && (valid_2dly==1'b1))
    begin
        ts_head_cnt <=  ts_head_cnt + 3'b001;
    end
end

assign  ts_head =   valid_2dly & (sync_2dly | (|ts_head_cnt));
           
always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        bit_cnt <=  {3{1'b0}};
    end
    else if((ts_head==1'b1) || ((is_ts_pkt==1'b1) && (valid_2dly==1'b1)))
    begin
        bit_cnt <=  bit_cnt + 'h1;
    end
    else if((valid_2dly==1'b1) && ((|bit_cnt)==1'b1))
    begin
        bit_cnt <=  {3{1'b0}};
    end
end
        
always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        is_ts_pkt   <=  1'b0;
    end
    else if((ts_head==1'b1) && ((|bit_cnt)==1'b0))
    begin
        is_ts_pkt   <=  1'b0;
    end
    else if((ts_head==1'b1) && ((&bit_cnt)==1'b1))
    begin
        is_ts_pkt   <=  1'b1;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        byte_cnt    <=  {8{1'b0}};
    end
    else if((sync_out_buf==1'b1) && ((|byte_cnt)==1'b0) && (d_out_buf==8'h47))
    begin
        byte_cnt    <=  8'h01;
    end
    else if(((|byte_cnt)==1'b1) && (valid_out_buf==1'b1))
    begin
        if(byte_cnt==187)
        begin
            byte_cnt    <=  {8{1'b0}};
        end
        else
        begin
            byte_cnt    <=  byte_cnt + 'h1;
        end
    end
end

////////////////////////////////////////////////////////////////////
//output buf
////////////////////////////////////////////////////////////////////    
always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        valid_out_buf   <=  1'b0;
    end
    else if(((&bit_cnt)==1'b1) && (valid_2dly==1'b1))
    begin
        valid_out_buf   <=  1'b1;
    end
    else
    begin
        valid_out_buf   <=  1'b0;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        sync_out_buf    <=  1'b0;
    end
    else if((ts_head==1'b1) && ((&bit_cnt)==1'b1))
    begin
        sync_out_buf    <=  1'b1;
    end
    else
    begin
        sync_out_buf    <=  1'b0;
    end
end

//shift register,no reset,use SRL logic resource
always@(posedge mclk)
begin
    if(valid_2dly==1'b1)
    begin
        //d_out_buf   <=  {d_2dly,d_out_buf[7:1]};
		  d_out_buf   <=  {d_out_buf[6:0],d_2dly};
    end
end   

////////////////////////////////////////////////////////////////////
//ts ser to par result
////////////////////////////////////////////////////////////////////
always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        ts_valid   <=  1'b0;
    end
    else if((((|byte_cnt)==1'b0) && (d_out_buf==8'h47)) ||
            ((|byte_cnt)==1'b1))
    begin
        ts_valid   <=  valid_out_buf;
    end
    else
    begin
        ts_valid   <=  1'b0;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin  
        ts_sync    <=  1'b0;
    end
    else if(((|byte_cnt)==1'b0) && (d_out_buf==8'h47) && (sync_out_buf==1'b1))
    begin
        ts_sync    <=  1'b1;
    end
    else
    begin
        ts_sync    <=  1'b0;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin  
        ts_end  <=  1'b0;
    end
    else if((byte_cnt==187) && (valid_out_buf==1'b1))
    begin
        ts_end  <=  1'b1;
    end
    else
    begin
        ts_end  <=  1'b0;
    end
end
    
always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        ts_data   <=  {8{1'b0}};
    end
    else
    begin
        ts_data   <=  d_out_buf;
    end
end

////////////////////////////////////////////////////////////////////
//fifo+ram write
////////////////////////////////////////////////////////////////////
assign  ram_wren    =   ts_valid;
assign  ram_din     =   ts_data;

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        ram_waddr   <=  {10{1'b0}};
    end
    else if(ts_valid==1'b1)
    begin
        ram_waddr   <=  ram_waddr + 'h1;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        fifo_wren   <=  1'b0;
    end
    else if(ts_end==1'b1)
    begin
        fifo_wren   <=  1'b1;
    end
    else
    begin
        fifo_wren   <=  1'b0;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        ram_start_addr  <=  {10{1'b0}};
    end
    else if(ts_sync==1'b1)
    begin
        ram_start_addr  <=  ram_waddr;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        fifo_din    <=  {32{1'b0}};
    end
    else if(ts_end==1'b1)
    begin
        fifo_din    <=  {{4{1'b0}},TUNER_INDEX[1:0],ram_start_addr[9:0]};
    end
end

////////////////////////////////////////////////////////////////////
//fifo+ram read
////////////////////////////////////////////////////////////////////
assign  fifo_rden   =   ts_pkt_ack;
assign  start_addr  =   fifo_dout[9:0];
assign  tuner_num   =   fifo_dout[11:10];
assign  pkt_len     =   188;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        fifo_rden_1dly  <=  1'b0;
    end
    else
    begin
        fifo_rden_1dly  <=  fifo_rden;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        word_cnt    <=  {8{1'b0}};
    end
    else if(fifo_rden_1dly==1'b1)
    begin
        word_cnt    <=  {{7{1'b0}},1'b1};
    end
    else if(word_cnt==(pkt_len+1))
    begin
        word_cnt    <=  {8{1'b0}};
    end
    else if(word_cnt>0)
    begin
        word_cnt    <=  word_cnt + 'h1;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ram_raddr   <=  {10{1'b0}};
    end
    else if(fifo_rden_1dly==1'b1)
    begin
        ram_raddr   <=  start_addr;
    end
    else if(word_cnt>0)
    begin
        ram_raddr   <=  ram_raddr + 'h1;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_o_valid  <=  1'b0;
    end
    else if(word_cnt>1)
    begin
        ts_o_valid  <=  1'b1;
    end
    else
    begin
        ts_o_valid  <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_o_sop    <=  1'b0;
    end
    else if(word_cnt==2)
    begin
        ts_o_sop    <=  1'b1;
    end
    else
    begin
        ts_o_sop    <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_o_eop    <=  1'b0;
    end
    else if(word_cnt==(pkt_len+1))
    begin
        ts_o_eop    <=  1'b1;
    end
    else
    begin
        ts_o_eop    <=  1'b0;
    end
end

assign  ts_o_data   =  ((tuner_num==2'b00) && (ts_o_sop==1'b1)) ?   8'h40   :
                       ((tuner_num==2'b01) && (ts_o_sop==1'b1)) ?   8'h41   :
                       ((tuner_num==2'b10) && (ts_o_sop==1'b1)) ?   8'h42   :
                       ((tuner_num==2'b11) && (ts_o_sop==1'b1)) ?   8'h43   :
                        ram_dout;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_pkt_rdy  <=  1'b0;
    end
    else if(fifo_rd_cnt>0)
    begin
        ts_pkt_rdy  <=  1'b1;
    end
    else
    begin
        ts_pkt_rdy  <=  1'b0;
    end
end

//read latency=2
asyncram_w8d1024 u0_asyncram_w8d1024(
    .clka                               ( mclk                      ),
    .wea                                ( ram_wren                  ),
    .addra                              ( ram_waddr                 ),
    .dina                               ( ram_din                   ),
    .clkb                               ( clk                       ),
    .addrb                              ( ram_raddr                 ),
    .doutb                              ( ram_dout                  )
    );

//read latency=1
asyncfifo_w16d16 u0_asyncfifo_w32d64(
    .wr_clk                             ( mclk                      ),
    .rd_clk                             ( clk                       ),
    .din                                ( fifo_din                  ),
    .wr_en                              ( fifo_wren                 ),
    .rd_en                              ( fifo_rden                 ),
    .dout                               ( fifo_dout                 ),
    .full                               ( /*not used*/              ),
    .empty                              ( /*not used*/              ),
    .rd_data_count                      ( fifo_rd_cnt               )
    );
    
endmodule