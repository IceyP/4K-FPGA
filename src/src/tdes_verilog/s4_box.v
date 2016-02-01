module s4_box(                           
	A                           ,        
	SPO                                 
	);                                   
                                         
input   [5:0]                   A                                   ;
output  [3:0]                   SPO                                 ;
                                         
assign SPO  = (A==6'h00) ? 4'b0111:       
              (A==6'h01) ? 4'b1101:      
              (A==6'h02) ? 4'b1101:      
              (A==6'h03) ? 4'b1000:      
              (A==6'h04) ? 4'b1110:      
              (A==6'h05) ? 4'b1011:      
              (A==6'h06) ? 4'b0011:      
              (A==6'h07) ? 4'b0101:      
              (A==6'h08) ? 4'b0000:      
              (A==6'h09) ? 4'b0110:      
              (A==6'h0A) ? 4'b0110:      
              (A==6'h0B) ? 4'b1111:      
              (A==6'h0C) ? 4'b1001:      
              (A==6'h0D) ? 4'b0000:      
              (A==6'h0E) ? 4'b1010:      
              (A==6'h0F) ? 4'b0011:      
              (A==6'h10) ? 4'b0001:      
              (A==6'h11) ? 4'b0100:      
              (A==6'h12) ? 4'b0010:      
              (A==6'h13) ? 4'b0111:      
              (A==6'h14) ? 4'b1000:      
              (A==6'h15) ? 4'b0010:      
              (A==6'h16) ? 4'b0101:      
              (A==6'h17) ? 4'b1100:      
              (A==6'h18) ? 4'b1011:      
              (A==6'h19) ? 4'b0001:      
              (A==6'h1A) ? 4'b1100:      
              (A==6'h1B) ? 4'b1010:      
              (A==6'h1C) ? 4'b0100:      
              (A==6'h1D) ? 4'b1110:      
              (A==6'h1E) ? 4'b1111:      
              (A==6'h1F) ? 4'b1001:      
              (A==6'h20) ? 4'b1010:      
              (A==6'h21) ? 4'b0011:      
              (A==6'h22) ? 4'b0110:      
              (A==6'h23) ? 4'b1111:      
              (A==6'h24) ? 4'b1001:      
              (A==6'h25) ? 4'b0000:      
              (A==6'h26) ? 4'b0000:      
              (A==6'h27) ? 4'b0110:      
              (A==6'h28) ? 4'b1100:      
              (A==6'h29) ? 4'b1010:      
              (A==6'h2A) ? 4'b1011:      
              (A==6'h2B) ? 4'b0001:      
              (A==6'h2C) ? 4'b0111:      
              (A==6'h2D) ? 4'b1101:      
              (A==6'h2E) ? 4'b1101:      
              (A==6'h2F) ? 4'b1000:      
              (A==6'h30) ? 4'b1111:      
              (A==6'h31) ? 4'b1001:      
              (A==6'h32) ? 4'b0001:      
              (A==6'h33) ? 4'b0100:      
              (A==6'h34) ? 4'b0011:      
              (A==6'h35) ? 4'b0101:      
              (A==6'h36) ? 4'b1110:      
              (A==6'h37) ? 4'b1011:      
              (A==6'h38) ? 4'b0101:      
              (A==6'h39) ? 4'b1100:      
              (A==6'h3A) ? 4'b0010:      
              (A==6'h3B) ? 4'b0111:      
              (A==6'h3C) ? 4'b1000:      
              (A==6'h3D) ? 4'b0010:      
              (A==6'h3E) ? 4'b0100:      
              (A==6'h3F) ? 4'b1110:      
              4'b1110;                   
endmodule


//SPO   	<=  "0111" when A = x"0" else    
//			"1101" when A = x"1" else   
//			"1101" when A = x"2" else   
//			"1000" when A = x"3" else   
//			"1110" when A = x"4" else   
//			"1011" when A = x"5" else   
//			"0011" when A = x"6" else   
//			"0101" when A = x"7" else   
//			"0000" when A = x"8" else   
//			"0110" when A = x"9" else   
//			"0110" when A = x"A" else   
//			"1111" when A = x"B" else   
//			"1001" when A = x"C" else   
//			"0000" when A = x"D" else   
//			"1010" when A = x"E" else   
//			"0011" when A = x"F" else   
//			"0001" when A = x"10" else  
//			"0100" when A = x"11" else  
//			"0010" when A = x"12" else  
//			"0111" when A = x"13" else                                  
//			"1000" when A = x"14" else
//			"0010" when A = x"15" else
//			"0101" when A = x"16" else
//			"1100" when A = x"17" else
//			"1011" when A = x"18" else
//			"0001" when A = x"19" else
//			"1100" when A = x"1A" else
//			"1010" when A = x"1B" else
//			"0100" when A = x"1C" else
//			"1110" when A = x"1D" else
//			"1111" when A = x"1E" else
//			"1001" when A = x"1F" else
//			"1010" when A = x"20" else
//			"0011" when A = x"21" else
//			"0110" when A = x"22" else
//			"1111" when A = x"23" else
//			"1001" when A = x"24" else
//			"0000" when A = x"25" else
//			"0000" when A = x"26" else
//			"0110" when A = x"27" else
//			"1100" when A = x"28" else
//			"1010" when A = x"29" else
//			"1011" when A = x"2A" else
//			"0001" when A = x"2B" else
//			"0111" when A = x"2C" else
//			"1101" when A = x"2D" else
//			"1101" when A = x"2E" else
//			"1000" when A = x"2F" else
//			"1111" when A = x"30" else
//			"1001" when A = x"31" else
//			"0001" when A = x"32" else
//			"0100" when A = x"33" else
//			"0011" when A = x"34" else
//			"0101" when A = x"35" else
//			"1110" when A = x"36" else
//			"1011" when A = x"37" else
//			"0101" when A = x"38" else
//			"1100" when A = x"39" else
//			"0010" when A = x"3A" else
//			"0111" when A = x"3B" else
//			"1000" when A = x"3C" else
//			"0010" when A = x"3D" else
//			"0100" when A = x"3E" else
//			"1110" when A = x"3F" else
//			"1110";
//
//END Behavioral;