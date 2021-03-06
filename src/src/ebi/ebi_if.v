/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  ebi_if.v
    Author       :  huangrui/1480
    ==================================================================================
    Description  :  
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-07-31  huangrui/1480       1.0         rt20        Create
    ==================================================================================
    Called by    :  ebi_if.v
    File tree    :  ebi_if.v                        
\************************************************************************************/

`timescale 1ns/100ps

module ebi_if(
    clk                         ,    
    rst                         ,
    lbus_ad                     , 
    lbus_ctrl                   ,
    ebi_addr                    ,
    ebi_wdata                   ,
    ebi_rdata                   ,
    ebi_we                      ,
    ebi_oe                       
    );

parameter   U_DLY                       = 1                         ;
parameter	ADDR_EBI_TEST					 				=	4'h0											;
parameter	ADDR_SC_CARD					 				=	4'hE											;


input                                   clk                         ;
input                                   rst                         ;
inout   [7:0]                           lbus_ad                     ;
input   [2:0]                           lbus_ctrl                   ;

output  [15:0]                          ebi_addr                    ;
output  [7:0]                           ebi_wdata                   ;
input   [7:0]                           ebi_rdata                   ;
output                                  ebi_we                      ;
output                                  ebi_oe                      ;

//3'b110,address low;3'b101,address high;
//3'b100,write;3'b000,read;
reg     [2:0]                           lbus_ctrl_1sync             ;
reg     [2:0]                           lbus_ctrl_2sync             ;

reg     [7:0]                           lbus_ad_1sync               ;
reg     [7:0]                           lbus_ad_2sync               ;

reg     [15:0]                          ebi_addr                    ;
reg     [7:0]                           ebi_wdata                   ;
reg                                     ebi_we                      ;
reg                                     ebi_oe                      ;

reg                                     ebi_we_buf                  ;
reg                                     ebi_we_buf_1dly             ;
reg                                     ebi_oe_buf                  ;
reg                                     ebi_oe_buf_1dly             ;

reg	   [7:0]								    ebi_rdata_buf               ;
reg		[7:0]			                   ebi_test                    ;

assign  lbus_ad =   (lbus_ctrl==3'b111)   ?   ebi_rdata_buf   :   8'hzz; 

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        lbus_ctrl_1sync <=  3'b000;
        lbus_ctrl_2sync <=  3'b000;
    end
    else
    begin
        lbus_ctrl_1sync <=  lbus_ctrl;
        lbus_ctrl_2sync <=  lbus_ctrl_1sync;
    end 
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        lbus_ad_1sync   <=  {8{1'b0}};
        lbus_ad_2sync   <=  {8{1'b0}};
    end
    else
    begin
        lbus_ad_1sync   <=  lbus_ad[7:0];
        lbus_ad_2sync   <=  lbus_ad_1sync;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ebi_addr    <=  {16{1'b0}};
    end
    else if(lbus_ctrl_2sync==3'b101)          //address low 8bit
    begin
        ebi_addr[7:0]   <=  lbus_ad_2sync;
    end
    else if(lbus_ctrl_2sync==3'b110)          //address high 8bit
    begin
        ebi_addr[15:8]  <=  lbus_ad_2sync;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ebi_wdata   <=  {8{1'b0}};
    end
    else if(lbus_ctrl_2sync==3'b100)
    begin
        ebi_wdata   <=  lbus_ad_2sync;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ebi_we_buf  <=  1'b0;
    end
    else if(lbus_ctrl_2sync==3'b100)
    begin
        ebi_we_buf  <=  1'b1;
    end
    else
    begin
        ebi_we_buf  <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ebi_we_buf_1dly <=  1'b0;
        ebi_we          <=  1'b0;
    end
    else
    begin
        ebi_we_buf_1dly <=  ebi_we_buf;
        ebi_we          <=  (~ebi_we_buf_1dly) & ebi_we_buf;
    end
end
    
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ebi_oe_buf  <=  1'b0;
    end
    else if(lbus_ctrl_2sync==3'b111)
    begin
        ebi_oe_buf  <=  1'b1;
    end
    else
    begin
        ebi_oe_buf  <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ebi_oe_buf_1dly <=  1'b0;
        ebi_oe          <=  1'b0;
    end
    else 
    begin
        ebi_oe_buf_1dly <=  ebi_oe_buf;
        ebi_oe          <=  (~ebi_oe_buf_1dly) & ebi_oe_buf;
    end
end

//////////////////////////////////////////
//for test
//////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
    		ebi_test	<=	{8{1'b0}};
    end
    else if(ebi_we==1'b1)
    begin
    		if(ebi_addr[15:12]==ADDR_EBI_TEST)
    		begin
    				ebi_test	<=	ebi_wdata;
    		end
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
    		ebi_rdata_buf	<=	{8{1'b0}};
    end
    else if(ebi_oe==1'b1)
    begin
    	  case(ebi_addr[15:12])
    	  ADDR_EBI_TEST:
    	  begin
    	  	  ebi_rdata_buf	<=	~ebi_test;
    	  end
    	  ADDR_SC_CARD:
    	  begin
    	  	  ebi_rdata_buf <= 	ebi_rdata;
    	  end 
    	  default:;
    		endcase
    end
end
       	 
endmodule   	   
