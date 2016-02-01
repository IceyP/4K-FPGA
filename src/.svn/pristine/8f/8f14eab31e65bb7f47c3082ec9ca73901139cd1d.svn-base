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
        32'd1:      ts_data =   8'h47;
        32'd2:      ts_data =   8'h00;
        32'd3:      ts_data =   8'h14;  //ts_pid
        32'd4:      ts_data =   {2'b10,ADAPT_FIELD_CTRL,ts_cc[3:0]};
        32'd5:      ts_data =   8'h9B;
        32'd6:      ts_data =   8'h76;
        32'd7:      ts_data =   8'hDA;
        32'd8:      ts_data =   8'hB9;
        32'd9:      ts_data =   8'h28;
        32'd10:     ts_data =   8'h74;
        32'd11:     ts_data =   8'h43;
        32'd12:     ts_data =   8'hF2;
        32'd13:     ts_data =   8'h70;
        32'd14:     ts_data =   8'h2B;
        32'd15:     ts_data =   8'hCF;
        32'd16:     ts_data =   8'h0C;
        32'd17:     ts_data =   8'hCF;
        32'd18:     ts_data =   8'hA2;
        32'd19:     ts_data =   8'h05;
        32'd20:     ts_data =   8'h74;
        32'd21:     ts_data =   8'h24;
        32'd22:     ts_data =   8'hFA;
        32'd23:     ts_data =   8'h39;
        32'd24:     ts_data =   8'hAC;
        32'd25:     ts_data =   8'hA7;
        32'd26:     ts_data =   8'h5D;
        32'd27:     ts_data =   8'h0D;
        32'd28:     ts_data =   8'h18;
        32'd29:     ts_data =   8'h2C;
        32'd30:     ts_data =   8'h54;
        32'd31:     ts_data =   8'hDB;
        32'd32:     ts_data =   8'hD4;
        32'd33:     ts_data =   8'h7D;
        32'd34:     ts_data =   8'h15;
        32'd35:     ts_data =   8'h59;
        32'd36:     ts_data =   8'hBB;
        32'd37:     ts_data =   8'hEE;
        32'd38:     ts_data =   8'h86;
        32'd39:     ts_data =   8'h40;
        32'd40:     ts_data =   8'h54;
        32'd41:     ts_data =   8'h97;
        32'd42:     ts_data =   8'h56;
        32'd43:     ts_data =   8'h2A;
        32'd44:     ts_data =   8'hEF;
        32'd45:     ts_data =   8'h89;
        32'd46:     ts_data =   8'hB3;
        32'd47:     ts_data =   8'h83;
        32'd48:     ts_data =   8'h4A;
        32'd49:     ts_data =   8'hF8;
        32'd50:     ts_data =   8'hF6;
        32'd51:     ts_data =   8'h47;
        32'd52:     ts_data =   8'hBB;
        32'd53:     ts_data =   8'hF8;
        32'd54:     ts_data =   8'h46;
        32'd55:     ts_data =   8'hE5;
        32'd56:     ts_data =   8'h5F;
        32'd57:     ts_data =   8'h89;
        32'd58:     ts_data =   8'h35;
        32'd59:     ts_data =   8'h79;
        32'd60:     ts_data =   8'hB0;
        32'd61:     ts_data =   8'hBD;
        32'd62:     ts_data =   8'h8B;
        32'd63:     ts_data =   8'hD7;
        32'd64:     ts_data =   8'hE3;
        32'd65:     ts_data =   8'hAB;
        32'd66:     ts_data =   8'h15;
        32'd67:     ts_data =   8'h9A;
        32'd68:     ts_data =   8'h99;
        32'd69:     ts_data =   8'h40;
        32'd70:     ts_data =   8'h77;
        32'd71:     ts_data =   8'h19;
        32'd72:     ts_data =   8'hC0;
        32'd73:     ts_data =   8'h4C;
        32'd74:     ts_data =   8'hE7;
        32'd75:     ts_data =   8'h32;
        32'd76:     ts_data =   8'h97;
        32'd77:     ts_data =   8'h2E;
        32'd78:     ts_data =   8'hAD;
        32'd79:     ts_data =   8'h21;
        32'd80:     ts_data =   8'hC3;
        32'd81:     ts_data =   8'h90;
        32'd82:     ts_data =   8'h4A;
        32'd83:     ts_data =   8'hB9;
        32'd84:     ts_data =   8'h45;
        32'd85:     ts_data =   8'h07;
        32'd86:     ts_data =   8'h0C;
        32'd87:     ts_data =   8'h40;
        32'd88:     ts_data =   8'hA7;
        32'd89:     ts_data =   8'hCF;
        32'd90:     ts_data =   8'h29;
        32'd91:     ts_data =   8'h28;
        32'd92:     ts_data =   8'h95;
        32'd93:     ts_data =   8'hE5;
        32'd94:     ts_data =   8'h7A;
        32'd95:     ts_data =   8'hFF;
        32'd96:     ts_data =   8'hA6;
        32'd97:     ts_data =   8'hA6;
        32'd98:     ts_data =   8'h6D;
        32'd99:     ts_data =   8'hBA;
        32'd100:    ts_data =   8'hDA;
        32'd101:    ts_data =   8'h8A;
        32'd102:    ts_data =   8'hCE;
        32'd103:    ts_data =   8'h0B;
        32'd104:    ts_data =   8'h36;
        32'd105:    ts_data =   8'h27;
        32'd106:    ts_data =   8'hEC;
        32'd107:    ts_data =   8'hAF;
        32'd108:    ts_data =   8'hCD;
        32'd109:    ts_data =   8'h86;
        32'd110:    ts_data =   8'h9D;
        32'd111:    ts_data =   8'h4E;
        32'd112:    ts_data =   8'hE0;
        32'd113:    ts_data =   8'h2F;
        32'd114:    ts_data =   8'h61;
        32'd115:    ts_data =   8'h0A;
        32'd116:    ts_data =   8'h23;
        32'd117:    ts_data =   8'h38;
        32'd118:    ts_data =   8'h5F;
        32'd119:    ts_data =   8'h35;
        32'd120:    ts_data =   8'hCE;
        32'd121:    ts_data =   8'hBF;
        32'd122:    ts_data =   8'h5A;
        32'd123:    ts_data =   8'h05;
        32'd124:    ts_data =   8'hB7;
        32'd125:    ts_data =   8'h2F;
        32'd126:    ts_data =   8'hDC;
        32'd127:    ts_data =   8'hC0;
        32'd128:    ts_data =   8'h5F;
        32'd129:    ts_data =   8'h9D;
        32'd130:    ts_data =   8'hA1;
        32'd131:    ts_data =   8'hDF;
        32'd132:    ts_data =   8'h62;
        32'd133:    ts_data =   8'hB0;
        32'd134:    ts_data =   8'h98;
        32'd135:    ts_data =   8'h18;
        32'd136:    ts_data =   8'hE8;
        32'd137:    ts_data =   8'h28;
        32'd138:    ts_data =   8'hF1;
        32'd139:    ts_data =   8'h09;
        32'd140:    ts_data =   8'h9D;
        32'd141:    ts_data =   8'hA0;
        32'd142:    ts_data =   8'h2F;
        32'd143:    ts_data =   8'hB5;
        32'd144:    ts_data =   8'h36;
        32'd145:    ts_data =   8'h5F;
        32'd146:    ts_data =   8'hB4;
        32'd147:    ts_data =   8'hE7;
        32'd148:    ts_data =   8'h3F;
        32'd149:    ts_data =   8'h8F;
        32'd150:    ts_data =   8'hC3;
        32'd151:    ts_data =   8'h32;
        32'd152:    ts_data =   8'h46;
        32'd153:    ts_data =   8'h34;
        32'd154:    ts_data =   8'h49;
        32'd155:    ts_data =   8'hC5;
        32'd156:    ts_data =   8'hD6;
        32'd157:    ts_data =   8'h21;
        32'd158:    ts_data =   8'h82;
        32'd159:    ts_data =   8'hF7;
        32'd160:    ts_data =   8'hC3;
        32'd161:    ts_data =   8'h3A;
        32'd162:    ts_data =   8'h61;
        32'd163:    ts_data =   8'h52;
        32'd164:    ts_data =   8'hB3;
        32'd165:    ts_data =   8'h0B;
        32'd166:    ts_data =   8'hFE;
        32'd167:    ts_data =   8'hE6;
        32'd168:    ts_data =   8'h22;
        32'd169:    ts_data =   8'h8A;
        32'd170:    ts_data =   8'hFF;
        32'd171:    ts_data =   8'h0A;
        32'd172:    ts_data =   8'hCB;
        32'd173:    ts_data =   8'hB3;
        32'd174:    ts_data =   8'hA8;
        32'd175:    ts_data =   8'hAD;
        32'd176:    ts_data =   8'h7A;
        32'd177:    ts_data =   8'h00;
        32'd178:    ts_data =   8'hA1;
        32'd179:    ts_data =   8'hD5;
        32'd180:    ts_data =   8'hBB;
        32'd181:    ts_data =   8'h4A;
        32'd182:    ts_data =   8'h44;
        32'd183:    ts_data =   8'hCB;
        32'd184:    ts_data =   8'hF4;
        32'd185:    ts_data =   8'h38;
        32'd186:    ts_data =   8'h91;
        32'd187:    ts_data =   8'h9F;
        32'd188:    ts_data =   8'hAF;        
        default:    ts_data =   8'h00;
        endcase
    end
    else
    begin
        ts_data =   8'h00;
    end
