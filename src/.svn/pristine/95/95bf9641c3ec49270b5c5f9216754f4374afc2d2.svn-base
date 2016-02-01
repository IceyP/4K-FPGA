
//--------------------------------------------------------------------------------------------------
// File          : $ pid_filter.v$
// Last modified : $Date: 2015/08/22 $
// Author        : Z.J.K
//--------------------------------------------------------------------------------------------------

module pid_filter #(
  parameter TS_PROCESS_BASE_ADD       = 12'h800,                 
  parameter P_BUS_ADDR_WIDTH          = 16,
  parameter P_BUS_DATA_WIDTH          = 8,
  parameter PAYLOAD_DATA_WIDTH        = 8
 
)(
  // Receive Transport stream 
  input                                  payload_clk,
  input                                  payload_rst,
  input                                  payload_in_valid,
  input                                  payload_in_start,
  input                                  payload_in_end,
  input  [PAYLOAD_DATA_WIDTH-1:0]        payload_in_data,
  
  input                                  payload_out_req,   
  output wire                            payload_out_valid, 
  output wire                            payload_out_start, 
  output wire                            payload_out_end,   
  output wire[PAYLOAD_DATA_WIDTH-1:0]    payload_out_data,  
  output wire                            payload_out_rdy,   

  input                                  bus_clk, 
  input                                  bus_rst,
  input                                  bus_read,
  input                                  bus_write,
  input       [P_BUS_ADDR_WIDTH-1:0]     bus_address,
  input       [P_BUS_DATA_WIDTH-1:0]     bus_writedata,
  output wire [P_BUS_DATA_WIDTH-1:0]     bus_readdata
);
`include "alt_clogb2.v"  
/*---------------------------int match info------------------*/
wire                                 search_over;
wire  [PAYLOAD_DATA_WIDTH-1:0]       t_match_listnum;
wire                                 t_match;
      
pid_filt_info #(
   .TS_PROCESS_BASE_ADD        (TS_PROCESS_BASE_ADD),           
   .P_BUS_ADDR_WIDTH           (P_BUS_ADDR_WIDTH),
   .P_BUS_DATA_WIDTH           (P_BUS_DATA_WIDTH),
   .PAYLOAD_DATA_WIDTH         (PAYLOAD_DATA_WIDTH)
)u_pid_filt_info(
  // Receive Transport stream 
   .payload_clk                (payload_clk),
   .payload_rst                (payload_rst),
   .payload_in_valid           (payload_in_valid),
   .payload_in_start           (payload_in_start) ,
   .payload_in_end             (payload_in_end),
   .payload_in_data            (payload_in_data),
   .search_over                (search_over),
  // Avalon-MM register interface
   .bus_clk                    (bus_clk) ,                    
   .bus_rst                    (bus_rst),
   .bus_read                   (bus_read),
   .bus_write                  (bus_write),
   .bus_address                (bus_address),
   .bus_writedata              (bus_writedata),
   .t_match_listnum            (t_match_listnum),
   .t_match                    (t_match)   
);

match_pack_buf #(
  .PAYLOAD_DATA_WIDTH         (PAYLOAD_DATA_WIDTH)                     
)u_match_buf(
  .payload_rst                (payload_rst),
  .payload_out_clk            (payload_clk),

  .payload_in_clk             (payload_clk),
  .payload_in_valid           (payload_in_valid),
  .payload_in_start           (payload_in_start),
  .payload_in_end             (payload_in_end),
  .payload_in_data            (payload_in_data),
                           
  .payload_out_req            (payload_out_req),
  .payload_out_valid          (payload_out_valid),
  .payload_out_start          (payload_out_start),
  .payload_out_end            (payload_out_end),
  .payload_out_data           (payload_out_data),
  .payload_out_rdy            (payload_out_rdy),
                            
  .match_flag                 (t_match),
  .match_index                (t_match_listnum),//pid filter list num 
  .match_over                 (search_over)
    
);

endmodule
