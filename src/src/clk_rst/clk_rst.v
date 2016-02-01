/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   New Media,R&D Hardware Department
    Filename     :   clk_rst.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-07-30  huangrui/1480       1.0         IPQAM       Create
    ==================================================================================
    Called by    :   clk_rst.v
    File tree    :   clk_rst.v                        
\************************************************************************************/

`timescale 1ns/100ps
    
module clk_rst(
    rstn_in                     , 
    clk_if                      ,
    
    clk_ebi                     ,
	 clk_ebi_2x                  ,
    clk_ebi_3x                  ,
    clk_ebi_4x                  ,
    rst_ebi_4x                  ,
    rst_ebi_3x                  ,
	 rst_ebi_2x                  ,
    rst_out                     
    );

parameter   U_DLY                       = 1                         ;
parameter   SIMULATION                  = "FALSE"                   ;

input                                   rstn_in                     ;
input                                   clk_if                      ;

output                                  clk_ebi                     ;
output											 clk_ebi_2x                  ;
output                                  rst_ebi_2x                  ;
output                                  clk_ebi_3x                  ;
output                                  rst_ebi_3x                  ;
output                                  clk_ebi_4x                  ;
output                                  rst_ebi_4x                  ;
output                                  rst_out                     ;

wire                                    pll30m_locked               ;
wire                                    rst_buf                     ;

gen_rst #(
    .SIMULATION                         ( SIMULATION                )
    )
u0_gen_rst(
    .clk                                ( clk_if                    ),
    .rst_i                              ( rstn_in                   ),
    .rst_o                              ( rst_buf                   )
    );
      
//pll_30m u0_pll_30m(
//    .CLK_IN1                            ( clk_if                    ),  //30MHz                  
//    .CLK_OUT1                           ( clk_ebi                   ),  //30MHz
//    .CLK_OUT2                           ( clk_ebi_3x                ),  //90MHz  
//    .CLK_OUT3                           ( clk_ebi_4x                ),  //120MHz    
//    .RESET                              ( rst_buf                   ),
//    .LOCKED                             ( pll30m_locked             )
//    );
	 
pll60 u0_pll_60m
   (// Clock in ports
    .CLK_IN1                             (clk_if),      		// 27M
    // Clock out ports
    .CLK_OUT1                            (clk_ebi),     		// 30M
    .CLK_OUT2                            (clk_ebi_2x),     	// 60M
    .CLK_OUT3									  (clk_ebi_3x),     	// 90M	
    .CLK_OUT4									  (clk_ebi_4x),     	// 120M
    // Status and control signals
    .RESET										  (rst_buf),			// IN
    .LOCKED										  (pll30m_locked));      // OUT   
    
rst_sync u0_rst30m_sync(
    .clk                                ( clk_ebi                   ),
    .enable                             ( pll30m_locked             ),
    .reset_in                           ( rst_buf                   ),
    .reset_out                          ( rst_out                   )
    );

rst_sync u1_rst30m_sync(
    .clk                                ( clk_ebi_2x                ),
    .enable                             ( pll30m_locked             ),
    .reset_in                           ( rst_buf                   ),
    .reset_out                          ( rst_ebi_2x                )
	 );
	 
rst_sync u2_rst30m_sync(
    .clk                                ( clk_ebi_3x                ),
    .enable                             ( pll30m_locked             ),
    .reset_in                           ( rst_buf                   ),
    .reset_out                          ( rst_ebi_3x                )
    );

rst_sync u3_rst30m_sync(
    .clk                                ( clk_ebi_4x                ),
    .enable                             ( pll30m_locked             ),
    .reset_in                           ( rst_buf                   ),
    .reset_out                          ( rst_ebi_4x                )
    );
    
endmodule
