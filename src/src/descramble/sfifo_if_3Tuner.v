module sfifo_if_3Tuner(
    clk                         ,
    rst                         ,
    flaga                       ,
    flagb                       ,
    fadd                        ,
    data_out                    ,
    sloe                        ,
    slrd                        ,
    slwr                        ,
    pktend_o                    ,
    pktstart_o                  ,
    pid_idx                     ,
    lend_p1                     ,
    lpid_fd1                    ,
    lbuffer_h1                  ,
    lpid_i1                     ,
    db_radd_en                  ,
    db_radd                     ,
    db_out1                     ,
    mrxdv
    );

input                                   clk                         ;
input                                   rst                         ;
input                                   flaga                       ;
input                                   flagb                       ;
output  [1:0]                           fadd                        ;
output  [7:0]                           data_out                    ;
output                                  sloe                        ;
output                                  slrd                        ;
output                                  slwr                        ;
output                                  pktend_o                    ;
output                                  pktstart_o                  ;
output  [11:0]                          pid_idx                     ;
input                                   lend_p1                     ;
input                                   lpid_fd1                    ;
input                                   lbuffer_h1                  ;
input   [11:0]                          lpid_i1                     ;
output                                  db_radd_en                  ;
output  [8:0]                           db_radd                     ;
input   [7:0]                           db_out1                     ;
output                                  mrxdv                       ;

wire                                    fifo_full                   ;   
wire                                    fifo_empty                  ;
reg     [8:0]                           radd                        ;
reg                                     d_rdy                       ;
reg                                     pktend                      ;
reg                                     pktstart                    ;
reg                                     end_p_d                     ;
reg                                     tmp1                        ;
reg                                     sel_scram                   ;
reg     [1:0]                           cur_scram                   ;
reg                                     lend_p                      ;
reg                                     lpid_fd                     ;
reg                                     lbuffer_h                   ;
wire    [7:0]                           db_out                      ;
reg     [11:0]                          lpid_i                      ;
reg                                     slwr_i                      ;
reg     [11:0]                          pid_idx                     ;

assign  fifo_empty  =   ~flaga;
assign  fifo_full   =   ~flagb;
assign  sloe        =   1'b1;
assign  slrd        =   1'b1;
assign  slwr        =   (fifo_full==1'b1)   ?   1'b1    :   slwr_i;
assign  pktend_o    =   ~pktend;
assign  pktstart_o  =   ~pktstart;

assign  fadd        =   2'b01;
assign  mrxdv       =   d_rdy;
assign  db_radd     =   radd;
assign  db_radd_en  =   ~fifo_full;

always@(posedge clk)
begin
    if(rst==1'b0)
    begin
        tmp1        <=  1'b0;
        sel_scram   <=  1'b0;
    end
    else
    begin
        tmp1    <=  lend_p1 & lpid_fd1;
        if(((lpid_fd1 & lend_p1)==1'b1) && (tmp1==1'b0))
        begin
            sel_scram   <=  1'b1;
        end
        
        if((pktend==1'b0) && (cur_scram==2'b01))
        begin
            sel_scram   <=  1'b0;
        end
    end
end

assign  data_out=   (rst==1'b1)  ?  db_out : 8'h00;
assign  db_out  =   ((rst==1'b1) && (sel_scram==1'b1) && 
                    ((cur_scram==2'b00) || (cur_scram==2'b01)))   ?   db_out1 :   8'h00;

always@(posedge clk)
begin
    if(rst==1'b0)
    begin
        lpid_fd     <=  1'b0;
        lend_p      <=  1'b0;
        cur_scram   <=  2'b00;
        lbuffer_h   <=  1'b0;
        lpid_i      <=  {12{1'b0}};
    end
    else if((sel_scram==1'b1) && ((cur_scram==2'b00) || (cur_scram==2'b01)))
    begin
        if(pktend==1'b1)
        begin
            lpid_fd     <=  1'b1;
            lend_p      <=  1'b1;
            cur_scram   <=  2'b01;
        end
        
        if((pktend==1'b0) || (fifo_full==1'b1))
        begin
            lpid_fd     <=  1'b0;
            lend_p      <=  1'b0;
            cur_scram   <=  2'b00;
        end
        lbuffer_h   <=  lbuffer_h1;
        lpid_i      <=  lpid_i1;
    end
    else
    begin
        lpid_fd     <=  1'b0;
        lend_p      <=  1'b0;
        cur_scram   <=  2'b00;
    end
end

always@(posedge clk)
begin
    if(rst==1'b0)
    begin
        slwr_i      <=  1'b1;
        pktend      <=  1'b1;
        pktstart    <=  1'b1;
        pid_idx     <=  {12{1'b0}};
    end
    else
    begin
        end_p_d <=  lpid_fd & lend_p;
        if(((lpid_fd & lend_p)==1'b1) && (end_p_d==1'b0))
        begin
            radd[8]     <=  lbuffer_h;
            pid_idx     <=  lpid_i[11:0];
            d_rdy       <=  1'b1;
            radd[7:0]   <=  8'h00;
        end
        
        if(d_rdy & (~fifo_full)==1'b1)
        begin
            slwr_i  <=  1'b0;
            if(radd[7:0]==8'h00)
            begin
                pktstart    <=  1'b0;
            end
            
            if(radd[7:0]==187)
            begin
                pktend      <=  1'b0;
                d_rdy       <=  1'b0;
                radd[7:0]   <=  8'h00;
            end
            else
            begin
                radd[7:0]   <=  radd[7:0] + 8'h01;
            end
        end
        else
        begin
            slwr_i <=  1'b1;
        end
        
        if(pktstart==1'b0)
        begin
            pktstart    <=  1'b1;
        end
        
        if(pktend==1'b0)
        begin
            pktend  <=  1'b1;
        end
    end
end

endmodule
