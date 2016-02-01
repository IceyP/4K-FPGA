module key_schedule(
    ck                          ,
    clk                         ,
    nrst                        ,
    ld                          ,
    ldkey_cnt                   ,
    ldkey_end                   ,
    kk                          ,
    b_end                        
    );

input   [0:7]                           ck                          ;
input                                   clk                         ;
input                                   nrst                        ;
input                                   ld                          ;
input   [0:2]                           ldkey_cnt                   ;
input                                   ldkey_end                   ;

output  [0:7]                           kk                          ;
output                                  b_end                       ;

reg     [1:64]                          kb                          ;
reg     [0:5]                           ni                          ;
wire    [0:7]                           kv                          ;
reg                                     block_end                   ;

assign  b_end   =   block_end;
assign  kk[5:7] =   kv[5:7] ^ ni[0:2];
assign  kk[0:4] =   kv[0:4];

always@(posedge clk)
begin
    if(nrst==1'b0)
    begin
        kb  <=  {64{1'b0}};
    end
    else if((ld==1'b1) && (ldkey_end==1'b0))
    begin
        case(ldkey_cnt)
        3'b001  :   kb[1:8]     <=  ck[0:7];
        3'b010  :   kb[9:16]    <=  ck[0:7];
        3'b011  :   kb[17:24]   <=  ck[0:7];
        3'b100  :   kb[25:32]   <=  ck[0:7];
        3'b101  :   kb[33:40]   <=  ck[0:7];
        3'b110  :   kb[41:48]   <=  ck[0:7];
        3'b111  :   kb[49:56]   <=  ck[0:7];
        3'b000  :   kb[57:64]   <=  ck[0:7];
        default:;
        endcase
    end
    else if(ni[3:5]==3'b000)
    begin
        kb[18]  <=  kb[1];
        kb[36]  <=  kb[2];
        kb[9]   <=  kb[3];
        kb[7]   <=  kb[4];
        kb[42]  <=  kb[5];
        kb[49]  <=  kb[6];
        kb[29]  <=  kb[7];
        kb[21]  <=  kb[8];
        kb[28]  <=  kb[9];
        kb[54]  <=  kb[10];
        kb[62]  <=  kb[11];
        kb[50]  <=  kb[12];
        kb[19]  <=  kb[13];
        kb[33]  <=  kb[14];
        kb[59]  <=  kb[15];
        kb[64]  <=  kb[16];
        kb[24]  <=  kb[17];
        kb[20]  <=  kb[18];
        kb[37]  <=  kb[19];
        kb[39]  <=  kb[20];
        kb[2]   <=  kb[21];
        kb[53]  <=  kb[22];
        kb[27]  <=  kb[23];
        kb[1]   <=  kb[24];
        kb[34]  <=  kb[25];
        kb[4]   <=  kb[26];
        kb[13]  <=  kb[27];
        kb[14]  <=  kb[28];
        kb[57]  <=  kb[29];
        kb[40]  <=  kb[30];
        kb[26]  <=  kb[31];
        kb[41]  <=  kb[32];
        kb[51]  <=  kb[33];
        kb[35]  <=  kb[34];
        kb[52]  <=  kb[35];
        kb[12]  <=  kb[36];
        kb[22]  <=  kb[37];
        kb[48]  <=  kb[38];
        kb[30]  <=  kb[39];
        kb[58]  <=  kb[40];
        kb[45]  <=  kb[41];
        kb[31]  <=  kb[42];
        kb[8]   <=  kb[43];
        kb[25]  <=  kb[44];
        kb[23]  <=  kb[45];
        kb[47]  <=  kb[46];
        kb[61]  <=  kb[47];
        kb[17]  <=  kb[48];
        kb[60]  <=  kb[49];
        kb[5]   <=  kb[50];
        kb[56]  <=  kb[51];
        kb[43]  <=  kb[52];
        kb[11]  <=  kb[53];
        kb[6]   <=  kb[54];
        kb[10]  <=  kb[55];
        kb[44]  <=  kb[56];
        kb[32]  <=  kb[57];
        kb[63]  <=  kb[58];
        kb[46]  <=  kb[59];
        kb[15]  <=  kb[60];
        kb[3]   <=  kb[61];
        kb[38]  <=  kb[62];
        kb[16]  <=  kb[63];
        kb[55]  <=  kb[64];
    end
end

always@(posedge clk)
begin
    if(nrst==1'b0)
    begin
        ni  <=  6'b11_0111;
    end
    else if((ld==1'b1) && (ldkey_end==1'b0))
    begin
        ni          <=  6'b11_0111;
        block_end   <=  1'b0;
    end
    else if(ni==6'b00_0000)
    begin
        ni          <=  ni;
        block_end   <=  1'b1;
    end
    else
    begin
        ni  <=  ni - 'h1;
    end
end

assign  kv  =   (ni[3:5]==3'b000)   ?   kb[1:8]     :
                (ni[3:5]==3'b001)   ?   kb[9:16]    :
                (ni[3:5]==3'b010)   ?   kb[17:24]   :
                (ni[3:5]==3'b011)   ?   kb[25:32]   :
                (ni[3:5]==3'b100)   ?   kb[33:40]   :
                (ni[3:5]==3'b101)   ?   kb[41:48]   :
                (ni[3:5]==3'b110)   ?   kb[49:56]   :   
                kb[57:64];

endmodule
