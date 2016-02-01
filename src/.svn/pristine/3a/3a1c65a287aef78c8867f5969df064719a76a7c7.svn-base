module desxor1(
    e                           ,
    b1x                         ,
    b2x                         ,
    b3x                         ,
    b4x                         ,
    b5x                         ,
    b6x                         ,
    b7x                         ,
    b8x                         ,
    k
    );
    
input   [1:48]                          e                           ;
input   [1:48]                          k                           ;
output  [1:6]                           b1x,b2x,b3x,b4x             ;
output  [1:6]                           b5x,b6x,b7x,b8x             ;

wire    [1:48]                          xx                          ;

assign  xx  =   k ^ e;
assign  b1x =   xx[1:6];
assign  b2x =   xx[7:12];    
assign  b3x =   xx[13:18];
assign  b4x =   xx[19:24];
assign  b5x =   xx[25:30];
assign  b6x =   xx[31:36];
assign  b7x =   xx[37:42];
assign  b8x =   xx[43:48];

endmodule
