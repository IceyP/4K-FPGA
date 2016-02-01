/*************************************************************************************\
    Copyright(c) 2012, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   New Media,R&D Hardware Department
    Filename     :   match_pack_buf.v
    Author       :   Z.J.K
    ==================================================================================
    Description  :   
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
 
    ==================================================================================
    File tree    :   match_pack_buf.v
\************************************************************************************/

`timescale 1ns/100ps

module match_pack_buf #(
  parameter PAYLOAD_DATA_WIDTH        = 8                      
)(
  
  // Receive Transport stream 
   input                                  payload_rst,
   input                                  payload_out_clk,
  
   input                                  payload_in_clk,
   input                                  payload_in_valid,
   input                                  payload_in_start,
   input                                  payload_in_end,
   input [PAYLOAD_DATA_WIDTH-1:0]         payload_in_data,
   output wire                            payload_req_in,
   
   input                                  payload_out_req,
   output reg                             payload_out_valid,
   output reg                             payload_out_start,
   output reg                             payload_out_end,
   output reg  [PAYLOAD_DATA_WIDTH-1:0]   payload_out_data,
   output wire                            payload_out_rdy,
   
   input                                  match_flag,
   input [7:0]                            match_index,//pid filter list num 
   input                                  match_over
    
);
`include "alt_clogb2.v"  
  
//-------------------------------------------------------------
// Buffer localparam
//--------------------------------------------------------------- 
localparam   P_TS_BUFFERS =  5;  
localparam   P_TS_BUFFER_SIZE = 192;      // Buffer size in bytes
localparam   P_TS_BUFFER_RAM_SIZE = P_TS_BUFFERS * P_TS_BUFFER_SIZE;     // RAM size in dw


//--------------------------------------------------------------------------------------------------
// Write to the buffer
//--------------------------------------------------------------------------------------------------
   
reg                                         buffer_write;
reg  [PAYLOAD_DATA_WIDTH-1:0]               buffer_writedata;
reg  [alt_clogb2(P_TS_BUFFERS+1)-1:0]       write_level;
reg  [alt_clogb2(P_TS_BUFFERS+1)-1:0]       t_write_level;
reg  [alt_clogb2(P_TS_BUFFER_SIZE)-1:0]     write_offset;
reg  [alt_clogb2(P_TS_BUFFERS)-1:0]         write_entry;
wire [alt_clogb2(P_TS_BUFFER_RAM_SIZE)-1:0] buffer_write_address;

reg                                         entry_written_tgl;
reg  [alt_clogb2(P_TS_BUFFERS)-1:0]         read_entry;
reg                                         entry_read_tgl;
reg                                         entry_read_tgl_d1;
reg                                         entry_read_tgl_d2;
reg                                         entry_read; 
reg  [15:0]                                 chan_num;               
reg  [2:0]                                  write_buffer_state; 
   
localparam               S_BUFFER_IDLE      = 0;
localparam               S_PAYLOAD          = 1;
localparam               S_WAIT_MATCH       = 2;
localparam               S_SAVE_CHAN        = 3;
localparam               S_MATCH_END        = 4;


