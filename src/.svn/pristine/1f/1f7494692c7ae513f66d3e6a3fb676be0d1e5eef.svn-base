/*************************************************************************************\
    Copyright(c) 2015, China Digital TV Holding Co., Ltd,All right reserved
    Department   :  Creative Center,R&D Hardware Department
    Filename     :  security_module.v
    Author       :  huangrui/1480
    ==================================================================================
    Description  :  cbus read latency=4;
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2015-01-08  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :  security_module.v
    File tree    :  security_module.v                        
\************************************************************************************/

`timescale 1ns/100ps

module security_module(
    clk                         ,    
    rst                         ,
    tdes_enable                 ,
    tdes_chacha_wren            ,
    tdes_chacha_waddr           ,
    tdes_chacha_wdata           ,
    tdes_descram_wren           ,
    tdes_descram_waddr          ,
    tdes_descram_wdata          ,
    
    cbus_addr                   ,
    cbus_we                     ,
    cbus_oe                     ,
    cbus_wdata                  ,
    cbus_rdata                           
    );

parameter   CBUS_ADDR_WIDTH             = 12                        ;
parameter   CBUS_DATA_WIDTH             = 8                         ;

//base address:16'h6000
parameter   ADDR_TDES_ENABLE            = 12'h000                   ;
parameter   ADDR_TDES_RESET             = 12'h001                   ;
parameter   ADDR_TDES_CTRL              = 12'h00f                   ;
parameter   ADDR_TDES_CW                = 12'h01x                   ;
parameter   ADDR_TDES_DCK_SET_SEL       = 12'h02f                   ;
parameter   ADDR_TDES_DSK_MASK          = 12'h03x                   ;
parameter   ADDR_TDES_DCK               = 12'h04x                   ;
parameter   ADDR_TDES_RESULT            = 12'h10x                   ;
parameter   ADDR_DCK_RESULT             = 12'h11x                   ;

parameter   ST_WIDTH                    = 6                         ;
parameter   ST_IDLE                     = 6'b00_0001                ,
            ST_LOAD_CW                  = 6'b00_0010                ,
            ST_LOAD_DSK                 = 6'b00_0100                ,
            ST_TDES_START               = 6'b00_1000                ,
            ST_TDES_PRO                 = 6'b01_0000                ,
            ST_TDES_RESULT              = 6'b10_0000                ;          

input                                   clk                         ;
input                                   rst                         ;
output                                  tdes_enable                 ;
output                                  tdes_chacha_wren            ;
output  [10:0]                          tdes_chacha_waddr           ;
output  [7:0]                           tdes_chacha_wdata           ;
output                                  tdes_descram_wren           ;
output  [10:0]                          tdes_descram_waddr          ;
output  [7:0]                           tdes_descram_wdata          ;

input   [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr                   ;
input                                   cbus_we                     ;
input                                   cbus_oe                     ;
input   [CBUS_DATA_WIDTH - 1 : 0]       cbus_wdata                  ;
output  [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;

reg                                     cbus_oe_1dly                ;
reg                                     cbus_oe_2dly                ;
reg                                     cbus_oe_3dly                ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_1dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_2dly              ;
reg     [CBUS_ADDR_WIDTH - 1 : 0]       cbus_addr_3dly              ;
reg     [CBUS_DATA_WIDTH - 1 : 0]       cbus_rdata                  ;

reg                                     tdes_enable                 ;
reg                                     tdes_reset                  ;
reg                                     tdes_set_mode               ;
reg     [6:0]                           tdes_pid_index              ;
reg                                     tdes_dck_set_sel            ;

reg     [ST_WIDTH - 1 : 0]              st_curr                     ;
reg     [ST_WIDTH - 1 : 0]              st_next                     ;

reg                                     tdes_chacha_wren            ;
reg     [10:0]                          tdes_chacha_waddr           ;
wire    [7:0]                           tdes_chacha_wdata           ;
reg                                     tdes_descram_wren           ;
reg     [10:0]                          tdes_descram_waddr          ;
wire    [7:0]                           tdes_descram_wdata          ;

reg                                     dck_cfg_finished            ;
reg                                     cw_cfg_finished             ;
reg     [5:0]                           byte_addr                   ;
wire    [7:0]                           dsk_key_buf                 ;
reg     [127:0]                         dsk_key                     ;
reg     [127:0]                         dck1_key                    ;
reg                                     tdes_num                    ;
reg                                     dck_state                   ;
reg     [127:0]                         dck_key                     ;
reg     [127:0]                         cw_key                      ;

reg                                     tdes_start                  ;
reg     [63:0]                          key1                        ;
reg     [63:0]                          key2                        ;
reg     [63:0]                          tdes_indata                 ;
wire                                    mode                        ;
wire                                    tdes_out_ok                 ;
wire    [63:0]                          tdes_outdata                ;
reg     [63:0]                          tdes_outdata_buf            ;
reg     [7:0]                           tdes_result                 ;

reg                                     tdpram_wea                  ;
reg     [7:0]                           tdpram_dina                 ;
reg     [4:0]                           tdpram_addra                ;
wire    [7:0]                           tdpram_douta                ;
reg     [4:0]                           tdpram_addrb                ;
wire    [7:0]                           tdpram_doutb                ;

reg                                     otpram_wea                  ;
reg     [7:0]                           otpram_dina                 ;
reg     [8:0]                           otpram_addra                ;
wire    [7:0]                           otpram_douta                ;
reg     [8:0]                           otpram_addrb                ;
wire    [7:0]                           otpram_doutb                ;

reg                                     dckram_wren                 ;
wire    [7:0]                           dckram_wdata                ;
reg     [4:0]                           dckram_waddr                ;
wire    [4:0]                           dckram_raddr                ;
wire    [7:0]                           dckram_rdata                ;

reg     [127:0]                         tdes_data_result            ;

//wire    [6:0]                           bit_high                    ;
//wire    [6:0]                           bit_low                     ;

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

////////////////////////////////////////////////////////////////////
//cbus write and read,read latency=4
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdes_enable         <=  1'b0;
        tdes_reset          <=  1'b0;
        tdes_set_mode       <=  1'b0;
        tdes_pid_index      <=  {7{1'b0}};
        tdes_dck_set_sel    <=  1'b0;
    end
    else if(cbus_we==1'b1)
    begin
        casex(cbus_addr)
        ADDR_TDES_ENABLE:       tdes_enable         <=  cbus_wdata[0];
        ADDR_TDES_RESET:        tdes_reset          <=  cbus_wdata[0];
        ADDR_TDES_CTRL:
        begin
            tdes_set_mode   <=  cbus_wdata[7];                          //1:set chacha key;0:set cw;
            tdes_pid_index  <=  cbus_wdata[6:0];
        end
        ADDR_TDES_DCK_SET_SEL:  tdes_dck_set_sel    <=  cbus_wdata[0];  //1:set chacha dck;0:set descramble cw dck           
        default:;
        endcase
    end
end

always@(posedge clk)
begin
    if((cbus_we==1'b1) && (cbus_addr[11:4]==8'h01))
    begin
        cw_key  <=  {cw_key[119:0],cbus_wdata[7:0]};
    end
end

//assign  bit_high    =   7'd127 - {cbus_addr_3dly[3:0],3'b000};
//assign  bit_low     =   bit_high - 7'd7;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cbus_rdata  <=  {CBUS_DATA_WIDTH{1'b0}};
    end
    else if(cbus_oe_3dly==1'b1)
    begin
        casex(cbus_addr_3dly)
        ADDR_TDES_CW:           
        begin
            //cbus_rdata  <=  cw_key[bit_high:bit_low];
            case(cbus_addr_3dly[3:0])
            4'h0:   cbus_rdata  <=  cw_key[127:120];
            4'h1:   cbus_rdata  <=  cw_key[119:112];
            4'h2:   cbus_rdata  <=  cw_key[111:104];
            4'h3:   cbus_rdata  <=  cw_key[103:96];
            4'h4:   cbus_rdata  <=  cw_key[95:88];
            4'h5:   cbus_rdata  <=  cw_key[87:80];
            4'h6:   cbus_rdata  <=  cw_key[79:72];
            4'h7:   cbus_rdata  <=  cw_key[71:64];
            4'h8:   cbus_rdata  <=  cw_key[63:56];
            4'h9:   cbus_rdata  <=  cw_key[55:48];
            4'ha:   cbus_rdata  <=  cw_key[47:40];
            4'hb:   cbus_rdata  <=  cw_key[39:32];
            4'hc:   cbus_rdata  <=  cw_key[31:24];
            4'hd:   cbus_rdata  <=  cw_key[23:16];
            4'he:   cbus_rdata  <=  cw_key[15:8];
            4'hf:   cbus_rdata  <=  cw_key[7:0];
            default:;
            endcase
        end
        ADDR_TDES_DSK_MASK,ADDR_TDES_DCK:
        begin
            cbus_rdata  <=  tdpram_douta;
        end
        12'b001x_xxxx_xxxx:     cbus_rdata  <=  otpram_douta;
        ADDR_TDES_ENABLE:       cbus_rdata  <=  {{15{1'b0}},tdes_enable};
        ADDR_TDES_RESET:        cbus_rdata  <=  {{15{1'b0}},tdes_reset};
        ADDR_TDES_CTRL:         cbus_rdata  <=  {tdes_set_mode,tdes_pid_index[6:0]};
        ADDR_TDES_DCK_SET_SEL:  cbus_rdata  <=  {{15{1'b0}},tdes_dck_set_sel};
        ADDR_TDES_RESULT:
        begin
            case(cbus_addr_3dly[3:0])
            4'h0:   cbus_rdata  <=  tdes_data_result[127:120];
            4'h1:   cbus_rdata  <=  tdes_data_result[119:112];
            4'h2:   cbus_rdata  <=  tdes_data_result[111:104];
            4'h3:   cbus_rdata  <=  tdes_data_result[103:96];
            4'h4:   cbus_rdata  <=  tdes_data_result[95:88];
            4'h5:   cbus_rdata  <=  tdes_data_result[87:80];
            4'h6:   cbus_rdata  <=  tdes_data_result[79:72];
            4'h7:   cbus_rdata  <=  tdes_data_result[71:64];
            4'h8:   cbus_rdata  <=  tdes_data_result[63:56];
            4'h9:   cbus_rdata  <=  tdes_data_result[55:48];
            4'ha:   cbus_rdata  <=  tdes_data_result[47:40];
            4'hb:   cbus_rdata  <=  tdes_data_result[39:32];
            4'hc:   cbus_rdata  <=  tdes_data_result[31:24];
            4'hd:   cbus_rdata  <=  tdes_data_result[23:16];
            4'he:   cbus_rdata  <=  tdes_data_result[15:8];
            4'hf:   cbus_rdata  <=  tdes_data_result[7:0];
            default:;
            endcase
        end
        ADDR_DCK_RESULT:        
        begin
            case(cbus_addr_3dly[3:0])
            4'h0:   cbus_rdata  <=  dck_key[127:120];
            4'h1:   cbus_rdata  <=  dck_key[119:112];
            4'h2:   cbus_rdata  <=  dck_key[111:104];
            4'h3:   cbus_rdata  <=  dck_key[103:96];
            4'h4:   cbus_rdata  <=  dck_key[95:88];
            4'h5:   cbus_rdata  <=  dck_key[87:80];
            4'h6:   cbus_rdata  <=  dck_key[79:72];
            4'h7:   cbus_rdata  <=  dck_key[71:64];
            4'h8:   cbus_rdata  <=  dck_key[63:56];
            4'h9:   cbus_rdata  <=  dck_key[55:48];
            4'ha:   cbus_rdata  <=  dck_key[47:40];
            4'hb:   cbus_rdata  <=  dck_key[39:32];
            4'hc:   cbus_rdata  <=  dck_key[31:24];
            4'hd:   cbus_rdata  <=  dck_key[23:16];
            4'he:   cbus_rdata  <=  dck_key[15:8];
            4'hf:   cbus_rdata  <=  dck_key[7:0];
            default:;
            endcase
        end
        default:;
        endcase
    end
end

////////////////////////////////////////////////////////////////////
//for test
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdes_data_result    <=  {128{1'b0}};
    end
    else if((tdes_out_ok==1'b1) && (tdes_num==1'b1))
    begin
        tdes_data_result    <=  {tdes_outdata_buf[63:0],tdes_outdata[63:0]};
    end
end
        
////////////////////////////////////////////////////////////////////
//tdes dsk xor and dck' ram write and read
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdpram_wea  <=  1'b0;
        tdpram_dina <=  {8{1'b0}};
    end
    else if((cbus_we==1'b1) && ((cbus_addr[11:4]==8'h03) || (cbus_addr[11:4]==8'h04)))
    begin
        tdpram_wea  <=  1'b1;
        tdpram_dina <=  cbus_wdata;
    end
    else
    begin
        tdpram_wea  <=  1'b0;
        tdpram_dina <=  {8{1'b0}};
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdpram_addra    <=  {5{1'b0}};
    end
    else if((cbus_we==1'b1) || (cbus_oe==1'b1))
    begin
        if(cbus_addr[11:4]==8'h03)
        begin
            tdpram_addra    <=  {1'b0,cbus_addr[3:0]};
        end
        else if(cbus_addr[11:4]==8'h04)
        begin
            tdpram_addra    <=  {1'b1,cbus_addr[3:0]};
        end
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdpram_addrb    <=  {5{1'b0}};
    end
    else if(st_curr==ST_LOAD_DSK)
    begin
        tdpram_addrb    <=  byte_addr[4:0]; 
    end
end

//assign  tdpram_addrb    =   byte_addr[4:0];           

////////////////////////////////////////////////////////////////////
//otp ram write and read
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        otpram_wea  <=  1'b0;
        otpram_dina <=  {8{1'b0}};
    end
    else if((cbus_we==1'b1) && (cbus_addr[11:9]==3'b001))
    begin
        otpram_wea  <=  1'b1;
        otpram_dina <=  cbus_wdata;
    end
    else
    begin
        otpram_wea  <=  1'b0;
        otpram_dina <=  {8{1'b0}};
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        otpram_addra    <=  {9{1'b0}};
    end
    else if(((cbus_we==1'b1) || (cbus_oe==1'b1)) && (cbus_addr[11:9]==3'b001)) 
    begin
        otpram_addra    <=  cbus_addr[8:0];
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        otpram_addrb    <=  {9{1'b0}};
    end
    else if(st_curr==ST_LOAD_DSK)
    begin
        if(tdes_dck_set_sel==1'b1)
        begin
            otpram_addrb    <=  {1'b0,4'h1,byte_addr[3:0]};
        end
        else
        begin
            otpram_addrb    <=  {1'b0,4'h2,byte_addr[3:0]};
        end
    end
end
        
//assign  otpram_addrb    =   (tdes_dck_set_sel==1'b1)    ?   {8'h21,byte_addr[3:0]}  :   {8'h22,byte_addr[3:0]};
assign  dsk_key_buf     =   tdpram_doutb ^ otpram_doutb;

////////////////////////////////////////////////////////////////////
//dsk,dck' and dck
////////////////////////////////////////////////////////////////////
always@(posedge clk)
begin
    if(st_curr==ST_LOAD_DSK)
    begin
        if((byte_addr>1) && (byte_addr<18))
        begin
            dsk_key     <=  {dsk_key[119:0],dsk_key_buf[7:0]};
        end
        else if(byte_addr>17)
        begin
            dck1_key    <=  {dck1_key[119:0],tdpram_doutb[7:0]};
        end
    end
end

always@(posedge clk)
begin
    if((st_curr==ST_LOAD_CW) && (byte_addr>1) && (byte_addr<18))
    begin
        dck_key <=  {dck_key[119:0],dckram_rdata[7:0]};
    end
end
                                           
////////////////////////////////////////////////////////////////////
//tdes state machine
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        dck_cfg_finished    <=  1'b0;
    end
    else if((cbus_we==1'b1) && (cbus_addr==12'h04f))
    begin
        dck_cfg_finished    <=  1'b1;
    end
    else
    begin
        dck_cfg_finished    <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        cw_cfg_finished <=  1'b0;
    end
    else if((cbus_we==1'b1) && (cbus_addr==12'h01f))
    begin
        cw_cfg_finished <=  1'b1;
    end
    else
    begin
        cw_cfg_finished <=  1'b0;
    end
end
        
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        dck_state   <=  1'b0;
    end
    else if(st_curr==ST_IDLE)
    begin
        if(dck_cfg_finished==1'b1)
        begin
            dck_state   <=  1'b1;
        end
        else if(cw_cfg_finished==1'b1)
        begin
            dck_state   <=  1'b0;
        end
    end
end  
    
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        byte_addr   <=  {6{1'b0}};
    end
    else if(st_curr==ST_LOAD_DSK)
    begin
        if(byte_addr==33)
        begin
            byte_addr   <=  {6{1'b0}};
        end
        else
        begin
            byte_addr   <=  byte_addr + 'h1;
        end
    end
    else if(st_curr==ST_TDES_RESULT)
    begin
        if(byte_addr==7)
        begin
            byte_addr   <=  {6{1'b0}};
        end
        else
        begin
            byte_addr   <=  byte_addr + 'h1;
        end
    end
    else if(st_curr==ST_LOAD_CW)
    begin
        if(byte_addr==17)
        begin
            byte_addr   <=  {6{1'b0}};
        end
        else
        begin
            byte_addr   <=  byte_addr + 'h1;
        end
    end
    else
    begin
        byte_addr   <=  {6{1'b0}};
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdes_num    <=  1'b0;
    end
    else if((st_curr==ST_TDES_PRO) && (tdes_out_ok==1'b1))
    begin
        tdes_num    <=  ~tdes_num;
    end
    else if(st_curr==ST_IDLE)
    begin
        tdes_num    <=  1'b0;
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
        if(dck_cfg_finished==1'b1)
        begin
            st_next =   ST_LOAD_DSK;
        end
        else if(cw_cfg_finished==1'b1)
        begin
            st_next =   ST_LOAD_CW;
        end
        else
        begin
            st_next =   ST_IDLE;
        end
    end
    ST_LOAD_DSK:
    begin
        if(byte_addr==33)
        begin
            st_next =   ST_TDES_START;
        end
        else
        begin
            st_next =   ST_LOAD_DSK;
        end
    end
    ST_LOAD_CW:
    begin
        if(byte_addr==17)
        begin
            st_next =   ST_TDES_START;
        end
        else
        begin
            st_next =   ST_LOAD_CW;
        end
    end
    ST_TDES_START:
    begin
        st_next =   ST_TDES_PRO;
    end
    ST_TDES_PRO:
    begin
        if(tdes_out_ok==1'b1)
        begin
            st_next =   ST_TDES_RESULT;
        end
        else
        begin
            st_next =   ST_TDES_PRO;
        end
    end
    ST_TDES_RESULT:
    begin
        if(byte_addr==7)
        begin
            if(tdes_num==1'b1)
            begin
                st_next =   ST_TDES_START;
            end
            else
            begin
                st_next =   ST_IDLE;
            end
        end
        else
        begin
            st_next =   ST_TDES_RESULT;
        end
    end
    default:    st_next =   ST_IDLE;
    endcase
end

////////////////////////////////////////////////////////////////////
//TDES
////////////////////////////////////////////////////////////////////     
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdes_start  <=  1'b0;
    end
    else if(st_curr==ST_TDES_START)
    begin
        tdes_start  <=  1'b1;
    end
    else
    begin
        tdes_start  <=  1'b0;
    end
end

always@(posedge clk)
begin
    if(st_curr==ST_TDES_START)
    begin
        if(dck_state==1'b1)
        begin
            key1    <=  dsk_key[127:64];
        end
        else
        begin
            key1    <=  dck_key[127:64];
        end
    end
end

always@(posedge clk)
begin
    if(st_curr==ST_TDES_START)
    begin
        if(dck_state==1'b1)
        begin
            key2    <=  dsk_key[63:0];
        end
        else
        begin
            key2    <=  dck_key[63:0];
        end
    end
end

always@(posedge clk)
begin
    if(st_curr==ST_TDES_START)
    begin
        if(tdes_num==1'b1)
        begin
            if(dck_state==1'b1)
            begin
                tdes_indata <=  dck1_key[63:0];
            end
            else
            begin
                tdes_indata <=  cw_key[63:0];
            end
        end
        else
        begin
            if(dck_state==1'b1)
            begin
                tdes_indata <=  dck1_key[127:64];
            end
            else
            begin
                tdes_indata <=  cw_key[127:64];
            end
        end
    end
end

////////////////////////////////////////////////////////////////////
//dck ram write,read and tdes output
////////////////////////////////////////////////////////////////////
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        dckram_wren         <=  1'b0;
        tdes_chacha_wren    <=  1'b0;
        tdes_descram_wren   <=  1'b0;
    end
    else if(st_curr==ST_TDES_RESULT)
    begin
        if(dck_state==1'b1)
        begin
            dckram_wren         <=  1'b1;
        end
        else if(tdes_set_mode==1'b1)        //chacha key
        begin
            tdes_chacha_wren    <=  1'b1;
        end
        else
        begin
            tdes_descram_wren   <=  1'b1;   //cw key
        end
    end
    else
    begin
        dckram_wren         <=  1'b0;
        tdes_chacha_wren    <=  1'b0;
        tdes_descram_wren   <=  1'b0;
    end
end   

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdes_outdata_buf    <=  {64{1'b0}};
    end
    else if(tdes_out_ok==1'b1)
    begin
        tdes_outdata_buf    <=  tdes_outdata;
    end
end
        
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tdes_result    <=  {8{1'b0}};
    end
    else if(st_curr==ST_TDES_RESULT)
    begin
        case(byte_addr)
        6'd0:   tdes_result <=  tdes_outdata_buf[63:56];
        6'd1:   tdes_result <=  tdes_outdata_buf[55:48];
        6'd2:   tdes_result <=  tdes_outdata_buf[47:40];
        6'd3:   tdes_result <=  tdes_outdata_buf[39:32];
        6'd4:   tdes_result <=  tdes_outdata_buf[31:24];
        6'd5:   tdes_result <=  tdes_outdata_buf[23:16];
        6'd6:   tdes_result <=  tdes_outdata_buf[15:8];
        6'd7:   tdes_result <=  tdes_outdata_buf[7:0];
        default:;
        endcase
    end
    else
    begin
        tdes_result    <=  {8{1'b0}};
    end
end

assign  dckram_wdata        =   (dck_state==1'b1)   ?   tdes_result :   {8{1'b0}};
assign  tdes_chacha_wdata   =   ((dck_state==1'b0) && (tdes_set_mode==1'b1))    ?   tdes_result :   {8{1'b0}};
assign  tdes_descram_wdata  =   ((dck_state==1'b0) && (tdes_set_mode==1'b0))    ?   tdes_result :   {8{1'b0}};

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        dckram_waddr        <=  {5{1'b0}};
        tdes_chacha_waddr   <=  {11{1'b0}};
        tdes_descram_waddr  <=  {11{1'b0}};
    end
    else if(st_curr==ST_TDES_RESULT)
    begin
        if(dck_state==1'b1)
        begin
            dckram_waddr        <=  {(~{tdes_dck_set_sel,tdes_num}),byte_addr[2:0]};
        end
        else if(tdes_set_mode==1'b1)
        begin
            tdes_chacha_waddr   <=  {tdes_pid_index[6:0],~tdes_num,byte_addr[2:0]};
        end
        else
        begin
            tdes_descram_waddr  <=  {tdes_pid_index[6:0],~tdes_num,byte_addr[2:0]};
        end
    end
end

assign  dckram_raddr    =   {~tdes_set_mode,byte_addr[3:0]};
assign  mode            =   1'b1;  
              
TDES_Top u0_TDES_Top(
    .clk                                ( clk                       ),
    .key1                               ( key1                      ),
    .key2                               ( key2                      ),
    .mode                               ( mode                      ),
    .reset                              ( tdes_reset | rst          ),
    .ready                              ( tdes_start                ),
    .in_data                            ( tdes_indata               ),
    .out_data                           ( tdes_outdata              ),
    .output_ok                          ( tdes_out_ok               )
    );

//dsk mask and dck'
//porta read latency=2;portb read latency=1;true dual port ram
tdpram_w8d32 u0_dskmask_ram(
    .clka                                 ( clk                       ),
    .wea                                  ( tdpram_wea                ),
    .addra                                ( tdpram_addra              ),
    .dina                                 ( tdpram_dina               ),
    .douta                                ( tdpram_douta              ),
    .clkb                                 ( clk                       ),
    .web                                  ( 1'b0                      ),
    .addrb                                ( tdpram_addrb              ),
    .dinb                                 ( {8{1'b0}}                 ),
    .doutb                                ( tdpram_doutb              )
    );

//addr 0x10-0x1f:chacha dsk;0x20-0x2f:descramble cw dsk;
//otp ram
//porta read latency=2;portb read latency=1;true dual port ram
otpram_w8d512 u0_otp_ram(
    .clka                               ( clk                       ),
    .wea                                ( otpram_wea                ),
    .addra                              ( otpram_addra              ),
    .dina                               ( otpram_dina               ),
    .douta                              ( otpram_douta              ),
    .clkb                               ( clk                       ),
    .web                                ( 1'b0                      ),
    .addrb                              ( otpram_addrb              ),
    .dinb                               ( {8{1'b0}}                 ),
    .doutb                              ( otpram_doutb              )
    );

//dck ram,read latency=2
sdpram_w8d32 u0_dckram(
    .clka                               ( clk                       ),
    .wea                                ( dckram_wren               ),
    .addra                              ( dckram_waddr              ),
    .dina                               ( dckram_wdata              ),
    .clkb                               ( clk                       ),
    .addrb                              ( dckram_raddr              ),
    .doutb                              ( dckram_rdata              )
    );
        	        
endmodule  	   
