module b_cipher(
    ck                          ,
    ri                          ,
    ro                          ,
    ldkey_cnt                   ,
    clk                         ,
    ld                          ,
    nrst                        ,
    b_end                       ,
    ldkey_end                   
    );

input   [0:7]                           ck                          ;
input   [0:63]                          ri                          ;
output  [0:63]                          ro                          ;
input   [0:2]                           ldkey_cnt                   ;
input                                   clk                         ;
input                                   ld                          ;
input                                   nrst                        ;
output                                  b_end                       ;
input                                   ldkey_end                   ;

wire    [7:0]                           sbox_add                    ;
wire    [7:0]                           sbox                        ;
wire    [0:7]                           kk                          ;
wire    [0:7]                           sbox_buf                    ;
wire    [0:7]                           sbox_add_buf                ;

assign  sbox_buf    =   {sbox[0],sbox[1],sbox[2],sbox[3],sbox[4],sbox[5],sbox[6],sbox[7]};
//assign  sbox_add_buf=   {sbox_add[0],sbox_add[1],sbox_add[2],sbox_add[3],sbox_add[4],sbox_add[5],sbox_add[6],sbox_add[7]};
assign  sbox_add    =   {sbox_add_buf[7],sbox_add_buf[6],sbox_add_buf[5],sbox_add_buf[4],sbox_add_buf[3],sbox_add_buf[2],sbox_add_buf[1],sbox_add_buf[0]};

sbox_rom u0_sbox_rom(
    .addra                              ( sbox_add                  ),
    .clka                               ( clk                       ),
    .douta                              ( sbox                      ),
    .ena                                ( 1'b1                      )
    );

block_decipher u0_block_decipher(
    .from_box                           ( sbox_buf                  ),
    .kk                                 ( kk                        ),
    .ri                                 ( ri                        ),
    .ro                                 ( ro                        ),
    .to_box                             ( sbox_add_buf              ),  
    .clk                                ( clk                       ),
    .ld                                 ( ld                        ),
    .nrst                               ( nrst                      ),
    .ldkey_end                          ( ldkey_end                 )
    );
    
key_schedule u0_key_schedule(
    .ck                                 ( ck                        ),
    .kk                                 ( kk                        ),
    .ldkey_cnt                          ( ldkey_cnt                 ),
    .clk                                ( clk                       ),
    .nrst                               ( nrst                      ),
    .ld                                 ( ld                        ),
    .b_end                              ( b_end                     ),
    .ldkey_end                          ( ldkey_end                 )
    );

endmodule
