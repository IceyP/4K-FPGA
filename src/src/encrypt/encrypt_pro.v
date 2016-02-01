/*************************************************************************************\
    Copyright(c) 2015, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  encrypt_pro.v
    Author       :  huangrui/1480
    ==================================================================================
    Description  :  cbus read latency = 4;
                    ts_i_index[11]:chacha bypass enable;
                    ts_i_index[10:8]:chacha bypass search index;
                    ts_i_index[7]:descramble enable bit;
                    ts_i_index[6:0]:pid_match_index;  
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2015-01-08  huangrui/1480       1.0         rt20        Create
    ==================================================================================
    Called by    :  encrypt_pro.v
    File tree    :  encrypt_pro.v                        
\************************************************************************************/

`timescale 1ns/100ps

module encrypt_pro(
    clk                         ,    
    rst                         ,
    ts_i_valid                  , 
    ts_i_data                   ,
    ts_i_sop                    ,
    ts_i_eop                    ,
    ts_i_index                  ,
    buf_bp                      ,   //0:full,1:not full
    chacha_enable               ,
                                
    ts_valid                    ,
    ts_data                     ,
    ts_eop                      ,
    ts_rdy                      ,
    ts_ack                      ,
    
    tdes_enable                 ,
    tdes_chacha_wren            ,
    tdes_chacha_waddr           ,
    tdes_chacha_wdata           ,
    
    cbus_addr                   ,
    cbus_we                     ,
    cbus_oe                     ,
    cbus_wdata                  ,
    cbus_rdata
    );       

parameter   CBUS_ADDR_WIDTH             = 12                        ;
parameter   CBUS_DATA_WIDTH             = 8                         ;
parameter   DATARAM_DEPTHBIT            = 12                        ;
parameter   INFO_FIFO_WIDTH             = 44                        ;

parameter   ST_WIDTH                    = 5                         ;
parameter   ST_IDLE                     = 5'b0_0001                 ,
            ST_RD_INFO_FIFO             = 5'b0_0010                 ,
            ST_PKT_HEAD                 = 5'b0_0100                 ,
            ST_TS_ENCRYPT               = 5'b0_1000                 ,
            ST_END                      = 5'b1_0000                 ;
            
input                                   clk                         ;
input                                   rst                         ;
input                                   ts_i_valid                  ;
input   [7:0]                           ts_i_data                   ;
input                                   ts_i_sop                    ;
input                                   ts_i_eop                    ;
input   [11:0]                          ts_i_index                  ;
output                                  buf_bp                      ;
input                                   chacha_enable               ;

output                                  ts_valid                    ;
output  [7:0]                           ts_data                     ;
output                                  ts_eop                      ;
output                                  ts_rdy                      ;
input                                   ts_ack                      ;

input                                   tdes_enable                 ;
input                                   tdes_chacha_wren            ;
input   [10:0]                          tdes_chacha_waddr           ;
input   [7:0]                           tdes_chacha_wdata           ;

input   [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr                   ;
input   [CBUS_DATA_WIDTH - 1 : 0]       cbus_wdata                  ;
input                                   cbus_we                     ;
input                                   cbus_oe                     ;
output  [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;

reg                                     info_fifo_wren              ;
reg     [INFO_FIFO_WIDTH - 1 : 0]       info_fifo_din               ;
wire    [INFO_FIFO_WIDTH - 1 : 0]       info_fifo_dout              ;
wire                                    info_fifo_rden              ;
wire                                    info_fifo_full              ;
wire                                    info_fifo_empty             ;
wire    [4:0]                           info_fifo_data_cnt          ;
reg                                     datram_wren                 ;
reg     [DATARAM_DEPTHBIT - 1 : 0]      datram_waddr                ;
reg     [7:0]                           datram_wdata                ;
reg     [DATARAM_DEPTHBIT - 1 : 0]      datram_raddr                ;
wire    [7:0]                           datram_rdata                ;
wire                                    keyram_wren                 ;
reg     [8:0]                           keyram_waddr                ;
wire    [15:0]                          keyram_wdata                ;
reg     [9:0]                           keyram_raddr                ;
wire    [7:0]                           keyram_rdata                ;

reg     [DATARAM_DEPTHBIT - 1 : 0]      start_addr                  ;
reg     [1:0]                           tuner_index                 ;

reg     [127:0]                         keyb_buf                    ;
wire    [127:0]                         keyb                        ;
wire                                    chacha_ts_ack               ;
wire                                    key_valid                   ;
wire    [15:0]                          key_data                    ;
wire    [23:0]                          key_counter                 ;
reg     [12:0]                          ts_pid                      ;
reg                                     ts_chaha_req                ;

reg     [ST_WIDTH - 1 : 0]              st_curr                     ;
reg     [ST_WIDTH - 1 : 0]              st_next                     ;

wire    [23:0]                          chacha_counter              ;
wire    [1:0]                           tuner_channel               ;
wire    [DATARAM_DEPTHBIT - 1 : 0]      ts_start_addr               ;
reg     [7:0]                           sc_byte_cnt                 ;

reg     [7:0]                           ts_data                     ;
reg                                     ts_valid                    ;
reg                                     ts_eop                      ;
reg                                     ts_rdy                      ;
reg     [7:0]                           byte_cnt                    ;
reg                                     ts_i_sop_1dly               ;
wire                                    chacha_encrypt_ena          ;
reg                                     descram_flag                ;
reg     [4:0]                           chacha_scram_ctrl           ;
wire    [3:0]                           chacha_encrypt_period       ;
reg     [3:0]                           chacha_bypass_index         ;
reg     [6:0]                           pid_index                   ;
reg     [7:0]                           ts_i_data_buf               ;
reg                                     ts_i_valid_1dly             ;
reg     [15:0]                          chacha_bypass_match_bytemap ;
wire    [7:0]                           match_byte_index_buf        ;
wire    [3:0]                           match_byte_index            ;
reg     [3:0]                           chacha_bypass_counter       ;
reg                                     chacha_bypass_match         ;
wire                                    chacha_bypass_match_flag    ;
reg     [1:0]                           pkt_type                    ;
reg                                     buf_bp                      ;

reg                                     pkt_counter_ram_wea         ;
wire    [6:0]                           pkt_counter_ram_addra       ;
reg     [7:0]                           pkt_counter_ram_dina        ;
wire    [6:0]                           pkt_counter_ram_addrb       ;
wire    [7:0]                           pkt_counter_ram_doutb       ;

wire    [6:0]                           chacha_bypass_ram_raddr     ;
wire    [7:0]                           chacha_bypass_data          ;
wire    [7:0]                           chacha_bypass_mask          ;
wire    [10:0]                          chacha_cwram_raddr          ;
wire    [7:0]                           chacha_cwram_rdata          ;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        buf_bp  <=  1'b1;
    end
    else if(info_fifo_data_cnt>19)
    begin
        buf_bp  <=  1'b0;
    end
    else
    begin
        buf_bp  <=  1'b1;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        byte_cnt    <=  {8{1'b0}};
    end
    else if(ts_i_sop==1'b1)
    begin
        byte_cnt    <=  8'h01;
    end
    else if(ts_i_eop==1'b1)
    begin
        byte_cnt    <=  {8{1'b0}};
    end
    else if((ts_i_valid==1'b1) && (|byte_cnt==1'b1))
    begin
        byte_cnt    <=  byte_cnt + 8'h01;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_i_sop_1dly   <=  1'b0;
    end
    else
    begin
        ts_i_sop_1dly   <=  ts_i_sop;
    end
end

//info fifo din parameter
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        start_addr  <=  {DATARAM_DEPTHBIT{1'b0}};
    end
    else if(ts_i_sop_1dly==1'b1)
    begin
        start_addr  <=  datram_waddr;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tuner_index <=  2'b00;
    end
    else if(ts_i_sop==1'b1)
    begin
        tuner_index <=  ts_i_data[1:0];
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        descram_flag        <=  1'b0;
        chacha_bypass_index <=  {4{1'b0}};
        pid_index           <=  {7{1'b0}};
    end
    else if((ts_i_sop==1'b1) && (ts_i_data[3]==1'b1))
    begin
        descram_flag        <=  1'b1;   //ts_i_index[7]
        chacha_bypass_index <=  ts_i_index[11:8];
        pid_index           <=  ts_i_index[6:0];
    end
    else if(ts_i_eop==1'b1)
    begin
        descram_flag        <=  1'b0;
        chacha_bypass_index <=  {4{1'b0}};
        pid_index           <=  {7{1'b0}};
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_pid  <=  {13{1'b0}};
    end
    else if(ts_i_valid==1'b1)
    begin
        if(byte_cnt==1)
        begin
            ts_pid[12:8]    <=  ts_i_data[4:0];
        end
        else if(byte_cnt==2)
        begin
            ts_pid[7:0]     <=  ts_i_data;
        end
    end
end


//info fifo write
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        info_fifo_wren  <=  1'b0;
    end
    else if(ts_i_eop==1'b1)
    begin
        info_fifo_wren  <=  1'b1;
    end
    else 
    begin
        info_fifo_wren  <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        info_fifo_din   <=  {INFO_FIFO_WIDTH{1'b0}};
    end
    else if(ts_i_eop==1'b1)
    begin
        info_fifo_din   <=  {1'b0,chacha_scram_ctrl[4:0],start_addr[DATARAM_DEPTHBIT - 1 : 0],tuner_index[1:0],key_counter[23:0]};
    end
end

//info fifo read
assign  info_fifo_rden          =   (st_curr==ST_RD_INFO_FIFO)  ?   1'b1    :   1'b0;
assign  chacha_counter          =   info_fifo_dout[23:0];
assign  tuner_channel           =   info_fifo_dout[25:24];
assign  ts_start_addr           =   info_fifo_dout[(25+DATARAM_DEPTHBIT):26];
assign  chacha_encrypt_period   =   info_fifo_dout[41:38];
assign  chacha_encrypt_ena      =   info_fifo_dout[42];
        
//ts data ram write
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        datram_wdata    <=  {8{1'b0}};
    end
    else
    begin
        datram_wdata    <=  ts_i_data;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        datram_wren <=  1'b0;
    end
    else
    begin
        datram_wren <=  ts_i_valid;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        datram_waddr    <=  {DATARAM_DEPTHBIT{1'b0}};
    end
    else if(datram_wren==1'b1)
    begin
        datram_waddr    <=  datram_waddr + 'h1;
    end
end

//ts data ram read
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        datram_raddr    <=  {DATARAM_DEPTHBIT{1'b0}};
    end
    else if((st_curr==ST_PKT_HEAD) && (sc_byte_cnt==3))
    begin
        datram_raddr    <=  ts_start_addr;
    end
    else if(st_curr==ST_TS_ENCRYPT)
    begin
        datram_raddr    <=  datram_raddr + 'h1;
    end
end

//key ram write
assign  keyram_wren     =   key_valid;
assign  keyram_wdata    =   {key_data[7:0],key_data[15:8]};

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        keyram_waddr    <=  {9{1'b0}};
    end
    else if(keyram_wren==1'b1)
    begin
        keyram_waddr    <=  keyram_waddr + 9'b1;
    end
end

//key ram read
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        keyram_raddr    <=  {10{1'b0}};
    end
    else if((chacha_encrypt_ena==1'b1) && (st_curr==ST_TS_ENCRYPT))
    begin
        if(sc_byte_cnt==7)
        begin
            keyram_raddr    <=  keyram_raddr + 'h8;
        end 
        else if((sc_byte_cnt>7) && (sc_byte_cnt<192))
        begin
            keyram_raddr    <=  keyram_raddr + 10'b1;
        end
    end
end

//ts output state machine
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
        if(ts_ack==1'b1)
        begin
            st_next =   ST_RD_INFO_FIFO;
        end
        else
        begin
            st_next =   ST_IDLE;
        end
    end
    ST_RD_INFO_FIFO:
    begin
        st_next =   ST_PKT_HEAD;
    end
    ST_PKT_HEAD:
    begin
        if(sc_byte_cnt==3)
        begin
            st_next =   ST_TS_ENCRYPT;
        end
        else
        begin
            st_next =   ST_PKT_HEAD;
        end
    end
    ST_TS_ENCRYPT:
    begin
        if(sc_byte_cnt==193)
        begin
            st_next =   ST_END;
        end
        else
        begin
            st_next =   ST_TS_ENCRYPT;
        end
    end
    ST_END:
    begin
        st_next =   ST_IDLE;
    end
    default:
    begin
        st_next =   ST_IDLE;
    end
    endcase
end

//packet head
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        sc_byte_cnt <=  {8{1'b0}};
    end
    else if((st_curr==ST_PKT_HEAD) || (st_curr==ST_TS_ENCRYPT))
    begin
        sc_byte_cnt <=  sc_byte_cnt + 8'h01;
    end
    else
    begin
        sc_byte_cnt <=  {8{1'b0}};
    end
end

////////////////////////////////////////////////////////////////////
//slave fifo output
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_data 			<=  	{8{1'b0}};
    end
    else if(st_curr==ST_PKT_HEAD)
    begin
        case(sc_byte_cnt)
        //pkt_type=2'b00:no chacha encrypt;=2'b01:chacha bypass;=2'b10:chacha encrypt;=2'b11:ca message
        8'h00:  ts_data <=  {pkt_type[1:0],tuner_channel[1:0],chacha_encrypt_period[3:0]};
        8'h01:  ts_data <=  chacha_counter[23:16];
        8'h02:  ts_data <=  chacha_counter[15:8];
        8'h03:  ts_data <=  chacha_counter[7:0];
        default:ts_data <=  {8{1'b0}};
        endcase
    end
    else if(st_curr==ST_TS_ENCRYPT)
    begin
        if(sc_byte_cnt==6)
        begin
            ts_data <=  8'h47;
        end
        else if(chacha_encrypt_ena==1'b1)
        begin
          if((sc_byte_cnt>9) && (sc_byte_cnt<194)) // commented. because this founction is encypt every packet
            begin
                ts_data <=  datram_rdata ^ keyram_rdata;
            end
            else
            begin
                ts_data <=  datram_rdata;
            end
        end
        else
        begin
            ts_data <=  datram_rdata;
        end
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_valid   <=  1'b0;
    end
    else if((st_curr==ST_PKT_HEAD) || ((st_curr==ST_TS_ENCRYPT) && (sc_byte_cnt>5)))
    begin
        ts_valid   <=  1'b1;
    end
    else
    begin
        ts_valid   <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_eop  <=  1'b0;
    end
    else if((st_curr==ST_TS_ENCRYPT) && (sc_byte_cnt==193))
    begin
        ts_eop  <=  1'b1;
    end
    else
    begin
        ts_eop  <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_rdy  <=  1'b0;
    end
    else if(info_fifo_data_cnt>0)
    begin
        ts_rdy  <=  1'b1;
    end
    else
    begin
        ts_rdy  <=  1'b0;
    end
end

////////////////////////////////////////////////////////////////////
//chacha encrypt bypass judge
////////////////////////////////////////////////////////////////////
assign  chacha_bypass_ram_raddr =   {ts_i_index[10:8],byte_cnt[3:0]};

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_i_data_buf   <=  {8{1'b0}};
    end
    else if(ts_i_valid==1'b1)
    begin
        ts_i_data_buf   <=  ts_i_data;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_i_valid_1dly <=  1'b0;
    end
    else
    begin
        ts_i_valid_1dly <=  ts_i_valid;
    end
end

assign  match_byte_index_buf    =   byte_cnt - 'h1;
assign  match_byte_index        =   match_byte_index_buf[3:0];

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        chacha_bypass_match_bytemap <=  {16{1'b0}};
    end
    else if((ts_i_valid_1dly==1'b1) && (byte_cnt>0) && (byte_cnt<17))
    begin
        if((ts_i_data_buf & chacha_bypass_mask)==(chacha_bypass_data & chacha_bypass_mask))
        begin
            chacha_bypass_match_bytemap[match_byte_index]   <=  1'b1;
        end
        else
        begin
            chacha_bypass_match_bytemap[match_byte_index]   <=  1'b0;
        end
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        chacha_bypass_counter   <=  {4{1'b0}};
    end
    else if((ts_i_valid_1dly==1'b1) && (byte_cnt==1))
    begin
        chacha_bypass_counter   <=  chacha_bypass_data[3:0];
    end
end

////////////////////////////////////////////////////////////////////
//chacha encrypt bypass counter ram write and read
////////////////////////////////////////////////////////////////////
assign  chacha_bypass_match_flag    =   &{chacha_bypass_match_bytemap[15:0],chacha_bypass_index[3]}; 

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        chacha_bypass_match <=  1'b0;
    end
    else if((ts_i_valid==1'b1) && (byte_cnt==17) && (chacha_bypass_match_flag==1'b1))
    begin
        chacha_bypass_match <=  1'b1;
    end
    else if(ts_i_eop==1'b1)
    begin
        chacha_bypass_match <=  1'b0;
    end
end

//always@(posedge clk or posedge rst)
//begin
//    if(rst==1'b1)
//    begin
//        pkt_counter_ram_wea     <=  1'b0;
//        pkt_counter_ram_dina    <=  {8{1'b0}};
//        ts_chaha_req            <=  1'b0;
//        pkt_type                <=  2'b00;
//    end
//    else if((ts_i_valid==1'b1) && (byte_cnt==18) && (descram_flag==1'b1) && (chacha_enable==1'b1))
//    begin
//        if(chacha_bypass_match==1'b1)
//        begin
//            pkt_counter_ram_wea     <=  1'b1;
//            pkt_counter_ram_dina    <=  {{4{1'b0}},chacha_bypass_counter[3:0]};
//            ts_chaha_req            <=  1'b0;
//            pkt_type                <=  2'b01;
//        end
//        else if((chacha_bypass_index[3]==1'b1) && (pkt_counter_ram_doutb>0))
//        begin
//            pkt_counter_ram_wea     <=  1'b1;
//            pkt_counter_ram_dina    <=  pkt_counter_ram_doutb - 'h1;
//            ts_chaha_req            <=  1'b0;
//            pkt_type                <=  2'b01;
//        end
//        else 
//        begin
//            pkt_counter_ram_wea     <=  1'b0;
//            ts_chaha_req            <=  1'b1;
//            pkt_type                <=  2'b10;
//        end
//    end
//    else
//    begin
//        pkt_counter_ram_wea     <=  1'b0;
//        ts_chaha_req            <=  1'b0;
//        pkt_type                <=  2'b00;
//    end
//end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        pkt_counter_ram_wea     <=  1'b0;
        pkt_counter_ram_dina    <=  {8{1'b0}};
        ts_chaha_req            <=  1'b0;
        pkt_type                <=  2'b00;
    end
    else if((ts_i_valid==1'b1) && (byte_cnt==18))
    begin
        if((descram_flag==1'b1) && (chacha_enable==1'b1))
		  begin
            if(chacha_bypass_match==1'b1)
            begin
                pkt_counter_ram_wea     <=  1'b1;
                pkt_counter_ram_dina    <=  {{4{1'b0}},chacha_bypass_counter[3:0]};
                ts_chaha_req            <=  1'b0;
                pkt_type                <=  2'b01;
            end
            else if((chacha_bypass_index[3]==1'b1) && (pkt_counter_ram_doutb>0))
            begin
                pkt_counter_ram_wea     <=  1'b1;
                pkt_counter_ram_dina    <=  pkt_counter_ram_doutb - 'h1;
                ts_chaha_req            <=  1'b0;
                pkt_type                <=  2'b01;
            end
            else 
            begin
                pkt_counter_ram_wea     <=  1'b0;
					 ts_chaha_req            <=  1'b1;
					 pkt_type                <=  2'b10;
            end
        end
        else
        begin
            pkt_counter_ram_wea     <=  1'b0;
            ts_chaha_req            <=  1'b0;
            pkt_type                <=  2'b00;
        end
    end
    else
    begin
        pkt_counter_ram_wea     <=  1'b0;
        ts_chaha_req            <=  1'b0;
    end
end


assign  pkt_counter_ram_addra   =   pid_index;
assign  pkt_counter_ram_addrb   =   pid_index;
            
////////////////////////////////////////////////////////////////////
//chacha encrypt key
////////////////////////////////////////////////////////////////////
assign  chacha_cwram_raddr  =   {ts_i_index[6:0],byte_cnt[3:0]};

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        keyb_buf    <=  128'hc0c1c2c3c4c5c6c7c8c9cacbcccdcecf;
    end
    else if((ts_i_valid_1dly==1'b1) && (byte_cnt>0) && (byte_cnt<17))
    begin
        keyb_buf    <=  {keyb_buf[119:0],chacha_cwram_rdata[7:0]};
    end
end

assign  keyb    =   {keyb_buf[103:96],keyb_buf[111:104],keyb_buf[119:112],keyb_buf[127:120],
                     keyb_buf[71:64],keyb_buf[79:72],keyb_buf[87:80],keyb_buf[95:88],
                     keyb_buf[39:32],keyb_buf[47:40],keyb_buf[55:48],keyb_buf[63:56],
                     keyb_buf[7:0],keyb_buf[15:8],keyb_buf[23:16],keyb_buf[31:24]};
                     
////////////////////////////////////////////////////////////////////
//chacha encrypt or not
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        chacha_scram_ctrl   <=  {5{1'b0}};
    end
    else if(ts_chaha_req==1'b1)
    begin
        chacha_scram_ctrl   <=  {1'b1,keyb_buf[3:0]};
    end
    else if(ts_i_eop==1'b1)
    begin
        chacha_scram_ctrl   <=  {5{1'b0}};
    end
end

//generate chacha encrypt key
cc_encryption u0_cc_encryption(
    .clk                                ( clk                       ),
    .rst                                ( rst                       ),
    .keyb                               ( keyb                      ),
    
    .ts_chacha_req                      ( ts_chaha_req              ),
    .ts_pid                             ( ts_pid                    ),
    .key_counter                        ( key_counter               ),
    .chacha_ts_ack                      ( chacha_ts_ack             ),  //not used
    
    .key_valid                          ( key_valid                 ),
    .key_data                           ( key_data                  )
    );

//chacha cw and bypass config
encrypt_cfg #(
    .CBUS_ADDR_WIDTH                    ( CBUS_ADDR_WIDTH           ),
    .CBUS_DATA_WIDTH                    ( CBUS_DATA_WIDTH           )
    )
u0_encrypt_cfg(
    .clk                                ( clk                       ),
    .rst                                ( rst                       ),
    .chacha_bypass_ram_raddr            ( chacha_bypass_ram_raddr   ),
    .chacha_bypass_data                 ( chacha_bypass_data        ),
    .chacha_bypass_mask                 ( chacha_bypass_mask        ),
    .chacha_cwram_raddr                 ( chacha_cwram_raddr        ),
    .chacha_cwram_rdata                 ( chacha_cwram_rdata        ),
    
    .tdes_enable                        ( tdes_enable               ),
    .tdes_chacha_wren                   ( tdes_chacha_wren          ),
    .tdes_chacha_waddr                  ( tdes_chacha_waddr         ),
    .tdes_chacha_wdata                  ( tdes_chacha_wdata         ),
    
    .cbus_addr                          ( cbus_addr                 ),
    .cbus_we                            ( cbus_we                   ),
    .cbus_oe                            ( cbus_oe                   ),
    .cbus_wdata                         ( cbus_wdata                ),
    .cbus_rdata                         ( cbus_rdata                )
    );
    
////////////////////////////////////////////////////////////////////
//chacha encrypt key ram
////////////////////////////////////////////////////////////////////    
//key ram,read latency=2
sdpram_w16d512 u0_keyram(
    .clka                               ( clk                       ),
    .wea                                ( keyram_wren               ),
    .addra                              ( keyram_waddr              ),
    .dina                               ( keyram_wdata              ),
    .clkb                               ( clk                       ),
    .addrb                              ( keyram_raddr              ),
    .doutb                              ( keyram_rdata              )
    );

////////////////////////////////////////////////////////////////////
//ts fifo+ram
////////////////////////////////////////////////////////////////////    
//block ram,read latency=1
syncfifo_w44d32 u0_info_fifo(
    .clk                                ( clk                       ),
    .din                                ( info_fifo_din             ),
    .wr_en                              ( info_fifo_wren            ),
    .rd_en                              ( info_fifo_rden            ),
    .dout                               ( info_fifo_dout            ),
    .full                               ( info_fifo_full            ),
    .empty                              ( info_fifo_empty           ),
    .data_count                         ( info_fifo_data_cnt        )
    );

//block ram,read latency=2,also used as usb-chip slavefifo buffer
sdpram_w8d4096 u0_datram(
    .clka                               ( clk                       ),
    .wea                                ( datram_wren               ),
    .addra                              ( datram_waddr              ),
    .dina                               ( datram_wdata              ),
    .clkb                               ( clk                       ),
    .addrb                              ( datram_raddr              ),
    .doutb                              ( datram_rdata              )
    );

//chacha bypass counter ram
//read latency=2;
sdpram_w8d128 u0_chacha_bypass_counter_ram(
    .clka                               ( clk                       ),
    .wea                                ( pkt_counter_ram_wea       ),
    .addra                              ( pkt_counter_ram_addra     ),
    .dina                               ( pkt_counter_ram_dina      ),
    .clkb                               ( clk                       ),
    .addrb                              ( pkt_counter_ram_addrb     ),
    .doutb                              ( pkt_counter_ram_doutb     )
    ); 

              
endmodule    
