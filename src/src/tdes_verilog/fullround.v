module fullround(
    pt                          ,
    xkey                        ,
    reset                       ,
    clk                         ,
    load_new_pt                 ,
    output_ok                   ,
    ct                          
    );
    
input   [1:64]                          pt                          ;
input   [1:48]                          xkey                        ;
input                                   reset                       ;
input                                   clk                         ;
input                                   load_new_pt                 ;
input                                   output_ok                   ;
output  [1:64]                          ct                          ;

wire    [1:32]                          left_in                     ;
wire    [1:32]                          right_in                    ;
wire    [1:32]                          mux_l_to_round              ;
wire    [1:32]                          mux_r_to_round              ;
wire    [1:32]                          round_l_to_ov               ;
wire    [1:32]                          round_r_to_ov               ;
wire    [1:32]                          ov_l_to_mux                 ;
wire    [1:32]                          ov_r_to_mux                 ;
wire    [1:32]                          ov_l_to_fp                  ;
wire    [1:32]                          ov_r_to_fp                  ;
                                                                    ;
ip initial_p(
    .pt                                 ( pt                        ),
    .l0x                                ( left_in                   ),
    .r0x                                ( right_in                  )
    );

mux32 mux_left(
    .e0                                 ( ov_l_to_mux               ),
    .e1                                 ( left_in                   ),
    .o                                  ( mux_l_to_round            ),
    .sel                                ( load_new_pt               )
    );

mux32 mux_right(
    .e0                                 ( ov_r_to_mux               ),
    .e1                                 ( right_in                  ),
    .o                                  ( mux_r_to_round            ),
    .sel                                ( load_new_pt               )
    );

roundfunc round(
    .clk                                ( clk                       ),
    .reset                              ( reset                     ),
    .li                                 ( mux_l_to_round            ),
    .ri                                 ( mux_r_to_round            ),
    .k                                  ( xkey                      ),
    .lo                                 ( round_l_to_ov             ),
    .ro                                 ( round_r_to_ov             )
    );
    
ov32 ov_left(
    .e                                  ( round_l_to_ov             ),
    .o1                                 ( ov_l_to_mux               ),
    .o2                                 ( ov_l_to_fp                ),
    .clk                                ( clk                       ),
    .sel                                ( output_ok                 )
    );

ov32 ov_right(
    .e                                  ( round_r_to_ov             ),
    .o1                                 ( ov_r_to_mux               ),
    .o2                                 ( ov_r_to_fp                ),
    .clk                                ( clk                       ),
    .sel                                ( output_ok                 )
    );

fp final_p(
    .l                                  ( ov_r_to_fp                ),
    .r                                  ( ov_l_to_fp                ),
    .ct                                 ( ct                        )
    );

endmodule
