/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  spi_if
    Author       :  zjk
    ==================================================================================
    Description  :  
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-12-25  zjk       1.0         IPQAM       Create
    ==================================================================================           
\************************************************************************************/
 
`timescale 1ns/1ps

module spi_if #(
  parameter  BUS_DATA_WIDTH   =  8            ,
  parameter  BUS_ADD_WIDTH    =  16                                 
)(
  input                             rst       ,
  input                             clk       ,    //sample clock ,>= 5 x  spi clk
  // SPI signals
  input                             ss_i      ,
  input                             sclk_i    ,
  input                             mosi_i    ,
  output wire                       miso_o    ,
  //bus interface
  input                             bus_clk   ,
  input       [BUS_DATA_WIDTH-1:0]  bus_rdata ,  
  output wire                       bus_we    ,
  output wire                       bus_oe    ,
  output wire [BUS_DATA_WIDTH-1:0]  bus_wdata ,
  output wire [BUS_ADD_WIDTH-1:0]   bus_addr        
 );
                                
  wire                     spi_tx_req         ;    
  wire   [7:0]             spi_tx_data        ;
  wire                     spi_tx_ack         ;
  
  wire                     spi_rx_sof         ;
  wire                     spi_rx_eof         ;
  wire                     spi_rx_valid       ;
  wire   [7:0]             spi_rx_data        ;
  
  
  spi_slave u_spi_slave
  (
    //  signals
    .clk                   (clk), 
    .rst                   (rst), 
    
    .dat_i                 (spi_tx_data),
    .we_i                  (spi_tx_req),   
    .we_ack_o              (spi_tx_ack),
    
    .dat_o                 (spi_rx_data), 
    .valid_o               (spi_rx_valid),
    .start_o               (spi_rx_sof),
    .end_o                 (spi_rx_eof),
  
    // SPI signals
    .ss_i                  (ss_i),
    .sclk_i                (sclk_i), 
    .miso_o                (miso_o), 
    .mosi_i                (mosi_i)
  );  
  
  spi_cmd_process  #(
    .BUS_DATA_WIDTH        (BUS_DATA_WIDTH) ,
    .BUS_ADD_WIDTH         (BUS_ADD_WIDTH)                        
   )
   u_spi_cmd(
    .clk                   (clk),      
    .rst                   (rst),      
    .rx_data               (spi_rx_data),      
    .rx_valid              (spi_rx_valid), 
    .rx_start              (spi_rx_sof), 
    .rx_end                (spi_rx_eof), 
  
    .tx_ack                (spi_tx_ack),    
    .tx_data               (spi_tx_data),      
    .tx_req                (spi_tx_req),      
  
    .bus_clk               (bus_clk),
    .bus_rdata             (bus_rdata),  
    .bus_we                (bus_we),
    .bus_oe                (bus_oe),
    .bus_wdata             (bus_wdata),
    .bus_addr              (bus_addr)   
    );  
     	
endmodule


