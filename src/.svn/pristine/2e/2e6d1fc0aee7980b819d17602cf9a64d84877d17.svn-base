/*************************************************************************************\
    Filename     :   cmd_buffer.v
    Author       :   Z.J.K
\************************************************************************************/

`timescale 1ns/100ps

module cmd_buffer #(
  parameter PAYLOAD_DATA_WIDTH        = 32                       
)(
  
  // Receive Transport stream 
   input                                        buf_rst,
   input                                        buf_in_clk,
  
   input                                        buf_in_valid,
   input                                        buf_in_cancle,
   input                                        buf_in_end,
   input [PAYLOAD_DATA_WIDTH-1:0]               buf_in_data,
   
   input                                        buf_out_clk,
   input                                        buf_out_ack,
   output reg                                   buf_out_valid,
   output reg  [PAYLOAD_DATA_WIDTH-1:0]         buf_out_data,
   output wire                                  buf_out_rdy   
);
`include "alt_clogb2.v"  
  

//-------------------------------------------------------------
// Buffer localparam
//--------------------------------------------------------------- 
localparam   P_TS_BUFFERS          = 2;  
localparam   P_TS_BUFFER_SIZE      = 256;      // Buffer size in 32bit dw  !!!!!!!!caution
localparam   P_TS_BUFFER_RAM_SIZE  = P_TS_BUFFERS * P_TS_BUFFER_SIZE;     // RAM size 32bit dw
localparam   P_TS_BUFFER_RAM_WIDTH = alt_clogb2(P_TS_BUFFER_RAM_SIZE);
//--------------------------------------------------------------------------------------------------
// Write to the buffer
//--------------------------------------------------------------------------------------------------
   
reg                                         buffer_write;
reg  [PAYLOAD_DATA_WIDTH-1:0]               buffer_writedata;

reg  [alt_clogb2(P_TS_BUFFERS+1)-1:0]       write_level;
reg  [alt_clogb2(P_TS_BUFFERS+1)-1:0]       t_write_level;
reg  [alt_clogb2(P_TS_BUFFER_SIZE)-1:0]     write_offset;
reg  [alt_clogb2(P_TS_BUFFERS)-1:0]         write_entry;
wire [P_TS_BUFFER_RAM_WIDTH-1:0]            buffer_write_baseadd;

reg                                         entry_written_tgl;
reg  [alt_clogb2(P_TS_BUFFERS)-1:0]         read_entry;
reg                                         entry_read_tgl;
reg                                         entry_read_tgl_d1;
reg                                         entry_read_tgl_d2;
reg                                         entry_read;                 
reg  [1:0]                                  write_buffer_state;
   
localparam [1:0] S_BUFFER_IDLE   = 0;
localparam [1:0] S_PAYLOAD       = 1;
localparam [1:0] S_PAYLOAD_OVER  = 2;

always @ (posedge buf_in_clk or posedge buf_rst)
begin
  if (buf_rst) begin
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
  end // if (buf_rst)  
  else begin
    t_write_level = write_level;
    entry_read_tgl_d1 <= entry_read_tgl;
    entry_read_tgl_d2 <= entry_read_tgl_d1;
    entry_read <= (entry_read_tgl_d2!=entry_read_tgl_d1);

    if (entry_read & t_write_level>0) begin
      t_write_level = t_write_level - 'h1;
      if (read_entry==P_TS_BUFFERS-1)
        read_entry <= 0;
      else
        read_entry <= read_entry + 'h1;
    end
     
    buffer_write <= 1'b0;
    buffer_writedata <= 0;  
    case (write_buffer_state)
      S_BUFFER_IDLE : begin 
        if(buf_in_valid) begin   
          if(write_level != P_TS_BUFFERS)begin
            write_offset <= 0;            
            buffer_write <= 1'b1;
            buffer_writedata <= buf_in_data; 
            write_buffer_state <= S_PAYLOAD;                 
          end
        end
      end
      S_PAYLOAD : begin   
        buffer_write <= buf_in_valid;
        buffer_writedata <= buf_in_data;
        write_offset  <= write_offset + buf_in_valid; 
        if(buf_in_cancle)  begin
        	 write_buffer_state <= S_BUFFER_IDLE;
        end
        else if(buf_in_end) begin
          write_buffer_state <= S_PAYLOAD_OVER;
        end        	
      end
      
      S_PAYLOAD_OVER : begin
        entry_written_tgl <= ~entry_written_tgl;              
        t_write_level= t_write_level + 'h1;
        if (write_entry==P_TS_BUFFERS-1)begin
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


reg                                         buffer_write_reg;
reg  [PAYLOAD_DATA_WIDTH-1:0]               buffer_writedata_reg;
reg  [P_TS_BUFFER_RAM_WIDTH-1:0]            buffer_write_address;

