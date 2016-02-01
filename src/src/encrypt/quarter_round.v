/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  quarter_round.v
    Author       :  jiayunlong/2020
    ==================================================================================
    Description  :
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-07-11  jiayunlong/2020     1.0         RT20        Create     
    ==================================================================================
    Called by    :  quarter_round.v
    File tree    :  quarter_round.v                          
\************************************************************************************/

`timescale 1ns/1ps

module quarter_round(                  //实现quarterround函数功能
    clk                         ,
	 rst                         ,
    in_a                        ,
	 in_b                        ,
	 in_c                        ,
	 in_d                        ,
	 out_a                       ,
	 out_b                       ,
	 out_c                       ,
	 out_d                       ,
    finish                       	 
	  );
	  
parameter   PRO_INTERVAL                = 1                         ;

input                                   clk                         ;
input                                   rst                         ;
input   [31:0]                          in_a                        ;
input   [31:0]                          in_b                        ;
input   [31:0]                          in_c                        ;
input   [31:0]                          in_d                        ;
output  [31:0]                          out_a                       ;
output  [31:0]                          out_b                       ;
output  [31:0]                          out_c                       ;
output  [31:0]                          out_d                       ;
output                                  finish                      ;

reg     [31:0]                          temp1_a                     ; 
reg     [31:0]                          temp1_b                     ;
reg     [31:0]                          temp1_c                     ;
reg     [31:0]                          temp1_d                     ;
reg     [31:0]                          temp2_a                     ; 
reg     [31:0]                          temp2_b                     ;
reg     [31:0]                          temp2_c                     ;
reg     [31:0]                          temp2_d                     ;
reg     [31:0]                          temp                        ;
reg     [31:0]                          out_a                       ;
reg     [31:0]                          out_b                       ;
reg     [31:0]                          out_c                       ;
reg     [31:0]                          out_d                       ;
reg     [3:0]                           counter                     ;
reg                                     finish                      ;           

/*******************************************\
#define QUARTERROUND(a,b,c,d) 
  a = PLUS(a,b); d = ROTATE(XOR(d,a),16); 
  c = PLUS(c,d); b = ROTATE(XOR(b,c),12); 
  a = PLUS(a,b); d = ROTATE(XOR(d,a), 8); 
  c = PLUS(c,d); b = ROTATE(XOR(b,c), 7);
 \******************************************/
always @ *
begin
    temp1_a  =   in_a + in_b;
	 temp     =   in_d ^ temp1_a;
	 temp1_d  =   {temp[15:0],temp[31:16]};
	 temp1_c  =   in_c + temp1_d;
	 temp     =   in_b ^ temp1_c;
	 temp1_b  =   {temp[19:0],temp[31:20]};
	 temp2_a  =   temp1_a + temp1_b;
	 temp     =   temp1_d ^ temp2_a;
	 temp2_d  =   {temp[23:0],temp[31:24]};
	 temp2_c  =   temp1_c + temp2_d;
	 temp     =   temp1_b ^ temp2_c;
	 temp2_b  =   {temp[24:0],temp[31:25]};
end


always@(posedge clk)
begin
    if(rst==1'b1)
	 begin
	     counter <=  {4{1'b0}};
	 end
	 else if(counter>=PRO_INTERVAL)
	 begin
	     counter <=  {4{1'b0}};
	 end
	 else
	 begin
	     counter <=  counter + 1'b1;
	 end
end

always@(posedge clk)
begin
    if(rst==1'b1)
	 begin
	     out_a <=  {32{1'b0}};
		  out_b <=  {32{1'b0}};
		  out_c <=  {32{1'b0}};
		  out_d <=  {32{1'b0}};
	 end
	 else if(counter==PRO_INTERVAL)
	 begin
	     out_a <=  temp2_a;
		  out_b <=  temp2_b;
		  out_c <=  temp2_c;
		  out_d <=  temp2_d;	  
	 end
end

always@(posedge clk)
begin
    if(rst==1'b1)
	 begin
	     finish <=  1'b0;
	 end
	 else if(counter==PRO_INTERVAL)
	 begin
	     finish <=  1'b1;
	 end
	 else
	 begin
	     finish <=  1'b0;
	 end
end
	 
endmodule
