/*************************************************************************************\
    Copyright(c) 2015, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   Creative Center,R&D Hardware Department
    Filename     :   rt21_top.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2015-01-14  huangrui/1480       1.0         rt21       Create
    ==================================================================================
    Called by    :   rt21_top.v
    File tree    :   rt21_top.v                        
\************************************************************************************/

//`include    "../src/top/define.v"

`timescale 1ns/100ps

module rt21_top(
    rst_n                       ,
    clk_27m                     ,
    
    //tuner
    tuner_tsclk                 ,
    tuner_tsdata                ,
    tuner_tssync                ,
    tuner_tsvadlid              ,
    
    //spi
    spi_clk                     ,
    spi_mosi                    ,
    spi_miso                    ,
    spi_csn                     ,
    
    //Smart Card
    sc_data                     ,   
    sc_xtali                    ,
    sc_rstin                    ,
    sc_cmdvcc                   ,  
    sc_sel5v3v                  ,
    sc_off                      ,
    //sc_aux1_o                   ,
    //sc_card_sw                  ,
    //sc_led                      ,
    
    //cy68013 slave fifo
    clk_if                      ,
    sl_rd                       ,   //RDY0
    sl_wr                       ,   //RDY1
    sl_oe                       ,   //PA2
    sl_fifo_adr                 ,   //PA[5:4]
    sl_pkt_end                  ,   //PA6
    sl_data                     ,   //PB[7:0]
    sl_flag                     ,   //CTL[2:0],default low valid
    //sl_cs_n                     ,   //PA[7]
    
    //sy68013 GPIF
    gpif_ad                     ,   //PD[7:0]
    gpif_ctrl                   ,   //{PA[3],PA[1],PA[0]}:3'b111,reserved;
                                    //3'b110,address low;3'b101,address high;
                                    //3'b100,write;3'b000,read;

    //GPIO
    gpio_led               
    );

parameter   SIMULATION                  = "FALSE"                   ;
parameter   TOTAL_CHN_NUM               = 3                         ;
parameter   PBUS_ADDR_WIDTH             = 16                        ;
parameter   PBUS_DATA_WIDTH             = 8                         ;
parameter   CBUS_ADDR_WIDTH             = 12                        ;
parameter   CBUS_DATA_WIDTH             = 8                         ;

input                                   rst_n                       ;
input                                   clk_27m                     ;

//tuner
input   [TOTAL_CHN_NUM - 1 : 0]         tuner_tsclk                 ;
input   [TOTAL_CHN_NUM - 1 : 0]         tuner_tsdata                ;
input   [TOTAL_CHN_NUM - 1 : 0]         tuner_tssync                ;
input   [TOTAL_CHN_NUM - 1 : 0]         tuner_tsvadlid              ;

//spi
input                                   spi_clk                     ;
input                                   spi_mosi                    ;
output                                  spi_miso                    ;
input                                   spi_csn                     ;

//Smart Card
inout                                   sc_data                     ;
output                                  sc_xtali                    ;
output                                  sc_rstin                    ;
output                                  sc_cmdvcc                   ;
output                                  sc_sel5v3v                  ;
input                                   sc_off                      ;

//output                                  sc_aux1_o                   ;
//output                                  sc_card_sw                  ;
//output                                  sc_led                      ;
    
//cy68013 slave fifo
input                                   clk_if                      ;   //30MHz
output                                  sl_rd                       ;
output                                  sl_wr                       ;
output                                  sl_oe                       ;
output  [1:0]                           sl_fifo_adr                 ;
output                                  sl_pkt_end                  ;
inout   [7:0]                           sl_data                     ;
input   [2:0]                           sl_flag                     ;
//output                                  sl_cs_n                     ;

//cy68013 GPIF
inout   [7:0]                           gpif_ad                     ;
input   [2:0]                           gpif_ctrl                   ;

//GPIO
output                                  gpio_led                    ;

wire                                    sc_data                     ;
wire                                    sc_data_i                   ;
wire                                    sc_data_o                   ;

//cbus
wire    [PBUS_ADDR_WIDTH - 1 : 0]       bus_addr                    ;
wire    [PBUS_DATA_WIDTH - 1 : 0]       bus_wdata                   ;
wire                                    bus_we                      ;
wire                                    bus_oe                      ;
wire    [PBUS_DATA_WIDTH - 1 : 0]       bus_rdata                   ;

//cpu cbus
wire    [CBUS_ADDR_WIDTH - 1 : 0]       cpu_cbus_addr               ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       cpu_cbus_wdata              ;
wire                                    cpu_cbus_we                 ;
wire                                    cpu_cbus_oe                 ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       cpu_cbus_rdata              ;

//pid filter cbus
wire    [CBUS_ADDR_WIDTH - 1 : 0]       filter_cbus_addr            ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       filter_cbus_wdata           ;
wire                                    filter_cbus_we              ;
wire                                    filter_cbus_oe              ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       filter_cbus_rdata           ;

//descram cbus
wire    [CBUS_ADDR_WIDTH - 1 : 0]       descram_cbus_addr           ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       descram_cbus_wdata          ;
wire                                    descram_cbus_we             ;
wire                                    descram_cbus_oe             ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       descram_cbus_rdata          ;

//chacha cbus
wire    [CBUS_ADDR_WIDTH - 1 : 0]       chacha_cbus_addr            ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       chacha_cbus_wdata           ;
wire                                    chacha_cbus_we              ;
wire                                    chacha_cbus_oe              ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       chacha_cbus_rdata           ;

//ca message(to cy68013) cbus
wire    [CBUS_ADDR_WIDTH - 1 : 0]       camms_cbus_addr             ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       camms_cbus_wdata            ;
wire                                    camms_cbus_we               ;
wire                                    camms_cbus_oe               ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       camms_cbus_rdata            ;

//psi cbus
wire    [CBUS_ADDR_WIDTH - 1 : 0]       psi_cbus_addr               ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       psi_cbus_wdata              ;
wire                                    psi_cbus_we                 ;
wire                                    psi_cbus_oe                 ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       psi_cbus_rdata              ;

//tdes cbus
wire    [CBUS_ADDR_WIDTH - 1 : 0]       tdes_cbus_addr              ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       tdes_cbus_wdata             ;
wire                                    tdes_cbus_we                ;
wire                                    tdes_cbus_oe                ;
wire    [CBUS_DATA_WIDTH - 1 : 0]       tdes_cbus_rdata             ;

//clock and reset
wire                                    clk30m_bufg                 ;
wire                                    clk_ebi                     ;
wire                                    rst_ebi                     ;
wire                                    clk_ebi_3x                  ;
wire                                    rst_ebi_3x                  ;

//ts mux
wire                                    tsmux_valid                 ;
wire    [7:0]                           tsmux_data                  ;
wire                                    tsmux_sop                   ;
wire                                    tsmux_eop                   ;

//ts filter
wire    [7:0]                           filter_rdata                ;
wire    [8:0]                           filter_raddr                ;
wire                                    filter_eop                  ;
wire                                    filter_pid_find             ;
wire                                    filter_buffer_h             ;
wire    [11:0]                          filter_pid_index            ;

//ts descramble
wire                                    descram_valid               ;
wire    [7:0]                           descram_data                ;
wire                                    descram_sop                 ;
wire                                    descram_eop                 ;
wire    [11:0]                          descram_index               ;
wire                                    buf_bp                      ;

//tdes
wire                                    tdes_enable                 ;
wire                                    tdes_chacha_wren            ;
wire    [10:0]                          tdes_chacha_waddr           ;
wire    [7:0]                           tdes_chacha_wdata           ;
wire                                    tdes_descram_wren           ;
wire    [10:0]                          tdes_descram_waddr          ;
wire    [7:0]                           tdes_descram_wdata          ;

wire    [TOTAL_CHN_NUM - 1:0]           all_pid_cfg                 ;
wire                                    chacha_enable               ;
wire    [7:0]                           sl_data_buf                 ;

wire    [15:0]                          ebi_addr                    ;
wire    [7:0]                           ebi_wdata                   ;
wire    [7:0]                           ebi_rdata                   ;
wire                                    ebi_we                      ;
wire                                    ebi_oe                      ;
wire    [9:0]                           sc_addr                     ;
wire                                    sc_we                       ;
wire    [7:0]                           ebi_sc_rdata                ;

wire                                    chacha_pkt_valid            ;
wire    [7:0]                           chacha_pkt_data             ;
wire                                    chacha_pkt_eop              ;
wire                                    chacha_pkt_rdy              ;
wire                                    chacha_pkt_ack              ;

wire                                    camms_pkt_valid             ;
wire    [7:0]                           camms_pkt_data              ;
wire                                    camms_pkt_eop               ;
wire                                    camms_pkt_rdy               ;
wire                                    camms_pkt_ack               ;

wire    [TOTAL_CHN_NUM - 1 : 0]         tuner_tsclk_bufg            ;

assign  sc_data_i   =   sc_data;
assign  sc_data     =   (sc_data_o==1'b0)   ?   sc_data_o   :   1'bz;
//assign  sl_cs_n     =   1'b0;
assign  sl_oe       =   1'b1;
assign  sl_rd       =   1'b1;
assign  sl_data     =   (sl_wr==1'b0)    ?   sl_data_buf    :   8'hzz;

IBUFG u0_clk30m_bufg(
    .O                                  ( clk30m_bufg               ),
    .I                                  ( clk_if                    )
    );
    
//clock and reset
clk_rst #(
    .SIMULATION                         ( SIMULATION                )
    )
u0_clk_rst(
    .rstn_in                            ( rst_n                     ),
    .clk_if                             ( clk30m_bufg               ),
    
    .rst_out                            ( rst_ebi                   ),
    .rst_ebi_3x                         ( rst_ebi_3x                ),
    .clk_ebi                            ( clk_ebi                   ),  //30MHz
    .clk_ebi_3x                         ( clk_ebi_3x                )   //120MHz
    );

//spi interface
spi_if u0_spi_if(
    .clk                                ( clk_ebi                   ),
    .rst                                ( rst_ebi                   ),
    
    .ss_i                               ( spi_csn                   ),
    .sclk_i                             ( spi_clk                   ),
    .mosi_i                             ( spi_mosi                  ),
    .miso_o                             ( spi_miso                  ),
    
    .bus_rdata                          ( bus_rdata                 ),
    .bus_we                             ( bus_we                    ),
    .bus_oe                             ( bus_oe                    ),
    .bus_wdata                          ( bus_wdata                 ),
    .bus_addr                           ( bus_addr                  )
    );

//cbus demux
cbus_demux #(
    .PBUS_ADDR_WIDTH                    ( PBUS_ADDR_WIDTH           ),
    .PBUS_DATA_WIDTH                    ( PBUS_DATA_WIDTH           ),
    .CBUS_ADDR_WIDTH                    ( CBUS_ADDR_WIDTH           ),
    .CBUS_DATA_WIDTH                    ( CBUS_DATA_WIDTH           )
    )
u0_cbus_demux(
    .clk                                ( clk_ebi                   ),
    .rst                                ( rst_ebi                   ),
    .cbus_addr                          ( bus_addr                  ),
    .cbus_wdata                         ( bus_wdata                 ),
    .cbus_rdata                         ( bus_rdata                 ),
    .cbus_oe                            ( bus_oe                    ),
    .cbus_we                            ( bus_we                    ),
                                                            
    .cpu_cbus_rdata                     ( cpu_cbus_rdata            ),
    .cpu_cbus_addr                      ( cpu_cbus_addr             ),
    .cpu_cbus_wdata                     ( cpu_cbus_wdata            ),
    .cpu_cbus_oe                        ( cpu_cbus_oe               ),
    .cpu_cbus_we                        ( cpu_cbus_we               ),
                                                                    
    .filter_cbus_rdata                  ( filter_cbus_rdata         ),
    .filter_cbus_addr                   ( filter_cbus_addr          ),
    .filter_cbus_wdata                  ( filter_cbus_wdata         ),
    .filter_cbus_oe                     ( filter_cbus_oe            ),
    .filter_cbus_we                     ( filter_cbus_we            ),
                                                                    
    .descram_cbus_rdata                 ( descram_cbus_rdata        ),
    .descram_cbus_addr                  ( descram_cbus_addr         ),
    .descram_cbus_wdata                 ( descram_cbus_wdata        ),
    .descram_cbus_oe                    ( descram_cbus_oe           ),
    .descram_cbus_we                    ( descram_cbus_we           ),
                                                                    
    .chacha_cbus_rdata                  ( chacha_cbus_rdata         ),
    .chacha_cbus_addr                   ( chacha_cbus_addr          ),
    .chacha_cbus_wdata                  ( chacha_cbus_wdata         ),
    .chacha_cbus_oe                     ( chacha_cbus_oe            ),
    .chacha_cbus_we                     ( chacha_cbus_we            ),
                                                                    
    .camms_cbus_rdata                   ( camms_cbus_rdata          ),
    .camms_cbus_addr                    ( camms_cbus_addr           ),
    .camms_cbus_wdata                   ( camms_cbus_wdata          ),
    .camms_cbus_oe                      ( camms_cbus_oe             ),
    .camms_cbus_we                      ( camms_cbus_we             ),
                                                                    
    .psi_cbus_rdata                     ( psi_cbus_rdata            ),
    .psi_cbus_addr                      ( psi_cbus_addr             ),
    .psi_cbus_wdata                     ( psi_cbus_wdata            ),
    .psi_cbus_oe                        ( psi_cbus_oe               ),
    .psi_cbus_we                        ( psi_cbus_we               ),
                                                                    
    .tdes_cbus_rdata                    ( tdes_cbus_rdata           ),
    .tdes_cbus_addr                     ( tdes_cbus_addr            ),
    .tdes_cbus_wdata                    ( tdes_cbus_wdata           ),
    .tdes_cbus_oe                       ( tdes_cbus_oe              ),
    .tdes_cbus_we                       ( tdes_cbus_we              )
    );   
  
cpu_if #(
    .CBUS_ADDR_WIDTH                    ( CBUS_ADDR_WIDTH           ),
    .CBUS_DATA_WIDTH                    ( CBUS_DATA_WIDTH           ),
    .TOTAL_CHN_NUM                      ( TOTAL_CHN_NUM             )
    )
u0_cpu_if(
    .clk                                ( clk_ebi                   ),
    .rst                                ( rst_ebi                   ),
    .cbus_addr                          ( cpu_cbus_addr             ),
    .cbus_wdata                         ( cpu_cbus_wdata            ),
    .cbus_we                            ( cpu_cbus_we               ),
    .cbus_oe                            ( cpu_cbus_oe               ),
    .cbus_rdata                         ( cpu_cbus_rdata            ),   
    .all_pid_cfg                        ( all_pid_cfg               ),
    .test_mode                          ( /*not used*/              ),
    .chacha_enable                      ( chacha_enable             )
    );
    
////////////////////////////////////////////////////////////////////
//ts_mux
////////////////////////////////////////////////////////////////////
generate
    genvar  i;
    for(i=0;i<TOTAL_CHN_NUM;i=i+1)
    begin:TS_CLK_GEN
        IBUFG u0_tuner_bufg(
            .O                          ( tuner_tsclk_bufg[i]       ),
            .I                          ( tuner_tsclk[i]            )
            );   
    end
endgenerate

ts_mux #(
    .TOTAL_CHN_NUM                      ( TOTAL_CHN_NUM             )
    )
u0_ts_mux(
    .tuner_clk                          ( tuner_tsclk_bufg          ),
    .tuner_data                         ( tuner_tsdata              ),
    .tuner_sync                         ( tuner_tssync              ),
    .tuner_valid                        ( tuner_tsvadlid            ),
    
    .clk                                ( clk_ebi_3x                ),
    .rst                                ( rst_ebi_3x                ),
    .tsmux_valid                        ( tsmux_valid               ), 
    .tsmux_data                         ( tsmux_data                ),
    .tsmux_sop                          ( tsmux_sop                 ),
    .tsmux_eop                          ( tsmux_eop                 )
    );

ts_filter #(
    .CBUS_ADDR_WIDTH                    ( CBUS_ADDR_WIDTH           ),
    .CBUS_DATA_WIDTH                    ( CBUS_DATA_WIDTH           ),
    .TOTAL_CHN_NUM                      ( TOTAL_CHN_NUM             )
    )
u0_ts_filter(
    .clk                                ( clk_ebi_3x                ),
    .rst                                ( rst_ebi_3x                ),
    .ts_valid                           ( tsmux_valid               ),
    .ts_data                            ( tsmux_data                ),
    .ts_sop                             ( tsmux_sop                 ),
    .ts_eop                             ( tsmux_eop                 ),
    
    .filter_rdata                       ( filter_rdata              ),
    .filter_raddr                       ( filter_raddr              ),
    .filter_eop                         ( filter_eop                ),
    .filter_pid_find                    ( filter_pid_find           ),
    .filter_buffer_h                    ( filter_buffer_h           ),
    .filter_pid_index                   ( filter_pid_index          ),
    .all_pid_cfg                        ( all_pid_cfg               ),
    
    .cbus_clk                           ( clk_ebi                   ),
    .cbus_rst                           ( rst_ebi                   ),
    .cbus_addr                          ( filter_cbus_addr          ),
    .cbus_wdata                         ( filter_cbus_wdata         ),
    .cbus_we                            ( filter_cbus_we            ),
    .cbus_oe                            ( filter_cbus_oe            ),
    .cbus_rdata                         ( filter_cbus_rdata         )
    );

ts_descramble #(
    .CBUS_ADDR_WIDTH                    ( CBUS_ADDR_WIDTH           ),
    .CBUS_DATA_WIDTH                    ( CBUS_DATA_WIDTH           )
    )
u0_ts_descramble(
    .clk                                ( clk_ebi_3x                ),
    .rst                                ( rst_ebi_3x                ),
    .ts_raddr                           ( filter_raddr              ),
    .ts_rdata                           ( filter_rdata              ),
    .ts_eop                             ( filter_eop                ),
    .ts_pid_find                        ( filter_pid_find           ),
    .ts_pid_index                       ( filter_pid_index          ),
    .ts_buffer_h                        ( filter_buffer_h           ),
    
    .tdes_enable                        ( tdes_enable               ),
    .tdes_descram_wren                  ( tdes_descram_wren         ),
    .tdes_descram_waddr                 ( tdes_descram_waddr        ),
    .tdes_descram_wdata                 ( tdes_descram_wdata        ),
    
    .ts_o_valid                         ( descram_valid             ),
    .ts_o_data                          ( descram_data              ),
    .ts_o_sop                           ( descram_sop               ),
    .ts_o_eop                           ( descram_eop               ),
    .ts_o_index                         ( descram_index             ),
    .buf_bp                             ( buf_bp                    ),
    
    .cbus_clk                           ( clk_ebi                   ),
    .cbus_rst                           ( rst_ebi                   ),
    .cbus_addr                          ( descram_cbus_addr         ),
    .cbus_wdata                         ( descram_cbus_wdata        ),
    .cbus_we                            ( descram_cbus_we           ),
    .cbus_oe                            ( descram_cbus_oe           ),
    .cbus_rdata                         ( descram_cbus_rdata        )
    );
   
encrypt_pro #(
    .CBUS_ADDR_WIDTH                    ( CBUS_ADDR_WIDTH           ),
    .CBUS_DATA_WIDTH                    ( CBUS_DATA_WIDTH           )
    )
u0_encrypt_pro(
    .clk                                ( clk_ebi                   ),
    .rst                                ( rst_ebi                   ),
    .ts_i_valid                         ( descram_valid             ),
    .ts_i_data                          ( descram_data              ),
    .ts_i_sop                           ( descram_sop               ),
    .ts_i_eop                           ( descram_eop               ),
    .ts_i_index                         ( descram_index             ),
    .buf_bp                             ( buf_bp                    ),
    .chacha_enable                      ( chacha_enable             ),
    
    .ts_valid                           ( chacha_pkt_valid          ),
    .ts_data                            ( chacha_pkt_data           ),
    .ts_eop                             ( chacha_pkt_eop            ),
    .ts_rdy                             ( chacha_pkt_rdy            ),
    .ts_ack                             ( chacha_pkt_ack            ),
    
    .tdes_enable                        ( tdes_enable               ),
    .tdes_chacha_wren                   ( tdes_chacha_wren          ),
    .tdes_chacha_waddr                  ( tdes_chacha_waddr         ),
    .tdes_chacha_wdata                  ( tdes_chacha_wdata         ),
    
    .cbus_addr                          ( chacha_cbus_addr          ),
    .cbus_wdata                         ( chacha_cbus_wdata         ),
    .cbus_we                            ( chacha_cbus_we            ),
    .cbus_oe                            ( chacha_cbus_oe            ),
    .cbus_rdata                         ( chacha_cbus_rdata         )
    );

ca_message_rx #(
    .CBUS_ADDR_WIDTH                    ( CBUS_ADDR_WIDTH           ),
    .CBUS_DATA_WIDTH                    ( CBUS_DATA_WIDTH           )
    )
u0_ca_message_pro(
    .clk                                ( clk_ebi                   ),
    .rst                                ( rst_ebi                   ),
    
    .ts_valid                           ( camms_pkt_valid           ),
    .ts_data                            ( camms_pkt_data            ),
    .ts_eop                             ( camms_pkt_eop             ),
    .ts_rdy                             ( camms_pkt_rdy             ),
    .ts_ack                             ( camms_pkt_ack             ),
    
    .cbus_addr                          ( camms_cbus_addr           ),
    .cbus_wdata                         ( camms_cbus_wdata          ),
    .cbus_we                            ( camms_cbus_we             ),
    .cbus_oe                            ( camms_cbus_oe             ),
    .cbus_rdata                         ( camms_cbus_rdata          )
    );

pktmux_slfifo u0_pktmux_slfifo(
    .clk                                ( clk_ebi                   ),
    .rst                                ( rst_ebi                   ),
    
    .tsa_valid                          ( chacha_pkt_valid          ),
    .tsa_data                           ( chacha_pkt_data           ),
    .tsa_eop                            ( chacha_pkt_eop            ),
    .tsa_rdy                            ( chacha_pkt_rdy            ),
    .tsa_ack                            ( chacha_pkt_ack            ),
    
    .tsb_valid                          ( camms_pkt_valid           ),
    .tsb_data                           ( camms_pkt_data            ),
    .tsb_eop                            ( camms_pkt_eop             ),
    .tsb_rdy                            ( camms_pkt_rdy             ),
    .tsb_ack                            ( camms_pkt_ack             ),
    
    .sl_wr                              ( sl_wr                     ),
    .sl_data                            ( sl_data_buf               ),
    .sl_bp                              ( sl_flag[1]                ),
    .sl_fifo_adr                        ( sl_fifo_adr               ),
    .sl_pkt_end                         ( sl_pkt_end                )
    );
    
security_module #(
    .CBUS_ADDR_WIDTH                    ( CBUS_ADDR_WIDTH           ),
    .CBUS_DATA_WIDTH                    ( CBUS_DATA_WIDTH           )
    ) 
u0_security_module(
    .clk                                ( clk_ebi                   ),
    .rst                                ( rst_ebi                   ),
    .tdes_enable                        ( tdes_enable               ),
    .tdes_chacha_wren                   ( tdes_chacha_wren          ),
    .tdes_chacha_waddr                  ( tdes_chacha_waddr         ),
    .tdes_chacha_wdata                  ( tdes_chacha_wdata         ),
    .tdes_descram_wren                  ( tdes_descram_wren         ),
    .tdes_descram_waddr                 ( tdes_descram_waddr        ),
    .tdes_descram_wdata                 ( tdes_descram_wdata        ),
    
    .cbus_addr                          ( tdes_cbus_addr            ),
    .cbus_wdata                         ( tdes_cbus_wdata           ),
    .cbus_we                            ( tdes_cbus_we              ),
    .cbus_oe                            ( tdes_cbus_oe              ),
    .cbus_rdata                         ( tdes_cbus_rdata           )
    );

//ebi pro
ebi_if u0_ebi_if(
    .clk                                ( clk_ebi                   ),
    .rst                                ( rst_ebi                   ),
    .lbus_ad                            ( gpif_ad                   ),
    .lbus_ctrl                          ( gpif_ctrl                 ),
    
    .ebi_addr                           ( ebi_addr                  ),
    .ebi_wdata                          ( ebi_wdata                 ),
    .ebi_rdata                          ( ebi_rdata                 ),
    .ebi_we                             ( ebi_we                    ),
    .ebi_oe                             ( ebi_oe                    )
    );

assign  sc_addr =   (ebi_addr[15:12]==4'b0111)  ?   ebi_addr[9:0]   :   {10{1'b0}};
assign  sc_we   =   ((ebi_addr[15:9]==7'b011_1010) || (ebi_addr[15:8]==7'b0111_0110))   ?   ebi_we  :   1'b0;

sc_interface u0_sc_interface(
    .reset                              ( rst_ebi                   ),
    .PCI_CLK                            ( clk_ebi                   ),
    .SC_SCK                             ( sc_xtali                  ),
    .HOST_ADD                           ( sc_addr                   ),
    .HOST_WE                            ( sc_we                     ),
    .HOST_RD                            ( 1'b1                      ),
    .CS                                 ( 1'b1                      ),
    .WDATA_IN                           ( ebi_wdata                 ),
    .WDATA_OUT                          ( ebi_sc_rdata              ),
    .SC_DATA_I                          ( sc_data_i                 ),
    .SC_DATA_O                          ( sc_data_o                 ),
    .SC_RST_O                           ( sc_rstin                  ),
    .SC_SW                              ( sc_off                    ),
    .SC_ON                              ( sc_cmdvcc                 ),
    .SC_SEL35                           ( sc_sel5v3v                ),
    .SC_INTP                            ( /*not used*/              )
    );

assign  ebi_rdata   =   (ebi_addr[15:12]==4'h7) ?   ebi_sc_rdata    :   {8{1'b0}};

//LED
reg     [23:0]                          led_cnt                     ;
always@(posedge clk_ebi or posedge rst_ebi)
begin
    if(rst_ebi==1'b1)
    begin
        led_cnt <=  {24{1'b0}};
    end
    else
    begin
        led_cnt <=  led_cnt + 'h1;
    end
end

assign  gpio_led    =   led_cnt[23];       
      
endmodule
