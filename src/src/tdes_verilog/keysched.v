module keysched(
    the_key                     ,
    shift                       ,
    clk                         ,
    ki                          
    );

input   [1:64]                          the_key                     ;
input   [1:3]                           shift                       ;
input                                   clk                         ;
output  [1:48]                          ki                          ;

wire    [1:28]                          c                           ;
wire    [1:28]                          d                           ;
wire    [1:28]                          c1                          ;
wire    [1:28]                          d1                          ;
pc1 pc_1(
    .key                                ( the_key                   ),
    .c0x                                ( c                         ),
    .d0x                                ( d                         )
    );
    
shifter shifter_comp(
    .datac                              ( c                         ),
    .datad                              ( d                         ),
    .shift                              ( shift                     ),
    .clk                                ( clk                       ),
    .datac_out                          ( c1                        ),
    .datad_out                          ( d1                        )
    );

pc2 pc_2(
    .c                                  ( c1                        ),
    .d                                  ( d1                        ),
    .k                                  ( ki                        )
    );

endmodule
