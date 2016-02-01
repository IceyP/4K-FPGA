//--------------------------------------------------------------------------------------------------
// (c)2010 CTI Corporation. All righpayload_in reserved.

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
// File          : $ pid_filt_info.v$
// Last modified : $Date: 2015/2/4 $
// Author        : Z.J.K
//--------------------------------------------------------------------------------------------------

module pid_filt_info #(
  parameter TS_PROCESS_BASE_ADD       = 12'h800,              
  parameter P_BUS_ADDR_WIDTH          = 16,
  parameter P_BUS_DATA_WIDTH          = 8,
  parameter PAYLOAD_DATA_WIDTH        = 8 
)(
  // Receive Transport stream 
   input                                 payload_clk,
   input                                 payload_rst,
   input                                 payload_in_valid,
   input                                 payload_in_start,
   input                                 payload_in_end,
   input      [PAYLOAD_DATA_WIDTH-1:0]   payload_in_data,
   output reg                            search_over,
 
  input                                  bus_clk,                     // Avalon-MM register interface
  input                                  bus_rst,
  input                                  bus_read,
  input                                  bus_write,
  input       [P_BUS_ADDR_WIDTH-1:0]     bus_address,
  input       [P_BUS_DATA_WIDTH-1:0]     bus_writedata,
  output reg  [PAYLOAD_DATA_WIDTH-1:0]   t_match_listnum,
  output reg                             t_match   
);
 
    
//--------------------------------------------------------------------------------------------------
// parameters
`include "alt_clogb2.v" 
localparam P_MAX_SEARCH_CYCLES = 64;          // Maximum number of clock cycles allowed for socket search
//--------------------------------------------------------------------------------------------------
// port_and_pid RAM. Written by host processor, read by port_and_pid matcher.
// For larger channel count configurations, multiple RAM's are put in parallel to allow more than
// one channel to be checked in a single cycle by the port_and_pid matcher.
//--------------------------------------------------------------------------------------------------
//512*32=1m36k
localparam               P_RAM_DEPTH     = 128;
localparam               P_RAM_ADDR_BITS = alt_clogb2(P_RAM_DEPTH);
localparam               P_RAM_WIDTH     = 128;
            
reg  [P_RAM_ADDR_BITS-1:0]               info_ram_address;
wire [P_RAM_WIDTH-1:0]                   info_ram_readdata;
reg  [P_RAM_ADDR_BITS-1:0]               bus_ram_address; 
reg                                      bus_ram_write;
wire [P_RAM_WIDTH-1:0]                   bus_ram_writedata;  
wire [P_RAM_WIDTH-1:0]                   s_match_info;
wire [P_RAM_WIDTH-1:0]                   s_match_info_mask;
reg  [P_RAM_WIDTH-1:0]                   info_ram_readdata_1dly;

           
      
sdp_ram_d128_w128 map_ram(
  .clka                  (bus_clk),
  .addra                 (bus_ram_address),
  .wea                   (bus_ram_write ),
  .dina                  (bus_ram_writedata),
  .clkb                  (payload_clk),
  .addrb                 (info_ram_address),
  .doutb                 (info_ram_readdata)
);

always @ (posedge payload_clk)
begin
  info_ram_readdata_1dly    <=  info_ram_readdata;
end
    
assign s_match_info      = (info_ram_address[0] == 1'b0)? info_ram_readdata : info_ram_readdata_1dly;
assign s_match_info_mask = (info_ram_address[0] == 1'b1)? info_ram_readdata : info_ram_readdata_1dly;



//--------------------------------------------------------------------------------------------------
// Avalon interface and control registers
//--------------------------------------------------------------------------------------------------
localparam  TS_PIDFILTER_SET  =  TS_PROCESS_BASE_ADD + 'd0 ;
localparam  DATA_BYTE_NUM     =  P_RAM_WIDTH/P_BUS_DATA_WIDTH; //16
localparam  DATA_INDEX_OFFSET =  alt_clogb2(DATA_BYTE_NUM);//4

reg [P_BUS_DATA_WIDTH-1:0]    info_data [DATA_BYTE_NUM-1:0];
reg                           ram_init;
integer                       i;                       
always @ (posedge bus_clk or posedge bus_rst)
begin
  if (bus_rst) begin
    bus_ram_write    <= 1'b0;
    bus_ram_address  <= 0;
    ram_init <= 1'b1;
    for(i=0;i<DATA_BYTE_NUM;i=i+1)begin
    	info_data[i] <= 0;
    end
  end
  else if(ram_init)begin
  	bus_ram_address <= bus_ram_address + 'b1; 
  	bus_ram_write    <= 1'b1;
  	if(bus_ram_address == P_RAM_DEPTH-1)begin
  		ram_init <=1'b0; 
    end	
  end
  // Process accesses
  else begin
    bus_ram_write      <= bus_write;  
    bus_ram_address    <= bus_address[P_RAM_ADDR_BITS+DATA_INDEX_OFFSET-1:DATA_INDEX_OFFSET];
    info_data[bus_address[DATA_INDEX_OFFSET-1:0]]  <= bus_writedata;      
  end
end
assign bus_ram_writedata = ram_init?{P_RAM_WIDTH{1'b1}}: {info_data[0],info_data[1],info_data[2],info_data[3],
                                                          info_data[4],info_data[5],info_data[6],info_data[7],
                                                          info_data[8],info_data[9],info_data[10],info_data[11],
                                                          info_data[12],info_data[13],info_data[14],info_data[15]};
//--------------------------------------------------------------------------------------------------
// Store port_and_pid info from receive packet  for use by matcher ;
//--------------------------------------------------------------------------------------------------
reg  [2:0]            match_state;
localparam            IDLE                = 0;
localparam            PAP_SAVE            = 1;    //PAP=POTR AND port_and_pid SAVE
localparam            MATCH_INFO_REG      = 2;
localparam            WAIT_MATCH_INFO     = 3;
localparam            MATCH_INFO_ING      = 4;
localparam            MATCH_SUCESS        = 5;
localparam            SEARCH_OVER         = 6;



reg   [P_RAM_WIDTH-1:0]                  port_and_pid;
reg   [DATA_INDEX_OFFSET-1:0]            byte_count;
(*keep = "true"*)
wire  [P_RAM_WIDTH-1:0]                  d_match_info = port_and_pid & s_match_info_mask;
     
  
always @ (posedge payload_clk or posedge payload_rst)
begin
  if(payload_rst)
  begin
    match_state <= IDLE;
    port_and_pid<=0;
    t_match <= 1'b0;
    t_match_listnum <= 0;
    info_ram_address <=0; 
    search_over <=1'b0;
    byte_count <= 0;
  end
  else 
  begin
    case(match_state)
      IDLE:
      begin
        if(payload_in_start & payload_in_valid)
        begin 
          search_over <=1'b0;
          info_ram_address <= 0;
          t_match_listnum <= 0;
          t_match <= 1'b0;
          port_and_pid[PAYLOAD_DATA_WIDTH-1:0] <= {payload_in_data[3:0],4'b0};
          byte_count <= 0;
          match_state<=PAP_SAVE;
        end
      end
      
      PAP_SAVE:
      begin
        if(payload_in_valid) 
        begin 
        	byte_count <= byte_count + 1'b1; 
          port_and_pid <= {port_and_pid[(P_RAM_WIDTH-PAYLOAD_DATA_WIDTH-1):0],payload_in_data};
          if(byte_count == (DATA_BYTE_NUM - 2))begin
            info_ram_address <= info_ram_address + 'd1;
            match_state <= MATCH_INFO_REG;
          end
        end
      end 
      
      MATCH_INFO_REG: begin 
        info_ram_address <= info_ram_address + 'd1;
        match_state <= WAIT_MATCH_INFO;
      end
      
      WAIT_MATCH_INFO:begin 
        info_ram_address <= info_ram_address + 'd1;
        match_state <= MATCH_INFO_ING;
      end 
           
      MATCH_INFO_ING:
      begin
        if((t_match_listnum>=P_MAX_SEARCH_CYCLES) || (payload_in_end == 1'b1))begin
          match_state <= SEARCH_OVER;
        end
        else begin
          if(s_match_info == d_match_info)begin      
            match_state <= MATCH_SUCESS;
          end
          else begin
            info_ram_address <= info_ram_address + 'd1;
            t_match_listnum <=  t_match_listnum + 'd1;
            match_state <= WAIT_MATCH_INFO;
          end
        end
      end
      
      MATCH_SUCESS:begin
     	  t_match <= 1'b1;
     	  match_state <= SEARCH_OVER;
      end  
       
      SEARCH_OVER:
      begin 
        search_over <=1'b1;
        match_state <= IDLE;
      end
    
      default : match_state <= IDLE;
    endcase
  end
end
endmodule
