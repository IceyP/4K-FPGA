module xp(
	ri                          ,
	e 
	);

input   [1:32]                          ri                          ;
output  [1:48]                          e                           ;

assign e[1]=ri[32]; 
assign e[2]=ri[1]; 
assign e[3]=ri[2];   
assign e[4]=ri[3]; 
assign e[5]=ri[4];
assign e[6]=ri[5];  
assign e[7]=ri[4];  
assign e[8]=ri[5];
assign e[9]=ri[6];  
assign e[10]=ri[7];  
assign e[11]=ri[8];  
assign e[12]=ri[9]; 
assign e[13]=ri[8];
assign e[14]=ri[9];  
assign e[15]=ri[10]; 
assign e[16]=ri[11];
assign e[17]=ri[12]; 
assign e[18]=ri[13]; 
assign e[19]=ri[12]; 
assign e[20]=ri[13];
assign e[21]=ri[14]; 
assign e[22]=ri[15]; 
assign e[23]=ri[16]; 
assign e[24]=ri[17];
assign e[25]=ri[16]; 
assign e[26]=ri[17]; 
assign e[27]=ri[18]; 
assign e[28]=ri[19];
assign e[29]=ri[20]; 
assign e[30]=ri[21]; 
assign e[31]=ri[20]; 
assign e[32]=ri[21];
assign e[33]=ri[22]; 
assign e[34]=ri[23]; 
assign e[35]=ri[24]; 
assign e[36]=ri[25];
assign e[37]=ri[24]; 
assign e[38]=ri[25]; 
assign e[39]=ri[26]; 
assign e[40]=ri[27];
assign e[41]=ri[28]; 
assign e[42]=ri[29]; 
assign e[43]=ri[28]; 
assign e[44]=ri[29];
assign e[45]=ri[30]; 
assign e[46]=ri[31]; 
assign e[47]=ri[32]; 
assign e[48]=ri[1];
	
endmodule