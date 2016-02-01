/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   Creative Center,R&D Hardware Department
    Filename     :   ts_descramble.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :   descram head of tuner_index=0: 8'h48;
                     descram head of tuner_index=1: 8'h49;
                     descram head of tuner_index=2: 8'h4a;
                     descram head of tuner_index=3: 8'h4b;
                     cbus read latency=4;
                     ts_pid_index[11]:chacha bypass enable;
                     ts_pid_index[10:8]:chacha bypass search index;
                     ts_pid_index[7]:descramble enable bit;
                     ts_pid_index[6:0]:pid_match_index;
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-12-29  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :   ts_descramble.v
    File tree    :   ts_descramble.v
\************************************************************************************/

`timescale 1ns/100ps

module ts_descramble(
    clk                         ,
    rst                         ,
    ts_raddr                    ,
    ts_rdata                    ,
    ts_eop                      ,
    ts_pid_find                 ,
    ts_pid_index                ,
    ts_buffer_h                 ,
    
    tdes_enable                 ,
    tdes_descram_wren           ,
    tdes_descram_waddr          ,
    tdes_descram_wdata          ,
                                
    ts_o_valid                  ,
    ts_o_data                   ,
    ts_o_sop                    ,
    ts_o_eop                    ,
    ts_o_index                  ,
    buf_bp                      ,
                                
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

input                                   clk                         ;
input                                   rst                         ;
output  [8:0]                           ts_raddr                    ;
input   [7:0]                           ts_rdata                    ;
input                                   ts_eop                      ;
input                                   ts_pid_find                 ;
input   [11:0]                          ts_pid_index                ;
input                                   ts_buffer_h                 ;

input                                   tdes_enable                 ;
input                                   tdes_descram_wren           ;
input   [10:0]                          tdes_descram_waddr          ;
input   [7:0]                           tdes_descram_wdata          ;

output                                  ts_o_valid                  ;
output  [7:0]                           ts_o_data                   ;
output                                  ts_o_sop                    ;
output                                  ts_o_eop                    ;
output  [11:0]                          ts_o_index                  ;
input                                   buf_bp                      ;

input                                   cbus_clk                    ;
input                                   cbus_rst                    ;
input   [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr                   ;
input   [CBUS_DATA_WIDTH - 1 : 0]       cbus_wdata                  ;
input                                   cbus_we                     ;
input                                   cbus_oe                     ;
output  [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;

wire                                    rstn                        ;
wire    [0:7]                           ck_data                     ;
wire    [0:7]                           sb_data                     ;
wire    [0:7]                           p_data                      ;
wire    [0:7]                           db_data                     ;
wire                                    db_data_valid               ;
wire    [0:2]                           ldkey_cnt                   ;
wire                                    descram_st                  ;
wire                                    sreg_kv                     ;
wire                                    sreg_kv1                    ;
wire                                    sreg_kv2                    ;
wire                                    sreg_kv3                    ;

wire    [7:0]                           dram_wdata                  ;
wire    [8:0]                           dram_waddr                  ;
wire                                    dram_wren                   ;
wire    [8:0]                           dram_raddr                  ;
wire    [7:0]                           dram_rdata                  ;
wire                                    dram_rden                   ;

reg                                     cw_ram_wren                 ;
reg     [10:0]                          cw_ram_waddr                ;
reg     [7:0]                           cw_ram_din                  ;
wire    [10:0]                          cw_ram_raddr                ;
wire    [7:0]                           cw_ram_dout                 ;
wire    [7:0]                           cw_rd_out                   ;

//???? 
wire    [11:0]                          descram_index               ;     
wire                                    descram_buffer_h            ;    
wire                                    descram_eop                 ; 
wire                                    descram_pid_fd              ;    
wire                                    descram_st_idle             ; 
wire    [1:0]                           end_point_sel               ; 
wire                                    ts_o_val_n                  ;
wire                                    test_mrxdv                  ;

reg     [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;
reg                                     cbus_oe_1dly                ;
reg                                     cbus_oe_2dly                ;
reg                                     cbus_oe_3dly                ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_1dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_2dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_3dly              ;

assign  rstn        =   ~rst;
assign  ts_o_valid  =   ~ts_o_val_n;

always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        cw_ram_wren <=  1'b0;
        cw_ram_din  <=  {8{1'b0}};
    end
    else if(tdes_enable==1'b1)
    begin
        cw_ram_wren <=  tdes_descram_wren;
        cw_ram_din  <=  tdes_descram_wdata;
    end
    else if((cbus_we==1'b1) && (cbus_addr[11]==1'b0))
    begin
        cw_ram_wren <=  1'b1;
        cw_ram_din  <=  cbus_wdata;
    end
    else
    begin
        cw_ram_wren <=  1'b0;
        cw_ram_din  <=  {8{1'b0}};
    end
end

always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        cw_ram_waddr    <=  {11{1'b0}};
    end
    else if((tdes_enable==1'b1) && (tdes_descram_wren==1'b1))
    begin
        cw_ram_waddr    <=  tdes_descram_waddr;
    end
    else if((cbus_addr[11]==1'b0) && ((cbus_we==1'b1) || (cbus_oe==1'b1)))
    begin
        cw_ram_waddr    <=  cbus_addr[10:0];
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
        
always@(posedge cbus_clk or posedge cbus_rst)
begin
    if(cbus_rst==1'b1)
    begin
        cbus_rdata  <=  {CBUS_DATA_WIDTH{1'b0}};
    end
    else if((cbus_oe_3dly==1'b1) && (cbus_addr_3dly[11]==1'b0))
    begin
        cbus_rdata  <=  cw_rd_out;
    end
end        
            
dsc3 u0_dsc3(
    .ck                                 ( ck_data                   ),
    .sb                                 ( sb_data                   ),
    .p                                  ( p_data                    ),
    .db                                 ( db_data                   ),
    .ldkey_cnt                          ( ldkey_cnt                 ),
    .clk                                ( clk                       ),
    .nrst                               ( rstn                      ),
    .st                                 ( descram_st                ),
    .db_valid                           ( db_data_valid             ),
    .sreg_kv                            ( sreg_kv                   ),
    .sreg_kv1                           ( sreg_kv1                  ),
    .sreg_kv2                           ( sreg_kv2                  ),
    .sreg_kv3                           ( sreg_kv3                  )
    );

descramble_ctl u0_descramble_ctl(
    .reset                              ( rstn                      ),
    .ck                                 ( ck_data                   ),
    .sb                                 ( sb_data                   ),
    .db_in                              ( dram_wdata                ),
    .db                                 ( db_data                   ),
    .cw_readadd                         ( cw_ram_raddr              ),
    .cw_out                             ( cw_ram_dout               ),
    .db_wadd                            ( dram_waddr                ),
    .ldkey_cnt                          ( ldkey_cnt                 ),
    .p                                  ( p_data                    ),
    .pid_i                              ( ts_pid_index              ),
    .r_add                              ( ts_raddr                  ),
    .r_data                             ( ts_rdata                  ),
    .lpid_i                             ( descram_index             ),
    .nrst                               ( /*not used*/              ),
    .st                                 ( descram_st                ),
    .db_valid                           ( db_data_valid             ),
    .pci_clk                            ( cbus_clk                  ),
    .buffer_h                           ( ts_buffer_h               ),
    .db_wea                             ( dram_wren                 ),
    .end_p                              ( ts_eop                    ),
    .pci_clk2                           ( clk                       ),
    .pid_fd                             ( ts_pid_find               ),
    .sreg_kv                            ( sreg_kv                   ),
    .sreg_kv2                           ( sreg_kv1                  ),
    .sreg_kv3                           ( sreg_kv3                  ),
    .lbuffer_h                          ( descram_buffer_h          ),
    .lend_p                             ( descram_eop               ),
    .lpid_fd                            ( descram_pid_fd            ),
    .t_stidle                           ( descram_st_idle           )
    );

//porta read latency=2;portb read latency=1;true dual port ram        
tdpram_w8d2048 u0_cw_ram(
    .clka                               ( cbus_clk                  ),
    .wea                                ( cw_ram_wren               ),
    .addra                              ( cw_ram_waddr              ),
    .dina                               ( cw_ram_din                ),
    .douta                              ( cw_rd_out                 ),
    .clkb                               ( clk                       ),
    .web                                ( 1'b0                      ),
    .addrb                              ( cw_ram_raddr              ),
    .dinb                               ( {8{1'b0}}                 ),
    .doutb                              ( cw_ram_dout               )
    );
	
//read latency=1
sdpram_w8d512 u0_descram_dram(
    .clka                               ( clk                       ),
    .wea                                ( dram_wren                 ),
    .addra                              ( dram_waddr                ),
    .dina                               ( dram_wdata                ),
    .clkb                               ( cbus_clk                  ),  //( clk                       ),
    .enb                                ( dram_rden                 ),
    .addrb                              ( dram_raddr                ),
    .doutb                              ( dram_rdata                )
    ); 

sfifo_if_3Tuner u0_sfifo_if_3Tuner(
    .clk                                ( cbus_clk                  ),  //( clk                       ), 
    .rst                                ( rstn                      ),
    .flaga                              ( 1'b1                      ),
    .flagb                              ( buf_bp                    ),
    .fadd                               ( end_point_sel             ),
    .data_out                           ( ts_o_data                 ),
    .sloe                               ( /*not used*/              ),
    .slrd                               ( /*not used*/              ),
    .slwr                               ( ts_o_val_n                ),
    .pktend_o                           ( ts_o_eop                  ),
    .pktstart_o                         ( ts_o_sop                  ),
    .pid_idx                            ( ts_o_index                ),
    .lend_p1                            ( descram_eop               ),
    .lpid_fd1                           ( descram_pid_fd            ),
    .lbuffer_h1                         ( descram_buffer_h          ),
    .lpid_i1                            ( descram_index             ),
    .db_radd_en                         ( dram_rden                 ),
    .db_radd                            ( dram_raddr                ),
    .db_out1                            ( dram_rdata                ),
    .mrxdv                              ( test_mrxdv                )
    );

endmodule   
