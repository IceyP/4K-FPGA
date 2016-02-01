/*************************************************************************************\
    Copyright(c) 2012, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   New Media,R&D Hardware Department
    Filename     :   scrambler_ts_gen.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2013-03-04  huangrui/1480       1.0         IPQAM       Create
    ==================================================================================
    Called by    :   scrambler_ts_gen.v
    File tree    :   scrambler_ts_gen.v
\************************************************************************************/

`timescale 1ns/100ps

module ts_gen8_ser(
    rst                         ,
    clk                         ,   
    
    ts_clk_ser                  ,
    ts_valid_ser                ,
    ts_data_ser                 ,
    ts_sync_ser
    );

parameter   U_DLY                       = 1                         ;
parameter   PKT_INTERVAL                = 4500                      ;
parameter   ADAPT_FIELD_CTRL            = 2'b01                     ;   //only payload
parameter   ADAPT_FIELD_LEN             = 8'h10                     ;

input                                   rst                         ;
input                                   clk                         ;

output                                  ts_clk_ser                  ;
output                                  ts_sync_ser                 ;
output                                  ts_valid_ser                ;
output                                  ts_data_ser                 ;

reg     [31:0]                          byte_cnt                    ;
wire                                    ts_sync                     ;
wire                                    ts_valid                    ;
reg     [7:0]                           ts_data                     ;
wire                                    ts_eop                      ;

reg     [3:0]                           ts_cc                       ;
reg     [7:0]                           pkt_cnt                     ;
wire    [27:0]                          temp                        ;
reg     [7:0]                           ts_data_shift               ;

////////////////////////////////////////////////////////////////////
//serial ts data
////////////////////////////////////////////////////////////////////
assign  ts_clk_ser      =   clk;
assign  ts_data_ser     =   ts_data_shift[0];
assign  ts_valid_ser    =   ((byte_cnt[3:0]>0) && (byte_cnt[3:0]<9) && (temp>=1) && (temp<=188))    ?   1'b1    :   1'b0;
//assign  ts_sync_ser     =   ((byte_cnt>16) && (byte_cnt<25))    ?   1'b1    :   1'b0;
assign  ts_sync_ser     =   (byte_cnt==17)  ?   1'b1    :   1'b0;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_data_shift   <=  {8{1'b0}};
    end
    else if(byte_cnt[2:0]==3'b000)
    begin
        ts_data_shift   <=  ts_data[7:0];
    end
    else
    begin
        ts_data_shift   <=  {1'b0,ts_data_shift[7:1]};
    end
end

////////////////////////////////////////////////////////////////////
//par ts data
////////////////////////////////////////////////////////////////////
assign  temp    =   byte_cnt[31:4];
        
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        byte_cnt    <=  {32{1'b0}};
    end
    else if(temp >187 + PKT_INTERVAL)
    begin
        byte_cnt    <=  {{27{1'b0}},1'b1,{4{1'b0}}};  
    end
    else
    begin
        byte_cnt    <=  byte_cnt + 'h1;
    end
end

assign  ts_valid    = ((temp>=1) && (temp<=188) && (byte_cnt[3:0]==4'h0)) ? 1'b1 : 1'b0;
assign  ts_sync     = ((temp==1) && (byte_cnt[3:0]==4'h0)) ? 1'b1 : 1'b0;
assign  ts_eop      = ((temp==188) && (byte_cnt[3:0]==4'h0)) ? 1'b1 : 1'b0;

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_cc   <=  4'h0;
    end
    else if((temp==1) && (byte_cnt[3:0]==4'h0))
    begin
        ts_cc   <=  ts_cc + 4'h1;
    end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        pkt_cnt <=  8'h00;
    end
    else if((temp==1) && (byte_cnt[3:0]==4'h0))
    begin
        pkt_cnt <=  pkt_cnt + 8'h01;
    end
end

always@*
begin
    if(ts_valid==1'b1)
    begin
        case(temp)
        32'd1:  ts_data =   8'h47;
        32'd2:  ts_data =   8'h00;
        32'd3:  ts_data =   8'h14;  //ts_pid
        32'd4:  ts_data =   {2'b00,ADAPT_FIELD_CTRL,ts_cc[3:0]};
        default:ts_data =   temp - 8'd4;
        endcase
    end
    else
    begin
        ts_data =   8'h00;
    end
end
 
endmodule