always @ (posedge payload_in_clk or posedge payload_rst)
begin
  if (payload_rst) begin
    write_buffer_state <= S_BUFFER_IDLE;
    buffer_write <= 1'b0;
    write_entry <= 0;
    write_offset <= 0;
    write_level <= 0;
    entry_written_tgl <= 1'b0;
    read_entry  <= 0;
    entry_read_tgl_d1 <= 1'b0;
    entry_read_tgl_d2 <= 1'b0;
    entry_read <= 1'b0;
    buffer_writedata <=0; 
    chan_num <= 0;
  end // if (payload_rst)  
  else begin
    t_write_level = write_level;

    entry_read_tgl_d1 <= entry_read_tgl;
    entry_read_tgl_d2 <= entry_read_tgl_d1;
    entry_read <= (entry_read_tgl_d2!=entry_read_tgl_d1);

    if (entry_read & t_write_level>0) begin
      t_write_level = t_write_level - 1;
      if (read_entry==P_TS_BUFFERS-1)
        read_entry <= 0;
      else
        read_entry <= read_entry + 1;
    end
     
    buffer_write <= 1'b0;    
    buffer_writedata <= payload_in_data;
    case (write_buffer_state)
      S_BUFFER_IDLE : begin
        write_offset <= 4;             //8bit
        if(payload_in_valid & payload_in_start&(write_level< P_TS_BUFFERS)) begin
          buffer_write <= 1'b1;
          write_buffer_state <= S_PAYLOAD;
          chan_num[15:0] <= {12'b0,payload_in_data[3:0]};
          buffer_writedata[3:0] <= 4'h7;
        end
      end
      S_PAYLOAD : begin
        if(payload_in_valid) begin
          buffer_write <= 1'b1;
          write_offset <= write_offset + 1; 
        end
        else begin
          buffer_write<= 1'b0;
          write_offset <= write_offset + 1;
        end  
        if(payload_in_end) begin
          write_buffer_state <= S_WAIT_MATCH;
        end
      end
     S_WAIT_MATCH : begin
	     if(match_flag)begin
	    	 buffer_write <= 1'b1;    
         buffer_writedata <=match_index[7:0];
         write_offset <= 2;
         write_buffer_state <= S_SAVE_CHAN; 
       end 
       else if(match_over)begin
         write_buffer_state <= S_BUFFER_IDLE;      
       end
       else begin
		     write_buffer_state <= S_WAIT_MATCH;
       end
     end
     	
     S_SAVE_CHAN:begin 
       buffer_write <= 1'b1;    
       buffer_writedata <=chan_num[7:0];
       write_offset <= 3;
       write_buffer_state <= S_MATCH_END; 
     end	
      
     S_MATCH_END : begin
         entry_written_tgl <= ~entry_written_tgl;
         t_write_level= t_write_level + 1;
         if (write_entry==P_TS_BUFFERS-1)begin
            write_entry <= 0;
         end
         else begin
           write_entry <= write_entry + 1;
         end
         write_buffer_state <= S_BUFFER_IDLE;  
      end   
    endcase // case (write_buffer_state)  
    write_level <= t_write_level;
    //bus_int <= (write_level!=0);
  end
end
assign buffer_write_address = write_entry * P_TS_BUFFER_SIZE + write_offset;

//--------------------------------------------------------------------------------------------------
// Buffer RAM
//--------------------------------------------------------------------------------------------------
//wire  [P_TS_BUFFER_RAM_WIDTH-1:0] buffer_read_baseadd;
//reg   [P_TS_BUFFER_RAM_WIDTH-1:0] buffer_read_address;
wire  [alt_clogb2(P_TS_BUFFER_RAM_SIZE)-1:0] buffer_read_address;
wire  [PAYLOAD_DATA_WIDTH-1:0]               buffer_data_out;
//localparam  RAM_WIDTH = alt_clogb2(1024);
sdp_ram_d1024_w8 u_ram (
  .clka    (payload_in_clk),
  .addra   (buffer_write_address),//{{(RAM_WIDTH-P_TS_BUFFER_RAM_WIDTH){1'b0}},
  .wea     (buffer_write),
  .dina    (buffer_writedata),
               
  .clkb    (payload_out_clk),
  .addrb   (buffer_read_address),//{{(RAM_WIDTH-P_TS_BUFFER_RAM_WIDTH){1'b0}},
  .doutb   (buffer_data_out)        
  );
  //--------------------------------------------------------------------------------------------------
// Read from the buffer
//--------------------------------------------------------------------------------------------------
reg   [2:0]                                 payload_out_state;
reg   [alt_clogb2(P_TS_BUFFERS)-1:0]        payload_out_entry;
reg                                         entry_written_tgl_d1;
reg                                         entry_written_tgl_d2;
reg                                         entry_written;
reg   [alt_clogb2(P_TS_BUFFERS+1)-1:0]      read_level;
reg                                         buffer_read;
reg                                         buffer_read_d;
reg   [alt_clogb2(P_TS_BUFFER_SIZE)-1:0]    buffer_read_offset;
reg   [alt_clogb2(P_TS_BUFFER_SIZE)-1:0]    payload_out_count;


localparam               S_PAYLOAD_OUT_IDLE  = 0;
localparam               S_PAYLOAD_OUT_REG   = 1;
localparam               S_PAYLOAD_OUT_START = 2;
localparam               S_PAYLOAD_OUT_READ  = 3;
localparam               S_PAYLOAD_OUT_ACK   = 4;
localparam               S_PAYLOAD_OUT_END   = 5;
localparam               S_PAYLOAD_OUT_RET   = 6;

always @ (posedge payload_out_clk or posedge payload_rst)
begin
  if (payload_rst) begin
    payload_out_state <= S_PAYLOAD_OUT_IDLE;
    payload_out_valid <= 1'b0;
    entry_read_tgl <= 1'b0;
    payload_out_entry <= 0;
    entry_written_tgl_d1 <= 1'b0;
    entry_written_tgl_d2 <= 1'b0;
    entry_written <= 1'b0;
    read_level = 0;
    buffer_read <= 1'b0;
    payload_out_start <= 1'b0;
    payload_out_end <= 1'b0;
    payload_out_data <= 0;
    payload_out_count <= 0;
    buffer_read_offset <= 0;
  end
  else begin
    buffer_read <= 1'b0;
    payload_out_valid <= 0;  
    payload_out_start <= 0;
    payload_out_data <= 0;
    payload_out_end<= 1'b0;
    entry_written_tgl_d1 <= entry_written_tgl;
    entry_written_tgl_d2 <= entry_written_tgl_d1;
    entry_written <= (entry_written_tgl_d2!=entry_written_tgl_d1);
    
    if (entry_written)begin
      read_level = read_level + 1;
    end   
    case (payload_out_state)
     
      S_PAYLOAD_OUT_IDLE : begin
        payload_out_count <= 0;
        buffer_read_offset <= 0;
        if ((read_level!=0)& payload_out_req) begin
          buffer_read_offset <= buffer_read_offset + 1;
          buffer_read <= 1'b1;
          payload_out_state <= S_PAYLOAD_OUT_REG;//S_PAYLOAD_OUT_START;      
        end
      end
      
      S_PAYLOAD_OUT_REG : begin
         // if(payload_out_req) begin
         // payload_out_start <= 1'b1; 
          //payload_out_valid <= 1'b1;    
         // payload_out_data <= buffer_data_out;
          buffer_read <= 1'b1;
          buffer_read_offset <= buffer_read_offset + 1;
          payload_out_state <= S_PAYLOAD_OUT_START;
        //  end
      end
      
      S_PAYLOAD_OUT_START:begin 
        // if(payload_out_req) begin        
           buffer_read <= 1'b1;
           buffer_read_offset <= buffer_read_offset + 1;
           payload_out_start <= 1'b1; 
           payload_out_valid <= 1'b1;   
           payload_out_data <= buffer_data_out;
           payload_out_state <=S_PAYLOAD_OUT_READ;
            //end
      end
      S_PAYLOAD_OUT_READ : begin
         // if(payload_out_req) begin
          payload_out_valid <= 1'b1;
          payload_out_data <= buffer_data_out;
          buffer_read <= 1'b1;
          if (buffer_read_offset==(P_TS_BUFFER_SIZE)) begin
            read_level = read_level - 1;
            entry_read_tgl <= ~entry_read_tgl;
            payload_out_state <= S_PAYLOAD_OUT_END;
          end
          else begin
            buffer_read_offset <= buffer_read_offset + 1;
          end
        //  end
      end
      /*
      S_PAYLOAD_OUT_ACK : begin
          payload_out_valid <= 1'b1;
          payload_out_data <= buffer_data_out[31:0];
          payload_out_state <= S_PAYLOAD_OUT_END;
      end
        */
      S_PAYLOAD_OUT_END: begin
          payload_out_valid <= 1'b1;
          payload_out_end  <= 1'b1;
          payload_out_data <= buffer_data_out;
          if (payload_out_entry==P_TS_BUFFERS-1)begin
             payload_out_entry <= 0;
           end
          else begin
            payload_out_entry <= payload_out_entry + 1; 
          end  
          buffer_read_offset <= 0;
          payload_out_state <= S_PAYLOAD_OUT_RET; 
      end
        S_PAYLOAD_OUT_RET:begin
          payload_out_state <= S_PAYLOAD_OUT_IDLE;
        end
    endcase // case (payload_out_state)
  end
end

assign buffer_read_address = payload_out_entry * P_TS_BUFFER_SIZE + buffer_read_offset;

assign payload_out_rdy = (read_level>0);

endmodule
