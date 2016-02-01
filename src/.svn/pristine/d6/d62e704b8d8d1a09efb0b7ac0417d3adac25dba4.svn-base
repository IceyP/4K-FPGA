module descramble_ctl(
    reset                       ,
    pci_clk2                    ,
    pci_clk                     ,
    ck                          ,
    sb                          ,
    nrst                        ,
    st                          ,
    p                           ,
    db                          ,
    db_valid                    ,
    ldkey_cnt                   ,
    sreg_kv                     ,
    sreg_kv2                    ,
    sreg_kv3                    ,
    db_in                       ,
    db_wea                      ,
    db_wadd                     ,
    r_data                      ,
    pid_i                       ,
    end_p                       ,
    pid_fd                      ,
    buffer_h                    ,
    r_add                       ,
    cw_readadd                  ,
    cw_out                      ,
    lend_p                      ,
    lpid_fd                     ,
    lbuffer_h                   ,
    lpid_i                      ,
    t_stidle
    );

parameter   IDLE                        = 6'b00_0001                ,
            GET_HD                      = 6'b00_0010                ,
            GET_ALEN                    = 6'b00_0100                ,
            GET_AP                      = 6'b00_1000                ,
            GET_SB                      = 6'b01_0000                ,
            GET_DB                      = 6'b10_0000                ;
                        
input                                   reset                       ;
input                                   pci_clk2                    ;
input                                   pci_clk                     ;
output  [0:7]                           ck                          ;
output  [0:7]                           sb                          ;
output                                  nrst                        ;
output                                  st                          ;
output  [0:7]                           p                           ;
input   [0:7]                           db                          ;
input   [0:2]                           ldkey_cnt                   ;
input                                   db_valid                    ;
input                                   sreg_kv                     ;
input                                   sreg_kv2                    ;
input                                   sreg_kv3                    ;
output  [7:0]                           db_in                       ;
output  [8:0]                           db_wadd                     ;
output                                  db_wea                      ;
input   [7:0]                           r_data                      ;
input   [11:0]                          pid_i                       ;
input                                   end_p                       ;
input                                   pid_fd                      ;
input                                   buffer_h                    ;
output  [8:0]                           r_add                       ;
output  [10:0]                          cw_readadd                  ;
input   [7:0]                           cw_out                      ;
output                                  lend_p                      ;
output                                  lpid_fd                     ;
output                                  lbuffer_h                   ;
output                                  t_stidle                    ;
output  [11:0]                          lpid_i                      ;

reg     [6:0]                           pid_idx                     ;
reg     [3:0]                           except_idx                  ;
reg                                     cw_odd                      ;
reg                                     pid_ds                      ;
reg     [8:0]                           radd                        ;
reg     [8:0]                           dbwadd                      ;
reg     [2:0]                           radd_cnt                    ;
wire                                    radd_inc                    ;
wire                                    dbwea                       ;
reg     [0:7]                           p_cnt                       ;
reg     [7:0]                           alen                        ;
reg                                     err_bit                     ;
wire                                    endpkt                      ;
reg                                     startpkt                    ;
wire                                    s_flag                      ;
reg     [5:0]                           ds_state                    ;
wire                                    st_idle                     ;
wire                                    st_get_hd                   ;
wire                                    st_get_alen                 ;
wire                                    st_get_ap                   ;
wire                                    st_get_sb                   ;
wire                                    st_get_db                   ;
reg                                     st                          ;
reg     [11:0]                          pid_i_1dly                  ;

assign  nrst    =   reset;
assign  ck[0]   =   cw_out[7];
assign  ck[1]   =   cw_out[6];
assign  ck[2]   =   cw_out[5];
assign  ck[3]   =   cw_out[4];
assign  ck[4]   =   cw_out[3];
assign  ck[5]   =   cw_out[2];
assign  ck[6]   =   cw_out[1];
assign  ck[7]   =   cw_out[0];
assign  sb[0]   =   r_data[7];
assign  sb[1]   =   r_data[6];
assign  sb[2]   =   r_data[5];
assign  sb[3]   =   r_data[4];
assign  sb[4]   =   r_data[3];
assign  sb[5]   =   r_data[2];
assign  sb[6]   =   r_data[1];
assign  sb[7]   =   r_data[0];

assign  p           =   p_cnt;
assign  t_stidle    =   st_get_sb;
assign  st_idle     =   ds_state[0];
assign  st_get_hd   =   ds_state[1];
assign  st_get_alen =   ds_state[2];
assign  st_get_ap   =   ds_state[3];
assign  st_get_sb   =   ds_state[4];
assign  st_get_db   =   ds_state[5];

