module mux32(
    e0                          ,
    e1                          ,
    o                           ,
    sel                         
    );
    
input   [1:32]                          e0                          ;
input   [1:32]                          e1                          ;
output  [1:32]                          o                           ;
input                                   sel                         ;

assign  o   =   (sel==1'b1) ?   e1  :   e0;

endmodule
