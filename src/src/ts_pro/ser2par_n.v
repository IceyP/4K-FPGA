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

module ser2par_n(
    ts_i_clk                    ,
    ts_i_data                   ,
    ts_i_sync                   ,
    ts_i_valid                  ,
    
    clk                         ,
    rst                         ,
    sl_fifo_rdy                 ,   //1:ready
    ram_full                    ,
    
    ts_o_data                   ,
    ts_o_valid                  
    );

parameter   RAM_DEPTH_BIT               = 12                        ;
parameter   RAM_DATA_WIDTH              = 8                         ;

input                                   ts_i_clk                    ;
input                                   ts_i_data                   ;
input                                   ts_i_sync                   ;
input                                   ts_i_valid                  ;

input                                   clk                         ;
input                                   rst                         ;
input                                   sl_fifo_rdy                 ;
output                                  ram_full                    ;

output  [7:0]                           ts_o_data                   ;
output                                  ts_o_valid                  ;

reg                                     d_1dly                      ;
reg                                     d_2dly                      ;
reg                                     sync_1dly                   ;
reg                                     sync_2dly                   ;
reg                                     valid_1dly                  ;
reg                                     valid_2dly                  ;

reg                                     ts_valid                    ;
reg                                     ts_sync                     ;
reg     [7:0]                           ts_data                     ;

reg                                     ts_head                     ;
reg     [2:0]                           bit_cnt                     ;

reg                                     fifo_wren                   ;
reg     [7:0]                           fifo_din                    ;
wire                                    fifo_rden                   ;
wire    [7:0]                           fifo_dout                   ;
wire    [11:0]                          fifo_rd_cnt                 ;
wire                                    fifo_full                   ;
wire                                    fifo_empty                  ;
reg                                     fifo_ok                     ;
reg     [2:0]                           div_cnt                     ;
wire                                    mclk                        ;
wire                                    mrst                        ;

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
        bit_cnt <=  {3{1'b0}};
    end
    else if(sync_2dly==1'b1)
    begin
        bit_cnt <=  3'b001;
    end
    else if(valid_2dly==1'b1)
    begin
        bit_cnt <=  bit_cnt + 'h1;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        ts_head <=  1'b0;
    end
    else if(sync_2dly==1'b1)
    begin
        ts_head <=  1'b1;
    end
    else if((bit_cnt==3'b111) && (valid_2dly==1'b1))
    begin
        ts_head <=  1'b0;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        ts_sync <=  1'b0;
    end
    else if((ts_head==1'b1) && (bit_cnt==3'b111) && (valid_2dly==1'b1))
    begin
        ts_sync <=  1'b1;
    end
    else 
    begin
        ts_sync <=  1'b0;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        ts_data <=  8'h00;
    end
    else if(valid_2dly==1'b1)
    begin
        ts_data   <=  {d_2dly,ts_data[7:1]};
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        ts_valid   <=  1'b0;
    end
    else if((bit_cnt==3'b111) && (valid_2dly==1'b1))
    begin
        ts_valid   <=  1'b1;
    end
    else
    begin
        ts_valid   <=  1'b0;
    end
end

////////////////////////////////////////////////////////////////////
//fifo write
////////////////////////////////////////////////////////////////////
always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        fifo_wren   <=  1'b0;
    end
    else
    begin
        fifo_wren   <=  ts_valid;
    end
end

always@(posedge mclk or posedge mrst)
begin
    if(mrst==1'b1)
    begin
        fifo_din    <=  {8{1'b0}};
    end
    else 
    begin
        fifo_din    <=  ts_data;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        fifo_ok <=  1'b0;
    end
    else if(fifo_alempty==1'b0)
    begin
        fifo_ok <=  1'b1;
    end
    else
    begin
        fifo_ok <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        div_cnt <=  3'b000;
    end
    else
    begin
        div_cnt <=  div_cnt + 'h1;
    end
end

assign  ram_full    =   fifo_full;
assign  fifo_rden   =   sl_fifo_rdy & fifo_ok & (&div_cnt);
assign  ts_o_valid  =   fifo_rden;
assign  ts_o_data   =   fifo_dout;

//first word fall through
asyncfifo_w8d4096 u0_asyncfifo_w8d4096(
    .wr_clk                             ( mclk                      ),
    .rd_clk                             ( clk                       ),
    .din                                ( fifo_din                  ),
    .wr_en                              ( fifo_wren                 ),
    .rd_en                              ( fifo_rden                 ),
    .dout                               ( fifo_dout                 ),
    .full                               ( fifo_full                 ),
    .empty                              ( fifo_empty                ),
    .almost_empty                       ( fifo_alempty              ),
    .rd_data_count                      ( fifo_rd_cnt               )
    );
    
endmodule