assign  cw_readadd  =   {pid_idx[6:0],cw_odd,ldkey_cnt[0:2]};
assign  r_add       =   radd;
assign  dbwea       =   ((st_get_hd | st_get_ap | st_get_db) & radd_inc) | (st_get_sb & db_valid);
assign  db_wea      =   dbwea;
assign  db_wadd     =   dbwadd;
assign  s_flag      =   ((st_get_hd==1'b1) && (radd[3:0]==4'h0) && (pid_ds==1'b1) && (radd_inc==1'b1))  ?   1'b1    :   1'b0;
assign  db_in       =   (st_get_sb==1'b1)   ?   db  :
                        (s_flag==1'b1)      ?   {r_data[7:4],1'b1,r_data[2:0]}    :
                        ((st_get_hd==1'b1) && (radd[3:0]==4'h3) && (pid_ds==1'b1) && (radd_inc==1'b1))  ?   {2'b00,r_data[5:0]} :
                        r_data;
                        
assign  endpkt      =   (dbwadd[7:0]==188)  ?   1'b1    :   1'b0;
assign  lend_p      =   endpkt;
assign  lpid_fd     =   endpkt;
assign  lbuffer_h   =   dbwadd[8];
assign  lpid_i      =   {except_idx[3:0],pid_ds,pid_idx[6:0]};
assign  radd_inc    =   &radd_cnt[2:0];

always@(posedge pci_clk2)
begin
    if(reset==1'b0)
    begin
        ds_state    <=  IDLE;
    end
    else
    begin
        startpkt    <=  end_p & pid_fd;
        case(ds_state)
        IDLE:
        begin
            if(startpkt==1'b1)
            begin
                ds_state    <=  GET_HD;
            end
        end
        GET_HD:
        begin
            if((radd[3:0]==4'h1) && (radd_inc==1'b1))
            begin
                err_bit <=  r_data[7];
            end
            if((radd[3:0]==4'h3) && (radd_inc==1'b1))
            begin
                if((pid_ds==1'b0) || (err_bit==1'b1))
                begin
                    ds_state    <=  GET_DB;
                end
                else if(r_data[7:6]==2'b00)
                begin
                    ds_state    <=  GET_DB;
                end
                else
                begin
                    cw_odd  <=  r_data[6];
                    if(r_data[4]==1'b0)
                    begin
                        ds_state    <=  GET_DB;
                    end
                    else if(r_data[5:4]==2'b01)
                    begin
                        p_cnt   <=  8'd184;
                        st      <=  1'b1;
                        ds_state<=  GET_SB;
                    end
                    else
                    begin
                        ds_state<=  GET_ALEN;
                    end
                end
            end
        end
        GET_ALEN:
        begin
            if(radd_inc==1'b1)
            begin
                alen    <=  r_data + 'h4;
                p_cnt   <=  183 - r_data;
                ds_state<=  GET_AP;
            end
        end
        GET_AP:
        begin
            if(alen>187)
            begin
                ds_state<=  GET_DB;
            end
            else if((radd[7:0]==alen) && (radd_inc==1'b1))
            begin
                ds_state<=  GET_SB;
                st      <=  1'b1;
            end
        end
        GET_SB:
        begin
            st  <=  1'b0;
            if((endpkt==1'b1) && (radd_inc==1'b1))
            begin
                ds_state<=  IDLE;
            end
        end
        GET_DB:
        begin
            if((endpkt==1'b1) && (radd_inc==1'b1))
            begin
                ds_state<=  IDLE;
            end
        end
        default:
        begin
            ds_state<=  IDLE;
        end
        endcase
    end
end

always@(posedge pci_clk2)
begin
    pid_i_1dly  <=  pid_i;
    if(startpkt==1'b1)
    begin
        radd[8]     <=  buffer_h;
        dbwadd[8]   <=  buffer_h;
        pid_idx     <=  pid_i_1dly[6:0];
        pid_ds      <=  pid_i_1dly[7];
        except_idx  <=  pid_i_1dly[11:8];
    end
end

always@(posedge pci_clk2)
begin
    if(st_idle==1'b1)
    begin
        radd_cnt    <=  3'b000;
    end
    else if(db_valid==1'b1)
    begin
        radd_cnt    <=  3'b000;
    end
    else
    begin
        radd_cnt    <=  radd_cnt + 'h1;
    end
end

always@(posedge pci_clk2)
begin
    if(st_idle==1'b1)
    begin
        radd[7:0]   <=  {8{1'b0}};
    end
    else if((((st_get_hd | st_get_ap | st_get_db) & radd_inc) | (st_get_sb & sreg_kv2))==1'b1)
    begin
        radd[7:0]   <=  radd[7:0] + 'h1;
    end
end

always@(posedge pci_clk2)
begin
    if(st_idle==1'b1)
    begin
        dbwadd[7:0] <=  {8{1'b0}};
    end
    else if(dbwea==1'b1)
    begin
        dbwadd[7:0] <=  dbwadd[7:0] + 'h1;
    end
end

endmodule
