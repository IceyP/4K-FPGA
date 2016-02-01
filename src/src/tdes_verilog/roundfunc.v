module roundfunc(
    clk                         ,
    reset                       ,
    li                          ,
    ri                          ,
    k                           ,
    lo                          ,
    ro                          
    );
    
input                                   clk                         ;
input                                   reset                       ;
input   [1:32]                          li                          ;
input   [1:32]                          ri                          ;
input   [1:48]                          k                           ;
output  [1:32]                          lo                          ;
output  [1:32]                          ro                          ;

wire    [1:48]                          xp_to_xor                   ;
wire    [1:6]                           b1x,b2x,b3x,b4x             ;
wire    [1:6]                           b5x,b6x,b7x,b8x             ;
wire    [1:4]                           so1x,so2x,so3x,so4x         ;
wire    [1:4]                           so5x,so6x,so7x,so8x         ;
wire    [1:32]                          ppo,r_toreg32,l_toreg32     ;

xp xpension(
    .ri                                 ( ri                        ),
    .e                                  ( xp_to_xor                 )
    );

desxor1 des_xor1(
    .e                                  ( xp_to_xor                 ),
    .k                                  ( k                         ),
    .b1x                                ( b1x                       ),
    .b2x                                ( b2x                       ),
    .b3x                                ( b3x                       ),
    .b4x                                ( b4x                       ),
    .b5x                                ( b5x                       ),
    .b6x                                ( b6x                       ),
    .b7x                                ( b7x                       ),
    .b8x                                ( b8x                       )
    );
    
s1_box s1a(
    .A                                  ( b1x                       ),
    .SPO                                ( so1x                      )
    );

s2_box s2a(
    .A                                  ( b2x                       ),
    .SPO                                ( so2x                      )
    );
    
s3_box s3a(
    .A                                  ( b3x                       ),
    .SPO                                ( so3x                      )
    );

s4_box s4a(
    .A                                  ( b4x                       ),
    .SPO                                ( so4x                      )
    );

s5_box s5a(
    .A                                  ( b5x                       ),
    .SPO                                ( so5x                      )
    );

s6_box s6a(
    .A                                  ( b6x                       ),
    .SPO                                ( so6x                      )
    );

s7_box s7a(
    .A                                  ( b7x                       ),
    .SPO                                ( so7x                      )
    );

s8_box s8a(
    .A                                  ( b8x                       ),
    .SPO                                ( so8x                      )
    );

pp pperm(
    .so1x                               ( so1x                      ),
    .so2x                               ( so2x                      ),
    .so3x                               ( so3x                      ),
    .so4x                               ( so4x                      ),
    .so5x                               ( so5x                      ),
    .so6x                               ( so6x                      ),
    .so7x                               ( so7x                      ),
    .so8x                               ( so8x                      ),
    .ppo                                ( ppo                       )
    );
    
desxor2 des_xor2(
    .d                                  ( ppo                       ),
    .l                                  ( li                        ),
    .q                                  ( r_toreg32                 )
    );
    
assign  l_toreg32   =   ri;

reg32 register32_left(
    .a                                  ( l_toreg32                 ),
    .q                                  ( lo                        ),
    .reset                              ( reset                     ),
    .clk                                ( clk                       )
    );

reg32 register32_right(
    .a                                  ( r_toreg32                 ),
    .q                                  ( ro                        ),
    .reset                              ( reset                     ),
    .clk                                ( clk                       )
    );

endmodule
