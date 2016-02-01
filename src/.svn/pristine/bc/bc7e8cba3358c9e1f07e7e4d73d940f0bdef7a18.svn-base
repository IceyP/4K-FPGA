module control_new(
    reset                       ,
    clk                         ,
    ready                       ,
    mode                        ,
    load_new_pt                 ,
    output_ok                   ,
    shift                       
    );

parameter   ST_WIDTH                    = 9                         ;
parameter   IDLE                        = 9'b0_0000_0001            , 
            INIT                        = 9'b0_0000_0010            ,
            R1                          = 9'b0_0000_0100            ,
            R2                          = 9'b0_0000_1000            ,
            R3                          = 9'b0_0001_0000            ,
            R4                          = 9'b0_0010_0000            ,
            R5                          = 9'b0_0100_0000            ,
            R6                          = 9'b0_1000_0000            ,
            R_OUT                       = 9'b1_0000_0000            ;
    
input                                   reset                       ;
input                                   clk                         ;
input                                   ready                       ;
input                                   mode                        ;
output                                  load_new_pt                 ;
output                                  output_ok                   ;
output  [1:3]                           shift                       ;

reg     [1:2]                           shift_in                    ;
reg     [ST_WIDTH - 1 : 0]              etat                        ;
reg     [ST_WIDTH - 1 : 0]              etatfutur                   ;
reg     [2:0]                           counter                     ;
reg                                     load_new_pt                 ;
reg                                     output_ok                   ;

always@(posedge clk)
begin
    if(reset==1'b1)
    begin
        counter <=  {3{1'b0}};
    end
    else if((etat==R2) || (etat==R4))
    begin
        counter <=  counter + 'h1;
    end
    else
    begin
        counter <=  {3{1'b0}};
    end
end
    
always@*
begin
    case(etat)
    IDLE:
    begin
        load_new_pt =   1'b0;
        output_ok   =   1'b0;
        shift_in    =   2'b00;
        if(ready==1'b1)
        begin
            etatfutur   =   INIT;
        end
        else
        begin
            etatfutur   =   IDLE;
        end
    end
    INIT:
    begin
        load_new_pt =   1'b0;
        output_ok   =   1'b0;
        if(mode==1'b0)
        begin
            shift_in    =   2'b01;
        end
        else
        begin
            shift_in    =   2'b00;
        end
        etatfutur   =   R1;
    end
    R1:
    begin
        load_new_pt =   1'b1;
        output_ok   =   1'b0;
        shift_in    =   2'b01;
        etatfutur   =   R2;
    end
    R2:
    begin
        load_new_pt =   1'b0;
        output_ok   =   1'b0;
        shift_in    =   2'b10;
        if(counter==5)
        begin
            etatfutur   =   R3;
        end
        else
        begin
            etatfutur   =   R2;
        end
    end
    R3:
    begin
        load_new_pt =   1'b0;
        output_ok   =   1'b0;
        shift_in    =   2'b01;
        etatfutur   =   R4;
    end
	R4:
    begin
        load_new_pt =   1'b0;
        output_ok   =   1'b0;
        shift_in    =   2'b10;
        if(counter==5)
        begin
            etatfutur   =   R5;
        end
        else
        begin
            etatfutur   =   R4;
        end
    end
    R5:
    begin
        load_new_pt =   1'b0;
        output_ok   =   1'b0;
        shift_in    =   2'b01;
        etatfutur   =   R6;
    end
    R6:
    begin
        load_new_pt =   1'b0;
        output_ok   =   1'b0;
        shift_in    =   2'b00;
        etatfutur   =   R_OUT;
    end	
    R_OUT:
    begin
        load_new_pt =   1'b0;
        output_ok   =   1'b1;
        shift_in    =   2'b00;
        etatfutur   =   IDLE;
    end
    default:
    begin
        load_new_pt =   1'b0;
        output_ok   =   1'b0;
        shift_in    =   2'b00;	
		etatfutur   =   IDLE;
    end
    endcase
end		

always@(posedge clk)
begin
    if(reset==1'b1)
    begin
        etat    <=  IDLE;
    end
    else
    begin
        etat    <=  etatfutur;
    end
end

assign  shift   =   {mode,shift_in[1:2]};

endmodule
