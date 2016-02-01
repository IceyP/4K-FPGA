
module payload_8bit_to_32bit #(
  parameter IN_DATA_WIDTH         = 8,  
  parameter OUT_DATA_WIDTH        = 32   
)(
  // Receive Transport stream 
  input                                  payload_clk,
  input                                  payload_rst,
  
  input                                  payload_in_valid,
  input                                  payload_in_start,
  input                                  payload_in_end,
  input      [IN_DATA_WIDTH-1:0]         payload_in_data,
  
  input                                  payload_out_valid,
  input                                  payload_out_start,
  input                                  payload_out_end,
  input      [OUT_DATA_WIDTH-1:0]        payload_out_data
);

/*-----------------------------8bit to 32 bit-------------------------*/
localparam   SHIF_BITS = OUT_DATA_WIDTH/IN_DATA_WIDTH;   

reg  [OUT_DATA_WIDTH*SHIF_BITS-1:0]      payload_data_reg;
reg  [SHIF_BITS-1:0]                     payload_start_reg;
reg  [SHIF_BITS-1:0]                     payload_valid_reg; 
reg                                      payload_end_reg;

wire [OUT_DATA_WIDTH-1:0]     payload_out_data  = payload_data_reg;
wire                          payload_out_start = payload_start_reg[SHIF_BITS-1]; 
wire                          payload_out_valid = payload_valid_reg[SHIF_BITS-1];
wire                          payload_out_end   = payload_end_reg;  

always @ (posedge ts_clk or posedge ts_rst)
begin
	if(ts_rst)begin
    payload_start_reg <= 0;  
    payload_valid_reg <= 0;
    payload_data_reg  <= 0;
    payload_end_reg   <= 0;
	end
	else begin
		payload_start_reg <= {payload_start_reg[SHIF_BITS-2:0],payload_in_start};  
    payload_data_reg  <= {payload_data_reg[OUT_DATA_WIDTH-9:0],payload_in_data}
    payload_end_reg   <= payload_in_end;
    if(payload_in_start & payload_in_valid)begin
    	payload_valid_reg <= {{(SHIF_BITS-1){1'b0}},1'b1};
    end
    else if(payload_in_valid)begin
    	payload_valid_reg <= {payload_valid_reg[SHIF_BITS-2:0],payload_valid_reg[SHIF_BITS-1]};
    end
    else if(payload_end_reg)begin
    	payload_valid_reg <= {(SHIF_BITS){1'b0}};
    end
    else begin
    	payload_valid_reg <= payload_valid_reg;
    end    	
	end
end


endmodule