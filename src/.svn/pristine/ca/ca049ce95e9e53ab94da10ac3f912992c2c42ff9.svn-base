`include "spi_defines.v"
module spi_slave
(
  //  signals
  clk, rst, dat_i, dat_o, 
  we_i, valid_o,start_o,end_o,we_ack_o,

  // SPI signals
  ss_i, sclk_i, miso_o, mosi_i
);

  // Wishbone signals
  input                        clk        ;         // master clock input
  input                        rst        ;         // synchronous active high reset
  input   [`SPI_MAX_CHAR-1:0]  dat_i      ;         // databus input
  input                        we_i       ;          // write enable input
  output  [`SPI_MAX_CHAR-1:0]  dat_o      ;         // databus output
  output                       valid_o    ;        //  request signal output
  output                       start_o    ; 
  output                       end_o      ; 
  output                       we_ack_o   ;
  
                                                     
  // SPI signals                                     
  input                        ss_i   ;       // slave select
  input                        sclk_i ;       // serial clock
  output                       miso_o ;       // master in slave out 
  input                        mosi_i ;       // master out slave in
   
 // reg                          valid_o    ;	
 // reg      [`SPI_MAX_CHAR-1:0] dat_o      ;
  wire                         valid_o    ;	
  wire     [`SPI_MAX_CHAR-1:0] dat_o      ;
  reg                          we_ack_o   ;
                                               
  // Internal signals-------------------------------------------------------------------------------
  reg     [`SPI_MAX_CHAR-1:0]      tx_data;              // wb data out
  reg     [`SPI_MAX_CHAR-1:0]      rx_data;  

  reg                              rx_tip;           // rx in progress 
  reg                              tx_tip;           // tx in progress 
  
  wire                             rx_negedge ;       // miso is sampled on negative edge
  wire                             tx_negedge ;       // mosi is driven on negative edge
  wire    [`SPI_CHAR_LEN_BITS-1:0] len;              // char len
  wire                             lsb;              // lsb first on line
   
  wire                             pos_edge;         // recognize posedge of sclk
  wire                             neg_edge;         // recognize negedge of sclk

  reg                              s_out;
 // reg   [1:0]                      s_in;
  reg                              s_in;
  reg   [2:0]                      s_sel; 
  reg   [2:0]                      s_clk; 
  
  assign rx_negedge = `SPI_CTRL_RX_NEGEDGE;
  assign tx_negedge = `SPI_CTRL_TX_NEGEDGE;
  assign len        = `SPI_MAX_CHAR - 1;
  assign lsb        = `SPI_CTRL_LSB;
  
  assign miso_o  = s_out;
  assign valid_o = rst? 1'b0 : (!rx_tip);
  assign dat_o   = rst? 8'h00 : rx_data;
  // sync SCK to the FPGA clock using a 3-bits shift register
  always @(posedge clk)  s_clk <= {s_clk[1:0], sclk_i};
  
  //assign pos_edge = (s_clk[2:1] == 2'b01);  // now we can detect SCK rising edges
  assign pos_edge = (s_clk[1:0] == 2'b01);
  assign neg_edge = (s_clk[1:0] == 2'b10);  // and falling edges
 // same thing for SSEL   
  always @(posedge clk)  s_sel <= {s_sel[1:0], ss_i};  
  wire    sel_active = ~s_sel[1];               // SSEL is active low
  assign  start_o    = (s_sel[1:0] == 2'b10);
  assign  end_o      = (s_sel[2:1] == 2'b01);
  
  //---------------------------------------------- ---------------------------------
  //                  Receiving bits from the line
  //----------------------------------------------------------------------------------    
  wire   rx_clk = (rx_negedge ? neg_edge : pos_edge);  
  reg    [`SPI_CHAR_LEN_BITS-1:0] rx_cnt;       // rx data bit count
  wire   rx_lst_bit = !(|rx_cnt);
 // and for MOSI
  //always @(posedge clk)  s_in <= {s_in[0], mosi_i};  
  always @(posedge clk)  s_in <=  mosi_i;
  // Character bit counter
  always @(posedge clk or posedge rst)
  begin
    if(rst)
      rx_cnt <=  len;
    else
      begin
        if(!rx_tip || end_o || start_o)
		    rx_cnt <=  len;
        else
          rx_cnt <=  rx_clk ? (rx_cnt -1'b1): rx_cnt;
      end
  end
 
  // Transfer in progress
  always @(posedge clk or posedge rst)
  begin
    if(rst)
      rx_tip <=  1'b0;
    else if(!rx_tip)
      rx_tip <=  1'b1;
    else if(rx_tip && rx_lst_bit && rx_clk)
      rx_tip <=  1'b0;
  end
 
  always @(posedge clk or posedge rst)
  begin
    if (rst)
      rx_data   <=  {`SPI_MAX_CHAR{1'b0}};
    else begin
    	if(sel_active && rx_clk)
        //rx_data <= lsb? {s_in[1],rx_data[`SPI_MAX_CHAR-1:1]}:{rx_data[`SPI_MAX_CHAR-2:0],s_in[1]};
		  rx_data <= lsb? {s_in,rx_data[`SPI_MAX_CHAR-1:1]}:{rx_data[`SPI_MAX_CHAR-2:0],s_in};
    end
  end
  
    // output

	 /*
  always @(posedge clk or posedge rst)
  begin
    if (rst)begin
      valid_o <= 1'b0;
      dat_o <= {`SPI_MAX_CHAR{1'b0}};
	 end
    else begin
	   if (!rx_tip)begin
        valid_o <= 1'b1;
        dat_o <=  rx_data;
	   end
      else begin 
        valid_o <=  1'b0;
		end
	 end
  end 
 */ 
  // ------------------------------------------------------------------------------
  //                   Sending bits to the line
  //--------------------------------------------------------------------------------
  wire   tx_clk = (tx_negedge ? neg_edge : pos_edge);
  reg    [`SPI_CHAR_LEN_BITS-1:0] tx_cnt;       // tx data bit count
  wire   tx_lst_bit = !(|tx_cnt);

  // Character bit counter
  always @(posedge clk or posedge rst)
  begin
    if(rst)
      tx_cnt <=  len;
    else
      begin
        if(!tx_tip || end_o || start_o)
		    tx_cnt <=  len;
        else
          tx_cnt <=  tx_clk ? (tx_cnt-1'b1): tx_cnt;
      end
  end
 
  // Transfer in progress
  always @(posedge clk or posedge rst)
  begin
    if(rst)
      tx_tip <=  1'b0;
    else if(we_i && !tx_tip)
      tx_tip <=  1'b1;
    else if(tx_tip && tx_lst_bit && tx_clk)
      tx_tip <=  1'b0;
  end
  
  
  always @(posedge clk or posedge rst)
  begin
    if (rst)begin
     tx_data  <=  8'hff;
     we_ack_o <=  1'b0;
	 end
    else begin
    	we_ack_o <=  1'b0;  	 
      if (we_i && !tx_tip)begin
        tx_data[`SPI_MAX_CHAR-1:0] <=  dat_i[`SPI_MAX_CHAR-1:0];
        we_ack_o <= 1'b1;
      end
      else begin 
		  if(sel_active && tx_clk) begin
          tx_data <= lsb? {1'b1,tx_data[`SPI_MAX_CHAR-1:1]}:{tx_data[`SPI_MAX_CHAR-2:0],1'b1};
			 s_out <= lsb? tx_data[0]:tx_data[`SPI_MAX_CHAR-1];
        end	
      end	
    end
  end
  
  
            
endmodule