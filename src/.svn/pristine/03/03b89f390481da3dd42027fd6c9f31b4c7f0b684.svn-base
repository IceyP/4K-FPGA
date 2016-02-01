/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   Creative Center,R&D Hardware Department
    Filename     :   ts_filter.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :   descram head of tuner_index=0: 8'h48;
                     descram head of tuner_index=1: 8'h49;
                     descram head of tuner_index=2: 8'h4a;
                     descram head of tuner_index=3: 8'h4b;
                     cbus read latency=4;
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-12-24  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :   ts_filter.v
    File tree    :   ts_filter.v
\************************************************************************************/

`timescale 1ns/100ps

module ts_filter(
    clk                         ,
    rst                         ,
    ts_valid                    ,
    ts_data                     ,
    ts_sop                      ,
    ts_eop                      ,
                                
    ts_o_valid                  ,
    ts_o_data                   ,
    ts_o_sop                    ,
    ts_o_eop                    ,
    ts_o_index                  ,
                                
    cbus_clk                    ,
    cbus_rst                    ,
    cbus_addr                   ,
    cbus_wdata                  ,
    cbus_we                     ,
    cbus_oe                     ,
    cbus_rdata                  
    );

parameter   CBUS_ADDR_WIDTH             = 12                        ;
parameter   CBUS_DATA_WIDTH             = 8                         ;

//base address is 0x1000
parameter   ADDR_ALL_PID_CFG1           = 12'h200                   ;
parameter   ADDR_ALL_PID_CFG2           = 12'h201                   ;
parameter   ADDR_ALL_PID_CFG3           = 12'h202                   ;
parameter   ADDR_ALL_PID_CFG4           = 12'h203                   ;

parameter   PIDRAM_DEPTH_BIT            = 7                         ;
parameter   PIDRAM_DATA_WIDTH           = 18                        ;
parameter   PKT_LEN                     = 188                       ;

parameter   ST_WIDTH                    = 3                         ;
parameter   ST_IDLE                     = 3'b001                    ,
            ST_PID_SEARCH               = 3'b010                    ,
            ST_SEARCH_END               = 3'b100                    ;

parameter   ST_O_WIDTH                  = 4                         ;
parameter   ST_O_IDLE                   = 4'b0001                   ,
            ST_O_RD_FIFO                = 4'b0010                   ,
            ST_O_WAIT                   = 4'b0100                   ,
            ST_O_RD_DATA                = 4'b1000                   ;

input                                   clk                         ;
input                                   rst                         ;
input                                   ts_valid                    ;
input   [7:0]                           ts_data                     ;
input                                   ts_sop                      ;
input                                   ts_eop                      ;

output                                  ts_o_valid                  ;
output  [7:0]                           ts_o_data                   ;
output                                  ts_o_sop                    ;
output                                  ts_o_eop                    ;
output  [7:0]                           ts_o_index                  ;

input                                   cbus_clk                    ;
input                                   cbus_rst                    ;
input   [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr                   ;
input   [CBUS_DATA_WIDTH - 1 : 0]       cbus_wdata                  ;
input                                   cbus_we                     ;
input                                   cbus_oe                     ;
output  [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;

reg     [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;
reg                                     cbus_oe_1dly                ;
reg                                     cbus_oe_2dly                ;
reg                                     cbus_oe_3dly                ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_1dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_2dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_3dly              ;
reg     [3:0]                           all_pid_cfg                 ;
reg     [3:0]                           all_pid_cfg_1dly            ;
reg     [3:0]                           all_pid_cfg_2dly            ;

reg                                     pid_ram_wren                ;
reg     [PIDRAM_DATA_WIDTH - 1 : 0]     pid_ram_din                 ;
reg     [PIDRAM_DEPTH_BIT - 1 : 0]      pid_ram_waddr               ;
reg     [PIDRAM_DEPTH_BIT - 1 : 0]      pid_ram_raddr               ;
wire    [PIDRAM_DATA_WIDTH - 1 : 0]     pid_ram_dout                ;

reg     [ST_WIDTH - 1 : 0]              st_curr                     ;
reg     [ST_WIDTH - 1 : 0]              st_next                     ;

reg     [2:0]                           word_cnt                    ;
reg     [12:0]                          ts_pid                      ;
reg     [1:0]                           tuner_index                 ;
reg     [7:0]                           search_cnt                  ;
reg     [6:0]                           pid_match_index             ;
reg     [1:0]                           pid_match_type              ;
wire    [7:0]                           pid_index_buf               ;
wire    [12:0]                          ram_pid                     ;
wire                                    pid_descram_ena             ;
wire                                    pid_filter_ena              ;
wire    [1:0]                           ram_tuner_index             ;
reg                                     null_packet                 ;

wire                                    ram_wren                    ;
wire    [7:0]                           ram_din                     ;
reg     [9:0]                           ram_waddr                   ;
reg     [9:0]                           ram_raddr                   ;
wire    [7:0]                           ram_dout                    ;

reg                                     fifo_wren                   ;
reg     [17:0]                          fifo_din                    ;
reg                                     fifo_rden                   ;
reg                                     fifo_rden_1dly              ;
reg                                     fifo_rden_2dly              ;
wire    [17:0]                          fifo_dout                   ;
wire    [3:0]                           fifo_rd_cnt                 ;
reg     [9:0]                           pkt_start_addr              ;
wire    [17:0]                          pid_rd_out                  ;

reg     [ST_O_WIDTH - 1 : 0]            st_o_curr                   ;
reg     [ST_O_WIDTH - 1 : 0]            st_o_next                   ;
reg     [7:0]                           rd_cnt                      ;
wire                                    descram_head                ;

reg                                     ts_o_valid                  ;
wire    [7:0]                           ts_o_data                   ;
reg                                     ts_o_sop                    ;
reg                                     ts_o_eop                    ;
reg     [7:0]                           ts_o_index                  ;

always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        pid_ram_wren    <=  1'b0;
    end
    else if((cbus_we==1'b1) && (cbus_addr[1:0]==2'b11) && (cbus_addr[11:9]=={3{1'b0}}))
    begin
        pid_ram_wren    <=  1'b1;
    end
    else
    begin
        pid_ram_wren    <=  1'b0;
    end
end

always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        cbus_oe_1dly    <=  1'b0;
        cbus_oe_2dly    <=  1'b0;
        cbus_oe_3dly    <=  1'b0;
    end
    else
    begin
        cbus_oe_1dly    <=  cbus_oe;
        cbus_oe_2dly    <=  cbus_oe_1dly;
        cbus_oe_3dly    <=  cbus_oe_2dly;
    end
end

always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        cbus_addr_1dly  <=  {CBUS_ADDR_WIDTH{1'b0}};
        cbus_addr_2dly  <=  {CBUS_ADDR_WIDTH{1'b0}};
        cbus_addr_3dly  <=  {CBUS_ADDR_WIDTH{1'b0}};
    end
    else
    begin
        cbus_addr_1dly  <=  cbus_addr;
        cbus_addr_2dly  <=  cbus_addr_1dly;
        cbus_addr_3dly  <=  cbus_addr_2dly;
    end
end
            
//base address is 0x1000
always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        pid_ram_din <=  {PIDRAM_DATA_WIDTH{1'b0}};
    end
    else if((cbus_we==1'b1) && && (cbus_addr[11:9]=={3{1'b0}}))
    begin
        case(cbus_addr[1:0])
        2'b00   :   pid_ram_din[17:13]  <=  {1'b0,cbus_wdata[3:0]};
        2'b01   :   pid_ram_din[12:8]   <=  cbus_wdata[4:0];
        2'b10   :   pid_ram_din[7:0]    <=  cbus_wdata[7:0];
        default :;
        endcase
    end
end

always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        all_pid_cfg <=  {4{1'b0}};
    end
    else if(cbus_we==1'b1)
    begin
        case(cbus_addr)
        ADDR_ALL_PID_CFG1   :   all_pid_cfg[0]  <=  cbus_wdata[0];
        ADDR_ALL_PID_CFG2   :   all_pid_cfg[1]  <=  cbus_wdata[0];
        ADDR_ALL_PID_CFG3   :   all_pid_cfg[2]  <=  cbus_wdata[0];
        ADDR_ALL_PID_CFG4   :   all_pid_cfg[3]  <=  cbus_wdata[0];
        default:;
        endcase
    end
end
       
always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        cbus_rdata  <=  {CBUS_DATA_WIDTH{1'b0}};
    end
    else if((cbus_oe_3dly==1'b1) && (cbus_addr_3dly[11:9]=={3{1'b0}}))
    begin
        case(cbus_addr_3dly[1:0])
        2'b00   :   cbus_rdata  <=  {{3{1'b0}},pid_rd_out[17:13]};
        2'b01   :   cbus_rdata  <=  {{3{1'b0}},pid_rd_out[12:8]};
        2'b10   :   cbus_rdata  <=  pid_rd_out[7:0];
        2'b11   :   cbus_rdata  <=  {CBUS_DATA_WIDTH{1'b0}};
        default:;
        endcase
    end
end        
    
always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        pid_ram_waddr   <=  {PIDRAM_DEPTH_BIT{1'b0}};
    end
    else if((((cbus_we==1'b1) && (cbus_addr[1:0]==2'b11)) || (cbus_oe==1'b1)) && (cbus_addr[11:9]=={3{1'b0}}))
    begin
        pid_ram_waddr   <=  cbus_addr[8:2];
    end
end

////////////////////////////////////////////////////////////////////
//pid filter
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        word_cnt    <=  {3{1'b0}};
    end
    else if(ts_sop==1'b1)
    begin
        word_cnt    <=  3'b001;
    end
    else if(ts_eop==1'b1)
    begin
        word_cnt    <= {3{1'b0}};
    end
    else if((ts_valid==1'b1) && (word_cnt<4))
    begin
        word_cnt    <=  word_cnt + 'h1;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tuner_index <=  2'b00;
    end
    else if(ts_sop==1'b1)
    begin
        case(ts_data[7:0])
        8'h40   :   tuner_index <=  2'b00;
        8'h41   :   tuner_index <=  2'b01;
        8'h42   :   tuner_index <=  2'b10;
        8'h43   :   tuner_index <=  2'b11;
        default:;
        endcase
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_pid          <=  {13{1'b0}};
    end
    else if(ts_valid==1'b1)
    begin
        if(word_cnt==1)
        begin
            ts_pid[12:8]    <=  ts_data[4:0];
        end
        else if(word_cnt==2)
        begin
            ts_pid[7:0]     <=  ts_data[7:0];
        end
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        null_packet <=  1'b0;
    end
    else if((ts_valid==1'b1) && (word_cnt==3) && (ts_pid==13'h1fff))
    begin
        null_packet <=  1'b1;
    end
    else if(ts_eop==1'b1)
    begin
        null_packet <=  1'b0;
    end
end
    
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        st_curr <=  ST_IDLE;
    end
    else 
    begin
        st_curr <=  st_next;
    end
end

always@*
begin
    case(st_curr)
    ST_IDLE:
    begin
        if((ts_valid==1'b1) && (word_cnt==3))
        begin
            st_next =   ST_PID_SEARCH;
        end
        else
        begin
            st_next =   ST_IDLE;
        end
    end
    ST_PID_SEARCH:
    begin
        if((search_cnt<129) && (pid_match_type==2'b00))
        begin
            st_next =   ST_PID_SEARCH;
        end
        else
        begin
            st_next =   ST_SEARCH_END;
        end
    end
    ST_SEARCH_END:
    begin
        if(ts_eop==1'b1)
        begin
            st_next =   ST_IDLE;
        end
        else
        begin
            st_next =   ST_SEARCH_END;
        end
    default:
    begin
        st_next =   ST_IDLE;
    end
    endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        search_cnt  <=  {8{1'b0}};
    end
    else if(st_curr==ST_PID_SEARCH)
    begin
        search_cnt  <=  search_cnt + 'h1;
    end
    else
    begin
        search_cnt  <=  {8{1'b0}};
    end
end

assign  pid_ram_raddr   =   search_cnt[PIDRAM_DEPTH_BIT - 1 : 0];
assign  pid_index_buf   =   search_cnt - 8'h02;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        all_pid_cfg_1dly    <=  {4{1'b0}};
        all_pid_cfg_2dly    <=  {4{1'b0}}; 
    end
    else
    begin
        all_pid_cfg_1dly    <=  all_pid_cfg;
        all_pid_cfg_2dly    <=  all_pid_cfg_1dly;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        pid_match_index <=  {7{1'b0}};
        pid_match_type  <=  2'b00;      //not match
    end
    else if((st_curr==ST_PID_SEARCH) && (search_cnt>1) && (pid_match_type==2'b00))
    begin
        if(all_pid_cfg_2dly[tuner_index]==1'b0)  //not all pid filter
        begin
            if((tuner_index==ram_tuner_index) && (ts_pid==ram_pid) && (pid_filter_ena==1'b1))
            begin
                if(pid_descram_ena==1'b1)
                begin
                    pid_match_type  <=  2'b01;  //descramble
                end
                else
                begin
                    pid_match_type  <=  2'b10;  //not descramble;
                end
                pid_match_index <=  pid_index_buf[6:0];
            end
            else
            begin
                pid_match_type  <=  2'b00;
            end
        end
        else                                    //all pid filter
        begin
            if((tuner_index==ram_tuner_index) && (ts_pid==ram_pid) && (pid_filter_ena==1'b1) && (pid_descram_ena==1'b1))
            begin
                pid_match_type  <=  2'b01;
                pid_match_index <=  pid_index_buf[6:0];
            end
            else if((search_cnt==129) && (null_packet==1'b0))
            begin
                pid_match_type  <=  2'b10;
            end
        end
    end
    else if(st_curr==ST_IDLE)
    begin
        pid_match_type  <=  2'b00;
    end
end

assign  ram_pid         =   pid_ram_dout[12:0];
assign  pid_descram_ena =   pid_ram_dout[13];
assign  pid_filter_ena  =   pid_ram_dout[14];
assign  ram_tuner_index =   pid_ram_dout[16:15];

////////////////////////////////////////////////////////////////////
//fifo+ram write
////////////////////////////////////////////////////////////////////
assign  ram_wren    =   ts_valid;
assign  ram_din     =   ts_data;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ram_waddr   <=  {10{1'b0}};
    end
    else if(ts_valid==1'b1)
    begin
        ram_waddr   <=  ram_waddr + 'h1;
    end
end
        
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        fifo_wren   <=  1'b0;
    end
    else if((ts_eop==1'b1) && (|pid_match_type==1'b1))
    begin
        fifo_wren   <=  1'b1;
    end
    else
    begin
        fifo_wren   <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        pkt_start_addr  <=  {10{1'b0}};
    end
    else if(ts_sop==1'b1)
    begin
        pkt_start_addr  <=  ram_waddr;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        fifo_din    <=  {18{1'b0}};
    end
    else if((ts_eop==1'b1) && (|pid_match_type==1'b1))
    begin
        fifo_din    <=  {pid_match_type[0],pid_match_index[6:0],pkt_start_addr[9:0]};
    end
end

////////////////////////////////////////////////////////////////////
//fifo+ram read
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        fifo_rden   <=  1'b0;
    end
    else if(st_o_curr==ST_O_RD_FIFO)
    begin
        fifo_rden   <=  1'b1;
    end
    else
    begin
        fifo_rden   <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        fifo_rden_1dly  <=  1'b0;
        fifo_rden_2dly  <=  1'b0;
    end
    else
    begin
        fifo_rden_1dly  <=  fifo_rden;
        fifo_rden_2dly  <=  fifo_rden_1dly;
    end
end            

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        rd_cnt  <=  {8{1'b0}};
    end
    else if(st_o_curr==ST_O_RD_DATA)
    begin
        rd_cnt  <=  rd_cnt + 'h1;
    end
    else
    begin
        rd_cnt  <=  {8{1'b0}};
    end
end
                
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        st_o_curr   <=  ST_O_IDLE;
    end
    else
    begin
        st_o_curr   <=  st_o_next;
    end
end

always@*
begin
    case(st_o_curr)
    ST_O_IDLE:
    begin
        if(fifo_rd_cnt>0)
        begin
            st_o_next   =   ST_O_RD_FIFO;
        end
        else
        begin
            st_o_next   =   ST_O_IDLE;
        end
    end
    ST_O_RD_FIFO:
    begin
        st_o_next   =   ST_O_WAIT;
    end
    ST_O_WAIT:
    begin
        if(fifo_rden_2dly==1'b1)
        begin
            st_o_next   =   ST_O_RD_DATA;
        end
        else
        begin
            st_o_next   =   ST_O_WAIT;
        end
    end
    ST_O_RD_DATA:
    begin
        if(rd_cnt==PKT_LEN)
        begin
            st_o_next   =   ST_O_IDLE;
        end
        else
        begin
            st_o_next   =   ST_O_RD_DATA;
        end
    end
    default:
    begin
        st_o_next   =   ST_O_IDLE;
    end
    endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_o_index    <=  {8{1'b0}};
    end
    else if(fifo_rden_2dly==1'b1)
    begin
        ts_o_index    <=  fifo_dout[17:10];
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ram_raddr   <=  {10{1'b0}};
    end
    else if(fifo_rden_2dly==1'b1)
    begin
        ram_raddr   <=  fifo_dout[9:0];
    end
    else if(st_o_curr==ST_O_RD_DATA)
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
    else if((st_o_curr==ST_O_RD_DATA) && (rd_cnt>0))
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
    else if((st_o_curr==ST_O_RD_DATA) && (rd_cnt==1))
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
    else if((st_o_curr==ST_O_RD_DATA) && (rd_cnt==PKT_LEN))
    begin
        ts_o_eop    <=  1'b1;
    end
    else
    begin
        ts_o_eop    <=  1'b0;
    end
end

assign  descram_head    =   ((ts_o_sop==1'b1) && (fifo_dout[17]==1'b1)) ?   1'b1    :   1'b0;
assign  ts_o_data       =   ((descram_head==1'b1) && (ram_dout==8'h40)) ?   8'h48   :
                            ((descram_head==1'b1) && (ram_dout==8'h41)) ?   8'h49   :
                            ((descram_head==1'b1) && (ram_dout==8'h42)) ?   8'h4a   :
                            ((descram_head==1'b1) && (ram_dout==8'h43)) ?   8'h4b   :
                            ram_dout;

////////////////////////////////////////////////////////////////////        
//data format:{1'b0,tuner_index[1:0],pid_filter_enable,pid_descram_enable,filter_pid[12:0]}
////////////////////////////////////////////////////////////////////
//read latency=2        
asyncram_w18d128 u0_pid_filter_ram(
    .clka                               ( cbus_clk                  ),
    .wea                                ( pid_ram_wren              ),
    .addra                              ( pid_ram_waddr             ),
    .dina                               ( pid_ram_din               ),
    .douta                              ( pid_rd_out                ),
    .clkb                               ( clk                       ),
    .web                                ( 1'b0                      ),
    .addrb                              ( pid_ram_raddr             ),
    .dinb                               ( {18{1'b0}}                ),
    .doutb                              ( pid_ram_dout              )
    );

//read latency=2
syncram_w8d1024 pid_filter_dram(
    .clka                               ( clk                       ),
    .wea                                ( ram_wren                  ),
    .addra                              ( ram_waddr                 ),
    .dina                               ( ram_din                   ),
    .clkb                               ( clk                       ),
    .addrb                              ( ram_raddr                 ),
    .doutb                              ( ram_dout                  )
    );

//data format:{descram_enable,pid_index[6:0],pkt_start_addr[9:0]}
//read latency=2
syncfifo_w18d16 pid_filter_info_fifo(
    .wr_clk                             ( clk                       ),
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