always @ (posedge buf_in_clk or posedge buf_rst)
begin
  if (buf_rst) begin
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
wire  [P_TS_BUFFER_RAM_WIDTH-1:0] buffer_read_address;
wire  [PAYLOAD_DATA_WIDTH-1:0]    buffer_data_out;
localparam  RAM_WIDTH = alt_clogb2(512);
sdp_ram_d512_w32 u_ram (
  .clka    (buf_in_clk),
  .addra   (buffer_write_address),//{{(RAM_WIDTH-P_TS_BUFFER_RAM_WIDTH){1'b0}},
  .wea     (buffer_write_reg),
  .dina    (buffer_writedata_reg),
               
  .clkb    (buf_out_clk),
  .addrb   (buffer_read_address),//{{(RAM_WIDTH-P_TS_BUFFER_RAM_WIDTH){1'b0}},
  .doutb   (buffer_data_out)        
  );
  //--------------------------------------------------------------------------------------------------
// Read from the buffer
//--------------------------------------------------------------------------------------------------
reg   [2:0]                               buf_out_state;
reg   [alt_clogb2(P_TS_BUFFERS)-1:0]      buf_out_entry;
reg                                       entry_written_tgl_d1;
reg                                       entry_written_tgl_d2;
reg                                       entry_written;
reg   [alt_clogb2(P_TS_BUFFERS+1)-1:0]    read_level;
reg   [alt_clogb2(P_TS_BUFFER_SIZE)-1:0]  buffer_read_offset;
reg   [alt_clogb2(P_TS_BUFFER_SIZE)-1:0]  buf_out_count;


localparam S_PAYLOAD_OUT_IDLE  = 0;
localparam S_PAYLOAD_OUT_REG   = 1;
localparam S_PAYLOAD_OUT_START = 2;
localparam S_PAYLOAD_OUT_READ  = 3;
localparam S_PAYLOAD_OUT_ACK   = 4;
localparam S_PAYLOAD_OUT_RET   = 5;

always @ (posedge buf_out_clk or posedge buf_rst)
begin
  if(buf_rst) begin
    buf_out_state <= S_PAYLOAD_OUT_IDLE;
    buf_out_valid <= 1'b0;
    entry_read_tgl <= 1'b0;
    buf_out_entry <= 0;
    entry_written_tgl_d1 <= 1'b0;
    entry_written_tgl_d2 <= 1'b0;
    entry_written <= 1'b0;
    read_level = 0;
    buf_out_data <= 0;
    buf_out_count <= 0;
    buffer_read_offset <= 0;
  end
  else begin
    entry_written_tgl_d1 <= entry_written_tgl;
    entry_written_tgl_d2 <= entry_written_tgl_d1;
    entry_written <= (entry_written_tgl_d2!=entry_written_tgl_d1);
    
    if (entry_written)begin
      read_level = read_level + 1'b1;
    end   
    case (buf_out_state)
       
      S_PAYLOAD_OUT_IDLE : begin
        buf_out_count <= 0;
		  buffer_read_offset <= 0;
        if (read_level!=0) begin
          buffer_read_offset <= buffer_read_offset + 1'b1;
          buf_out_state <= S_PAYLOAD_OUT_REG;//S_PAYLOAD_OUT_START;      
        end
      end
      
      S_PAYLOAD_OUT_REG : begin
        //if(buf_out_req) begin
          //buffer_read_offset <= buffer_read_offset + 1'b1;
          buf_out_state <= S_PAYLOAD_OUT_START;
       // end
      end
      
      S_PAYLOAD_OUT_START:begin 
        //if(buf_out_req) begin        
        //  buffer_read_offset <= buffer_read_offset + 1;  
          buf_out_count <= buffer_data_out[alt_clogb2(P_TS_BUFFER_SIZE)-1:0];
          buf_out_state <=S_PAYLOAD_OUT_READ;
      //  end
      end
      S_PAYLOAD_OUT_READ : begin
        if (buffer_read_offset == (buf_out_count+'d1)) begin
          read_level = read_level - 1'b1;
          entry_read_tgl <= ~entry_read_tgl;
		    buf_out_state <= S_PAYLOAD_OUT_RET; 
        end
        else begin
			 buf_out_valid <= 1'b1;
          buf_out_data <= buffer_data_out[31:0];
			 buffer_read_offset <= buffer_read_offset + 1'b1;
		    buf_out_state <= S_PAYLOAD_OUT_ACK;
        end			 
      end
		
		S_PAYLOAD_OUT_ACK:begin
		  if(buf_out_ack)begin
		    buf_out_valid <= 1'b0;
		    buf_out_state <= S_PAYLOAD_OUT_READ;
		  end
		end
		
      S_PAYLOAD_OUT_RET:begin
		  if(buf_out_entry==P_TS_BUFFERS-1)begin
          buf_out_entry <= 0;
        end
        else begin
          buf_out_entry <= buf_out_entry + 1'b1;
        end 
		  buffer_read_offset <= 0;
        buf_out_state <= S_PAYLOAD_OUT_IDLE;
      end
      
    endcase // case (buf_out_state)
  end
end

assign buffer_read_address = buf_out_entry * P_TS_BUFFER_SIZE + buffer_read_offset;
assign buf_out_rdy = (read_level != 0);

endmodule
