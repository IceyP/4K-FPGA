/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  cc_encryption.v
    Author       :  jiayunlong/2020
    ==================================================================================
    Description  :
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-07-11  jiayunlong/2020     1.0         RT20        Create     
    ==================================================================================
    Called by    :  cc_encryption.v
    File tree    :  cc_encryption.v  
	                 +----plus_xor.v   
						       +----quarter_round.v                        
\************************************************************************************/

`timescale 1ns/1ps 

module cc_encryption( 
    clk                                 , 
    rst                                 , 
    keyb                                , 

    ts_chacha_req                       , 
    ts_pid                              , 
    key_counter                         , 
    chacha_ts_ack                       , 

    key_valid                           , 
    key_data 
    ); 

parameter        [127:0] CONSTANT       = 128'h617078653120646e79622d366b206574  ; //常量657870616e642031362d62797465206b 
parameter        PRO_INTERVAL1          = 4                         ; 
input                                   clk                         ; //时钟信号 
input                                   rst                         ; //复位，高电平有效  
input   [127:0]                         keyb                        ; //k值，每60秒换一次 
input                                   ts_chacha_req               ; //ts请求信号 
input   [12:0]                          ts_pid                      ; 
output  [15:0]                          key_data                    ; //最终结果，即为密钥 
output  [23:0]                          key_counter                 ; //计数器，与包头对应，是加密开始的标志 
output                                  key_valid                   ; //判断密钥是否有效的信号，为1时代表信号有效 
output                                  chacha_ts_ack               ; 

wire    [31:0]                          r2_col1_new1                ; //2-round的计算结果 
wire    [31:0]                          r2_col1_new2                ; 
wire    [31:0]                          r2_col1_new3                ; 
wire    [31:0]                          r2_col1_new4                ; 
wire    [31:0]                          r2_col2_new1                ; 
wire    [31:0]                          r2_col2_new2                ; 
wire    [31:0]                          r2_col2_new3                ; 
wire    [31:0]                          r2_col2_new4                ; 
wire    [31:0]                          r2_col3_new1                ; 
wire    [31:0]                          r2_col3_new2                ; 
wire    [31:0]                          r2_col3_new3                ; 
wire    [31:0]                          r2_col3_new4                ; 
wire    [31:0]                          r2_col4_new1                ; 
wire    [31:0]                          r2_col4_new2                ; 
wire    [31:0]                          r2_col4_new3                ; 
wire    [31:0]                          r2_col4_new4                ;
wire    [31:0]                          s_r11                       ;
wire    [31:0]                          s_r12                       ;
wire    [31:0]                          s_r13                       ; 
wire    [31:0]                          s_r14                       ;
wire    [31:0]                          s_r21                       ;
wire    [31:0]                          s_r22                       ;
wire    [31:0]                          s_r23                       ;
wire    [31:0]                          s_r24                       ;
wire    [31:0]                          s_r31                       ;
wire    [31:0]                          s_r32                       ;
wire    [31:0]                          s_r33                       ;
wire    [31:0]                          s_r34                       ;
wire    [31:0]                          s_r41                       ;
wire    [31:0]                          s_r42                       ;
wire    [31:0]                          s_r43                       ;
wire    [31:0]                          s_r44                       ;
wire                                    r1_finish                   ; //2-round运算完成的标志，为1时表示完成，与底层模块相连 
reg     [3:0]                           round_cnt                   ; //finish每次为1时，加1，控制对plus_xor模块的4次调用 
reg     [23:0]                          counter_r64                 ; //64为计数器，round_cnt最大时加1 
reg     [23:0]                          key_counter                 ; 
reg     [511:0]                         B0                          ; //初始矩阵，相当于未进行算法之前的初始数据 
reg     [511:0]                         s_r                         ; //实现B0经过8-round变换后的B8与初始B0的模加运算
reg     [511:0]                         s_r_buf                     ;
reg                                     k_valid_r                   ;  
wire                                    chacha_ts_ack               ;

reg     [5:0]                           k_val_cnt                   ;

assign  chacha_ts_ack   =   1'b0;   //not used

/* 调用底层模块plus_xor */
plus_xor plus_xor_ins1(
    .clk                                ( clk                       ),
    .rst                                ( rst                       ),
	 .ts_chacha_req                     ( ts_chacha_req             ),
    .r0_col1_old1                       ( B0[511:480]               ),
    .r0_col1_old2                       ( B0[383:352]               ),
    .r0_col1_old3                       ( B0[255:224]               ),
    .r0_col1_old4                       ( B0[127:96]                ),
    .r0_col2_old1                       ( B0[479:448]               ),               
    .r0_col2_old2                       ( B0[351:320]               ),                
    .r0_col2_old3                       ( B0[223:192]               ),               
    .r0_col2_old4                       ( B0[95:64]                 ),                    
    .r0_col3_old1                       ( B0[447:416]               ),      
    .r0_col3_old2                       ( B0[319:288]               ),                
    .r0_col3_old3                       ( B0[191:160]               ),               
    .r0_col3_old4                       ( B0[63:32]                 ),
    .r0_col4_old1                       ( B0[415:384]               ),
    .r0_col4_old2                       ( B0[287:256]               ),                
    .r0_col4_old3                       ( B0[159:128]               ),               
    .r0_col4_old4                       ( B0[31:0]                  ),                
    .r2_col1_new1                       ( r2_col1_new1              ),
    .r2_col1_new2                       ( r2_col1_new2              ),
    .r2_col1_new3                       ( r2_col1_new3              ),
    .r2_col1_new4                       ( r2_col1_new4              ),
    .r2_col2_new1                       ( r2_col2_new1              ),
    .r2_col2_new2                       ( r2_col2_new2              ),
    .r2_col2_new3                       ( r2_col2_new3              ),
    .r2_col2_new4                       ( r2_col2_new4              ),    
    .r2_col3_new1                       ( r2_col3_new1              ),
    .r2_col3_new2                       ( r2_col3_new2              ),
    .r2_col3_new3                       ( r2_col3_new3              ),
    .r2_col3_new4                       ( r2_col3_new4              ),
    .r2_col4_new1                       ( r2_col4_new1              ),
    .r2_col4_new2                       ( r2_col4_new2              ),
    .r2_col4_new3                       ( r2_col4_new3              ),
    .r2_col4_new4                       ( r2_col4_new4              ),
    .r1_finish                          ( r1_finish                 )    
    );
                
/* 对round_cnt复位，+1 */
always@(posedge clk)
begin
    if(rst==1'b1)
    begin
        round_cnt <=  {4{1'b0}};
    end
    else if(ts_chacha_req==1'b1)
    begin
        round_cnt   <=  4'h1;
    end
    else if((round_cnt>0) && (r1_finish==1'b1))
    begin
        if(round_cnt==12)
        begin
            round_cnt <=  {4{1'b0}};
        end
        else
        begin
            round_cnt   <=  round_cnt + 'h1;
        end
    end
end

/* B0开始运算，调用4次模块 */
always@(posedge clk)
begin
    if (rst == 1'b1)
    begin
        B0 <=  512'd0;
    end
    else if((ts_chacha_req==1'b1) || (((round_cnt==4) || (round_cnt==8)) && (r1_finish==1'b1)))
    begin
        B0 <=  {CONSTANT[127:0], keyb[127:0],keyb[127:0],
                {8{1'b0}},counter_r64[23:0],{32{1'b0}}, 
                {32{1'b0}},ts_pid[7:0],{3{1'b0}},
                ts_pid[12],ts_pid[11:8],{16{1'b0}}};
    end
    else if(r1_finish==1'b1)
    begin
        B0 <=  {r2_col1_new1[31:0], r2_col2_new1[31:0], r2_col3_new1[31:0], r2_col4_new1[31:0], 
                r2_col1_new2[31:0], r2_col2_new2[31:0], r2_col3_new2[31:0], r2_col4_new2[31:0],
                r2_col1_new3[31:0], r2_col2_new3[31:0], r2_col3_new3[31:0], r2_col4_new3[31:0],
                r2_col1_new4[31:0], r2_col2_new4[31:0], r2_col3_new4[31:0], r2_col4_new4[31:0]}; 
    end
end

assign	s_r11 =  r2_col1_new1[31:0]+CONSTANT[127:96];
assign	s_r12 =  r2_col2_new1[31:0]+CONSTANT[95:64];
assign	s_r13 =  r2_col3_new1[31:0]+CONSTANT[63:32];
assign	s_r14 =  r2_col4_new1[31:0]+CONSTANT[31:0];
assign	s_r21 =  r2_col1_new2[31:0]+keyb[127:96]; 
assign	s_r22 =  r2_col2_new2[31:0]+keyb[95:64]; 
assign	s_r23 =  r2_col3_new2[31:0]+keyb[63:32]; 
assign	s_r24 =  r2_col4_new2[31:0]+keyb[31:0];
assign	s_r31 =  r2_col1_new3[31:0]+keyb[127:96]; 
assign	s_r32 =  r2_col2_new3[31:0]+keyb[95:64]; 
assign	s_r33 =  r2_col3_new3[31:0]+keyb[63:32]; 
assign	s_r34 =  r2_col4_new3[31:0]+keyb[31:0];
assign	s_r41 =  r2_col1_new4[31:0]+{{8{1'b0}},counter_r64[23:0]}-32'd1; 
assign	s_r42 =  r2_col2_new4[31:0]; 
assign	s_r43 =  r2_col3_new4[31:0]; 
assign	s_r44 =  r2_col4_new4[31:0]+{ts_pid[7:0],{3{1'b0}},ts_pid[12],ts_pid[11:8],{16{1'b0}}};

/* 实现B8与B0的模加 */ 
always@(posedge clk) 
begin 
    if (rst==1'b1) 
    begin 
        s_r <= 512'd0;
        k_valid_r<=1'b0; 
    end 
    else if((round_cnt[1:0]==2'b00) &&  ((|round_cnt)==1'b1) && (r1_finish==1'b1))
    begin 
        k_valid_r<=1'b1;
        s_r <= {{s_r11[7:0],s_r11[15:8],s_r11[23:16],s_r11[31:24]}, 
		          {s_r12[7:0],s_r12[15:8],s_r12[23:16],s_r12[31:24]}, 
		          {s_r13[7:0],s_r13[15:8],s_r13[23:16],s_r13[31:24]},
		          {s_r14[7:0],s_r14[15:8],s_r14[23:16],s_r14[31:24]}, 
		          {s_r21[7:0],s_r21[15:8],s_r21[23:16],s_r21[31:24]}, 
		          {s_r22[7:0],s_r22[15:8],s_r22[23:16],s_r22[31:24]}, 
		          {s_r23[7:0],s_r23[15:8],s_r23[23:16],s_r23[31:24]},
		          {s_r24[7:0],s_r24[15:8],s_r24[23:16],s_r24[31:24]},
		          {s_r31[7:0],s_r31[15:8],s_r31[23:16],s_r31[31:24]}, 
		          {s_r32[7:0],s_r32[15:8],s_r32[23:16],s_r32[31:24]}, 
		          {s_r33[7:0],s_r33[15:8],s_r33[23:16],s_r33[31:24]},
		          {s_r34[7:0],s_r34[15:8],s_r34[23:16],s_r34[31:24]},
		          {s_r41[7:0],s_r41[15:8],s_r41[23:16],s_r41[31:24]}, 
		          {s_r42[7:0],s_r42[15:8],s_r42[23:16],s_r42[31:24]}, 
		          {s_r43[7:0],s_r43[15:8],s_r43[23:16],s_r43[31:24]},
		          {s_r44[7:0],s_r44[15:8],s_r44[23:16],s_r44[31:24]}};
	 end
	 else
	 begin
	     k_valid_r<=1'b0;
	 end
end 


/* 64位计数器，round_cnt最大时加1 */ 
always@(posedge clk) 
begin
    if(rst==1'b1)
    begin
        counter_r64 <= {24{1'b0}};
    end
    else if(((round_cnt==3) || (round_cnt==7) || (round_cnt==11) || (round_cnt==12)) && (r1_finish==1'b1))
    begin
        counter_r64 <= counter_r64 + 'h1;
    end
end 

always@(posedge clk) 
begin 
    if(rst==1'b1)
    begin
        key_counter <=  {24{1'b0}};
    end
    else if(ts_chacha_req==1'b1)
    begin
        key_counter <=  counter_r64;
    end
end

always@(posedge clk) 
begin 
    if(rst==1'b1)
    begin
        s_r_buf <=  {512{1'b0}};
    end
    else if(k_valid_r==1'b1) 
    begin 
        s_r_buf <= s_r; 
    end 
    else
    begin 
        //s_r_buf <= {16'h0000,s_r_buf[511:32],s_r_buf[31:16]}; 
        s_r_buf <= {s_r_buf[495:0],16'h0000};
    end 
end 

always@(posedge clk) 
begin 
    if(rst==1'b1)
    begin
        k_val_cnt   <=  {6{1'b0}};
    end
    else if(k_valid_r==1'b1)
    begin
        k_val_cnt   <=  6'b1;
    end
    else if(k_val_cnt[5]==1'b1)
    begin
        k_val_cnt   <=  {6{1'b0}};
    end
    else if(k_val_cnt>0)
    begin
        k_val_cnt   <=  k_val_cnt + 'h1;
    end
end

assign  key_data    =   s_r_buf[511:496];
assign  key_valid   =   (k_val_cnt>0)   ?   1'b1    :   1'b0;

endmodule

