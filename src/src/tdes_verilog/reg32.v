module reg32(
    a                           ,
    q                           ,
    reset                       ,
    clk                         
    );
    
input   [1:32]                          a                           ;
output  [1:32]                          q                           ;
input                                   reset                       ;
input                                   clk                         ;

reg     [1:32]                          memory                      ;

always@(posedge clk or posedge reset)
begin
    if(reset==1'b1)
    begin
        memory  <=  {32{1'b0}};
    end
    else
    begin
        memory  <=  a;
    end
end

assign  q   =   memory;

endmodule
