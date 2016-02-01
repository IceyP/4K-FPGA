module TDES_Top(
	clk                         ,
	reset                       ,
	mode                        ,
	ready                       ,
	in_data                     ,
	key1                        ,
	key2                        ,
	out_data                    ,
	output_ok 
	);

input                                   clk                         ;
input                                   reset                       ;
input                                   mode                        ;
input                                   ready                       ;
input   [1:64]                          in_data                     ;
input   [1:64]                          key1                        ;
input   [1:64]                          key2                        ;
output  [1:64]                          out_data                    ;
output                                  output_ok                   ;

wire    [1:64]                          key_i                       ;
wire    [1:64]                          tmp_i                       ;
wire    [1:64]                          tmp_o                       ;
reg                                     des_mode                    ;
reg                                     rdy_i                       ;
wire                                     out_ok_i                    ;
reg                                     output_ok_reg               ;
reg                                     load_tmp_i                  ; 
reg     [1:0]                           load_key_i                  ; 

reg     [3:0]                           state                       ;
reg     [3:0]                           state_next                  ;

parameter   IDLE                        = 4'd0                      ,
            DE_ST1                      = 4'd1                      ,
            DE_DE1                      = 4'd2                      ,
            DE_OUT1                     = 4'd3                      ,
            DE_ST2                      = 4'd4                      ,
            DE_EN                       = 4'd5                      ,
            DE_OUT2                     = 4'd6                      ,
            DE_ST3                      = 4'd7                      ,
            DE_DE2                      = 4'd8                      ,
            DE_OUT3                     = 4'd9                      ;          

assign output_ok=output_ok_reg;

assign out_data = (output_ok_reg == 1) ? tmp_o : 0;
assign tmp_i = (load_tmp_i == 1) ? in_data : tmp_o;
assign key_i = (load_key_i==2'b01) ? key1 :
		        (load_key_i==2'b10) ? key2 : 
		        (load_key_i==2'b11) ? key1 :
		        64'd0;

always@*
begin
    case(state)
    IDLE:
    begin
        output_ok_reg=1'b0;
        rdy_i=1'b0;
        load_tmp_i=1'b0;
        load_key_i=2'b00; 
        if ((mode == 1) && (ready==1))
        begin
            state_next=DE_ST1;
            rdy_i=1'b1;
            des_mode=1'b1;
            load_tmp_i=1'b1;
            load_key_i=2'b11;
        end
        else if ((mode==1) && (ready==0))
        begin
            state_next=IDLE;
            rdy_i=1'b0;
            des_mode=1'b1;
            load_tmp_i=1'b0;
            load_key_i=2'b00;
        end
        else
        begin
            state_next=IDLE;
            rdy_i=1'b1;
            des_mode=1'b0;
            load_tmp_i=1'b1;
            load_key_i=2'b01;
        end
    end 
    
    DE_ST1:
    begin
        load_tmp_i=1'b1;
        load_key_i=2'b11;
        output_ok_reg=1'b0;
        des_mode=1'b1;
        rdy_i=1'b0;
        state_next=DE_DE1; 
    end
    
    DE_DE1:
    begin
        load_tmp_i=1'b1;
        load_key_i=2'b11;
        output_ok_reg=1'b0;
        des_mode=1'b1;
        rdy_i=1'b0;
        if (out_ok_i == 1) 
            state_next=DE_OUT1;				
        else
            state_next=DE_DE1;
    end
    
    DE_OUT1:
    begin
        load_tmp_i=1'b0;
        load_key_i=2'b10;
        output_ok_reg=1'b0;
        des_mode=1'b0;
        rdy_i=1'b1;
        state_next=DE_ST2;
    end
    	
    DE_ST2:
    begin
        load_tmp_i=1'b0;
        load_key_i=2'b10;
        output_ok_reg=1'b0;
        des_mode=1'b0;
        rdy_i=1'b0;
        state_next=DE_EN;
    end
    
    DE_EN:
    begin
        load_tmp_i=1'b0;
        load_key_i=2'b10;
        output_ok_reg=1'b0;
        des_mode=1'b0;
        rdy_i=1'b0;
        if (out_ok_i==1)
            state_next=DE_OUT2;
        else
            state_next=DE_EN;
    end
    
    DE_OUT2:
    begin
        load_tmp_i=1'b0;
        load_key_i=2'b01;
        output_ok_reg=1'b0;
        des_mode=1'b1;
        rdy_i=1'b1;
        state_next=DE_ST3;
    end
    
    DE_ST3:
    begin
        load_tmp_i=1'b0;
        load_key_i=2'b01;
        output_ok_reg=1'b0;
        des_mode=1'b1;
        rdy_i=1'b0;
        state_next=DE_DE2;
    end
    
    DE_DE2:
    begin
        load_tmp_i=1'b0;
        load_key_i=2'b01;
        output_ok_reg=1'b0;
        des_mode=1'b1;
        rdy_i=1'b0;
        if (out_ok_i==1)
            state_next=DE_OUT3;
        else
            state_next=DE_DE2;			 	
    end
    
    DE_OUT3:
    begin
        load_tmp_i=1'b0;
        load_key_i=2'b01;
        output_ok_reg=1'b1;
        des_mode=1'b1;
        rdy_i=1'b0;
        state_next=IDLE;
    end	
    
    default:;
    endcase
end

always@(posedge clk)
begin
    if (reset == 1)
        state<=IDLE;
    else
        state<=state_next;
end

state_encrypt u0_state_encrypt(
    .pt                                 ( tmp_i                     ),	
    .key                                ( key_i                     ),
    .clk                                ( clk                       ),
    .ready                              ( rdy_i                     ),
    .mode                               ( des_mode                  ),
    .reset                              ( reset                     ),
    .ct                                 ( tmp_o                     ),
    .out_ok                             ( out_ok_i                  )
    );

endmodule

