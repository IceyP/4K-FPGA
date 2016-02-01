/*************************************************************************************\
    Copyright(c) 2014, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   Creative Center,R&D Hardware Department
    Filename     :   ts_mux.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :   packet head of tuner_index=2'b00:0x40;
                     packet head of tuner_index=2'b01:0x41;
                     packet head of tuner_index=2'b10:0x42;
                     packet head of tuner_index=2'b11:0x43;
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2014-12-23  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :   ts_mux.v
    File tree    :   ts_mux.v
\************************************************************************************/

`timescale 1ns/100ps

module ts_mux(
    tuner_clk                   ,
    tuner_data                  ,
    tuner_sync                  ,
    tuner_valid                 ,
    
    clk                         ,
    rst                         ,
    tsmux_valid                 , 
    tsmux_data                  ,
    tsmux_sop                   ,
    tsmux_eop                   
    );

parameter   TOTAL_CHN_NUM               = 4                         ;

parameter   ST_WIDTH                    = 3                         ;
parameter   ST_IDLE                     = 3'b001                    ,
            ST_START                    = 3'b010                    ,
            ST_END                      = 3'b100                    ;
            
input   [TOTAL_CHN_NUM - 1 : 0]         tuner_clk                   ;
input   [TOTAL_CHN_NUM - 1 : 0]         tuner_data                  ;
input   [TOTAL_CHN_NUM - 1 : 0]         tuner_sync                  ;
input   [TOTAL_CHN_NUM - 1 : 0]         tuner_valid                 ;

input                                   clk                         ;
input                                   rst                         ;
output                                  tsmux_valid                 ;
output  [7:0]                           tsmux_data                  ;
output                                  tsmux_sop                   ;
output                                  tsmux_eop                   ;

reg                                     tsmux_valid                 ;
reg     [7:0]                           tsmux_data                  ;
reg                                     tsmux_sop                   ;
reg                                     tsmux_eop                   ;

wire    [7:0]                           ts_data[TOTAL_CHN_NUM - 1 : 0];
wire    [TOTAL_CHN_NUM - 1 : 0]         ts_valid                    ;
wire    [TOTAL_CHN_NUM - 1 : 0]         ts_sop                      ;
wire    [TOTAL_CHN_NUM - 1 : 0]         ts_eop                      ;
wire    [TOTAL_CHN_NUM - 1 : 0]         ts_pkt_rdy                  ;
wire    [TOTAL_CHN_NUM - 1 : 0]         ts_pkt_ack_buf              ;
reg     [TOTAL_CHN_NUM - 1 : 0]         ts_pkt_ack                  ;

reg                                     rr_start                    ;
reg     [ST_WIDTH - 1 : 0]              st_curr                     ;
reg     [ST_WIDTH - 1 : 0]              st_next                     ;

wire                                    pkt_valid                   ;
wire                                    pkt_start                   ;
wire                                    pkt_end                     ;

assign  pkt_valid   =   |ts_valid;
assign  pkt_start   =   |ts_sop;
assign  pkt_end     =   |ts_eop;

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
        if(|ts_pkt_rdy==1'b1)
        begin
            st_next =   ST_START;
        end
        else
        begin
            st_next =   ST_IDLE;
        end
    end
    ST_START:
    begin
        st_next =   ST_END;
    end
    ST_END:
    begin
        if(pkt_end==1'b1)
        begin
            st_next =   ST_IDLE;
        end
        else
        begin
            st_next =   ST_END;
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
        rr_start    <=  1'b0;
    end
    else if(st_curr==ST_START)
    begin
        rr_start    <=  1'b1;
    end
    else
    begin
        rr_start    <=  1'b0;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tsmux_valid <=  1'b0;
        tsmux_sop   <=  1'b0;
        tsmux_eop   <=  1'b0;
    end
    else
    begin
        tsmux_valid <=  pkt_valid;
        tsmux_sop   <=  pkt_start;
        tsmux_eop   <=  pkt_end;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        tsmux_data  <=  {8{1'b0}};
    end
    else
    begin
        case(ts_valid)
        4'b0001:    tsmux_data  <=  ts_data[0];
        4'b0010:    tsmux_data  <=  ts_data[1];
        4'b0100:    tsmux_data  <=  ts_data[2];
        4'b1000:    tsmux_data  <=  ts_data[3];
        default:    tsmux_data  <=  {8{1'b0}};
        endcase
    end
end
        
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_pkt_ack  <=  {TOTAL_CHN_NUM{1'b0}};
    end
    else
    begin
        ts_pkt_ack  <=  ts_pkt_ack_buf;
    end
end

////////////////////////////////////////////////////////////////////
//round_robin_arbiter
////////////////////////////////////////////////////////////////////
round_robin_arbiter #(
    .CHN_NUM                            ( TOTAL_CHN_NUM             )
    )
u0_rr_arbiter(
    .clk                                ( clk                       ),
    .rst                                ( rst                       ),
    .req                                ( ts_pkt_rdy                ),
    .ack                                ( rr_start                  ),
    .grant                              ( ts_pkt_ack_buf            )
    );
    
generate
    genvar  i;
    for(i=0;i<TOTAL_CHN_NUM;i=i+1)
    begin:TS_SER_TO_PAR
        ser2par #(
            .TUNER_INDEX                ( i                         )
            )
        ser2par_ch(
            .ts_i_clk                   ( tuner_clk[i]              ),
            .ts_i_data                  ( tuner_data[i]             ),
            .ts_i_sync                  ( tuner_sync[i]             ),
            .ts_i_valid                 ( tuner_valid[i]            ),
            
            .clk                        ( clk                       ),
            .rst                        ( rst                       ),
            .ts_pkt_rdy                 ( ts_pkt_rdy[i]             ),
            .ts_pkt_ack                 ( ts_pkt_ack[i]             ),
            
            .ts_o_data                  ( ts_data[i]                ),
            .ts_o_valid                 ( ts_valid[i]               ),
            .ts_o_sop                   ( ts_sop[i]                 ),
            .ts_o_eop                   ( ts_eop[i]                 )
            );
    end
endgenerate

endmodule   