end

/*
original:
47 00 14 90 9B 76 DA B9 28 74 43 F2 70 2B CF 0C 
CF A2 05 74 24 FA 39 AC A7 5D 0D 18 2C 54 DB D4 
7D 15 59 BB EE 86 40 54 97 56 2A EF 89 B3 83 4A 
F8 F6 47 BB F8 46 E5 5F 89 35 79 B0 BD 8B D7 E3 
AB 15 9A 99 40 77 19 C0 4C E7 32 97 2E AD 21 C3 
90 4A B9 45 07 0C 40 A7 CF 29 28 95 E5 7A FF A6 
A6 6D BA DA 8A CE 0B 36 27 EC AF CD 86 9D 4E E0 
2F 61 0A 23 38 5F 35 CE BF 5A 05 B7 2F DC C0 5F 
9D A1 DF 62 B0 98 18 E8 28 F1 09 9D A0 2F B5 36 
5F B4 E7 3F 8F C3 32 46 34 49 C5 D6 21 82 F7 C3 
3A 61 52 B3 0B FE E6 22 8A FF 0A CB B3 A8 AD 7A 
00 A1 D5 BB 4A 44 CB F4 38 91 9F AF 

cw:ff ff ff fd ff ff ff fd

descrambler:
47 00 14 10 01 02 03 04 05 06 07 08 09 0A 0B 0C 
0D 0E 0F 10 11 12 13 14 15 16 17 18 19 1A 1B 1C 
1D 1E 1F 20 21 22 23 24 25 26 27 28 29 2A 2B 2C 
2D 2E 2F 30 31 32 33 34 35 36 37 38 39 3A 3B 3C 
3D 3E 3F 40 41 42 43 44 45 46 47 48 49 4A 4B 4C 
4D 4E 4F 50 51 52 53 54 55 56 57 58 59 5A 5B 5C 
5D 5E 5F 60 61 62 63 64 65 66 67 68 69 6A 6B 6C 
6D 6E 6F 70 71 72 73 74 75 76 77 78 79 7A 7B 7C 
7D 7E 7F 80 81 82 83 84 85 86 87 88 89 8A 8B 8C 
8D 8E 8F 90 91 92 93 94 95 96 97 98 99 9A 9B 9C 
9D 9E 9F A0 A1 A2 A3 A4 A5 A6 A7 A8 A9 AA AB AC 
AD AE AF B0 B1 B2 B3 B4 B5 B6 B7 B8 
*/

endmodule
