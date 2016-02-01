
//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
// File          : $ ts_8bit_buffer.v$
// Last modified : $Date: 2015/1/22 $
// Author        : Z.J.K
//--------------------------------------------------------------------------------------------------
module ts_8bit_buffer #(
  parameter PAYLOAD_DATA_WIDTH        = 8                       
)(
  
  // Receive Transport stream 
   input                                  payload_in_rst,   
   input                                  payload_in_clk,
   input                                  payload_in_valid,
   input                                  payload_in_start,
   input                                  payload_in_end,
   input [PAYLOAD_DATA_WIDTH-1:0]         payload_in_data,
   output wire                            payload_req_in,
   
   input                                  payload_out_rst, 
   input                                  payload_out_clk,
   
   input                                  payload_out_req,
   output reg                             payload_out_valid,
   output reg  [PAYLOAD_DATA_WIDTH-1:0]   payload_out_data,
   output wire [PAYLOAD_DATA_WIDTH-1:0]   payload_buf_level    
);
`include "alt_clogb2.v"  
  

//-------------------------------------------------------------
// Buffer localparam
//--------------------------------------------------------------- 
localparam               P_TS_BUFFERS          = 5;  
localparam               P_TS_BUFFER_SIZE      = 192;      // Buffer size in 8bit dw  !!!!!!!!caution
localparam               P_TS_BUFFER_RAM_SIZE  = P_TS_BUFFERS * P_TS_BUFFER_SIZE;     // RAM size 8bit dw
localparam               P_TS_BUFFER_RAM_DBITS = alt_clogb2(P_TS_BUFFER_RAM_SIZE);
//--------------------------------------------------------------------------------------------------
// Write to the buffer
//--------------------------------------------------------------------------------------------------
   
reg                                       buffer_write;
reg  [PAYLOAD_DATA_WIDTH-1:0]             buffer_writedata;

reg  [alt_clogb2(P_TS_BUFFERS+1)-1:0]     write_level;
reg  [alt_clogb2(P_TS_BUFFERS+1)-1:0]     t_write_level;
reg  [alt_clogb2(P_TS_BUFFER_SIZE)-1:0]   write_offset;
reg  [alt_clogb2(P_TS_BUFFERS)-1:0]       write_entry;
wire [P_TS_BUFFER_RAM_DBITS-1:0]          buffer_write_baseadd;

reg                                       entry_written_tgl;
reg  [alt_clogb2(P_TS_BUFFERS)-1:0]       read_entry;
reg                                       entry_read_tgl;
reg                                       entry_read_tgl_d1;
reg                                       entry_read_tgl_d2;
reg                                       entry_read;                 
reg  [1:0]                                write_buffer_state;
reg                                       buf_overflow_flag_tgl;
//--------------------------------------------------------------------------------------------------
// Synchronise reset to the payload_in_clk clock
//--------------------------------------------------------------------------------------------------
wire         payload_rst        =    payload_in_rst | payload_out_rst; 
reg                                       payload_in_rst_syn;
reg                                       payload_in_rst_d1;
reg                                       payload_in_rst_d2;

reg                                       payload_out_rst_syn;
reg                                       payload_out_rst_d1;
reg                                       payload_out_rst_d2;

always @(posedge payload_in_clk )
begin
   if(payload_rst)
   begin
     payload_in_rst_d1   <= 1;
     payload_in_rst_d2   <= 1;
     payload_in_rst_syn  <= 1;
   end

   else
   begin
     payload_in_rst_d1   <= 0;
     payload_in_rst_d2   <= payload_in_rst_d1;
     payload_in_rst_syn  <= payload_in_rst_d2;
   end
end

always @(posedge payload_out_clk )
begin
   if(payload_rst)
   begin
     payload_out_rst_d1   <= 1;
     payload_out_rst_d2   <= 1;
     payload_out_rst_syn  <= 1;
   end

   else
   begin
     payload_out_rst_d1   <= 0;
     payload_out_rst_d2   <= payload_out_rst_d1;
     payload_out_rst_syn  <= payload_out_rst_d2;
   end
end 

/*------------------------------------------------------------------*/  
localparam               S_BUFFER_IDLE   = 0;
localparam               S_PAYLOAD       = 1;
localparam               S_PAYLOAD_OVER  = 2;

always @ (posedge payload_in_clk or posedge payload_in_rst_syn)
begin
  if(payload_in_rst_syn) begin
    write_buffer_state <= S_BUFFER_IDLE;
    buffer_write <= 1'b0;
    write_entry <= 0;
    write_level <= 0;
    t_write_level = 0;
    entry_written_tgl <= 1'b0;
    read_entry  <= 0;
    entry_read_tgl_d1 <= 1'b0;
    entry_read_tgl_d2 <= 1'b0;
    entry_read <= 1'b0;
    buffer_writedata <=0;   
    buf_overflow_flag_tgl <= 1'b0;   
  end // if (payload_rst)  
  else begin
    t_write_level = write_level;
    entry_read_tgl_d1 <= entry_read_tgl;
    entry_read_tgl_d2 <= entry_read_tgl_d1;
    entry_read <= (entry_read_tgl_d2!=entry_read_tgl_d1);

    if(entry_read & t_write_level>0) begin
      t_write_level = t_write_level - 'h1;
      if(read_entry==P_TS_BUFFERS-1)
        read_entry <= 0;
      else
      read_entry <= read_entry + 'h1;
    end
     
    buffer_write <= 1'b0;
    buffer_writedata <= 0;  
    case(write_buffer_state)
      S_BUFFER_IDLE : begin 
        if(payload_in_start & payload_in_valid) begin   
          if(write_level != P_TS_BUFFERS)begin
            write_offset <= 0;            
            buffer_write <= 1'b1;
            buffer_writedata <= payload_in_data; 
            write_buffer_state <= S_PAYLOAD;                 
          end
          else begin
            buf_overflow_flag_tgl <= ~buf_overflow_flag_tgl;
          end
        end
      end
      S_PAYLOAD : begin   
        buffer_write <= payload_in_valid;
        buffer_writedata <= payload_in_data;
        if(write_offset == P_TS_BUFFER_SIZE -1 )begin
          write_offset <= 0;
          entry_written_tgl <= ~entry_written_tgl;              
          t_write_level= t_write_level + 'h1;
          if(write_entry==P_TS_BUFFERS-1)begin
            write_entry <= 0;
          end
          else begin
            write_entry <= write_entry + 'h1;
          end
        end
        else begin
          write_offset  <= write_offset + payload_in_valid;
        end
            
        if(payload_in_end) begin
          write_buffer_state <= S_PAYLOAD_OVER;
        end 
      end
      
      S_PAYLOAD_OVER : begin
        entry_written_tgl <= ~entry_written_tgl;              
        t_write_level= t_write_level + 'h1;
        if(write_entry==P_TS_BUFFERS-1)begin
          write_entry <= 0;
        end
        else begin
          write_entry <= write_entry + 'h1;
        end
        write_buffer_state <= S_BUFFER_IDLE;         
      end 
        
    endcase // case (write_buffer_state)
    write_level <= t_write_level;
  end
end

assign buffer_write_baseadd = write_entry * P_TS_BUFFER_SIZE;
assign payload_req_in = (write_level<P_TS_BUFFERS)& (write_buffer_state==S_BUFFER_IDLE);

reg                                       buffer_write_reg;
reg  [PAYLOAD_DATA_WIDTH-1:0]             buffer_writedata_reg;
reg  [P_TS_BUFFER_RAM_DBITS-1:0]          buffer_write_address;

always @ (posedge payload_in_clk or posedge payload_in_rst)
begin
  if (payload_in_rst) begin
    buffer_write_reg <= 1'b0;
    buffer_writedata_reg <= 0;
    buffer_write_address <= 0; 
  end
  else begin
    buffer_write_address <= buffer_write_baseadd + write_offset;
    buffer_write_reg <= buffer_write;
    buffer_writedata_reg <= buffer_writedata;   
  end
end

//--------------------------------------------------------------------------------------------------
// Buffer RAM
//--------------------------------------------------------------------------------------------------
reg  [alt_clogb2(P_TS_BUFFERS+1)-1:0]     read_level;
wire [P_TS_BUFFER_RAM_DBITS-1:0]          buffer_read_address;
wire [PAYLOAD_DATA_WIDTH-1:0]             buffer_data_out;

sdp_ram_d1024_w8 u_ram (
  .clka    (payload_in_clk),
  .addra   (buffer_write_address),
  .wea     (buffer_write_reg),
  .dina    (buffer_writedata_reg),
               
  .clkb    (payload_out_clk),
  .addrb   (buffer_read_address),
  .doutb   (buffer_data_out)        
  );
  
//--------------------------------------------------------------------------------------------------
// Read from the buffer
//--------------------------------------------------------------------------------------------------// 
 
reg [1:0]                                 payload_out_state;
reg [alt_clogb2(P_TS_BUFFERS)-1:0]        payload_out_entry;
reg                                       entry_written_tgl_d1;
reg                                       entry_written_tgl_d2;
reg                                       entry_written;
reg [alt_clogb2(P_TS_BUFFER_SIZE)-1:0]    read_offset;

localparam S_PAYLOAD_OUT_START   = 0;
localparam S_PAYLOAD_OUT_REG     = 1;  
localparam S_PAYLOAD_OUT         = 2;
localparam S_PAYLOAD_OUT_END     = 3;
   
//reg    buffer_overflow;

always @ (posedge payload_out_clk or posedge payload_out_rst_syn)
begin
  if (payload_out_rst_syn) begin
    payload_out_state <= S_PAYLOAD_OUT_START;
    entry_read_tgl <= 1'b0;
    payload_out_entry <= 0;
    entry_written_tgl_d1 <= 1'b0;
    entry_written_tgl_d2 <= 1'b0;
    entry_written <= 1'b0;
    read_level = 0; 
//    buffer_overflow <= 1'b0;
    read_offset <= 0;
    payload_out_data <=0;
    payload_out_valid<=1'b0;   
  end
  else begin
    entry_written_tgl_d1 <= entry_written_tgl;
    entry_written_tgl_d2 <= entry_written_tgl_d1;
    entry_written <= (entry_written_tgl_d2!=entry_written_tgl_d1);
    
    if (entry_written)
      read_level = read_level + 1;
    else 
      read_level = read_level;
      
    payload_out_valid<=1'b0;   
    case (payload_out_state)
      S_PAYLOAD_OUT_START : begin
        if (read_level!= 0) begin         
           payload_out_state <= S_PAYLOAD_OUT_REG;
        end
      end
      S_PAYLOAD_OUT_REG : begin
        payload_out_state <= S_PAYLOAD_OUT;
      end
        

      S_PAYLOAD_OUT:begin
        if(payload_out_req&(~payload_out_valid))begin
           payload_out_data <=buffer_data_out;
           payload_out_valid<=1'b1;
           payload_out_state <= S_PAYLOAD_OUT_END;
        end
      end
   
      S_PAYLOAD_OUT_END : begin
        if(read_offset==(P_TS_BUFFER_SIZE-1))begin
          read_level = read_level - 1;
          entry_read_tgl <= ~entry_read_tgl;
          read_offset<=0;
          if(payload_out_entry==P_TS_BUFFERS-1)begin
             payload_out_entry <= 0;
          end
          else begin
             payload_out_entry <= payload_out_entry + 1;
          end
        end
        else begin
           read_offset <= read_offset + 1;
        end // else:
        payload_out_state <= S_PAYLOAD_OUT_START;
      end // case: S_PAYLOAD_OUT_END
      default:;
    endcase    
  end
end
assign    buffer_read_address = payload_out_entry * P_TS_BUFFER_SIZE + read_offset;
assign    payload_buf_level = read_level;

endmodule