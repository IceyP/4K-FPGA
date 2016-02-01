module dsc3(
    ck                          ,
    sb                          ,
    p                           ,
    db                          ,
    ldkey_cnt                   ,
    clk                         ,
    nrst                        ,
    st                          ,
    db_valid                    ,
    sreg_kv                     ,
    sreg_kv2                    ,
    sreg_kv3                    ,
    sreg_kv1
    );

input   [0:7]                           ck                          ;
input   [0:7]                           sb                          ;
input   [0:7]                           p                           ;
output  [0:7]                           db                          ;
output  [0:2]                           ldkey_cnt                   ;
input                                   clk                         ;
input                                   nrst                        ;
input                                   st                          ;
output                                  db_valid                    ;
output                                  sreg_kv                     ;
output                                  sreg_kv2                    ;
output                                  sreg_kv3                    ;
output                                  sreg_kv1                    ;

wire                                    X36_NET00005_X95            ;
wire                                    X36_NET00006_X95            ;
wire                                    X36_NET00001_X95            ;
wire                                    ldkey_end                   ;
wire    [0:2]                           ldkey_cnt_s                 ;
wire    [0:7]                           sreg_k                      ;
wire    [0:2]                           sreg_l                      ;
wire    [0:7]                           cb                          ;
wire    [0:63]                          ro                          ;
wire    [0:63]                          ri                          ;

assign  ldkey_cnt   =   ldkey_cnt_s;

b_cipher u0_b_cipher(
    .ck                                 ( ck                        ),
    .ri                                 ( ri                        ),
    .ro                                 ( ro                        ),
    .ldkey_cnt                          ( ldkey_cnt_s               ),
    .clk                                ( clk                       ),
    .ld                                 ( X36_NET00006_X95          ),
    .nrst                               ( nrst                      ),
    .ldkey_end                          ( ldkey_end                 )
    );

stream_cipher u0_stream_cipher(
    .ck                                 ( ck                        ),       
    .sb                                 ( sb                        ),
    .cb                                 ( cb                        ),
    .ldkey_cnt                          ( ldkey_cnt_s               ),
    .clk                                ( clk                       ),
    .ld                                 ( X36_NET00005_X95          ),
    .nrst                               ( nrst                      ),
    .sc_disable                         ( X36_NET00001_X95          )
    );
    
sreg u0_sreg(
    .cb                                 ( cb                        ),  
    .db                                 ( db                        ),
    .ri                                 ( ri                        ),
    .ro                                 ( ro                        ),
    .sb                                 ( sb                        ),
    .p                                  ( p                         ),
    .sreg_k                             ( sreg_k                    ),
    .sreg_l                             ( sreg_l                    ),
    .ldkey_cnt                          ( ldkey_cnt_s               ),
    .b_ld                               ( X36_NET00006_X95          ),
    .clk                                ( clk                       ),
    .db_valid                           ( db_valid                  ),
    .nrst                               ( nrst                      ),
    .sreg_kv                            ( sreg_kv                   ),
    .st                                 ( st                        ),
    .s_ldkey                            ( X36_NET00005_X95          ),
    .sc_disable                         ( X36_NET00001_X95          ),
    .sreg_kv3                           ( sreg_kv3                  ),
    .sreg_kv2                           ( sreg_kv2                  ),
    .sreg_kv1                           ( sreg_kv1                  ),
    .ldkey_end                          ( ldkey_end                 )
    );
    
endmodule
