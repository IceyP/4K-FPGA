/*************************************************************************************\
    Copyright(c) 2015, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   New Media,R&D Hardware Department
    Filename     :   tb_top.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2015-01-15  huangrui/1480       1.0         IPQAM       Create
    ==================================================================================
    Called by    :   tb_top.v
    File tree    :   tb_top.v
\************************************************************************************/

`timescale 1ns/100ps

module tb_top;

reg                                     rst                         ;
reg                                     clk_27m                     ;
reg                                     clk_125m                    ;
reg                                     clk_250m                    ;
reg                                     clk_78m                     ;
//reg                                     clk_cfg                     ;
reg                                     mgt_refclk_n_1              ;
reg                                     mgt_refclk_n_2              ;
reg                                     mgt_refclk_n_3              ;

reg     [15:0]                          lbus_addr                   ;
reg     [15:0]                          lbus_wdata                  ;
reg                                     lbus_cs_n                   ;
reg                                     lbus_oe_n                   ;
reg                                     lbus_we_n                   ;
reg                                     lbus_cfg_finished           ;

wire    [15:0]                          lbus_data                   ;
wire                                    lbus_wait_n                 ;
wire                                    clk_cfg                     ;
wire                                    rst_cfg                     ;
wire    [15:0]                          lbus_data2                  ;
wire    [15:0]                          lbus_data3                  ;
wire                                    channel_up                  ;

wire                                    calib_done                  ;
wire                                    scram_valid                 ;
wire    [7:0]                           scram_data                  ;

integer i;

initial
begin
    rst =   1'b1;
    #200
    rst =   1'b0;
end

initial
    clk_27m     =   1'b0;
always
    clk_27m     =   # 18.518 ~clk_27m;

//---------------------------cpu config---------------------------//
parameter   ADDR_FPGA_VER               = 12'h001                   ;


assign lbus_data = (~lbus_we_n) ? lbus_wdata : 16'hz;

task cpu_wr;
    input   [15:0]  cpu_waddr;
    input   [15:0]  cpu_wdata;
    begin
        @(posedge clk_cfg);
        lbus_cs_n    =   1'b0;
        lbus_we_n    =   1'b0;
        lbus_addr    =   cpu_waddr;
        //lbus_wdata   =   cpu_wdata;
        lbus_wdata    =   cpu_wdata;
        @(posedge clk_cfg);
        @(posedge clk_cfg);
        @(posedge clk_cfg);
        @(posedge clk_cfg);
        lbus_cs_n    =   1'b1;
        lbus_we_n    =   1'b1; 
    end
endtask

task cpu_rd;
    input   [15:0]  cpu_raddr;
    output  [15:0]  cpu_rdata;
    reg     [15:0]  cpu_rdata;
    begin
        @(posedge clk_cfg);
        lbus_cs_n    =   1'b0;
        lbus_oe_n    =   1'b0;
        lbus_addr    =   cpu_raddr; 
        @(posedge clk_cfg);
        @(posedge clk_cfg);
        @(posedge clk_cfg);             //????????????????????????????????????????????????????see lbus timing
        @(posedge clk_cfg);             //????????????????????????????????????????????????????see lbus timing
        //while (lbus_wait_n == 1'b0)
        //    @(posedge clk_cfg);
        wait(lbus_wait_n==1'b1);
        cpu_rdata    =   lbus_data;
        @(posedge clk_cfg);
        lbus_cs_n    =   1'b1;
        lbus_oe_n    =   1'b1;
    end
endtask

initial
begin
    lbus_cfg_finished   =   1'b0;
    lbus_cs_n   =   1'b1;
    lbus_oe_n   =   1'b1;
    lbus_we_n   =   1'b1;
    lbus_addr   =   {16{1'b0}};
    lbus_wdata  =   {16{1'b0}};
    #7000;
    //ECM packet1
    cpu_wr(ADDR_ECM_PKT_DATA,16'h8001);//packet type
    
    
    lbus_cfg_finished   =   1'b1;
end
                
initial begin
    $fsdbDumpfile("test_000.fsdb");
    $fsdbDumpvars;
end	

endmodule

