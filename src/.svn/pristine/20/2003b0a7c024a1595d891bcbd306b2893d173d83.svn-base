//--------------------------------------------------------------------------------------------------

//--------------------------------------------------------------------------------------------------
//--------------------------------------------------------------------------------------------------
// File          : $do_sec_section.v$
// Last modified : $Date: 2015/01/27 $
// Author        : Z.J.K
//--------------------------------------------------------------------------------------------------

module do_psi_section #(
  parameter PAYLOAD_DATA_WIDTH        = 8 
)
(
  // Receive Transport stream 
  input                                  payload_clk,
  input                                  payload_rst,
  input                                  payload_in_valid,
  input                                  payload_in_start,
  input                                  payload_in_end,
  input  [PAYLOAD_DATA_WIDTH-1:0]        payload_in_data,
                      
  // Register access   
  input                                  payload_out_req,
  output reg[PAYLOAD_DATA_WIDTH-1:0]     payload_out_data,
  output reg                             payload_out_valid,
  output reg                             payload_out_start,
  output reg                             payload_out_end
);

`include "alt_clogb2.v" 
//--------------------------------------------------------------------------------------------------
// parameters
localparam          TS_PKT_LEN        =  188;  
localparam          INFO_RAM_DEPTH    =  32;
localparam          INFO_RAM_WIDTH    =  32;
localparam          INFO_RAM_DBITS    =  alt_clogb2(INFO_RAM_DEPTH);
localparam          INFO_RAM_WBITS    =  alt_clogb2(INFO_RAM_WIDTH);


//--------------------------------------------------------------------------------------------------
// Store PID info from receive packet  for use by matcher ;
// Analysis PAT ,store the PMT pid into ram; head (adaption field) + paloayload (point filed + pes or pas)
//--------------------------------------------------------------------------------------------------
localparam          PID_IDLE         =  0;
localparam          WAIT_FILT_INDEX  =  1; 
localparam          GET_FILT_INDEX   =  2; 
localparam          SKIP_CHAN_NO     =  3; 
localparam          SYN_HEAD         =  4; 
localparam          START_FLAG       =  5; 
localparam          TS_PID           =  6; 
localparam          ADAPT_CC         =  7; 
localparam          IF_TS_WENA       =  8; 
localparam          ADAPT_FIED_SKIP  =  9;  
localparam          POINT_FIED_SKIP  =  10;
localparam          SECT_LEN_H       =  11;
localparam          SECT_LEN_L       =  12;
localparam          SECTION_SKIP     =  13;
localparam          GEN_UPDATE_INFO  =  14;
localparam          UPDATE_INFO_RAM  =  15;

reg   [3:0]                              pid_state;

reg                                      pay_start; 
reg   [1:0]                              adap_filed_flag;
reg   [7:0]                              adap_filed_len;
reg   [7:0]                              point_filed_len;
reg   [11:0]                             section_len;

reg   [7:0]                              ts_byte_count;
reg   [7:0]                              ts_byte_offset;
reg   [INFO_RAM_DBITS-1:0]               pid_filt_index;
reg                                      pid_data_wena;

reg                                      update_if_data;
reg    [1:0]                             update_pkt_num;
reg    [1:0]                             update_sect_status; //00- section start 01- section have high sect len ,02-section have low sect len,11- do section over                               
reg    [7:0]                             update_point_len;
reg    [11:0]                            update_sect_len;
reg    [3:0]                             update_pid_cc;

reg                                      ts_err_flag;

reg                                      if_data;           //if_data = 1 section clect ok ,wait read 
reg   [1:0]                              pkt_num; 
reg   [1:0]                              sect_status; 
reg   [7:0]                              rem_point_len;
reg   [11:0]                             rem_sect_len;        //  remainder section len,real 12bit , but < 256 so 9bit
reg   [3:0]                              pre_pid_cc;   
                                                 
////47 40 20 11

 

always @ (posedge payload_clk or posedge payload_rst)
begin
  if(payload_rst)
  begin
    pid_state <= PID_IDLE;                                       
    pid_filt_index <= 0;
    ts_byte_count <= 0; 
    pay_start <= 0;            
    adap_filed_flag <= 0;
    adap_filed_len<=0;
    point_filed_len<=0;
    update_if_data <= 0;
    update_pkt_num <= 0;
    update_sect_status <= 0;
    update_point_len <= 0;
    update_sect_len <= 0;
    update_pid_cc <= 0; 
    section_len <= 0;
    ts_err_flag <= 0;
    ts_byte_offset <= 0;
    pid_data_wena <= 1'b0;
  end
  else begin
    case(pid_state)   
      PID_IDLE:
      begin
        ts_byte_count <= 0;
        adap_filed_len <= 0;
        point_filed_len <= 0;
        section_len <= 0;
        ts_err_flag <= 0;
        update_if_data <= 0;
        update_pkt_num <= 0;
        update_sect_status <= 0;
        update_point_len <= 0;
        update_sect_len <= 0;
        update_pid_cc <= 0; 
        if(payload_in_start & payload_in_valid)
        begin               
          pid_state <= WAIT_FILT_INDEX;
        end   
      end
      
      WAIT_FILT_INDEX:begin
      	if(payload_in_valid)begin
      		pid_state <= GET_FILT_INDEX;
        end
      end
      
      GET_FILT_INDEX:begin
        if(payload_in_valid)begin
          pid_filt_index <= payload_in_data[INFO_RAM_DBITS-1:0];
          pid_state <= SKIP_CHAN_NO;
        end
      end
      
      SKIP_CHAN_NO:begin
      	if(payload_in_valid)begin
          pid_state <= SYN_HEAD;
        end
      end
      
      SYN_HEAD:
      begin
        if(payload_in_valid) begin  
        	if(payload_in_data == 'h47) begin    	
            pid_state  <= START_FLAG;
          end
          else begin
          	pid_state  <= PID_IDLE; 
          end           
        end
      end
      
      START_FLAG:
      begin
        if(payload_in_valid) begin
        	pay_start <= payload_in_data[6];
        	pid_state  <= TS_PID;
        end  
      end
      
      TS_PID:
      begin
        if(payload_in_valid) begin
        	pid_state  <= ADAPT_CC;
        end  
      end
     
      ADAPT_CC:
      begin
        if(payload_in_valid) begin
        	{adap_filed_flag,update_pid_cc} <= payload_in_data[5:0];
        	pid_data_wena <= 1'b0;
        	pid_state  <= IF_TS_WENA;
        end  
      end  
          
      IF_TS_WENA:
      begin
      	if(if_data == 1'b1)begin
      		pid_state <= PID_IDLE;
      	end
      	else begin
      	  if(payload_in_valid) begin      				
      	    if(pay_start == 1'b1)begin
      	    	if(adap_filed_flag == 2'b11)begin ////pkt head + self + point len =6; adap_filed_flag == 2'b11, adapt filed =<182
      	        if(payload_in_data <= (TS_PKT_LEN-'d6))begin
      	        	ts_byte_offset <= 'd5 + payload_in_data[7:0];
      	          adap_filed_len <= payload_in_data[7:0];
      	          pid_data_wena <= 1'b1;
                  update_pkt_num <= pkt_num + 1'b1;
      	          pid_state  <= ADAPT_FIED_SKIP;
      	        end
      	        else begin
                  ts_err_flag <= 1'b1;
      	        	pid_state  <= GEN_UPDATE_INFO;
      	        end
      	      end
      	      else if(adap_filed_flag == 2'b01)begin
      	      	ts_byte_offset <= 'd5 + payload_in_data[7:0];
                point_filed_len <= payload_in_data[7:0];
                pid_data_wena <= 1'b1;
                update_pkt_num <= pkt_num + 1'b1;
      	    	  pid_state  <= POINT_FIED_SKIP;
      	      end
      	      else begin ////if(adap_filed_flag == 2'b10,2'b00) no exist
                ts_err_flag <= 1'b1;
                pid_state  <= GEN_UPDATE_INFO;
      	      end
      	    end
      	    else begin
      	    	if((update_pid_cc == pre_pid_cc+1) &&(pkt_num != 0)&& (rem_sect_len < (TS_PKT_LEN-'d5)))begin //only recv 2 pkt section ts pkts
      	    	  point_filed_len <= rem_point_len; 
      	    	  section_len <= rem_sect_len;
      	    	  if(rem_point_len != 0)begin
      	    	  	pid_data_wena <= 1'b1;
                  update_pkt_num <= pkt_num + 1'b1;
      	    	  	pid_state  <= POINT_FIED_SKIP;
      	    	  end
      	    	  else if(sect_status == 0)begin
      	    	  	pid_data_wena <= 1'b1;
                  update_pkt_num <= pkt_num + 1'b1;
      	    	  	pid_state <= SECT_LEN_H;
      	    	  end
      	    	  else if(sect_status == 2'b01)begin
      	    	  	pid_data_wena <= 1'b1;
                  update_pkt_num <= pkt_num + 1'b1;
      	    	  	pid_state <= SECT_LEN_L;
      	      	end
      	    	  else if(rem_sect_len != 0)begin
      	    	  	pid_data_wena <= 1'b1;
                  update_pkt_num <= pkt_num + 1'b1;
                  pid_state  <= SECTION_SKIP;
                end
                else begin
                  ts_err_flag <= 1'b1;
                  pid_state  <= GEN_UPDATE_INFO;
                end
              end
              else begin
                ts_err_flag <= 1'b1;
                pid_state  <= GEN_UPDATE_INFO;
              end
      	    end
      	  end
      	end
      end 
      
      ADAPT_FIED_SKIP:begin
      	if(payload_in_valid) begin
      		ts_byte_count <= ts_byte_count + 1'b1;
      		if(ts_byte_count == adap_filed_len)begin
      			ts_byte_count <= 0;
      			ts_byte_offset <= ts_byte_offset + payload_in_data[7:0] + 'd1; //self
        	  point_filed_len <= payload_in_data[7:0];
        	  pid_state <= POINT_FIED_SKIP;
          end
        end
      end
      
      POINT_FIED_SKIP:begin
      	if(ts_byte_offset >= TS_PKT_LEN)begin
      		update_point_len <= ts_byte_offset - TS_PKT_LEN;
      		pid_state <= GEN_UPDATE_INFO;
      	end
      	else begin
      		update_point_len <= 0;
      		if(payload_in_valid) begin
      		  ts_byte_count <= ts_byte_count + 1'b1;
      		  if(ts_byte_count == point_filed_len)begin
        	    ts_byte_count <= 0;
        	    ts_byte_offset <= ts_byte_offset + 1'b1;
        	    //table_id <= payload_in_data[7:0];
        	    pid_state <= SECT_LEN_H;
        	  end
        	end
        end
      end
      
      SECT_LEN_H:begin
      	if(payload_in_valid)begin    		
          update_sect_status <= 2'b01;
          section_len[11:8] <= payload_in_data[3:0];
          ts_byte_offset <= ts_byte_count + 1'b1; 
          pid_state <= SECT_LEN_L;
        end
        if((payload_in_end ==1'b1) || (ts_byte_offset >= TS_PKT_LEN ))begin
          pid_state <= GEN_UPDATE_INFO;
        end
      end
      
      SECT_LEN_L:begin
      	if(payload_in_valid)begin    		
          section_len[7:0] <= payload_in_data[7:0];
          ts_byte_offset <= ts_byte_count + 1'b1; 
          pid_state <= SECTION_SKIP;
        end
        if((payload_in_end ==1'b1) || (ts_byte_offset >= TS_PKT_LEN ))begin
          pid_state <= GEN_UPDATE_INFO;
        end
      end
      
      SECTION_SKIP:begin
        update_sect_status <= 2'b10;
      	if(payload_in_valid)begin
      		ts_byte_count <= ts_byte_count + 1'b1;    		      		          
            section_len <= section_len - 1'b1;         
      	end  	
      	if((payload_in_end ==1'b1) || (ts_byte_offset >= TS_PKT_LEN ) || (section_len == 0))begin
      		pid_state <= GEN_UPDATE_INFO;
      		update_sect_len <= section_len;
        end
      end 
         
      GEN_UPDATE_INFO:begin
        if(ts_err_flag)begin
          update_if_data <= 0;
          update_pkt_num <= 0;
          update_sect_status <= 0;
          update_point_len <= 0;
          update_sect_len <= 0;
          update_pid_cc <= 0; 
        end
        else begin
        	if(pid_data_wena) begin
        	  if((update_point_len == 0)&&(update_sect_status == 2'b10)&&(update_sect_len == 0))begin
        		  update_if_data <= 1'b1;
              update_sect_status <= 2'b11;
            end
          end
        end
        pid_state <= UPDATE_INFO_RAM;
      end
      
      UPDATE_INFO_RAM:
      begin 
        pid_state  <= PID_IDLE;
      end   
       
      default : pid_state <= PID_IDLE;
    endcase
  end
end

/*--------------------- info ram  ----------------------------------------*/
reg   [INFO_RAM_DBITS-1:0]               info_address;  
reg                                      info_write;   
reg   [INFO_RAM_WIDTH-1:0]               info_writedata;                            
wire  [INFO_RAM_WIDTH-1:0]               info_readdata;

reg   [INFO_RAM_DBITS-1:0]               check_address;  
reg                                      check_write;   
reg   [INFO_RAM_WIDTH-1:0]               check_writedata;                            
wire  [INFO_RAM_WIDTH-1:0]               check_readdata;
reg                                      init_info_ram;
always @ (posedge payload_clk or posedge payload_rst)
begin
	if(payload_rst)begin
    info_address <= 0;   
    info_write <= 0;     
    info_writedata <= 0; 
    if_data <= 0;      
    pkt_num <= 0;      
    sect_status <= 0;  
    rem_point_len <= 0;
    rem_sect_len <= 0; 
    pre_pid_cc <= 0; 
    init_info_ram <= 1'b1;  
	end
	else if(init_info_ram)begin
		info_write <= 1'b1;
		info_writedata <= 0;
		info_address <= info_address + 'b1;
		if(info_address == {INFO_RAM_DBITS{1'b1}})begin
			init_info_ram <= 1'b0;
		end
  end
	else begin		
		case(pid_state) 
		  SKIP_CHAN_NO:info_address <= pid_filt_index;
		  UPDATE_INFO_RAM:begin
		  	info_write <= 1'b1;   
        info_writedata <= {3'b0,update_if_data,update_pkt_num,update_sect_status,update_point_len,update_sect_len,update_pid_cc};
		  end
		  TS_PID:begin
		  	{if_data,pkt_num,sect_status,rem_point_len,rem_sect_len,pre_pid_cc} <= info_readdata[28:0];
		  end
		  default:begin
			  info_write <= 1'b0;
			  info_writedata <= 0;
		  end
	  endcase
	end
end

//ddp_ram_d512_w32 u_info (
//  .clka                  (payload_clk),
//  .rsta                  (payload_rst),
//  .wea                   (info_write),
//  .addra                 (info_address),
//  .dina                  (info_writedata),
//  .douta                 (info_readdata),
//  
//  .clkb                  (payload_clk),
//  .rstb                  (payload_rst),
//  .web                   (check_write),
//  .addrb                 (check_address),
//  .dinb                  (check_writedata),
//  .doutb                 (check_readdata)
//);

ddp_ram_d32_w32 u_info (
  .clka                  (payload_clk),
  .rsta                  (payload_rst),
  .wea                   (info_write),
  .addra                 (info_address),
  .dina                  (info_writedata),
  .douta                 (info_readdata),
  
  .clkb                  (payload_clk),
  .rstb                  (payload_rst),
  .web                   (check_write),
  .addrb                 (check_address),
  .dinb                  (check_writedata),
  .doutb                 (check_readdata)
);
//------------data delay------------------------------------------
localparam               DELAY_UNIT      = 9;

reg  [PAYLOAD_DATA_WIDTH*DELAY_UNIT-1:0] in_data_delay;
reg  [DELAY_UNIT-1:0]                    in_valid_delay;

always @ (posedge payload_clk or posedge payload_rst)
begin
	if(payload_rst)
  begin
    in_data_delay <= 0;
    in_valid_delay <= 0;
  end
  else begin
  	in_data_delay <= {in_data_delay[PAYLOAD_DATA_WIDTH*(DELAY_UNIT-1)-1:0],payload_in_data};
  	in_valid_delay <= {in_valid_delay[DELAY_UNIT-2:0],payload_in_valid};
  end
end

//------------------------------------ts buffer write--------------------------------------------
localparam           P_TS_BUFFER_SIZE  = 192;  // 192 byte
localparam           PID_RAM_DEPTH     = INFO_RAM_DEPTH * P_TS_BUFFER_SIZE * 2; //1pid * 2 * 192 byte
localparam           PID_RAM_DBITS     = alt_clogb2(PID_RAM_DEPTH);

wire [PID_RAM_DBITS-1:0]                data_buf_waddr_base;
reg  [PID_RAM_DBITS-1:0]                data_buf_waddr;
reg  [PID_RAM_DBITS-1:0]                write_offset; 
reg                                     data_buf_wite;
reg  [PAYLOAD_DATA_WIDTH-1:0]           data_buf_wdata;

always @ (posedge payload_clk or posedge payload_rst)
begin
	if(payload_rst)
  begin
    data_buf_wite <= 0;
    data_buf_wdata <= 0;
    write_offset <= 0;
    data_buf_waddr <= 0;
  end
  else begin
  	if(pid_data_wena)begin
  		data_buf_wite  <= in_valid_delay[DELAY_UNIT-1];
  		data_buf_wdata <= in_data_delay[PAYLOAD_DATA_WIDTH*DELAY_UNIT-1:PAYLOAD_DATA_WIDTH*(DELAY_UNIT-1)] ;
  		write_offset   <= write_offset + in_valid_delay[DELAY_UNIT-1];
  		data_buf_waddr <= data_buf_waddr_base + write_offset;
  	end
  	else begin
  		data_buf_wite <= 0;
      data_buf_wdata <= 0;
      write_offset <= 0;
  	end
  end
end

assign   data_buf_waddr_base = P_TS_BUFFER_SIZE * (pid_filt_index + pkt_num);

/*---------------------------ts buffer read ------------------------------------*/
wire  [PID_RAM_DBITS-1:0]               data_buf_raddr;
wire  [PAYLOAD_DATA_WIDTH-1:0]          data_buf_rdata;

//sdp_ram_d24576_w8 u_data_ram (
//  .clka    (payload_clk),
//  .addra   (data_buf_waddr),
//  .wea     (data_buf_wite),
//  .dina    (data_buf_wdata),
//               
//  .clkb    (payload_clk),
//  .addrb   (data_buf_raddr),
//  .doutb   (data_buf_rdata)        
//  );
  
sdp_ram_d12288_w8 u_data_ram (
  .clka    (payload_clk),
  .addra   (data_buf_waddr),
  .wea     (data_buf_wite),
  .dina    (data_buf_wdata),
               
  .clkb    (payload_clk),
  .addrb   (data_buf_raddr),
  .doutb   (data_buf_rdata)        
  );
localparam            PAYLOAD_IDLE      =  0; 
localparam            WAIT_CHECK_DATA   =  1;
localparam            READ_CHECK_DATA   =  2;
localparam            CHECK_DATA_STATUS =  3;
localparam            READ_BUF_START    =  4;
localparam            WAIT_BUF_DATA     =  5;
localparam            DATA_OUT_START    =  6;
localparam            DATA_OUT_ING      =  7;
localparam            DATA_OUT_END      =  8;
localparam            IF_PKT_RDOVER     =  9;
localparam            CLEAN_PRE_STATUS  =  10;
localparam            UPDATE_OUT_ADDR   =  11; 

reg  [3:0]                               payload_out_state;   
reg  [PID_RAM_DBITS-1:0]                 read_offset;
reg  [1:0]                               check_pkt_count;  //2 pkt 

reg                                      check_if_data;    
reg   [1:0]                              check_pkt_num;       
reg   [1:0]                              check_sect_status;  

always @ (posedge payload_clk or posedge payload_rst)
begin
	if(payload_rst)begin
    check_address <= 0;   
    check_write <= 0;     
    check_writedata <= 0; 
	end
	else begin
		check_write <= 1'b0;     
    check_writedata <= 0;
		case (payload_out_state)
			UPDATE_OUT_ADDR: check_address <= check_address + 1'b1;
			READ_CHECK_DATA: {check_if_data,check_pkt_num,check_sect_status} <= check_readdata[28:24];
			CLEAN_PRE_STATUS:begin
				check_write <= 1'b1;     
        check_writedata <= 0; 
			end
		endcase 			
  end
end

always @ (posedge payload_clk or posedge payload_rst)
begin
  if(payload_rst)
  begin
  	payload_out_data <= 0; 
    payload_out_valid <= 0;
    payload_out_start <= 0;
    payload_out_end <= 0;  
  	payload_out_state <= PAYLOAD_IDLE;
  end
  else begin
    payload_out_valid <= 0;
    payload_out_start <= 0;
    payload_out_end <= 0;    
  	case (payload_out_state)
  	
  	  PAYLOAD_IDLE:begin
  	  	if(payload_out_req)begin
  	  		payload_out_state <= WAIT_CHECK_DATA;
  	  	end
  	  end
  	  
  	  WAIT_CHECK_DATA:begin
  	  	payload_out_state <= READ_CHECK_DATA;
  	  end
  	  
  	  READ_CHECK_DATA:begin
  	  	payload_out_state <= CHECK_DATA_STATUS;
  	  end
  	  
  	  CHECK_DATA_STATUS:begin
  	  	if((check_if_data == 1'b1) &&(check_sect_status == 2'b11) && (check_pkt_num != 0))begin
  	  		check_pkt_count <= 0;
  	  		read_offset <= 0;
  	  		payload_out_state <= READ_BUF_START;
  	  	end
  	  	else begin
  	  		payload_out_state <= UPDATE_OUT_ADDR;
  	  	end
  	  end
  	  
  	  READ_BUF_START:begin
  	  	read_offset <= read_offset + 1'b1;
  	  	payload_out_state <= WAIT_BUF_DATA;
  	  end 
  	  
  	  WAIT_BUF_DATA:begin
  	  	read_offset <= read_offset + 1'b1;
  	  	payload_out_state <= DATA_OUT_START;
  	  end 
  	  		
  	  DATA_OUT_START:begin
  	  	payload_out_valid <= 1'b1;
        payload_out_start <= 1'b1;
        read_offset <= read_offset + 1'b1;
        payload_out_data <= data_buf_rdata;
        payload_out_state <= DATA_OUT_ING;
  	  end
  	  
  	  DATA_OUT_ING:begin
        payload_out_valid <= 1'b1;
        payload_out_data <= data_buf_rdata;
        if(read_offset==(P_TS_BUFFER_SIZE)) begin
          payload_out_state <= DATA_OUT_END;
        end
        else begin
          read_offset <= read_offset + 1;
        end
      end
      
      DATA_OUT_END:begin
      	payload_out_valid <= 1'b1;
        payload_out_data <= data_buf_rdata;
        payload_out_end <= 1'b1;
        check_pkt_count <= check_pkt_count + 1'b1;
        payload_out_state <= IF_PKT_RDOVER; 
      end
      
      IF_PKT_RDOVER:begin
      	if(check_pkt_count == check_pkt_num)begin
      		payload_out_state <= CLEAN_PRE_STATUS;
      	end
      	else begin
          read_offset <= 0;
  	  		payload_out_state <= READ_BUF_START;
      	end
      end
            
      CLEAN_PRE_STATUS:begin
      	payload_out_state <= UPDATE_OUT_ADDR;
      end

      UPDATE_OUT_ADDR:begin
      	payload_out_state <= PAYLOAD_IDLE;
      end
      
      default:payload_out_state <= PAYLOAD_IDLE;
    endcase
  end
end


assign   data_buf_raddr = (P_TS_BUFFER_SIZE * (check_address + check_pkt_count)) + read_offset;
endmodule // 



       