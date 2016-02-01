/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   Creative Center,R&D Hardware Department
    Filename     :   filter_ctrl.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :   
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-12-30  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :   filter_ctrl.v
    File tree    :   filter_ctrl.v
\************************************************************************************/

`timescale 1ns/100ps

module filter_ctrl(
    clk                         ,
    rst                         ,
    ts_valid                    ,
    ts_data                     ,
    ts_sop                      ,
    ts_eop                      ,
    all_pid_cfg                 ,
                                
    pid_find                    ,
    pid_index                   ,
    pid_raddr                   ,
    pid_rdata                   ,
    filter_eop                  ,
    dram_waddr                  
    );

////////////////////////////////////////////////////////////////////        
//data format:{chacha_except_index[2:0],tuner_index[1:0],pid_filter_enable,pid_descram_enable,filter_pid[12:0]}
////////////////////////////////////////////////////////////////////
//read latency=2        
parameter   PIDRAM_DEPTH_BIT            = 7                         ;
parameter   PIDRAM_DATA_WIDTH           = 21                        ;
parameter   TOTAL_CHN_NUM               = 3                         ;

parameter   ST_WIDTH                    = 3                         ;
parameter   ST_IDLE                     = 3'b001                    ,
            ST_PID_SEARCH               = 3'b010                    ,
            ST_SEARCH_END               = 3'b100                    ;

input                                   clk                         ;
input                                   rst                         ;
input                                   ts_valid                    ;
input   [7:0]                           ts_data                     ;
input                                   ts_sop                      ;
input                                   ts_eop                      ;
input   [TOTAL_CHN_NUM - 1 : 0]         all_pid_cfg                 ;

output                                  pid_find                    ;
output  [11:0]                          pid_index                   ;
output  [PIDRAM_DEPTH_BIT - 1 : 0]      pid_raddr                   ;
input   [PIDRAM_DATA_WIDTH - 1 : 0]     pid_rdata                   ;
output                                  filter_eop                  ;
output  [8:0]                           dram_waddr                  ;

reg     [ST_WIDTH - 1 : 0]              st_curr                     ;
reg     [ST_WIDTH - 1 : 0]              st_next                     ;

reg     [7:0]                           word_cnt                    ;
reg     [12:0]                          ts_pid                      ;
reg     [1:0]                           tuner_index                 ;
reg     [7:0]                           search_cnt                  ;
reg     [6:0]                           pid_match_index             ;
reg     [1:0]                           pid_match_type              ;
wire    [7:0]                           pid_index_buf               ;
wire    [12:0]                          ram_pid                     ;
wire                                    pid_descram_ena             ;
wire                                    pid_filter_ena              ;
wire    [1:0]                           ram_tuner_index             ;
reg                                     null_packet                 ;

reg                                     ts_eop_1dly                 ;
reg                                     ts_eop_2dly                 ;
reg                                     s_flag                      ;
wire                                    filter_eop                  ;
wire                                    pid_find                    ;
wire    [11:0]                          pid_index                   ;
wire    [8:0]                           dram_waddr                  ;
wire    [3:0]                           chacha_except_index         ;
reg     [3:0]                           chacha_except_idx           ;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        word_cnt    <=  {8{1'b0}};
    end
    else if(ts_sop==1'b1)
    begin
        word_cnt    <=  8'h01;
    end
    else if(ts_eop==1'b1)
    begin
        word_cnt    <= {8{1'b0}};
    end
    else if((ts_valid==1'b1) && (word_cnt>0))
    begin
        word_cnt    <=  word_cnt + 'h1;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tuner_index <=  2'b00;
    end
    else if(ts_sop==1'b1)
    begin
        tuner_index <=  ts_data[1:0];
        //case(ts_data[7:0])
        //8'h40   :   tuner_index <=  2'b00;
        //8'h41   :   tuner_index <=  2'b01;
        //8'h42   :   tuner_index <=  2'b10;
        //8'h43   :   tuner_index <=  2'b11;
        //default:;
        //endcase
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_pid          <=  {13{1'b0}};
    end
    else if(ts_valid==1'b1)
    begin
        if(word_cnt==1)
        begin
            ts_pid[12:8]    <=  ts_data[4:0];
        end
        else if(word_cnt==2)
        begin
            ts_pid[7:0]     <=  ts_data[7:0];
        end
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        null_packet <=  1'b0;
    end
    else if((ts_valid==1'b1) && (word_cnt==3) && (ts_pid==13'h1fff))
    begin
        null_packet <=  1'b1;
    end
    else if(ts_eop==1'b1)
    begin
        null_packet <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        st_curr <=  ST_IDLE;
    end
    else 
    begin
        st_curr <=  st_next;
    end
end

always@*
begin
    case(st_curr)
    ST_IDLE:
    begin
        if((ts_valid==1'b1) && (word_cnt==3))
        begin
            st_next =   ST_PID_SEARCH;
        end
        else
        begin
            st_next =   ST_IDLE;
        end
    end
    ST_PID_SEARCH:
    begin
        if((search_cnt<129) && (pid_match_type==2'b00))
        begin
            st_next =   ST_PID_SEARCH;
        end
        else
        begin
            st_next =   ST_SEARCH_END;
        end
    end
    ST_SEARCH_END:
    begin
        if(ts_eop==1'b1)
        begin
            st_next =   ST_IDLE;
        end
        else
        begin
            st_next =   ST_SEARCH_END;
        end
    end
    default:
    begin
        st_next =   ST_IDLE;
    end
    endcase
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        search_cnt  <=  {8{1'b0}};
    end
    else if(st_curr==ST_PID_SEARCH)
    begin
        search_cnt  <=  search_cnt + 'h1;
    end
    else
    begin
        search_cnt  <=  {8{1'b0}};
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        pid_match_index     <=  {7{1'b0}};
        pid_match_type      <=  2'b00;              //not match
        chacha_except_idx   <=  4'h0; 
    end
    else if((st_curr==ST_PID_SEARCH) && (search_cnt>1) && (pid_match_type==2'b00))
    begin
        if(all_pid_cfg[tuner_index]==1'b0)      //not all pid filter
        begin
            if((tuner_index==ram_tuner_index) && (ts_pid==ram_pid) && (pid_filter_ena==1'b1))
            begin
                if(pid_descram_ena==1'b1)
                begin
                    pid_match_type  <=  2'b01;  //descramble
                end
                else
                begin
                    pid_match_type  <=  2'b10;  //not descramble;
                end
                pid_match_index     <=  pid_index_buf[6:0];
                chacha_except_idx   <=  chacha_except_index;
            end
            else
            begin
                pid_match_type      <=  2'b00;
            end
        end
        else                                    //all pid filter
        begin
            if((tuner_index==ram_tuner_index) && (ts_pid==ram_pid) && (pid_filter_ena==1'b1) && (pid_descram_ena==1'b1))
            begin
                pid_match_type      <=  2'b01;
                pid_match_index     <=  pid_index_buf[6:0];
                chacha_except_idx   <=  chacha_except_index;
            end
            else if((search_cnt==129) && (null_packet==1'b0))
            begin
                pid_match_type      <=  2'b10;
            end
        end
    end
    else if(st_curr==ST_IDLE)
    begin
        pid_match_type  <=  2'b00;
    end
end

assign  pid_raddr           =   search_cnt[PIDRAM_DEPTH_BIT - 1 : 0];
assign  pid_index_buf       =   search_cnt - 8'h02;

assign  ram_pid             =   pid_rdata[12:0];
assign  pid_descram_ena     =   pid_rdata[13];
assign  pid_filter_ena      =   pid_rdata[14];
assign  ram_tuner_index     =   pid_rdata[16:15];
assign  chacha_except_index =   pid_rdata[20:17];

////////////////////////////////////////////////////////////////////
//output
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_eop_1dly <=  1'b0;
        ts_eop_2dly <=  1'b0;
    end
    else
    begin
        ts_eop_1dly <=  ts_eop;
        ts_eop_2dly <=  ts_eop_1dly;
    end
end 

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        s_flag  <=  1'b0;
    end
    else if(ts_eop_2dly==1'b1)
    begin
        s_flag  <=  ~s_flag;
    end
end

assign  filter_eop  =   ts_eop_1dly;
assign  pid_find    =   |pid_match_type;
assign  pid_index   =   {chacha_except_idx[3:0],pid_match_type[0],pid_match_index[6:0]};
assign  dram_waddr  =   {s_flag,word_cnt[7:0]};

endmodule   
