module shifter(	
	datac                       ,       
	datad                       ,
	shift                       ,
	clk                         ,
	datac_out                   ,
	datad_out                   
	);

input                                   clk                         ;		
input   [1:28]                          datac                       ;
input   [1:28]                          datad                       ;
input   [1:3]                           shift                       ;
output  [1:28]                          datac_out                   ;
output  [1:28]                          datad_out                   ;

reg     [1:28]                          datac_out_mem               ;
reg     [1:28]                          datad_out_mem               ;

always@(posedge clk)
begin
    case(shift)
    3'b000:
    begin
        datac_out_mem<=datac;
        datad_out_mem<=datad; 
    end 
    3'b100:
    begin
        datac_out_mem<=datac; 
        datad_out_mem<=datad; 
    end
    3'b001:
    begin
        datac_out_mem<={datac_out_mem[2:28],datac_out_mem[1]};
        datad_out_mem<={datad_out_mem[2:28],datad_out_mem[1]};
    end
    3'b101:
    begin
        datac_out_mem<={datac_out_mem[28],datac_out_mem[1:27]};
        datad_out_mem<={datad_out_mem[28],datad_out_mem[1:27]};
    end
    3'b010:
    begin
        datac_out_mem<={datac_out_mem[3:28],datac_out_mem[1:2]};
        datad_out_mem<={datad_out_mem[3:28],datad_out_mem[1:2]};
    end
    3'b110:
    begin
        datac_out_mem<={datac_out_mem[27:28],datac_out_mem[1:26]};
        datad_out_mem<={datad_out_mem[27:28],datad_out_mem[1:26]};
    end
    default:;
    endcase
end

assign datac_out = datac_out_mem;
assign datad_out = datad_out_mem;

endmodule
