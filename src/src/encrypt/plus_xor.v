/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  plus_xor.v
    Author       :  jiayunlong/2020
    ==================================================================================
    Description  :
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-07-11  jiayunlong/2020     1.0         RT20        Create     
    ==================================================================================
    Called by    :  puls_xor.v
    File tree    :  puls_xor.v
	                 +----quarter_round.v                          
\************************************************************************************/

`timescale 1ns/1ps

module plus_xor(                        //实现2-round的chacha算法
    clk                         ,
    rst                         ,
	ts_chacha_req               ,  
    r0_col1_old1                ,
    r0_col1_old2                ,
    r0_col1_old3                ,
    r0_col1_old4                ,
    r0_col2_old1                ,
    r0_col2_old2                ,
    r0_col2_old3                ,
    r0_col2_old4                ,    
    r0_col3_old1                ,
    r0_col3_old2                ,
    r0_col3_old3                ,
    r0_col3_old4                ,
    r0_col4_old1                ,
    r0_col4_old2                ,
    r0_col4_old3                ,
    r0_col4_old4                ,
    r2_col1_new1                ,
    r2_col1_new2                ,
    r2_col1_new3                ,
    r2_col1_new4                ,
    r2_col2_new1                ,
    r2_col2_new2                ,
    r2_col2_new3                ,
    r2_col2_new4                ,    
    r2_col3_new1                ,
    r2_col3_new2                ,
    r2_col3_new3                ,
    r2_col3_new4                ,
    r2_col4_new1                ,
    r2_col4_new2                ,
    r2_col4_new3                ,
    r2_col4_new4                ,
    r1_finish
    );
 
parameter   PRO_INTERVAL                = 8                         ;

input                                   clk                         ;
input                                   rst                         ;
input   [31:0]                          r0_col1_old1                ;//第1列4个输入
input   [31:0]                          r0_col1_old2                ;
input   [31:0]                          r0_col1_old3                ;
input   [31:0]                          r0_col1_old4                ;
input   [31:0]                          r0_col2_old1                ;//第2列4个输入
input   [31:0]                          r0_col2_old2                ;
input   [31:0]                          r0_col2_old3                ;
input   [31:0]                          r0_col2_old4                ;
input   [31:0]                          r0_col3_old1                ;//第3列4个输入
input   [31:0]                          r0_col3_old2                ;
input   [31:0]                          r0_col3_old3                ;
input   [31:0]                          r0_col3_old4                ;
input   [31:0]                          r0_col4_old1                ;//第4列4个输入
input   [31:0]                          r0_col4_old2                ;
input   [31:0]                          r0_col4_old3                ;
input   [31:0]                          r0_col4_old4                ;
output  [31:0]                          r2_col1_new1                ;//2-round后，第1列4个输出
output  [31:0]                          r2_col1_new2                ;
output  [31:0]                          r2_col1_new3                ;
output  [31:0]                          r2_col1_new4                ;
output  [31:0]                          r2_col2_new1                ;//2-round后，第2列4个输出
output  [31:0]                          r2_col2_new2                ;
output  [31:0]                          r2_col2_new3                ;
output  [31:0]                          r2_col2_new4                ;
output  [31:0]                          r2_col3_new1                ;//2-round后，第3列4个输出
output  [31:0]                          r2_col3_new2                ;
output  [31:0]                          r2_col3_new3                ;
output  [31:0]                          r2_col3_new4                ;
output  [31:0]                          r2_col4_new1                ;//2-round后，第4列4个输出
output  [31:0]                          r2_col4_new2                ;
output  [31:0]                          r2_col4_new3                ;
output  [31:0]                          r2_col4_new4                ;
output                                  r1_finish                   ;//为1时，完成运算
wire                                    r2_col1_finish              ;
wire                                    r2_col2_finish              ;
wire                                    r2_col3_finish              ;
wire                                    r2_col4_finish              ;
wire                                    r1_col1_finish              ;
wire                                    r1_col2_finish              ;
wire                                    r1_col3_finish              ;
wire                                    r1_col4_finish              ;
wire    [31:0]                          r1_col1_new1                ;//第1-round与第2-round的16个连接线
wire    [31:0]                          r1_col1_new2                ;
wire    [31:0]                          r1_col1_new3                ;
wire    [31:0]                          r1_col1_new4                ;
wire    [31:0]                          r1_col2_new1                ;
wire    [31:0]                          r1_col2_new2                ;
wire    [31:0]                          r1_col2_new3                ;
wire    [31:0]                          r1_col2_new4                ;
wire    [31:0]                          r1_col3_new1                ;
wire    [31:0]                          r1_col3_new2                ;
wire    [31:0]                          r1_col3_new3                ;
wire    [31:0]                          r1_col3_new4                ;
wire    [31:0]                          r1_col4_new1                ;
wire    [31:0]                          r1_col4_new2                ;
wire    [31:0]                          r1_col4_new3                ;
wire    [31:0]                          r1_col4_new4                ;
wire    [31:0]                          r2_col1_new1_r              ;
wire    [31:0]                          r2_col1_new4_r              ;
wire    [31:0]                          r2_col1_new3_r              ;
wire    [31:0]                          r2_col1_new2_r              ;
wire    [31:0]                          r2_col2_new1_r              ;
wire    [31:0]                          r2_col2_new4_r              ;
wire    [31:0]                          r2_col2_new3_r              ;
wire    [31:0]                          r2_col2_new2_r              ;
wire    [31:0]                          r2_col3_new1_r              ;
wire    [31:0]                          r2_col3_new4_r              ;
wire    [31:0]                          r2_col3_new3_r              ;
wire    [31:0]                          r2_col3_new2_r              ;
wire    [31:0]                          r2_col4_new1_r              ;
wire    [31:0]                          r2_col4_new4_r              ;
wire    [31:0]                          r2_col4_new3_r              ;
wire    [31:0]                          r2_col4_new2_r              ;
input                                   ts_chacha_req               ;
reg     [6:0]                           counter                     ;
reg                                     r1_finish_r                 ;
reg     [31:0]                          r2_col1_new1                ;
reg     [31:0]                          r2_col1_new2                ;
reg     [31:0]                          r2_col1_new3                ;
reg     [31:0]                          r2_col1_new4                ;
reg     [31:0]                          r2_col2_new1                ;
reg     [31:0]                          r2_col2_new2                ;
reg     [31:0]                          r2_col2_new3                ;
reg     [31:0]                          r2_col2_new4                ;
reg     [31:0]                          r2_col3_new1                ;
reg     [31:0]                          r2_col3_new2                ;
reg     [31:0]                          r2_col3_new3                ;
reg     [31:0]                          r2_col3_new4                ;
reg     [31:0]                          r2_col4_new1                ;
reg     [31:0]                          r2_col4_new2                ;
reg     [31:0]                          r2_col4_new3                ;
reg     [31:0]                          r2_col4_new4                ;

/* 第1-round  quarterround(0,4,8,12) */
quarter_round  quarter_round1_col1(                                 
    .clk(clk)                   ,
    .rst(rst)                   ,
    .in_a(r0_col1_old1)         ,
    .in_b(r0_col1_old2)         ,
    .in_c(r0_col1_old3)         ,
    .in_d(r0_col1_old4)         ,
    .out_a(r1_col1_new1)        ,
    .out_b(r1_col1_new2)        ,
    .out_c(r1_col1_new3)        ,
    .out_d(r1_col1_new4)        ,
    .finish(r1_col1_finish)
    );

/* 第1-round  quarterround(1,5,9,13) */
quarter_round  quarter_round1_col2(
    .clk(clk)                   ,
    .rst(rst)                   ,
    .in_a(r0_col2_old1)         ,
    .in_b(r0_col2_old2)         ,
    .in_c(r0_col2_old3)         ,
    .in_d(r0_col2_old4)         ,
    .out_a(r1_col2_new1)        ,
    .out_b(r1_col2_new2)        ,
    .out_c(r1_col2_new3)        ,
    .out_d(r1_col2_new4)        ,
    .finish(r1_col2_finish)
    );

/* 第1-round  quarterround(2,6,10,14) */
quarter_round  quarter_round1_col3(
    .clk(clk)                   ,
    .rst(rst)                   ,
    .in_a(r0_col3_old1)         ,
    .in_b(r0_col3_old2)         ,
    .in_c(r0_col3_old3)         ,
    .in_d(r0_col3_old4)         ,
    .out_a(r1_col3_new1)        ,
    .out_b(r1_col3_new2)        ,
    .out_c(r1_col3_new3)        ,
    .out_d(r1_col3_new4)        ,
    .finish(r1_col3_finish)
    );

/* 第1-round  quarterround(3,7,11,15) */
quarter_round  quarter_round1_col4(
    .clk(clk)                   ,
    .rst(rst)                   ,
    .in_a(r0_col4_old1)         ,
    .in_b(r0_col4_old2)         ,
    .in_c(r0_col4_old3)         ,
    .in_d(r0_col4_old4)         ,
    .out_a(r1_col4_new1)        ,
    .out_b(r1_col4_new2)        ,
    .out_c(r1_col4_new3)        ,
    .out_d(r1_col4_new4)        ,
    .finish(r1_col4_finish)
    );

/* 第2-round  quarterround(0,5,10,15) */
quarter_round  quarter_round2_col1(
    .clk(clk)                   ,
    .rst(rst)                   ,
    .in_a(r1_col1_new1)         ,
    .in_b(r1_col2_new2)         ,
    .in_c(r1_col3_new3)         ,
    .in_d(r1_col4_new4)         ,
    .out_a(r2_col1_new1_r)      ,
    .out_b(r2_col2_new2_r)      ,
    .out_c(r2_col3_new3_r)      ,
    .out_d(r2_col4_new4_r)      ,
    .finish(r2_col1_finish)
    );

/* 第2-round  quarterround(1,6,11,12) */
quarter_round  quarter_round2_col2(
    .clk(clk)                   ,
    .rst(rst)                   ,
    .in_a(r1_col2_new1)         ,
    .in_b(r1_col3_new2)         ,
    .in_c(r1_col4_new3)         ,
    .in_d(r1_col1_new4)         ,
    .out_a(r2_col2_new1_r)      ,
    .out_b(r2_col3_new2_r)      ,
    .out_c(r2_col4_new3_r)      ,
    .out_d(r2_col1_new4_r)      ,
    .finish(r2_col2_finish)
    );

/* 第2-round  quarterround(2,7,8,13) */
quarter_round  quarter_round2_col3(
    .clk(clk)                   ,
    .rst(rst)                   ,
    .in_a(r1_col3_new1)         ,
    .in_b(r1_col4_new2)         ,
    .in_c(r1_col1_new3)         ,
    .in_d(r1_col2_new4)         ,
    .out_a(r2_col3_new1_r)      ,
    .out_b(r2_col4_new2_r)      ,
    .out_c(r2_col1_new3_r)      ,
    .out_d(r2_col2_new4_r)      ,
    .finish(r2_col3_finish)
    );

/* 第2-round  quarterround(3,4,9,14) */
quarter_round  quarter_round2_col4(
    .clk(clk)                   ,
    .rst(rst)                   ,
    .in_a(r1_col4_new1)         ,
    .in_b(r1_col1_new2)         ,
    .in_c(r1_col2_new3)         ,
    .in_d(r1_col3_new4)         ,
    .out_a(r2_col4_new1_r)      ,
    .out_b(r2_col1_new2_r)      ,
    .out_c(r2_col2_new3_r)      ,
    .out_d(r2_col3_new4_r)      ,
    .finish(r2_col4_finish)
    );
 
/* 计数确保组合逻辑能够完成 */
always@(posedge clk)
begin
    if(rst==1'b1)
    begin
        counter <= {7{1'b0}};
    end
    else if(ts_chacha_req==1'b1)
    begin
        counter <= 7'b1;
    end
    else if(counter>=96)
    begin
        counter <= {7{1'b0}};
    end
    else if(counter>0)
    begin
        counter <=  counter + 'h1;
    end
end

always@(posedge clk)
begin
    if(rst==1'b1)
    begin
        r1_finish_r <= 1'b0;
    end
    else if((counter[2:0]==3'b000) && ((|counter)==1'b1))
    begin
        r1_finish_r <= 1'b1;
    end
    else
    begin
        r1_finish_r <= 1'b0;
    end
end

/* 对输出赋值 */
always@(posedge clk)
begin
    if(rst==1'b1)
    begin
        r2_col1_new1 <=  32'd0;
        r2_col1_new2 <=  32'd0;
        r2_col1_new3 <=  32'd0;
        r2_col1_new4 <=  32'd0;
        r2_col2_new1 <=  32'd0;
        r2_col2_new2 <=  32'd0;
        r2_col2_new3 <=  32'd0;
        r2_col2_new4 <=  32'd0;
        r2_col3_new1 <=  32'd0;
        r2_col3_new2 <=  32'd0;
        r2_col3_new3 <=  32'd0;
        r2_col3_new4 <=  32'd0;
        r2_col4_new1 <=  32'd0;
        r2_col4_new2 <=  32'd0;
        r2_col4_new3 <=  32'd0;
        r2_col4_new4 <=  32'd0;
    end
    else if(counter[2:0]==3'b000)
    begin
        r2_col1_new1 <=  r2_col1_new1_r;
        r2_col1_new2 <=  r2_col1_new2_r;
        r2_col1_new3 <=  r2_col1_new3_r;
        r2_col1_new4 <=  r2_col1_new4_r;
        r2_col2_new1 <=  r2_col2_new1_r;
        r2_col2_new2 <=  r2_col2_new2_r;
        r2_col2_new3 <=  r2_col2_new3_r;
        r2_col2_new4 <=  r2_col2_new4_r;
        r2_col3_new1 <=  r2_col3_new1_r;
        r2_col3_new2 <=  r2_col3_new2_r;
        r2_col3_new3 <=  r2_col3_new3_r;
        r2_col3_new4 <=  r2_col3_new4_r;
        r2_col4_new1 <=  r2_col4_new1_r;
        r2_col4_new2 <=  r2_col4_new2_r;
        r2_col4_new3 <=  r2_col4_new3_r;
        r2_col4_new4 <=  r2_col4_new4_r;
    end
end

assign  r1_finish =    r1_finish_r;

endmodule
