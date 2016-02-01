/*************************************************************************************\
    Copyright(c) 2015, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  cbus_demux.v
    Author       :  huangrui/1480
    ==================================================================================
    Description  :  
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2015-01-15  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :  cbus_demux.v
    File tree    :  cbus_demux.v                        
\************************************************************************************/

`timescale 1ns/1ps

module cbus_demux(
    clk                         ,
    rst                         ,
    cbus_addr                   ,
    cbus_wdata                  ,
    cbus_rdata                  ,
    cbus_oe                     ,
    cbus_we                     ,
    
    cpu_cbus_rdata              ,
    cpu_cbus_addr               ,
    cpu_cbus_wdata              ,
    cpu_cbus_oe                 ,
    cpu_cbus_we                 ,
    
    filter_cbus_rdata           ,
    filter_cbus_addr            ,
    filter_cbus_wdata           ,
    filter_cbus_oe              ,
    filter_cbus_we              ,
    
    descram_cbus_rdata          ,
    descram_cbus_addr           ,
    descram_cbus_wdata          ,
    descram_cbus_oe             ,
    descram_cbus_we             ,
    
    chacha_cbus_rdata           ,
    chacha_cbus_addr            ,
    chacha_cbus_wdata           ,
    chacha_cbus_oe              ,
    chacha_cbus_we              ,
    
    camms_cbus_rdata            ,
    camms_cbus_addr             ,
    camms_cbus_wdata            ,
    camms_cbus_oe               ,
    camms_cbus_we               ,
    
    psi_cbus_rdata              ,
    psi_cbus_addr               ,
    psi_cbus_wdata              ,
    psi_cbus_oe                 ,
    psi_cbus_we                 ,
    
    tdes_cbus_rdata             ,
    tdes_cbus_addr              ,
    tdes_cbus_wdata             ,
    tdes_cbus_oe                ,
    tdes_cbus_we                
    );                          
                                
parameter   PBUS_ADDR_WIDTH             = 16                        ;  
parameter   PBUS_DATA_WIDTH             = 8                         ;
parameter   CBUS_ADDR_WIDTH             = 12                        ;
parameter   CBUS_DATA_WIDTH             = 8                         ;
parameter   DEMUX_ADDR_WIDTH            = PBUS_ADDR_WIDTH - CBUS_ADDR_WIDTH;

parameter   BASE_ADDR_CPU               = 4'h0                      ;
parameter   BASE_ADDR_FILTER            = 4'h1                      ;
parameter   BASE_ADDR_DESCRAM           = 4'h2                      ;
parameter   BASE_ADDR_CHACHA            = 4'h3                      ;
parameter   BASE_ADDR_CAMMS             = 4'h4                      ;
parameter   BASE_ADDR_PSI               = 4'h5                      ;
parameter   BASE_ADDR_TDES              = 4'h6                      ;
    
input                                   clk                         ;
input                                   rst                         ;
input   [PBUS_ADDR_WIDTH - 1 : 0]       cbus_addr                   ;            
input   [PBUS_DATA_WIDTH - 1 : 0]       cbus_wdata                  ; 
output  [PBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;          
input                                   cbus_oe                     ;           
input                                   cbus_we                     ;  

input   [CBUS_DATA_WIDTH - 1 : 0]       cpu_cbus_rdata              ;
output  [CBUS_ADDR_WIDTH - 1 : 0]       cpu_cbus_addr               ;
output  [CBUS_DATA_WIDTH - 1 : 0]       cpu_cbus_wdata              ;
output                                  cpu_cbus_oe                 ;
output                                  cpu_cbus_we                 ;

input   [CBUS_DATA_WIDTH - 1 : 0]       filter_cbus_rdata           ;
output  [CBUS_ADDR_WIDTH - 1 : 0]       filter_cbus_addr            ;
output  [CBUS_DATA_WIDTH - 1 : 0]       filter_cbus_wdata           ;
output                                  filter_cbus_oe              ;
output                                  filter_cbus_we              ;

input   [CBUS_DATA_WIDTH - 1 : 0]       descram_cbus_rdata          ;
output  [CBUS_ADDR_WIDTH - 1 : 0]       descram_cbus_addr           ;
output  [CBUS_DATA_WIDTH - 1 : 0]       descram_cbus_wdata          ;
output                                  descram_cbus_oe             ;
output                                  descram_cbus_we             ;

input   [CBUS_DATA_WIDTH - 1 : 0]       chacha_cbus_rdata           ;
output  [CBUS_ADDR_WIDTH - 1 : 0]       chacha_cbus_addr            ;
output  [CBUS_DATA_WIDTH - 1 : 0]       chacha_cbus_wdata           ;
output                                  chacha_cbus_oe              ;
output                                  chacha_cbus_we              ;

input   [CBUS_DATA_WIDTH - 1 : 0]       camms_cbus_rdata            ;
output  [CBUS_ADDR_WIDTH - 1 : 0]       camms_cbus_addr             ;
output  [CBUS_DATA_WIDTH - 1 : 0]       camms_cbus_wdata            ;
output                                  camms_cbus_oe               ;
output                                  camms_cbus_we               ;

input   [CBUS_DATA_WIDTH - 1 : 0]       psi_cbus_rdata              ;
output  [CBUS_ADDR_WIDTH - 1 : 0]       psi_cbus_addr               ;
output  [CBUS_DATA_WIDTH - 1 : 0]       psi_cbus_wdata              ;
output                                  psi_cbus_oe                 ;
output                                  psi_cbus_we                 ;

input   [CBUS_DATA_WIDTH - 1 : 0]       tdes_cbus_rdata             ;
output  [CBUS_ADDR_WIDTH - 1 : 0]       tdes_cbus_addr              ;
output  [CBUS_DATA_WIDTH - 1 : 0]       tdes_cbus_wdata             ;
output                                  tdes_cbus_oe                ;
output                                  tdes_cbus_we                ;

reg     [4:0]                           cbus_oe_dly                 ;
reg     [DEMUX_ADDR_WIDTH - 1 : 0]      cbus_addr_1dly              ;
reg     [DEMUX_ADDR_WIDTH - 1 : 0]      cbus_addr_2dly              ;
reg     [DEMUX_ADDR_WIDTH - 1 : 0]      cbus_addr_3dly              ;
reg     [DEMUX_ADDR_WIDTH - 1 : 0]      cbus_addr_4dly              ;
reg     [DEMUX_ADDR_WIDTH - 1 : 0]      cbus_addr_5dly              ;
reg     [PBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ; 

reg     [CBUS_ADDR_WIDTH - 1 : 0]       cpu_cbus_addr               ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       cpu_cbus_wdata              ;
reg                                     cpu_cbus_oe                 ;
reg                                     cpu_cbus_we                 ;

reg     [CBUS_ADDR_WIDTH - 1 : 0]       filter_cbus_addr            ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       filter_cbus_wdata           ;
reg                                     filter_cbus_oe              ;
reg                                     filter_cbus_we              ;

reg     [CBUS_ADDR_WIDTH - 1 : 0]       descram_cbus_addr           ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       descram_cbus_wdata          ;
reg                                     descram_cbus_oe             ;
reg                                     descram_cbus_we             ;

reg     [CBUS_ADDR_WIDTH - 1 : 0]       chacha_cbus_addr            ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       chacha_cbus_wdata           ;
reg                                     chacha_cbus_oe              ;
reg                                     chacha_cbus_we              ;

reg     [CBUS_ADDR_WIDTH - 1 : 0]       camms_cbus_addr             ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       camms_cbus_wdata            ;
reg                                     camms_cbus_oe               ;
reg                                     camms_cbus_we               ;

reg     [CBUS_ADDR_WIDTH - 1 : 0]       psi_cbus_addr               ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       psi_cbus_wdata              ;
reg                                     psi_cbus_oe                 ;
reg                                     psi_cbus_we                 ;

reg     [CBUS_ADDR_WIDTH - 1 : 0]       tdes_cbus_addr              ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       tdes_cbus_wdata             ;
reg                                     tdes_cbus_oe                ;
reg                                     tdes_cbus_we                ;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cbus_oe_dly <=  {5{1'b0}};
    end
    else
    begin
        cbus_oe_dly <=  {cbus_oe_dly[3:0],cbus_oe};
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cbus_addr_1dly  <=  {DEMUX_ADDR_WIDTH{1'b0}};
        cbus_addr_2dly  <=  {DEMUX_ADDR_WIDTH{1'b0}};
        cbus_addr_3dly  <=  {DEMUX_ADDR_WIDTH{1'b0}};
        cbus_addr_4dly  <=  {DEMUX_ADDR_WIDTH{1'b0}};
        cbus_addr_5dly  <=  {DEMUX_ADDR_WIDTH{1'b0}};
    end
    else
    begin
        cbus_addr_1dly  <=  cbus_addr[PBUS_ADDR_WIDTH - 1 : CBUS_ADDR_WIDTH];
        cbus_addr_2dly  <=  cbus_addr_1dly;
        cbus_addr_3dly  <=  cbus_addr_2dly;
        cbus_addr_4dly  <=  cbus_addr_3dly;
        cbus_addr_5dly  <=  cbus_addr_4dly;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cpu_cbus_addr       <=  {CBUS_ADDR_WIDTH{1'b0}};
        cpu_cbus_wdata      <=  {CBUS_DATA_WIDTH{1'b0}};
        cpu_cbus_we         <=  1'b0;
        cpu_cbus_oe         <=  1'b0;        
        filter_cbus_addr    <=  {CBUS_ADDR_WIDTH{1'b0}};
        filter_cbus_wdata   <=  {CBUS_DATA_WIDTH{1'b0}};
        filter_cbus_we      <=  1'b0;
        filter_cbus_oe      <=  1'b0;        
        descram_cbus_addr   <=  {CBUS_ADDR_WIDTH{1'b0}};
        descram_cbus_wdata  <=  {CBUS_DATA_WIDTH{1'b0}};
        descram_cbus_we     <=  1'b0;
        descram_cbus_oe     <=  1'b0;       
        chacha_cbus_addr    <=  {CBUS_ADDR_WIDTH{1'b0}};
        chacha_cbus_wdata   <=  {CBUS_DATA_WIDTH{1'b0}};
        chacha_cbus_we      <=  1'b0;
        chacha_cbus_oe      <=  1'b0;       
        camms_cbus_addr     <=  {CBUS_ADDR_WIDTH{1'b0}};
        camms_cbus_wdata    <=  {CBUS_DATA_WIDTH{1'b0}};
        camms_cbus_we       <=  1'b0;
        camms_cbus_oe       <=  1'b0;  
        psi_cbus_addr       <=  {CBUS_ADDR_WIDTH{1'b0}};
        psi_cbus_wdata      <=  {CBUS_DATA_WIDTH{1'b0}};
        psi_cbus_we         <=  1'b0;
        psi_cbus_oe         <=  1'b0;        
        tdes_cbus_addr      <=  {CBUS_ADDR_WIDTH{1'b0}};
        tdes_cbus_wdata     <=  {CBUS_DATA_WIDTH{1'b0}};
        tdes_cbus_we        <=  1'b0;
        tdes_cbus_oe        <=  1'b0;
    end
    else if(cbus_we | cbus_oe==1'b1)
    begin
        cpu_cbus_we         <=  1'b0;
        cpu_cbus_oe         <=  1'b0;
        filter_cbus_we      <=  1'b0;
        filter_cbus_oe      <=  1'b0;
        descram_cbus_we     <=  1'b0;
        descram_cbus_oe     <=  1'b0;
        chacha_cbus_we      <=  1'b0;
        chacha_cbus_oe      <=  1'b0;
        camms_cbus_we       <=  1'b0;
        camms_cbus_oe       <=  1'b0;
        psi_cbus_we         <=  1'b0;
        psi_cbus_oe         <=  1'b0;
        tdes_cbus_we        <=  1'b0;
        tdes_cbus_oe        <=  1'b0;
        case(cbus_addr[PBUS_ADDR_WIDTH - 1 : CBUS_ADDR_WIDTH])
        BASE_ADDR_CPU:
        begin
            cpu_cbus_addr       <=  cbus_addr[CBUS_ADDR_WIDTH - 1 : 0];
            cpu_cbus_wdata      <=  cbus_wdata;
            cpu_cbus_we         <=  cbus_we;
            cpu_cbus_oe         <=  cbus_oe;
        end
        BASE_ADDR_FILTER:
        begin
            filter_cbus_addr    <=  cbus_addr[CBUS_ADDR_WIDTH - 1 : 0];
            filter_cbus_wdata   <=  cbus_wdata;
            filter_cbus_we      <=  cbus_we;
            filter_cbus_oe      <=  cbus_oe;
        end 
        BASE_ADDR_DESCRAM:
        begin
            descram_cbus_addr   <=  cbus_addr[CBUS_ADDR_WIDTH - 1 : 0];
            descram_cbus_wdata  <=  cbus_wdata;
            descram_cbus_we     <=  cbus_we;
            descram_cbus_oe     <=  cbus_oe;
        end   
        BASE_ADDR_CHACHA: 
        begin
            chacha_cbus_addr    <=  cbus_addr[CBUS_ADDR_WIDTH - 1 : 0];
            chacha_cbus_wdata   <=  cbus_wdata;
            chacha_cbus_we      <=  cbus_we;
            chacha_cbus_oe      <=  cbus_oe;
        end
        BASE_ADDR_CAMMS:
        begin
            camms_cbus_addr     <=  cbus_addr[CBUS_ADDR_WIDTH - 1 : 0];
            camms_cbus_wdata    <=  cbus_wdata;
            camms_cbus_we       <=  cbus_we;
            camms_cbus_oe       <=  cbus_oe;
        end  
        BASE_ADDR_PSI:
        begin
            psi_cbus_addr       <=  cbus_addr[CBUS_ADDR_WIDTH - 1 : 0];
            psi_cbus_wdata      <=  cbus_wdata;
            psi_cbus_we         <=  cbus_we;
            psi_cbus_oe         <=  cbus_oe;
        end    
        BASE_ADDR_TDES:   
        begin
            tdes_cbus_addr      <=  cbus_addr[CBUS_ADDR_WIDTH - 1 : 0];
            tdes_cbus_wdata     <=  cbus_wdata;
            tdes_cbus_we        <=  cbus_we;
            tdes_cbus_oe        <=  cbus_oe;
        end
        default:;
        endcase
    end
    else
    begin
        cpu_cbus_we     <=  1'b0;
        cpu_cbus_oe     <=  1'b0;
        filter_cbus_we  <=  1'b0;
        filter_cbus_oe  <=  1'b0;
        descram_cbus_we <=  1'b0;
        descram_cbus_oe <=  1'b0;
        chacha_cbus_we  <=  1'b0;
        chacha_cbus_oe  <=  1'b0;
        camms_cbus_we   <=  1'b0;
        camms_cbus_oe   <=  1'b0;
        psi_cbus_we     <=  1'b0;
        psi_cbus_oe     <=  1'b0;
        tdes_cbus_we    <=  1'b0;
        tdes_cbus_oe    <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cbus_rdata  <=  {PBUS_DATA_WIDTH{1'b0}}; 
    end
    else if(cbus_oe_dly[4]==1'b1)
    begin
        case(cbus_addr_5dly)
        BASE_ADDR_CPU:      cbus_rdata  <=  cpu_cbus_rdata;
        BASE_ADDR_FILTER:   cbus_rdata  <=  filter_cbus_rdata;
        BASE_ADDR_DESCRAM:  cbus_rdata  <=  descram_cbus_rdata;
        BASE_ADDR_CHACHA:   cbus_rdata  <=  chacha_cbus_rdata;
        BASE_ADDR_CAMMS:    cbus_rdata  <=  camms_cbus_rdata;
        BASE_ADDR_PSI:      cbus_rdata  <=  psi_cbus_rdata;
        BASE_ADDR_TDES:     cbus_rdata  <=  tdes_cbus_rdata;
        default:;
        endcase
    end
end

endmodule   	   
