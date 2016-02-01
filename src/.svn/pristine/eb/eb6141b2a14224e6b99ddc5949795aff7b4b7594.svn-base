`include "spi_defines.v"
module spi_cmd_process #(
  parameter  BUS_DATA_WIDTH   =  8           ,
  parameter  BUS_ADD_WIDTH    =  16                                
)(
  input                           clk        ,      
  input                           rst        ,      
  input      [`SPI_MAX_CHAR-1:0]  rx_data    ,      
  input                           rx_valid   , 
  input                           rx_start   , 
  input                           rx_end     , 
   
  input                           tx_ack     ,    
  output reg [`SPI_MAX_CHAR-1:0]  tx_data    ,      
  output reg                      tx_req     ,
  
  input                           bus_clk    ,
  input      [BUS_DATA_WIDTH-1:0] bus_rdata  ,  
  output reg                      bus_we     ,
  output reg                      bus_oe     ,
  output reg [BUS_DATA_WIDTH-1:0] bus_wdata  ,
  output reg [BUS_ADD_WIDTH-1:0]  bus_addr     
  ); 
  //--------------------------------------------------------------
  //                     cmd process state
  //---------------------------------------------------------------
  localparam         CON_WR_REG    = 8'h51   ;     
  localparam         CON_RD_REG    = 8'h52   ; 
  localparam         RD_DATA_REG   = 8'h96   ; 
  localparam         REST_CMD      = 8'h55   ;
  
  localparam         TS_RD_ADDR    = 16'h5800;
  
  localparam         REC_NO_ERR    = 8'h90   ;
  localparam         REC_INT_ERR   = 8'hf1   ; 
  localparam         REC_LEN_ERR   = 8'hf2   ; 
  localparam         REC_CRC_ERR   = 8'hf3   ;
  localparam         REC_BUSY_ERR  = 8'hf4   ; 
  
  localparam         REC_START     = 0    ;
  localparam         REC_TYPE_REG  = 1    ;  
  localparam         REC_ADDR_REGH = 2    ;     
  localparam         REC_ADDR_REGL = 3    ;  
  localparam         REC_ADDR_LEN  = 4    ;
  localparam         REC_CON_WR    = 5    ;  //consecutive write 
  localparam         REC_CON_RD    = 6    ;  //consecutive read  
  localparam         REC_CRC_REGH  = 7    ;
  localparam         REC_CRC_REGL  = 8    ;
  localparam         DO_CRC_CHECK  = 9    ; 
  localparam         RSP_STATUS    = 10   ;
  localparam         RSP_LEN       = 11   ;
  localparam         RSP_DIN       = 12   ;
  localparam         RSP_DOUT      = 13   ;
  localparam         DO_CRC_CPU    = 14   ;
  localparam         RSP_CRCH      = 15   ;
  localparam         RSP_CRCL      = 16   ;
  localparam         SPI_CMD_REST  = 17   ;
          
  localparam         BUS_WRITE     = 2'b10   ; 
  localparam         BUS_READ      = 2'b01   ; 
  
  localparam         RESET_PRD     = 128     ;
  
 
  wire [7:0]         rsp_fifo_dout           ;
  wire               rsp_fifo_valid          ; 
  wire [15:0]        local_crc               ;
  reg  [15:0]        loc_crc_reg             ;
                   
  reg  [7:0]         rec_type                ;
  reg  [15:0]        rec_addr                ;
  reg  [7:0]         addr_len                ;  
  reg  [7:0]         len_count               ;
  reg  [4:0]         cmd_state               ;
  reg  [7:0]         err_code                ;
  reg                rec_buf_wr              ;
  reg  [31:0]        rec_buf_data            ;
  reg  [15:0]        rec_crc                 ;
  reg                rsp_fifo_rd             ;
  reg                cmd_rest                ;
  reg  [7:0]         cmd_rest_count          ;            
//--------------------------------------------------------  
  always @(posedge clk or posedge rst)
  begin
    if(rst)begin
    	rec_type       <= 0;
    	rec_addr       <= 0;
    	addr_len       <= 0;
    	len_count      <= 0;
    	err_code       <= REC_NO_ERR;
    	rec_buf_wr     <= 0;  
      rec_buf_data   <= 0;
      rec_crc        <= 0;
      tx_data        <= 0;
      tx_req         <= 0;
      loc_crc_reg    <= 0;
      cmd_rest       <= 0;
      cmd_rest_count <= 0;  
      cmd_state      <= REC_START;
    end
    else begin
      rsp_fifo_rd <= 1'b0;
      if(tx_ack)begin
    	  tx_req <= 1'b0;
    	end
	   rec_buf_wr <= 1'b0; 
      rec_buf_data <= 0;
    	case(cmd_state)
    	  REC_START:begin
		    rec_buf_wr <= 1'b0; 
          rec_buf_data <= 0;
			 len_count  <= 0;
			 cmd_rest   <= 1'b0;
			 cmd_rest_count <= 0;
    	  	 if(rx_start)begin
    	  		cmd_state <= REC_TYPE_REG;
    	    end
    	  end
    	  REC_TYPE_REG:begin
		      if(rx_end)begin
			      cmd_state  <= REC_START;
          end
    	    else if(rx_valid)begin
			      case(rx_data)
              CON_WR_REG,CON_RD_REG:begin
                cmd_state  <= REC_ADDR_REGH;
				        err_code   <= REC_NO_ERR;
				        rec_type <= rx_data; 
				      end
				      RD_DATA_REG:begin
				        cmd_state <= RSP_STATUS; 
				      end	  
              REST_CMD: cmd_state  <= SPI_CMD_REST;
				      default:cmd_state  <= REC_START;
    	      endcase
    	    end 
    	  end
    	  REC_ADDR_REGH:begin
          if(rx_end)begin
            cmd_state  <= REC_START;
          end
    	    else if(rx_valid)begin
    	  		rec_addr[15:8] <= rx_data; 
            cmd_state <= REC_ADDR_REGL;
    	    end
    	  end
    	  REC_ADDR_REGL:begin
          if(rx_end)begin
            cmd_state  <= REC_START;
          end
    	    else if(rx_valid)begin
            rec_addr[7:0] <= rx_data; 
            cmd_state <= REC_ADDR_LEN;
    	    end
    	  end
    	  REC_ADDR_LEN:begin
          rec_buf_wr <= 1'b0; 
          rec_buf_data <= 0;
          if(rx_end)begin
            cmd_state  <= REC_START;
          end
    	    else if(rx_valid)begin
            if(rx_data != 0)begin  		
              addr_len  <= rx_data; 
    	  		  rec_buf_wr <= 1'b1; 
              rec_buf_data <= {24'b0,rx_data};
              case(rec_type)
                CON_WR_REG: cmd_state  <= REC_CON_WR;
                CON_RD_REG: cmd_state  <= REC_CRC_REGH;
                default:cmd_state  <= REC_START;
    	  	    endcase
    	  	  end
            else begin
              err_code   <= REC_LEN_ERR;
              cmd_state  <= REC_START;  	
            end
          end
    	  end
		  		  
        REC_CON_WR:begin  
          rec_buf_wr <= 1'b0; 
          rec_buf_data <= 0;		  
          if(len_count == addr_len)begin
           	cmd_state  <= REC_CRC_REGH; 
          end 
          else begin
            if(rx_end)begin
              cmd_state  <= REC_START;
            end
            else if(rx_valid)begin
              rec_buf_wr <= 1'b1; 
              rec_buf_data <= {6'b0,BUS_WRITE,rec_addr,rx_data};
              rec_addr <= rec_addr + 1'b1;
              len_count <= len_count + 1'b1;
       	    end
       	  end
        end
        REC_CON_RD:begin
        	if(len_count == addr_len)begin
           	cmd_state  <= REC_START; 
            rec_buf_wr <= 1'b0; 
            rec_buf_data <= 0;
          end
          else begin
            rec_buf_wr <= 1'b1; 
            rec_buf_data <= {6'b0,BUS_READ,rec_addr,8'b0};
            if(rec_addr != TS_RD_ADDR)begin
              rec_addr <= rec_addr + 1'b1;
            end
            len_count <= len_count + 1'b1;
          end
        end             
        REC_CRC_REGH:begin
		      loc_crc_reg <= local_crc;
          if(rx_end)begin
            cmd_state  <= REC_START;
			    end
    	    else if(rx_valid)begin
        		rec_crc[15:8] <= rx_data;
        		cmd_state  <= REC_CRC_REGL;
    	    end	
    	  end
    	  REC_CRC_REGL:begin
          if(rx_end)begin
            cmd_state  <= REC_START;
          end
    	    else if(rx_valid)begin
        		rec_crc[7:0] <= rx_data;
        		cmd_state  <= DO_CRC_CHECK;
    	    end	
    	  end
    	  DO_CRC_CHECK:begin
    	  	if(rec_crc == loc_crc_reg)begin
    	  	  case(rec_type)
    	  	    CON_WR_REG: cmd_state  <= REC_START;
    	  	    CON_RD_REG: cmd_state  <= REC_CON_RD;
    	  	  endcase
    	  	end
    	  	else begin
    	  	  err_code   <= REC_CRC_ERR;
    	  	  cmd_state  <= REC_START;
    	  	end
    	  end
   	  
        RSP_STATUS:begin     //attention: crc gongyong
          tx_req <= 1'b1;
    	    tx_data <= err_code;				 
    	    cmd_state <= RSP_LEN;
        end
		  
    	  RSP_LEN:begin
    	  	if(tx_req == 0)begin
    	  	  tx_req <= 1'b1;
    	  	  case(rec_type)
    	  	    CON_WR_REG:begin
                cmd_state  <= DO_CRC_CPU;
                tx_data <= 0;
				      end
				 
              CON_RD_REG:begin 
					      tx_data <= addr_len;
					      cmd_state  <= RSP_DIN;
				      end
              default:begin
			          cmd_state  <= REC_START;
                tx_data <= 0;
              end			  
    	  	  endcase
    	  	end
    	  end
		  
    	  RSP_DIN:begin
          if(rx_end)begin
            cmd_state <= REC_START;
    	    end
          else if(len_count == addr_len)begin
    	    	cmd_state  <= DO_CRC_CPU;
    	    end	
          else if(tx_req == 0)begin
            rsp_fifo_rd <= 1'b1;
            cmd_state  <= RSP_DOUT; 
			    end	  				
    	  end
		  
    	  RSP_DOUT:begin
          if(rx_end)begin
            cmd_state <= REC_START;
          end
          else if(rsp_fifo_valid )begin
            tx_data    <= rsp_fifo_dout;
            tx_req     <= 1'b1;
            len_count  <= len_count + 1'b1;
            cmd_state  <= RSP_DIN;
          end
        end
		  
    	  DO_CRC_CPU: begin
		    if(tx_req == 0)begin
			   loc_crc_reg <= local_crc;
				cmd_state  <= RSP_CRCH;
			 end
		  end
		  
    	  RSP_CRCH:begin
    	  	 tx_data    <= loc_crc_reg[15:8];
    	  	 tx_req     <= 1'b1;
    	  	 cmd_state  <= RSP_CRCL;
    	  end
    	  
    	  RSP_CRCL:begin
    	  	if(tx_req == 0)begin
    	  		tx_data    <= loc_crc_reg[7:0];
    	  		tx_req     <= 1'b1;
    	  		cmd_state  <= REC_START;
    	    end
    	  end
		  
    	  SPI_CMD_REST:begin
		      cmd_rest <= 1'b1;
          if(cmd_rest_count == RESET_PRD)begin
            cmd_state <= REC_START;
          end
          else begin
            cmd_rest_count <= cmd_rest_count + 1'b1;
          end			 
		  end	  
      endcase
    end
  end  
  
//-------------------crc ints-------------------------------------------

   wire          crc_rst   = ((cmd_state == REC_START)|| (cmd_state == RSP_STATUS)|| (cmd_rest == 1'b1));
   wire          crc_en    = (cmd_state < RSP_STATUS) ? rx_valid : tx_ack;
   wire [7:0]    crc_data  = (cmd_state < RSP_STATUS) ? rx_data  : tx_data;
   
   crc16_d8 u_crc ( 
     .d           (crc_data)                ,
     .crc_en      (crc_en)                  ,
     .crc_out     (local_crc)               ,
     .rst         (crc_rst)                 ,
     .clk         (clk)
     );
 //--------------------------recv cmd buffer ints------------------------------------
 //                          bus interface state
 //-----------------------------------------------------------------------------------
   localparam    WAIT_PRD          = 6;
   localparam    BUS_IDLE          = 0;
   localparam    BUS_OUT           = 1; 
   localparam    BUS_IDE           = 2;
   localparam    BUS_WAIT          = 3;
   localparam    BUS_IN            = 4;       
 
   wire          rec_cancle = (err_code != REC_NO_ERR)&& (cmd_state == REC_START);
   wire          rec_end    = (cmd_state == REC_START);
   
   reg           out_ack                   ;
   wire          out_valid                 ;
   wire  [31:0]  out_data                  ;
   wire          out_rdy                   ;             
   
   reg   [2:0]   bus_state                 ;
   reg   [2:0]   wait_count                ;
   reg   [7:0]   rsp_fifo_din              ; 
   reg           rsp_fifo_we               ;
                                                         
   cmd_buffer   recv_buf (  
     .buf_rst      (cmd_rest)              ,               
     .buf_in_clk   (clk)                   ,                                           
     .buf_in_valid (rec_buf_wr)            ,
     .buf_in_cancle(rec_cancle)            ,
     .buf_in_end   (rec_end)               ,
     .buf_in_data  (rec_buf_data)          ,
     
     .buf_out_clk  (bus_clk)               ,
     .buf_out_ack  (out_ack)	             ,	
     .buf_out_valid(out_valid)             ,
     .buf_out_data (out_data)              ,
     .buf_out_rdy  (out_rdy) 
    ); 
  always @(posedge bus_clk or posedge cmd_rest)
  begin
    if(cmd_rest)begin
    	bus_we       <= 0;
      bus_oe       <= 0;
      bus_wdata    <= 0;
      bus_addr     <= 0;	
      out_ack      <= 0; 
      wait_count   <= 0; 
      rsp_fifo_din <= 0;   
      rsp_fifo_we  <= 0;     
      bus_state    <= BUS_IDLE;  	
    end
    else begin
    	rsp_fifo_we <= 1'b0;
    	case(bus_state)
    	  BUS_IDLE:begin
    	  	 if(out_rdy)begin
    	  		wait_count  <= 0;
    	  		bus_state <= BUS_OUT;
    	    end
    	  end
    	  BUS_OUT:begin
    	    if(out_valid)begin
    	    	{bus_we,bus_oe,bus_addr,bus_wdata} <= out_data[25:0];
    	    	bus_state <= BUS_IDE;
				out_ack <= 1'b1;
    	    end
    	  end
		  
		  BUS_IDE:begin
			 bus_we  <= 1'b0;
			 bus_oe  <= 1'b0;
			 out_ack <= 1'b0;
			 if(bus_oe)begin
			   bus_state <= BUS_WAIT;
			 end
			 else begin
			   bus_state <= BUS_IDLE;
			 end
		  end
		  
    	  BUS_WAIT:begin
		    wait_count <= wait_count + 1'b1;
    	    if(wait_count == WAIT_PRD)begin
    	  	   bus_state <= BUS_IN;
    	    end
    	  end 
		  
    	  BUS_IN:begin
    	  	 rsp_fifo_din <= bus_rdata;
    	  	 rsp_fifo_we <= 1'b1;
    	  	 bus_state <= BUS_IDLE;
    	  end
		  default:bus_state <= BUS_IDLE;
      endcase
    end
  end
 //--------------------------send data fifo ints------------------------------------
 
  fifo_w8_d1024 out_state_fifo(
    .wr_clk       (bus_clk)                     ,
	 .rd_clk       (clk)                         ,          
    .rst          (cmd_rest)                    ,
    .din          (rsp_fifo_din)                ,
    .wr_en        (rsp_fifo_we)                 ,
    .rd_en        (rsp_fifo_rd)                 ,
    .dout         (rsp_fifo_dout)               ,
    .valid        (rsp_fifo_valid)              ,
    .empty        ()                            ,
    .full         ()
  );
endmodule 