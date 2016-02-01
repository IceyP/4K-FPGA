module state_encrypt(
    pt                          , 
	key                         ,
	clk                         ,
	ready                       ,
	mode                        ,
	reset                       ,
	ct                          ,
	out_ok 
    );
		
input   [1:64]                          pt                          ;
input   [1:64]                          key                         ;
input                                   clk                         ;
input                                   ready                       ;
input                                   mode                        ;
input                                   reset                       ;
output  [1:64]                          ct                          ;
output                                  out_ok                      ;

wire                                    load_new_pt                 ;
wire                                    output_ok                   ;
wire    [1:3]                           shift_sig                   ;
wire    [1:48]                          ki_sig                      ;
//	signal key_sig : std_logic_vector(1 to 64);
//	signal pt_sig : std_logic_vector(1 to 64);

control_new u0_control_new(
    .reset                              ( reset                     ),
    .clk                                ( clk                       ),
    .ready                              ( ready                     ),
    .mode                               ( mode                      ),
    .load_new_pt                        ( load_new_pt               ),
    .output_ok                          ( output_ok                 ),
    .shift                              ( shift_sig                 )
    );

fullround u0_fullround(
    .pt                                 ( pt                        ),
    .xkey                               ( ki_sig                    ),
    .reset                              ( reset                     ),
    .clk                                ( clk                       ),
    .load_new_pt                        ( load_new_pt               ),
    .output_ok                          ( output_ok                 ),
    .ct                                 ( ct                        )
    );
    
keysched u0_keysched(
    .the_key                            ( key                       ),
    .shift                              ( shift_sig                 ),
    .clk                                ( clk                       ),
    .ki                                 ( ki_sig                    )
	);

assign	out_ok = output_ok;
	
endmodule