/*************************************************************************************\
    Copyright(c) 2015, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  cpu_if.v
    Author       :  huangrui/1480
    ==================================================================================
    Description  :  cbus read latency = 4;
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2015-01-08  huangrui/1480       1.0         RT21        Create
    ==================================================================================
    Called by    :  cpu_if.v
    File tree    :  cpu_if.v                        
\************************************************************************************/

`timescale 1ns/1ps

module cpu_if(
    clk                         ,
    rst                         ,
    
    cbus_addr                   ,
    cbus_wdata                  ,
    cbus_we                     ,
    cbus_oe                     ,
    cbus_rdata                  ,
    
    all_pid_cfg                 ,
    test_mode                   ,
    chacha_enable
    );

parameter   CBUS_ADDR_WIDTH             = 12                        ; 
parameter   CBUS_DATA_WIDTH             = 8                         ;
parameter   TOTAL_CHN_NUM               = 3                         ;

parameter   BOARD_TYPE                  = 8'h01                     ;
parameter   FPGA_VERSION                = 8'h10                     ;

//base address is 16'h0000
parameter   ADDR_BOARD_TYPE             = 12'h000                   ;
parameter   ADDR_FPGA_VERSION           = 12'h001                   ;
parameter   ADDR_SPI_TEST               = 12'h002                   ;
parameter   ADDR_TS_TEST_MODE           = 12'h003                   ;

parameter   ADDR_CHACHA_ENA             = 12'h201                   ;

parameter   ADDR_ALL_PID_CFG1           = 12'h300                   ;
parameter   ADDR_ALL_PID_CFG2           = 12'h301                   ;
parameter   ADDR_ALL_PID_CFG3           = 12'h302                   ;
parameter   ADDR_ALL_PID_CFG4           = 12'h303                   ;


input                                   clk                         ;
input                                   rst                         ;
input   [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr                   ;
inout   [CBUS_DATA_WIDTH - 1 : 0]       cbus_wdata                  ;
input                                   cbus_we                     ;
input                                   cbus_oe                     ;
output  [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;

output  [TOTAL_CHN_NUM - 1 : 0]         all_pid_cfg                 ;
output                                  test_mode                   ;
output                                  chacha_enable               ;

reg                                     cbus_oe_1dly                ;
reg                                     cbus_oe_2dly                ;
reg                                     cbus_oe_3dly                ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_1dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_2dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_3dly              ;

reg     [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       spi_test                    ;
reg     [3:0]                           all_pid_cfg_b               ;
reg                                     chacha_enable               ;
reg                                     test_mode                   ;

assign  all_pid_cfg =   all_pid_cfg_b[TOTAL_CHN_NUM - 1 : 0];

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

//cbus write
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        spi_test        <=  {CBUS_DATA_WIDTH{1'b0}};
        test_mode       <=  1'b0;
        all_pid_cfg_b   <=  {4{1'b0}};
        chacha_enable   <=  1'b0;
    end
    else if(cbus_we)
    begin
        case(cbus_addr)
        ADDR_SPI_TEST:      spi_test            <=  cbus_wdata;
        ADDR_TS_TEST_MODE:  test_mode           <=  cbus_wdata[0];
        ADDR_ALL_PID_CFG1:  all_pid_cfg_b[0]    <=  cbus_wdata[0];
        ADDR_ALL_PID_CFG2:  all_pid_cfg_b[1]    <=  cbus_wdata[0];
        ADDR_ALL_PID_CFG3:  all_pid_cfg_b[2]    <=  cbus_wdata[0];
        ADDR_ALL_PID_CFG4:  all_pid_cfg_b[3]    <=  cbus_wdata[0];
        ADDR_CHACHA_ENA:    chacha_enable       <=  cbus_wdata[0];
        default:;
        endcase
    end
end

//cbus read   
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cbus_rdata  <=  {CBUS_DATA_WIDTH{1'b0}};
    end
    else if(cbus_oe_3dly==1'b1)
    begin
        case(cbus_addr_3dly)
        ADDR_BOARD_TYPE:    cbus_rdata  <=  BOARD_TYPE;     
        ADDR_FPGA_VERSION:  cbus_rdata  <=  FPGA_VERSION;
        ADDR_SPI_TEST:      cbus_rdata  <=  ~spi_test;
        ADDR_TS_TEST_MODE:  cbus_rdata  <=  {{7{1'b0}},test_mode};
        ADDR_CHACHA_ENA:    cbus_rdata  <=  {{7{1'b0}},chacha_enable};
        ADDR_ALL_PID_CFG1:  cbus_rdata  <=  {{7{1'b0}},all_pid_cfg_b[0]};
        ADDR_ALL_PID_CFG2:  cbus_rdata  <=  {{7{1'b0}},all_pid_cfg_b[1]};
        ADDR_ALL_PID_CFG3:  cbus_rdata  <=  {{7{1'b0}},all_pid_cfg_b[2]};
        ADDR_ALL_PID_CFG4:  cbus_rdata  <=  {{7{1'b0}},all_pid_cfg_b[3]};
        default:;
        endcase
    end
end
    
endmodule   	   
