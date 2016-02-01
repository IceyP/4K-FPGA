/*************************************************************************************\
    Copyright(c) 2015, China Digital TV Holding Co., Ltd,All right reserved
    Department   :   Creative Center,R&D Hardware Department
    Filename     :   pktmux_slfifo.v
    Author       :   huangrui/1480
    ==================================================================================
    Description  :   
    
    ==================================================================================
    Modification History:
    Date        By                  Rev.        Prj.        Change Description
    ----------------------------------------------------------------------------------
    2015-01-14  huangrui/1480       1.0         rt21        Create
    ==================================================================================
    Called by    :   pktmux_slfifo.v
    File tree    :   pktmux_slfifo.v
\************************************************************************************/

`timescale 1ns/100ps

module pktmux_slfifo(
    clk                         ,
    rst                         ,
                                
    tsa_valid                   ,
    tsa_data                    ,
    tsa_eop                     ,
    tsa_rdy                     ,
    tsa_ack                     ,
                                
    tsb_valid                   ,
    tsb_data                    ,
    tsb_eop                     ,
    tsb_rdy                     ,
    tsb_ack                     ,
                                 
    sl_wr                       ,
    sl_data                     ,
    sl_bp                       ,   //0:full;1:not full
    sl_fifo_adr                 ,
	 sl_ram_full					  ,
	 sl_rd_clk						  ,
//	 sl_rst                      ,
    sl_pkt_end                   
    );

parameter   TOTAL_CHN_NUM               = 2                         ;

parameter   ST_WIDTH                    = 3                         ;
parameter   ST_IDLE                     = 3'b001                    ,
            ST_START                    = 3'b010                    ,
            ST_END                      = 3'b100                    ;

input                                   clk                         ;
input                                   rst                         ;
            
input                                   tsa_valid                   ;
input   [7:0]                           tsa_data                    ;
input                                   tsa_eop                     ;
input                                   tsa_rdy                     ;
output                                  tsa_ack                     ;

input                                   tsb_valid                   ;
input   [7:0]                           tsb_data                    ;
input                                   tsb_eop                     ;
input                                   tsb_rdy                     ;
output                                  tsb_ack                     ;

output                                  sl_wr                       ;
output  [7:0]                           sl_data                     ;
input                                   sl_bp                       ;
output                                  sl_pkt_end                  ;
output  [1:0]                           sl_fifo_adr                 ;
input												 sl_rd_clk						  ;
output											 sl_ram_full					  ;

reg                                     sl_wr                       ;
//reg     [7:0]                           sl_data                     ;
reg                                     sl_pkt_end                  ;

wire    [TOTAL_CHN_NUM - 1 : 0]         ts_pkt_rdy                  ;
wire    [TOTAL_CHN_NUM - 1 : 0]         ts_pkt_ack_buf              ;
reg     [TOTAL_CHN_NUM - 1 : 0]         ts_pkt_ack                  ;
wire                                    tsa_ack                     ;
wire                                    tsb_ack                     ;

reg                                     rr_start                    ;
reg     [ST_WIDTH - 1 : 0]              st_curr                     ;
reg     [ST_WIDTH - 1 : 0]              st_next                     ;

(*keep="true"*)
wire                                    pkt_valid                   ;
(*keep="true"*)
wire                                    pkt_end                     ;

//---------------------------
//--------FIFO---------------
//---------------------------
reg												 fifo_wren;
reg	[7:0]										 fifo_din;
wire												 fifo_rden;
wire	[7:0]										 fifo_dout;
wire  [11:0]									 fifo_rd_cnt;
wire												 fifo_full;
wire												 fifo_empty;
reg												 fifo_ok;
reg	[2:0]										 div_cnt;

wire												 fifo_alempty;
reg												 fifo_alempty_1syn;
reg												 fifo_alempty_2syn;
wire												 fifo_alfull;
reg												 fifo_alfull_1syn;
reg												 fifo_alfull_2syn;

//assign  pkt_valid   =   tsa_valid | tsb_valid;
assign  pkt_valid   =   tsa_valid;
assign  pkt_end     =   tsa_eop | tsb_eop;
assign  ts_pkt_rdy  =   {tsa_rdy,tsb_rdy};
assign  sl_fifo_adr =   2'b00;
assign  tsa_ack     =   ts_pkt_ack[1];
assign  tsb_ack     =   ts_pkt_ack[0];

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        st_curr <=  ST_IDLE;
    end
    else
    begin
        st_curr <=  st_next;
    end
end

always@*
begin
    case(st_curr)
    ST_IDLE:
    begin
        if(|ts_pkt_rdy==1'b1)
        begin
            st_next =   ST_START;
        end
        else
        begin
            st_next =   ST_IDLE;
        end
    end
    ST_START:
    begin
        st_next =   ST_END;
    end
    ST_END:
    begin
        if(pkt_end==1'b1)
        begin
            st_next =   ST_IDLE;
        end
        else
        begin
            st_next =   ST_END;
        end
    end
    default:
    begin
        st_next =   ST_IDLE;
    end
    endcase
end           

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        rr_start    <=  1'b0;
    end
    else if(st_curr==ST_START)
    begin
        rr_start    <=  1'b1;
    end
    else
    begin
        rr_start    <=  1'b0;
    end
end

always@(posedge sl_rd_clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        sl_wr       <=  1'b1;
        sl_pkt_end  <=  1'b1;
    end
    else
    begin
        sl_wr       <=  ~fifo_rden;
        sl_pkt_end  <=  1'b1;           //~pkt_end;
    end
end
        
always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        ts_pkt_ack  <=  {TOTAL_CHN_NUM{1'b0}};
    end
    else
    begin
        ts_pkt_ack  <=  ts_pkt_ack_buf;
    end
end

////////////////////////////////////////////////////////////////////
//round_robin_arbiter
////////////////////////////////////////////////////////////////////
round_robin_arbiter2 #(
    .CHN_NUM                            ( TOTAL_CHN_NUM             )
    )
u0_rr_arbiter2(
    .clk                                ( clk                       ),
    .rst                                ( rst                       ),
    .req                                ( ts_pkt_rdy                ),
    .ack                                ( rr_start                  ),
    .grant                              ( ts_pkt_ack_buf            )
    );

////////////////////////////////////////////////////////////////////
//FIFO write
////////////////////////////////////////////////////////////////////
always @ (posedge clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		fifo_wren	<=		1'b0;
	end
	else
	begin
		fifo_wren	<=		(tsa_valid | tsb_valid) & ~fifo_alfull_2syn;
	end
end

always@(posedge clk or posedge rst)
begin
    if(rst==1'b1)
    begin
        fifo_din <=  {8{1'b0}};
    end
    else
    begin
        if(tsa_valid==1'b1)
        begin
            fifo_din <=  tsa_data;
        end
        else if(tsb_valid==1'b1)
        begin
            fifo_din <=  tsb_data;
        end
    end
end

always @ (posedge sl_rd_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		fifo_ok	<= 1'b0;
	end
	else if(fifo_alempty_2syn == 1'b0)
	begin
		fifo_ok	<= 1'b1;
	end
	else
	begin
		fifo_ok	<= 1'b0;
	end
end

always @ (posedge sl_rd_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		div_cnt	<= 3'b000;
	end
	else
	begin
		div_cnt	<= div_cnt + 'h1;
	end
end

assign	fifo_rden	=	sl_bp & fifo_ok & (&div_cnt);
//assign	fifo_rden	=	sl_fifo_rdy & fifo_ok & (&div_cnt);

assign	sl_data		=	fifo_dout;

assign	sl_ram_full =  fifo_alfull;

//------------------------------------------------------------------
//FIFO 8 * 2048
//------------------------------------------------------------------	 
FIFO8K fifo_8k (

  .rst(rst), // input rst
  .wr_clk(clk), // input wr_clk
  .rd_clk(sl_rd_clk), // input rd_clk
  .din(fifo_din), // input [7 : 0] din
  .wr_en(fifo_wren), // input wr_en
  .rd_en(fifo_rden), // input rd_en
  .dout(fifo_dout), // output [7 : 0] dout
  .full(fifo_full), // output full
  .almost_full(fifo_alfull), // output almost_full
  .empty(fifo_empty), // output empty
  .almost_empty(fifo_alempty) // output almost_empty
);
/*
  .rst(rst), // input rst
  .wr_clk(clk), // input wr_clk
  .rd_clk(sl_rd_clk), // input rd_clk
  .din(fifo_din), // input [7 : 0] din
  .wr_en(fifo_wren), // input wr_en
  .rd_en(fifo_rden), // input rd_en
  .dout(fifo_dout), // output [7 : 0] dout
  .full(fifo_full), // output full
  //.almost_full(fifo_alfull), // output almost_full
  .empty(fifo_empty), // output empty
  //.almost_empty(fifo_alempty) // output almost_empty
  .prog_full(fifo_alfull), // output prog_full
  .prog_empty(fifo_alempty) // output prog_empty
);
*/
always @ (posedge sl_rd_clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		fifo_alempty_1syn	<= 1'b0;
		fifo_alempty_2syn	<= 1'b0;
	end
	else
	begin
		fifo_alempty_1syn	<= fifo_alempty;
		fifo_alempty_2syn	<= fifo_alempty_1syn;
	end
end

always @ (posedge clk or posedge rst)
begin
	if(rst == 1'b1)
	begin
		fifo_alfull_1syn	<= 1'b0;
		fifo_alfull_2syn	<= 1'b0;
	end
	else
	begin
		fifo_alfull_1syn	<= fifo_alfull;
		fifo_alfull_2syn	<= fifo_alfull_1syn;
	end
end

endmodule   
