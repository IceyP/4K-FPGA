
//--------------------------------------------------------------------------------------------------
// File          : $ pid_filter_top.v$
// Last modified : $Date: 2015/1/22 $
// Author        : Z.J.K
//--------------------------------------------------------------------------------------------------
module pid_filter_top #( 
  parameter TS_PROCESS_BASE_ADD       = 12'h800,           
  parameter P_BUS_ADDR_WIDTH          = 12,
  parameter P_BUS_DATA_WIDTH          = 8,
  parameter TS_DATA_WIDTH             = 8   
)(
  // Receive Transport stream 
   input                                 ts_clk,
   input                                 ts_rst,
   input                                 ts_in_valid,
   input                                 ts_in_start,
   input                                 ts_in_end,
   input  [TS_DATA_WIDTH-1:0]            ts_in_data,
 
  input                                  bus_clk,                  
  input                                  bus_rst,
  input                                  bus_read,
  input                                  bus_write,
  input       [P_BUS_ADDR_WIDTH-1:0]     bus_address,
  input       [P_BUS_DATA_WIDTH-1:0]     bus_writedata,
  output reg  [P_BUS_DATA_WIDTH-1:0]     bus_readdata
);
`include "alt_clogb2.v" 
//--------------------------------------------------------------------------------------------------   
// Bus control interface and control registers
//
// Address  R&W                  Use
// =======  ====                 ===
// 0        R         [7:0]   read  TS FIFO STATUS    
// 1        R                 read  ts          
// 2        W                 clear FIFO
//--------------------------------------------------------------------------------------------------

//localparam  READ_FIFO_DATA   = TS_PROCESS_BASE_ADD + 0;
//localparam  READ_FIFO_STATUS = TS_PROCESS_BASE_ADD + 1;
//localparam  CLEAR_FIFO       = TS_PROCESS_BASE_ADD + 2;
localparam  READ_FIFO_DATA   = 12'h800;
localparam  READ_FIFO_STATUS = 12'h801;
localparam  CLEAR_FIFO       = 12'h802;

wire   [P_BUS_DATA_WIDTH-1:0]           ts_pkt_num;
reg                                     filt_bus_read;
reg                                     filt_bus_write;
reg   [P_BUS_ADDR_WIDTH-1:0]            filt_bus_address;
reg   [P_BUS_DATA_WIDTH-1:0]            filt_bus_writedata;
wire  [P_BUS_DATA_WIDTH-1:0]            filt_bus_readdata;
  
reg                                     bus_buf_read;
reg                                     clear_fifo_tgl;

wire [P_BUS_DATA_WIDTH-1:0]             buffer_read_data;
wire                                    bus_buf_readdatavalid;    

always @ (posedge bus_clk or posedge bus_rst)
begin
  if (bus_rst) begin
    bus_readdata       <= 8'd0;
    bus_buf_read       <= 1'b0;
    filt_bus_read      <= 0;    
    filt_bus_write     <= 0;   
    filt_bus_address   <= 0; 
    filt_bus_writedata <= 0;
  end
  // Process accesses
  else begin
    bus_buf_read     <= 1'b0; 
    case (bus_address)
      READ_FIFO_DATA :  begin
        if(bus_read)begin
		    bus_buf_read <= 1'b1;
        end
        if(bus_buf_readdatavalid) begin
            bus_readdata <= buffer_read_data;
            bus_buf_read <= 1'b0;    
        end
      end

      READ_FIFO_STATUS : begin
        if(bus_read)begin
          bus_readdata <= ts_pkt_num;
        end
      end
      CLEAR_FIFO : begin
        clear_fifo_tgl <= ~clear_fifo_tgl; 
      end        
      default : begin
        filt_bus_read      <= bus_read;    
        filt_bus_write     <= bus_write;   
        filt_bus_address   <= bus_address; 
        filt_bus_writedata <= bus_writedata;
        bus_readdata       <= filt_bus_readdata;
      end
    endcase
  end
end

//--------------------------------
//CLear buffer signal syn
//--------------------------------------
//tclk
reg clear_fifo_tgl_d1_tclk;
reg clear_fifo_tgl_d2_tclk;
reg clear_fifo_valid_tclk;
always @ (posedge ts_clk or posedge ts_rst)
begin
  if (ts_rst) begin
    clear_fifo_tgl_d1_tclk<=1'b0;
    clear_fifo_tgl_d2_tclk<=1'b0; 
    clear_fifo_valid_tclk <=1'b0; 
  end
  else begin
    clear_fifo_tgl_d1_tclk<=clear_fifo_tgl;
    clear_fifo_tgl_d2_tclk<=clear_fifo_tgl_d1_tclk;
    if(clear_fifo_tgl_d2_tclk!=clear_fifo_tgl_d1_tclk)begin
      clear_fifo_valid_tclk <=1'b1;
    end
    else begin
      clear_fifo_valid_tclk <=1'b0;
    end
  end
end
//bclk
reg clear_fifo_tgl_d1_bclk;
reg clear_fifo_tgl_d2_bclk;
reg clear_fifo_valid_bclk;
always @ (posedge bus_clk or posedge bus_rst)
begin
  if (bus_rst) begin
    clear_fifo_tgl_d1_bclk<=1'b0;
    clear_fifo_tgl_d2_bclk<=1'b0; 
    clear_fifo_valid_bclk <=1'b0; 
  end
  else begin
    clear_fifo_tgl_d1_bclk<=clear_fifo_tgl;
    clear_fifo_tgl_d2_bclk<=clear_fifo_tgl_d1_bclk;
    if(clear_fifo_tgl_d2_bclk!=clear_fifo_tgl_d1_bclk)begin
      clear_fifo_valid_bclk <=1'b1;
    end
    else begin
      clear_fifo_valid_bclk <=1'b0;
    end
  end
end


/*------------------------------------------------------*/
//                   64 pid filt
//-------------------------------------------------------
wire                                    filt_out_req;
wire                                    filt_out_valid;
wire                                    filt_out_start;
wire                                    filt_out_end;
wire  [TS_DATA_WIDTH-1:0]               filt_out_data;
wire                                    filt_out_rdy;

pid_filter #( 
  .TS_PROCESS_BASE_ADD   (TS_PROCESS_BASE_ADD),           
  .P_BUS_ADDR_WIDTH      (P_BUS_ADDR_WIDTH),
  .P_BUS_DATA_WIDTH      (P_BUS_DATA_WIDTH) 
)u_pid_filter(
  // Receive Transport stream 
  .payload_clk           (ts_clk),
  .payload_rst           (ts_rst),
  .payload_in_valid      (ts_in_valid),
  .payload_in_start      (ts_in_start),
  .payload_in_end        (ts_in_end),
  .payload_in_data       (ts_in_data),
  
  .payload_out_req       (1'b1),
  .payload_out_valid     (filt_out_valid),
  .payload_out_start     (filt_out_start),
  .payload_out_end       (filt_out_end),
  .payload_out_data      (filt_out_data),
  .payload_out_rdy       (filt_out_rdy),
   
  .bus_clk               (bus_clk) ,                       
  .bus_rst               (bus_rst),           
  .bus_read              (filt_bus_read),     
  .bus_write             (filt_bus_write),    
  .bus_address           (filt_bus_address),  
  .bus_writedata         (filt_bus_writedata),
  .bus_readdata          (filt_bus_readdata)
);

wire                                    sect_data_req;
wire [TS_DATA_WIDTH-1:0]                sect_data_out;
wire                                    sect_data_valid;
wire                                    sect_data_start;
wire                                    sect_data_end;

do_psi_section  #( 
  .PAYLOAD_DATA_WIDTH    (TS_DATA_WIDTH)           
)u_psi_section(
  // Receive Transport stream 
  .payload_clk           (ts_clk),
  .payload_rst           (ts_rst),
  .payload_in_valid      (filt_out_valid),
  .payload_in_start      (filt_out_start),
  .payload_in_end        (filt_out_end),
  .payload_in_data       (filt_out_data),
  
  .payload_out_req       (sect_data_req),  
  .payload_out_data      (sect_data_out), 
  .payload_out_valid     (sect_data_valid),
  .payload_out_start     (sect_data_start),
  .payload_out_end       (sect_data_end)
  );
  
ts_8bit_buffer #(
.PAYLOAD_DATA_WIDTH      (TS_DATA_WIDTH) 
)u_bus_read_buf(
.payload_in_rst          (ts_rst|clear_fifo_valid_tclk),             
.payload_in_clk          (ts_clk),  
.payload_in_valid        (sect_data_valid),
.payload_in_start        (sect_data_start),
.payload_in_end          (sect_data_end),  
.payload_in_data         (sect_data_out), 
.payload_req_in          (sect_data_req),
  
.payload_out_rst         (bus_rst|clear_fifo_valid_bclk), 
.payload_out_clk         (bus_clk),
.payload_out_req         (bus_buf_read),
.payload_out_valid       (bus_buf_readdatavalid),
.payload_out_data        (buffer_read_data),
.payload_buf_level       (ts_pkt_num) 
);
endmodule

