/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   Creative Center,R&D Hardware Department
    Filename     :   ts_filter.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :   filter_pid_index[7]:descramble enable;
                     filter_pid_index[6:0]:pid_index;
                     cbus read latency = 4;
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
                                
    filter_rdata                ,
    filter_raddr                ,
    filter_eop                  ,
    filter_pid_find             ,
    filter_buffer_h             ,
    filter_pid_index            ,
    all_pid_cfg                 ,
                                
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
parameter   TOTAL_CHN_NUM               = 3                         ;

parameter   PIDRAM_DEPTH_BIT            = 7                         ;
parameter   PIDRAM_DATA_WIDTH           = 21                        ;

input                                   clk                         ;
input                                   rst                         ;
input                                   ts_valid                    ;
input   [7:0]                           ts_data                     ;
input                                   ts_sop                      ;
input                                   ts_eop                      ;

output  [7:0]                           filter_rdata                ;
input   [8:0]                           filter_raddr                ;
output                                  filter_eop                  ;
output                                  filter_pid_find             ;
output                                  filter_buffer_h             ;
output  [11:0]                          filter_pid_index            ;
input   [TOTAL_CHN_NUM - 1 : 0]         all_pid_cfg                 ;

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
reg     [TOTAL_CHN_NUM - 1 : 0]         all_pid_cfg_1dly            ;
reg     [TOTAL_CHN_NUM - 1 : 0]         all_pid_cfg_2dly            ;
wire    [PIDRAM_DATA_WIDTH - 1 : 0]     pid_rd_out                  ;

reg                                     pid_ram_wren                ;
reg     [PIDRAM_DATA_WIDTH - 1 : 0]     pid_ram_din                 ;
reg     [PIDRAM_DEPTH_BIT - 1 : 0]      pid_ram_waddr               ;
wire    [PIDRAM_DEPTH_BIT - 1 : 0]      pid_ram_raddr               ;
wire    [PIDRAM_DATA_WIDTH - 1 : 0]     pid_ram_dout                ;

wire    [8:0]                           dram_waddr                  ;
wire                                    filter_buffer_h             ;

assign  filter_buffer_h =   dram_waddr[8];

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
    else if((cbus_we==1'b1) && (cbus_addr[11:9]==3'b000))
    begin
        case(cbus_addr[1:0])
        2'b00   :   pid_ram_din[PIDRAM_DATA_WIDTH-1:13] <=  cbus_wdata[7:0];
        2'b01   :   pid_ram_din[12:8]                   <=  cbus_wdata[4:0];
        2'b10   :   pid_ram_din[7:0]                    <=  cbus_wdata[7:0];
        default :;
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
        2'b00   :   cbus_rdata  <=  pid_rd_out[PIDRAM_DATA_WIDTH - 1:13];
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

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        all_pid_cfg_1dly    <=  {TOTAL_CHN_NUM{1'b0}};
        all_pid_cfg_2dly    <=  {TOTAL_CHN_NUM{1'b0}}; 
    end
    else
    begin
        all_pid_cfg_1dly    <=  all_pid_cfg;
        all_pid_cfg_2dly    <=  all_pid_cfg_1dly;
    end
end

////////////////////////////////////////////////////////////////////        
//data format:{chacha_except_index[2:0],tuner_index[1:0],pid_filter_enable,pid_descram_enable,filter_pid[12:0]}
////////////////////////////////////////////////////////////////////
//read latency=2,true dual port ram        
asyncram_w21d128 u0_pid_lut_ram(
    .clka                               ( cbus_clk                  ),
    .wea                                ( pid_ram_wren              ),
    .addra                              ( pid_ram_waddr             ),
    .dina                               ( pid_ram_din               ),
    .douta                              ( pid_rd_out                ),
    .clkb                               ( clk                       ),
    .web                                ( 1'b0                      ),
    .addrb                              ( pid_ram_raddr             ),
    .dinb                               ( {PIDRAM_DATA_WIDTH{1'b0}} ),
    .doutb                              ( pid_ram_dout              )
    );

//read latency=1
sdpram_w8d512 u0_pid_filter_dram(
    .clka                               ( clk                       ),
    .wea                                ( ts_valid                  ),
    .addra                              ( dram_waddr                ),
    .dina                               ( ts_data                   ),
    .clkb                               ( clk                       ),
    .enb                                ( 1'b1                      ),
    .addrb                              ( filter_raddr              ),
    .doutb                              ( filter_rdata              )
    );
    
filter_ctrl #(
    .PIDRAM_DEPTH_BIT                   ( PIDRAM_DEPTH_BIT          ),
    .PIDRAM_DATA_WIDTH                  ( PIDRAM_DATA_WIDTH         ),
    .TOTAL_CHN_NUM                      ( TOTAL_CHN_NUM             )
    )
u0_filter_ctrl(
    .clk                                ( clk                       ),
    .rst                                ( rst                       ),
    .ts_data                            ( ts_data                   ),
    .ts_valid                           ( ts_valid                  ),
    .ts_sop                             ( ts_sop                    ),
    .ts_eop                             ( ts_eop                    ),
    .all_pid_cfg                        ( all_pid_cfg_2dly          ),
    .pid_find                           ( filter_pid_find           ),
    .pid_index                          ( filter_pid_index          ),
    .filter_eop                         ( filter_eop                ),
    .pid_raddr                          ( pid_ram_raddr             ),
    .pid_rdata                          ( pid_ram_dout              ), 
    .dram_waddr                         ( dram_waddr                )
    );
	    
endmodule   
