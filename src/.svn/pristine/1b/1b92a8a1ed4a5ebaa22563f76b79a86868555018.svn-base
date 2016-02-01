module ov32(
    e                           ,
    o1                          ,
    o2                          ,
    clk                         ,
    sel                         
    );
    
input   [1:32]                          e                           ;
output  [1:32]                          o1                          ;
output  [1:32]                          o2                          ;
input                                   clk                         ;
input                                   sel                         ;
reg     [1:32]                          o2                          ;

always@(posedge clk)
begin
    if(sel==1'b1)
    begin
        o2  <=  e;
    end
end

assign  o1  =   e;

endmodule
