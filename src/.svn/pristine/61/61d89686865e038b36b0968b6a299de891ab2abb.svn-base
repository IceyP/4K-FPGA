/*************************************************************************************\
    Copyright(c) 2015, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  encrypt_cfg.v
    Author       :  huangrui/1480
    ==================================================================================
    Description  :  
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2015-01-08  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :  encrypt_cfg.v
    File tree    :  encrypt_cfg.v                        
\************************************************************************************/

`timescale 1ns/100ps

module encrypt_cfg(
    clk                         ,    
    rst                         ,
    chacha_bypass_ram_raddr     ,
    chacha_bypass_data          ,
    chacha_bypass_mask          ,
    chacha_cwram_raddr          ,
    chacha_cwram_rdata          ,
    
    tdes_enable                 ,
    tdes_chacha_wren            ,
    tdes_chacha_waddr           ,
    tdes_chacha_wdata           ,

    cbus_addr                   ,
    cbus_we                     ,
    cbus_oe                     ,
    cbus_wdata                  ,
    cbus_rdata                           
    );

parameter   CBUS_ADDR_WIDTH             = 12                        ;
parameter   CBUS_DATA_WIDTH             = 8                         ;

input                                   clk                         ;
input                                   rst                         ;
input   [6:0]                           chacha_bypass_ram_raddr     ;
output  [7:0]                           chacha_bypass_data          ;
output  [7:0]                           chacha_bypass_mask          ;
input   [10:0]                          chacha_cwram_raddr          ;
output  [7:0]                           chacha_cwram_rdata          ;

input                                   tdes_enable                 ;
input                                   tdes_chacha_wren            ;
input   [10:0]                          tdes_chacha_waddr           ;
input   [7:0]                           tdes_chacha_wdata           ;

input   [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr                   ;
input                                   cbus_we                     ;
input                                   cbus_oe                     ;
input   [CBUS_DATA_WIDTH - 1 : 0]       cbus_wdata                  ;
output  [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;

reg                                     cbus_oe_1dly                ;
reg                                     cbus_oe_2dly                ;
reg                                     cbus_oe_3dly                ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_1dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_2dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_3dly              ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;

reg                                     tdprama_wea                 ;
reg     [6:0]                           tdprama_addra               ;
wire    [6:0]                           tdpram_addrb                ;
reg     [7:0]                           tdpram_dina                 ;
wire    [7:0]                           tdprama_douta               ;
wire    [7:0]                           tdprama_doutb               ;

reg                                     tdpramb_wea                 ;
reg     [6:0]                           tdpramb_addra               ;
wire    [7:0]                           tdpramb_douta               ;
wire    [7:0]                           tdpramb_doutb               ;

reg                                     cwram_wea                   ;
reg     [10:0]                          cwram_addra                 ;
wire    [10:0]                          cwram_addrb                 ;
reg     [7:0]                           cwram_dina                  ;
wire    [7:0]                           cwram_douta                 ;
wire    [7:0]                           cwram_doutb                 ;

assign  tdpram_addrb        =   chacha_bypass_ram_raddr;
assign  chacha_bypass_data  =   tdprama_doutb;
assign  chacha_bypass_mask  =   tdpramb_doutb;
assign  cwram_addrb         =   chacha_cwram_raddr;
assign  chacha_cwram_rdata  =   cwram_doutb;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
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

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
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

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdprama_wea <=  1'b0;
        tdpramb_wea <=  1'b0;
    end
    else if((cbus_we==1'b1) && (cbus_addr[11:8]==4'h8))
    begin
        if(cbus_addr[4]==1'b1)          //chacha bypass data mask
        begin
            tdprama_wea <=  1'b0;
            tdpramb_wea <=  1'b1;
        end
        else                            //chacha bypass data
        begin
            tdprama_wea <=  1'b1;
            tdpramb_wea <=  1'b0;
        end
    end
    else
    begin
        tdprama_wea <=  1'b0;
        tdpramb_wea <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdprama_addra   <=  {7{1'b0}};
        tdpramb_addra   <=  {7{1'b0}};
    end
    else if(((cbus_we==1'b1) || (cbus_oe==1'b1)) && (cbus_addr[11:8]==4'h8))
    begin
        if(cbus_addr[4]==1'b1)
        begin
            tdpramb_addra   <=  {cbus_addr[7:5],cbus_addr[3:0]};
        end
        else
        begin
            tdprama_addra   <=  {cbus_addr[7:5],cbus_addr[3:0]};
        end
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdpram_dina <=  {8{1'b0}};
    end
    else
    begin
        tdpram_dina <=  cbus_wdata;
    end
end
    
////////////////////////////////////////////////////////////////////
//chacha_cw_ram,cbus write and read
////////////////////////////////////////////////////////////////////    
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cwram_wea   <=  1'b0;
        cwram_dina  <=  {8{1'b0}};
    end
    else if(tdes_enable==1'b1)
    begin
        cwram_wea   <=  tdes_chacha_wren;
        cwram_dina  <=  tdes_chacha_wdata;
    end
    else if((cbus_we==1'b1) && (cbus_addr[11]==1'b0))
    begin
        cwram_wea   <=  1'b1;
        cwram_dina  <=  cbus_wdata;
    end
    else
    begin
        cwram_wea   <=  1'b0;
        cwram_dina  <=  {8{1'b0}};
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cwram_addra <=  {11{1'b0}};
    end
    else if(tdes_enable==1'b1)
    begin
        cwram_addra <=  tdes_chacha_waddr;
    end
    else if(((cbus_we==1'b1) || (cbus_oe==1'b1)) && (cbus_addr[11]==1'b0))
    begin
        cwram_addra <=  cbus_addr[10:0];
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cbus_rdata  <=  {CBUS_DATA_WIDTH{1'b0}};
    end
    else if(cbus_oe_3dly==1'b1)
    begin
        if(cbus_addr_3dly[11:8]==4'h8)
        begin
            if(cbus_addr_3dly[3]==1'b1)
            begin
                cbus_rdata  <=  tdpramb_douta;
            end
            else
            begin
                cbus_rdata  <=  tdprama_douta;
            end
        end
        else if(cbus_addr_3dly[11]==1'b0)
        begin
            cbus_rdata  <=  cwram_douta;
        end
    end
end

//chacha bypass data
//porta read latency=2;portb read latency=1;true dual port ram
tdpram_w8d128 u0_chacha_bypassdata_ram(
  .clka                                 ( clk                       ),
  .wea                                  ( tdprama_wea               ),
  .addra                                ( tdprama_addra             ),
  .dina                                 ( tdpram_dina               ),
  .douta                                ( tdprama_douta             ),
  .clkb                                 ( clk                       ),
  .web                                  ( 1'b0                      ),
  .addrb                                ( tdpram_addrb              ),
  .dinb                                 ( {8{1'b0}}                 ),
  .doutb                                ( tdprama_doutb             )
);

//chacha bypass mask
//porta read latency=2;portb read latency=1;true dual port ram
chacha_maskram_tdpw8d128 u0_chacha_bypassmask_ram(
  .clka                                 ( clk                       ),
  .wea                                  ( tdpramb_wea               ),
  .addra                                ( tdpramb_addra             ),
  .dina                                 ( tdpram_dina               ),
  .douta                                ( tdpramb_douta             ),
  .clkb                                 ( clk                       ),
  .web                                  ( 1'b0                      ),
  .addrb                                ( tdpram_addrb              ),
  .dinb                                 ( {8{1'b0}}                 ),
  .doutb                                ( tdpramb_doutb             )
);

//chacha cw ram
//porta read latency=2;portb read latency=1;true dual port ram        
tdpram_w8d2048 u0_chacha_cw_ram(
    .clka                               ( clk                       ),
    .wea                                ( cwram_wea                 ),
    .addra                              ( cwram_addra               ),
    .dina                               ( cwram_dina                ),
    .douta                              ( cwram_douta               ),
    .clkb                               ( clk                       ),
    .web                                ( 1'b0                      ),
    .addrb                              ( cwram_addrb               ),
    .dinb                               ( {8{1'b0}}                 ),
    .doutb                              ( cwram_doutb               )
    );

endmodule  	   
