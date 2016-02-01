/*************************************************************************************\
    Copyright(c) 2015, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   Creative Center,R&D Hardware Department
    Filename     :   ca_message_rx.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :   cbus read latency=4;
                     ca message packet is 192 bytes;
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2015-01-14  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :   ca_message_rx.v
    File tree    :   ca_message_rx.v
\************************************************************************************/

`timescale 1ns/100ps

module ca_message_rx(
    clk                         ,
    rst                         ,
    
    ts_valid                    ,
    ts_data                     ,
    ts_eop                      ,
    ts_rdy                      ,
    ts_ack                      ,

    cbus_addr                   ,
    cbus_wdata                  ,
    cbus_we                     ,
    cbus_oe                     ,
    cbus_rdata                  
    );

parameter   CBUS_ADDR_WIDTH             = 12                        ;
parameter   CBUS_DATA_WIDTH             = 8                         ;

//base address is 16'h4000
parameter   ADDR_CA_MESSAGE_START       = 12'h000                   ;
parameter   ADDR_CA_MESSAGE_END         = 12'h0BF                   ;
    
input                                   clk                         ;
input                                   rst                         ;

output                                  ts_valid                    ;
output   [7:0]                          ts_data                     ;
output                                  ts_eop                      ;
output                                  ts_rdy                      ;
input                                   ts_ack                      ;

input   [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr                   ;
input                                   cbus_we                     ;
input                                   cbus_oe                     ;
input   [CBUS_DATA_WIDTH - 1 : 0]       cbus_wdata                  ;
output  [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;

reg     [7:0]                           byte_cnt                    ;
reg     [9:0]                           start_addr                  ;
wire    [9:0]                           pkt_start_addr              ;
reg                                     fifo_rden_1dly              ;
reg     [7:0]                           word_cnt                    ;
wire    [7:0]                           pkt_len                     ;

wire    [7:0]                           ts_data                     ;
reg                                     ts_valid                    ;
reg                                     ts_eop                      ;
reg                                     ts_rdy                      ;

wire                                    ram_wren                    ;
wire    [7:0]                           ram_din                     ;
reg     [9:0]                           ram_waddr                   ;
reg     [9:0]                           ram_raddr                   ;
wire    [7:0]                           ram_dout                    ;

reg                                     fifo_wren                   ;
reg     [15:0]                          fifo_din                    ;
wire                                    fifo_rden                   ;
wire    [15:0]                          fifo_dout                   ;
wire    [3:0]                           fifo_data_cnt               ;

assign  cbus_rdata  =   {CBUS_DATA_WIDTH{1'b0}};

////////////////////////////////////////////////////////////////////
//fifo+ram write
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ram_waddr   <=  {10{1'b0}};
    end
    else if(ram_wren==1'b1)
    begin
        ram_waddr   <=  ram_waddr + 'h1;
    end
end

assign  ram_wren    =   (cbus_addr[11:8]==4'h0)  ?   cbus_we :   1'b0;
assign  ram_din     =   cbus_wdata;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        byte_cnt    <=  {8{1'b0}};
    end
    else if((cbus_we==1'b1) && (cbus_addr[11:8]==4'h0))
    begin
        if(cbus_addr[7:0]==8'h00)
        begin
            byte_cnt    <=  8'h01;
        end
        else
        begin
            byte_cnt    <=  byte_cnt + 'h1;
        end
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        start_addr  <=  {10{1'b0}};
    end
    else if((cbus_we==1'b1) && (cbus_addr==ADDR_CA_MESSAGE_START))
    begin
        start_addr  <=  ram_waddr;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        fifo_wren   <=  1'b0;
        fifo_din    <=  {16{1'b0}};
    end
    else if((cbus_we==1'b1) && (cbus_addr==ADDR_CA_MESSAGE_END) && (byte_cnt==8'hbf))
    begin
        fifo_wren   <=  1'b1;
        fifo_din    <=  {{6{1'b0}},start_addr[9:0]};
    end
    else
    begin
        fifo_wren   <=  1'b0;
        fifo_din    <=  {16{1'b0}};
    end
end
        
assign  fifo_rden       =   ts_ack;
assign  pkt_start_addr  =   fifo_dout[9:0];
assign  pkt_len         =   192;

////////////////////////////////////////////////////////////////////
//fifo+ram read
////////////////////////////////////////////////////////////////////
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
        ram_raddr   <=  pkt_start_addr;
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
        ts_valid  <=  1'b0;
    end
    else if(word_cnt>1)
    begin
        ts_valid  <=  1'b1;
    end
    else
    begin
        ts_valid  <=  1'b0;
    end
end

//always@(posedge clk or posedge rst)
//begin
//    if(rst==1'b1)
//    begin
//        ts_sop    <=  1'b0;
//    end
//    else if(word_cnt==2)
//    begin
//        ts_sop    <=  1'b1;
//    end
//    else
//    begin
//        ts_sop    <=  1'b0;
//    end
//end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_eop    <=  1'b0;
    end
    else if(word_cnt==(pkt_len+1))
    begin
        ts_eop    <=  1'b1;
    end
    else
    begin
        ts_eop    <=  1'b0;
    end
end

assign  ts_data   =  ram_dout;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_rdy  <=  1'b0;
    end
    else if(fifo_data_cnt>0)
    begin
        ts_rdy  <=  1'b1;
    end
    else
    begin
        ts_rdy  <=  1'b0;
    end
end

//read latency=2
sdpram_w8d1024 u0_camms_ram(
    .clka                               ( clk                       ),
    .wea                                ( ram_wren                  ),
    .addra                              ( ram_waddr                 ),
    .dina                               ( ram_din                   ),
    .clkb                               ( clk                       ),
    .addrb                              ( ram_raddr                 ),
    .doutb                              ( ram_dout                  )
    );

//read latency=1
syncfifo_w16d16 u0_camms_fifo(
    .clk                                ( clk                       ),
    .din                                ( fifo_din                  ),
    .wr_en                              ( fifo_wren                 ),
    .rd_en                              ( fifo_rden                 ),
    .dout                               ( fifo_dout                 ),
    .full                               ( /*not used*/              ),
    .empty                              ( /*not used*/              ),
    .data_count                         ( fifo_data_cnt             )
    );
    
endmodule   
