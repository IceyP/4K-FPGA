module sreg(
    nrst                        ,
    clk                         ,
    p                           ,
    sreg_k                      ,
    sreg_l                      ,
    sreg_kv                     ,
    sreg_kv3                    ,
    sreg_kv2                    ,
    sreg_kv1                    ,
    s_ldkey                     ,
    sc_disable                  ,
    ldkey_cnt                   ,
    ldkey_end                   ,
    st                          ,
    cb                          ,
    sb                          ,
    ro                          ,
    ri                          ,
    b_ld                        ,
    db                          ,
    db_valid                     
    );

parameter   IDLE                        = 4'b0001                   ,
            LKEY                        = 4'b0010                   ,
            WORK                        = 4'b0100                   ,
            RESD                        = 4'b1000                   ;
                
input                                   nrst                        ;
input                                   clk                         ;
input   [0:7]                           p                           ;
output  [0:7]                           sreg_k                      ;
output  [0:2]                           sreg_l                      ;
output                                  sreg_kv                     ;
output                                  sreg_kv3                    ;
output                                  sreg_kv2                    ;
output                                  sreg_kv1                    ;
output                                  s_ldkey                     ;
output                                  sc_disable                  ;
output  [0:2]                           ldkey_cnt                   ;
output                                  ldkey_end                   ;
input                                   st                          ;
input   [0:7]                           cb                          ;
input   [0:7]                           sb                          ;
input   [0:63]                          ro                          ;
output  [0:63]                          ri                          ;
output  [0:7]                           db                          ;
output                                  b_ld                        ;
output                                  db_valid                    ;

wire                                    kv,kv0,kv1,kv2,kv3          ;
wire                                    kg7,kg15,ke8n,ke7n          ;
reg     [0:63]                          r1,r2                       ;
reg     [0:7]                           k                           ;
reg     [0:2]                           l                           ;
reg                                     kvd1,kvd2                   ;
reg     [0:7]                           sb_reg                      ;
wire                                    lkey                        ;
reg                                     lkey_end                    ;
reg     [0:2]                           lkey_cnt                    ;
wire    [0:2]                           lkey_cntm                   ;
reg     [3:0]                           sreg_state                  ;
reg                                     st_work_d                   ;
wire                                    st_idle                     ;
wire                                    st_loadkey                  ;
wire                                    st_work                     ;
wire                                    st_sr                       ;
reg     [0:7]                           sbreg                       ;

assign  sreg_k  =   k;
assign  sreg_l  =   l;
assign  sreg_kv =   kv;
assign  sreg_kv3=   kv3;
assign  sreg_kv2=   kv2;
assign  sreg_kv1=   kv1;
assign  kv      =   &{l[0:1],~l[2]};
assign  kv0     =   ~(l[0] | l[1] | l[2]);
assign  kv1     =   (~l[0]) & (~l[1]) & l[2];
assign  kv2     =   (~l[0]) & l[1] & (~l[2]);
assign  kv3     =   (~l[0]) & l[1] & l[2];
assign  kg7     =   |k[0:4];
assign  kg15    =   |k[0:3];
assign  ke8n    =   ~(k[5] | k[6] | k[7]);
assign  ke7n    =   k[5] & k[6] & k[7];
assign  ri      =   r1;
assign  lkey    =   kv & ke7n;
assign  db_valid=   kv & kg15;
assign  lkey_cntm=  lkey_cnt + 1;
assign  ldkey_end=  lkey_end;

assign  st_idle     =   sreg_state[0];
assign  st_loadkey  =   sreg_state[1];
assign  st_work     =   sreg_state[2];
assign  st_sr       =   sreg_state[3];

assign  b_ld        =   st_loadkey & kg7;
assign  db          =   (st_sr==1'b1)   ?   r2[0:7] :   (r2[0:7] ^ r1[0:7]);
assign  s_ldkey     =   st_loadkey & (~kg7) & (~lkey_end);
assign  ldkey_cnt   =   (st_loadkey==1'b1)  ?   lkey_cntm   :   3'b000;
assign  sc_disable  =   ~((st_work & (~l[0])) | (st_loadkey & (~kg7)));

always@(posedge clk)
begin
    if(nrst==1'b0)
    begin
        sreg_state <=  IDLE;
    end
    else
    begin
        case(sreg_state)
        IDLE:
        begin
            if(st==1'b1)
            begin
                sreg_state <=  LKEY;
            end
        end
        LKEY:
        begin
            if(lkey_end==1'b1)
            begin
                sreg_state <=  WORK;
            end
        end
        WORK:
        begin
            if(kv==1'b1)
            begin
                if(k=={p[0:4],3'b111})
                begin
                    sreg_state <=  RESD;
                end
                else if(ke7n==1'b1)
                begin
                    sreg_state <=  LKEY;
                end
            end
        end
        RESD:
        begin
            if((kv==1'b1) && (k==(p + 5'b01111)))
            begin
                sreg_state <=  IDLE;
            end
        end
        default:    sreg_state <=  IDLE;
        endcase
    end
end

always@(posedge clk)
begin
    if(st_loadkey==1'b1)
    begin
        lkey_cnt    <=  lkey_cntm;
        if(lkey_cnt==3'b111)
        begin
            lkey_end    <=  1'b1;
        end
    end
    else
    begin
        lkey_end    <=  1'b0;
        lkey_cnt    <=  3'b000;
    end
end

always@(posedge clk)
begin
    kvd1    <=  kv;
    kvd2    <=  kvd1;
    if(st_idle==1'b1)
    begin
        k   <=  {8{1'b0}};
        l   <=  3'b000;
    end
    else if(kv==1'b1)
    begin
        l   <=  3'b000;
        k   <=  k + 'h1;
    end
    else if((st_work==1'b1) || (st_sr==1'b1))
    begin
        l   <=  l + 'h1;
    end
end

always@(posedge clk)
begin
    if(kv2==1'b1)
    begin
        sbreg   <=  sb;
    end
    
    if(kv==1'b1)
    begin
        r1[0:7]     <=  r1[8:15] ;
        r1[8:15]    <=  r1[16:23];
        r1[16:23]   <=  r1[24:31];
        r1[24:31]   <=  r1[32:39];
        r1[32:39]   <=  r1[40:47];
        r1[40:47]   <=  r1[48:55];
        r1[48:55]   <=  r1[56:63];
        if(kg7==1'b1)
        begin
            r1[56:63]   <=  sbreg ^ cb;
        end
        else
        begin
            r1[56:63]   <=  sbreg;
        end
    end
end

always@(posedge clk)
begin
    st_work_d   <=  st_work;
    if(kv==1'b1)
    begin
        r2[0:7]     <=  r2[8:15];
        r2[8:15]    <=  r2[16:23];
        r2[16:23]   <=  r2[24:31];
        r2[24:31]   <=  r2[32:39];
        r2[32:39]   <=  r2[40:47];
        r2[40:47]   <=  r2[48:55];
        r2[48:55]   <=  r2[56:63];
        r2[56:63]   <=  r1[0:7]; 
    end
    else if((kvd1 & ke8n & kg15 & st_work_d)==1'b1)      
    begin
        r2  <=  ro;
    end  
end

endmodule
