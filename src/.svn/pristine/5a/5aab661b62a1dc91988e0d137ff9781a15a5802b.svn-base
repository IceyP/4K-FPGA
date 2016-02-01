//-----------------------------------------------------------------------------
// CRC module for
//       data[7:0]
//       crc[15:0]=1+x^2+x^15+x^16;
//
module crc16_d8(
    input   [7:0] d,
    input         crc_en,
    output  [15:0] crc_out,
    input         rst,
    input         clk);

reg [15:0] c,lfsr_c;

assign crc_out = c;

always @(*) 
begin
    lfsr_c[0] = c[8] ^ c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15] ^ d[0] ^ d[1] ^ d[2] ^ d[3] ^ d[4] ^ d[5] ^ d[6] ^ d[7];
    lfsr_c[1] = c[9] ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15] ^ d[1] ^ d[2] ^ d[3] ^ d[4] ^ d[5] ^ d[6] ^ d[7];
    lfsr_c[2] = c[8] ^ c[9] ^ d[0] ^ d[1]; 
    lfsr_c[3] = c[9] ^ c[10] ^ d[1] ^ d[2]; 
    lfsr_c[4] = c[10] ^ c[11] ^ d[2] ^ d[3]; 
    lfsr_c[5] = c[11] ^ c[12] ^ d[3] ^ d[4]; 
    lfsr_c[6] = c[12] ^ c[13] ^ d[4] ^ d[5]; 
    lfsr_c[7] = c[13] ^ c[14] ^ d[5] ^ d[6]; 
    lfsr_c[8] = c[0] ^ c[14] ^ c[15] ^d[6]  ^ d[7]; 
    lfsr_c[9] = c[1] ^ c[15] ^ d[7]; 
    lfsr_c[10]= c[2]; 
    lfsr_c[11]= c[3]; 
    lfsr_c[12]= c[4]; 
    lfsr_c[13]= c[5]; 
    lfsr_c[14]= c[6]; 
    lfsr_c[15] = c[7]  ^ c[8]  ^ c[9]  ^ c[10] ^ c[11] ^ c[12] ^ c[13] ^ c[14] ^ c[15] ^ d[0] ^ d[1] ^ d[2] ^ d[3] ^ d[4] ^ d[5] ^ d[6] ^ d[7];
end

always @(posedge clk or posedge rst) 
begin
    if(rst) 
    begin
        c  <= {16{1'b1}};
    end
    else if(crc_en==1'b1)
    begin
        c  <= lfsr_c;
    end
end

endmodule