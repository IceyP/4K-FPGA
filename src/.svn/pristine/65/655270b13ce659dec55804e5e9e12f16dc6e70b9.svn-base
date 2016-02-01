module block_decipher(
    nrst                        ,
    clk                         ,
    ld                          ,
    ldkey_end                   ,
    ri                          ,
    kk                          ,
    from_box                    ,
    ro                          ,
    to_box
    );

input                                   nrst                        ;
input                                   clk                         ;
input                                   ld                          ;
input                                   ldkey_end                   ;
input   [0:63]                          ri                          ;
input   [0:7]                           kk                          ;
input   [0:7]                           from_box                    ;

output  [0:63]                          ro                          ;                                   
output  [0:7]                           to_box                      ;

reg     [0:63]                          r                           ;
wire    [0:7]                           fb                          ;
wire    [0:7]                           pb                          ;
wire    [0:7]                           t_box                       ;
wire    [0:7]                           f_box                       ;
wire    [0:7]                           tmp                         ;

assign  to_box[0]   =   t_box[7];
assign  to_box[1]   =   t_box[6];
assign  to_box[2]   =   t_box[5];
assign  to_box[3]   =   t_box[4];
assign  to_box[4]   =   t_box[3];
assign  to_box[5]   =   t_box[2];
assign  to_box[6]   =   t_box[1];
assign  to_box[7]   =   t_box[0];

assign  f_box[0]    =   from_box[7];
assign  f_box[1]    =   from_box[6];
assign  f_box[2]    =   from_box[5];
assign  f_box[3]    =   from_box[4];
assign  f_box[4]    =   from_box[3];
assign  f_box[5]    =   from_box[2];
assign  f_box[6]    =   from_box[1];
assign  f_box[7]    =   from_box[0];

assign  tmp     =   ((ld & ldkey_end)==1'b1)    ?   r[48:55]    :   (r[40:47] ^ pb);
assign  t_box   =   kk ^ tmp;
assign  fb      =   r[56:63] ^ f_box;
assign  ro      =   r;

assign  pb[4]   =   f_box[0];
assign  pb[7]   =   f_box[1];
assign  pb[1]   =   f_box[2];
assign  pb[5]   =   f_box[3];
assign  pb[3]   =   f_box[4];
assign  pb[2]   =   f_box[5];
assign  pb[0]   =   f_box[6];
assign  pb[6]   =   f_box[7];

always@(posedge clk)
begin
    if(nrst==1'b0)
    begin
        r   <=  {64{1'b0}};
    end
    else if(ld==1'b1)
    begin
        r   <=  ri;
    end
    else
    begin
        r[0:7]      <=  fb;
        r[8:15]     <=  r[0:7];
        r[16:23]    <=  r[8:15] ^ fb;
        r[24:31]    <=  r[16:23] ^ fb;
        r[32:39]    <=  r[24:31] ^ fb;
        r[40:47]    <=  r[32:39];
        r[48:55]    <=  r[40:47] ^ pb;
        r[56:63]    <=  r[48:55];
    end
end

endmodule
