//--------------------------------------------------------------------------------------------------
// File          : $RCSfile: tb_udp_ts_map.v,v $
// Last modified : $Date: 2010/12/07 $
// Author        : Z.J.K
//--------------------------------------------------------------------------------------------------
//
// Testbench for udp_ts_map transmitter design
//
//--------------------------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

`define AVALON_ADDR_WIDTH  16
`define AVALON_DATA_WIDTH  8
`define PAYLOAD_DATA_WIDTH 8
`define PACKAGE_LENGTH_IN_BYTES 188 
`define PACKET_OUT_BATES  192
`define TS_RX_BASE        `AVALON_ADDR_WIDTH'b0

`define MAX_INPUT_RATE     1000
`define DEPTH_THRESHOLD    40
`define CHANNEL_COUNT      2
`define INITIAL_WAIT       20000
`define CPU_CLK_PERIOD     10000
`ifdef PAYLOAD_CLK_PERIOD
`else
`define PAYLOAD_CLK_PERIOD 8000
`endif
module tb_pid_filter();

// Clock and reset signals
reg                           clk;
reg                           payload_clk;
reg                           cpu_clk;
reg                           reset_n;


// Avalon master signals
reg  [`AVALON_ADDR_WIDTH-1:0] cpu_address;
reg                           cpu_read = 1'b0;
wire [`AVALON_DATA_WIDTH-1:0] cpu_readdata;
wire                          cpu_waitrequest;
wire                          cpu_int;
reg                           cpu_write = 1'b0;
reg  [`AVALON_DATA_WIDTH-1:0] cpu_writedata;

// Payload input signals
reg  [15:0]                   payload_in_channel = 0;
reg  [`PAYLOAD_DATA_WIDTH-1:0]payload_in_data = 'b0;
reg                           payload_in_end = 1'b0;
reg  [11:0]                   payload_in_length = 0;
wire                          payload_in_ready = 1'b1;
reg                           payload_in_start = 1'b0;
reg                           payload_in_valid = 1'b0;

// Payload output signals
wire [`PAYLOAD_DATA_WIDTH-1:0]payload_out_data;
wire                          payload_out_end;
wire                          payload_out_start;
wire                          payload_out_valid;




reg fail;
reg test_failed;
reg couldnt_find_vectors;
integer vector_set_number;
integer output_count;
integer i;
//--------------------------------------------------------------------------------------------------
// Avalon bus mastering functions
//--------------------------------------------------------------------------------------------------
task avalon_write;
   input [`AVALON_ADDR_WIDTH-1:0]   address;
   input [`AVALON_DATA_WIDTH-1:0]   data;
begin
   @(posedge cpu_clk);
   cpu_address    <= address;
   cpu_writedata  <= data;
   cpu_read       <= 1'b0;
   cpu_write      <= 1'b1;

   @(posedge cpu_clk);
   /*
   while(cpu_waitrequest === 1'b1)
   begin
      @(posedge cpu_clk);
   end
  */
   cpu_write      <= 1'b0;
end
endtask


task avalon_read;
   input  [`AVALON_ADDR_WIDTH-1:0]  address;
   output [`AVALON_DATA_WIDTH-1:0]  data;
   reg    [`AVALON_DATA_WIDTH-1:0]  data;
begin
   @(posedge cpu_clk);
   cpu_address    <= address;
   cpu_read       <= 1'b1;
   cpu_write      <= 1'b0;
   //@(posedge cpu_clk);             

  // while(cpu_waitrequest === 1'b1)
   repeat(6)
   begin
      @(posedge cpu_clk);
   end

   cpu_read       <= 1'b0;
   data           = cpu_readdata;
end
endtask

//--------------------------------------------------------------------------------------------------
// read_ts_packets
//--------------------------------------------------------------------------------------------------
parameter    TS_PKT_ADDRESS            = 16'h5801;
parameter    TS_PKT_DATA               = 16'h5800;
reg   [`AVALON_DATA_WIDTH-1:0]  ts_pkt_state=0;
reg   [`AVALON_DATA_WIDTH-1:0]  ts_pkt_data =0;
task read_ts_pkt;
   integer i; 
    integer j;    
begin
    avalon_read(TS_PKT_ADDRESS,ts_pkt_state);
      for(i=0;i<ts_pkt_state;i=i+1)
      begin
        @(posedge cpu_clk);
        for(j=0;j<`PACKET_OUT_BATES;j=j+1)
        begin
          avalon_read(TS_PKT_DATA,ts_pkt_data);
          @(posedge cpu_clk);
        end
      end
end
endtask



//--------------------------------------------------------------------------------------------------
// Monitor input data rate
//--------------------------------------------------------------------------------------------------
reg run_input_rate_monitor;
real input_clock_count = 0;
real input_valid_count = 0;
real input_rate = 0;
always
begin
  @(run_input_rate_monitor==1);
  input_clock_count = 0;
  input_valid_count = 0;
  @(payload_in_ready===1'b1 & payload_in_valid===1'b1);
  while (run_input_rate_monitor)
  begin
    input_clock_count = input_clock_count + 1;
    if (input_clock_count==0) $display("Warning: input_clock_count limit exceeded. Bit rate calculation will be wrong!");
    if (payload_in_valid) input_valid_count = input_valid_count + 1;
    input_rate = (input_valid_count*8*1000000/`PAYLOAD_CLK_PERIOD)/input_clock_count;
    @(posedge payload_clk);
  end
end

//--------------------------------------------------------------------------------------------------
// Monitor output data rate
//--------------------------------------------------------------------------------------------------
reg run_output_rate_monitor;
real output_clock_count = 0;
real output_valid_count = 0;
real output_rate = 0;
always
begin
  @(run_output_rate_monitor==1);
  output_clock_count = 0;
  output_valid_count = 0;
  @(payload_out_valid===1'b1);
  while (run_output_rate_monitor)
  begin
    output_clock_count = output_clock_count + 1;
    if (output_clock_count==0) $display("Warning: output_clock_count limit exceeded. Bit rate calculation will be wrong!");
    if (payload_out_valid) begin
      output_valid_count = output_valid_count + 1;
    end
    output_rate = (output_valid_count*32*1000000/`PAYLOAD_CLK_PERIOD)/output_clock_count;
    @(posedge payload_clk);
  end
end

task get_payload;
   integer output_file_desc;
   reg [799:0] output_filename;
   integer count;
   integer data;
   integer word_length;
begin

      // Open the output vector file and find the next packet
      $swrite(output_filename,  "output%0d.dat", vector_set_number);
      output_file_desc  = $fopen(output_filename,  "r");
      if(output_file_desc == 0)
      begin
         $swrite(output_filename,  "output%0d.dat", vector_set_number);
         output_file_desc  = $fopen(output_filename,  "r");
         if(output_file_desc == 0)
         begin
            $display("\nERROR: Failed to open file: %s\n", output_filename);
            $stop;
         end
      end

      output_count= output_count+1;
      
      word_length = `PACKAGE_LENGTH_IN_BYTES;
      for(count = 0; count < word_length; count=count+1)
      begin
         while(!payload_out_valid)
         begin
            @(posedge payload_clk);
         end

         if(payload_out_end && (count != (word_length-1)))
         begin
            $display("\nERROR: Unexpected end indication\n");
            test_failed = 1;
           `ifdef STOP_ON_ERROR
             $stop;
           `endif
         end

         if(!payload_out_end && (count == (word_length-1)))
         begin
            $display("\nERROR: Missing end indication\n");
            test_failed = 1;
           `ifdef STOP_ON_ERROR
             $stop;
           `endif
         end

         // Read data
         if($fscanf(output_file_desc, "%h", data) != 1)
         begin
            $display("\nERROR reading packet data from output file.\n");
            $stop;
         end

         data = ChangeEndianism(data);
         if(payload_out_data !== data)
         begin
            $display("ERROR: Output mismatch (word %0d). %8x seen, %8x expected", count, payload_out_data, data);
            test_failed = 1;
           `ifdef STOP_ON_ERROR
             $stop;
           `endif
         end
         @(posedge payload_clk);
      end
      $fclose(output_file_desc);
   end
endtask

//--------------------------------------------------------------------------------------------------
// Functions for driving  data
//--------------------------------------------------------------------------------------------------
task drive_in_data;
   input                                file_descriptor;
   input                                input_packet_number;
   output                               EOF;
   integer                              file_descriptor;
   integer                              input_packet_number;
   reg                                  EOF;
                                        
   integer                              packet_length_in_bytes;
   integer                              packet_length_in_words;
   integer                              channel;
   reg [`PAYLOAD_DATA_WIDTH-1:0]        data;// word;
   integer                              data_count;// word_count;
   
begin
   // Packet header format is as follows:

   // Channel number
   // Packet length in bytes
   // Word 0
   // Word 1
   // ...
   // Word n


   // Read the channel number
   //if($fscanf(file_descriptor, "%h", channel) != 1)
   //begin
   //   EOF = 1;
  // end
  // else
  // begin
     // EOF = 0;
      $display("\nINFO:Drive data start !!!!\n");
      // Read the packet length
    //  if($fscanf(file_descriptor, "%h", packet_length_in_bytes) != 1)
    //  begin
     //    $display("\nError reading packet length from input file.\n");
     //    $stop;
     // end
    //  packet_length_in_words = (packet_length_in_bytes/4) + ((packet_length_in_bytes%4) ? 1 : 0);

      @(posedge payload_clk);
      @(posedge payload_clk);
      @(posedge payload_clk);
      while (`MAX_INPUT_RATE!=0 & input_rate>`MAX_INPUT_RATE)
        @(posedge payload_clk);

      //for(word_count = 0; word_count<packet_length_in_words; word_count=word_count+1)
      for(data_count = 0; data_count < `PACKAGE_LENGTH_IN_BYTES; data_count=data_count+1)
      begin
         if($fscanf(file_descriptor, "%h", data) != 1)
         begin
         	  EOF = 1;
            //$display("\nError reading word from input file.\n");
            //$stop;
         end
         EOF = 0;
         while(!payload_in_ready)
         begin
            payload_in_valid <= 1'b0;
            @(posedge payload_clk);
         end
         payload_in_valid   <= 1'b1;
         payload_in_start   <= (data_count == 0) ? 1 : 0;
         payload_in_end     <= (data_count == (`PACKAGE_LENGTH_IN_BYTES-1)) ? 1 : 0;
         payload_in_channel <= channel[13:0];
         payload_in_length  <= packet_length_in_bytes;
         payload_in_data    <= data;
        // payload_in_data    <= ChangeEndianism(word);

         @(posedge payload_clk);
      end

      payload_in_valid <= 1'b0;
      payload_in_end <= 1'b0;

  // end
end
endtask
//--------------------------------------------------------------------------------------------------
// Endianism convertion function
//--------------------------------------------------------------------------------------------------
function [31:0] ChangeEndianism;
   input [31:0] In;

   ChangeEndianism = {In[7:0], In[15:8], In[23:16], In[31:24]};
endfunction


//--------------------------------------------------------------------------------------------------
// Clock and reset generation
//--------------------------------------------------------------------------------------------------

task reset_inputs;
begin : RESET
   output_count = 0;
   test_failed         = 0;
   cpu_address         = 0;
   cpu_read            = 0;
   cpu_write           = 0;
   cpu_writedata       = 0;
   payload_in_channel  = 0;
   payload_in_data     = 0;
   payload_in_end      = 0;
   payload_in_length   = 0;
   payload_in_start    = 0;
   payload_in_valid    = 0;
end
endtask


// 100MHz
always
begin
   cpu_clk = 0;
   #(`CPU_CLK_PERIOD/2);
   cpu_clk = 1;
   #(`CPU_CLK_PERIOD/2);
end

// DDR pll ref clock - 50MHz
always
begin
   clk = 0;
   #10000;
   clk = 1;
   #10000;
end

// Payload clock
always
begin
   payload_clk = 0;
   #(`PAYLOAD_CLK_PERIOD/2);
   payload_clk = 1;
   #(`PAYLOAD_CLK_PERIOD/2);
end


// Reset, synchronised to the CPU clock
initial
begin
   reset_inputs;
   reset_n = 1'b0;

   repeat(1)
   begin
      @(posedge cpu_clk);
   end

   reset_n <= 1'b1;
end
//---------------------------------------------
//  cpu read and write
//------------------------------------------------
reg [15:0] temp;
reg [15:0] data;
reg [31:0] word_count;
initial begin
   @(posedge reset_n);
   #(`INITIAL_WAIT);
   @(posedge cpu_clk);
 //-------------------------
   repeat(256)begin
     @(posedge cpu_clk);
   end
 
 avalon_write(`TS_RX_BASE + (16'h5000), 8'h00);     
  avalon_write(`TS_RX_BASE + (16'h5001), 8'h00);
  avalon_write(`TS_RX_BASE + (16'h5002), 8'h08);  
  avalon_write(`TS_RX_BASE + (16'h5003), 8'h06);  
  avalon_write(`TS_RX_BASE + (16'h5004), 8'h00);
  avalon_write(`TS_RX_BASE + (16'h5005), 8'h01);  
  avalon_write(`TS_RX_BASE + (16'h5006), 8'h00);
  avalon_write(`TS_RX_BASE + (16'h5007), 8'h01);
  avalon_write(`TS_RX_BASE + (16'h5008), 8'h00);     
  avalon_write(`TS_RX_BASE + (16'h5009), 8'h0D);
  avalon_write(`TS_RX_BASE + (16'h500A), 8'h00);  
  avalon_write(`TS_RX_BASE + (16'h500B), 8'h03);  
  avalon_write(`TS_RX_BASE + (16'h500C), 8'h00);
  avalon_write(`TS_RX_BASE + (16'h500D), 8'h01);  
  avalon_write(`TS_RX_BASE + (16'h500E), 8'h02);
  avalon_write(`TS_RX_BASE + (16'h500F), 8'h0F);
                                         
  avalon_write(`TS_RX_BASE + (16'h5010), 8'h00);     
  avalon_write(`TS_RX_BASE + (16'h5011), 8'h0F);
  avalon_write(`TS_RX_BASE + (16'h5012), 8'h0F);  
  avalon_write(`TS_RX_BASE + (16'h5013), 8'h0F);  
  avalon_write(`TS_RX_BASE + (16'h5014), 8'h0F);
  avalon_write(`TS_RX_BASE + (16'h5015), 8'h0F);  
  avalon_write(`TS_RX_BASE + (16'h5016), 8'h0F);
  avalon_write(`TS_RX_BASE + (16'h5017), 8'h0F);
  avalon_write(`TS_RX_BASE + (16'h5018), 8'h0F);     
  avalon_write(`TS_RX_BASE + (16'h5019), 8'h0F);
  avalon_write(`TS_RX_BASE + (16'h501A), 8'h0F);  
  avalon_write(`TS_RX_BASE + (16'h501B), 8'h0F);  
  avalon_write(`TS_RX_BASE + (16'h501C), 8'h0F);
  avalon_write(`TS_RX_BASE + (16'h501D), 8'h0F);  
  avalon_write(`TS_RX_BASE + (16'h501E), 8'h0F);
  avalon_write(`TS_RX_BASE + (16'h501F), 8'h0F);
//--------------------------------------------
   forever
   begin
    read_ts_pkt;
   end
end
/*
initial
begin : READ_TS_PACKET
   @(posedge reset_n);
   forever
   begin
    read_ts_pkt;
   end
end
*/
//--------------------------------------------------------------------------------------------------
// Function for applying a single set of test vectors
//--------------------------------------------------------------------------------------------------
task apply_test_vectors;
   input  test_number;
   output couldnt_find_vector_set;
   output fail;

   integer test_number;
   reg     couldnt_find_vector_set;
   reg     fail;

   integer input_file_desc;
   reg     input_done;
   integer input_packet_count;
   reg     no_output;
   integer i;
   reg [799:0] input_filename;
   reg [31:0] temp;

   integer progress_indication_desc;
   reg [799:0] progress_indication_filename;
begin
   fail = 0;
   input_done = 0;
   input_packet_count  = 0;
   couldnt_find_vector_set = 1;

   $swrite(input_filename,  "input%0d.dat", test_number);
   input_file_desc  = $fopen(input_filename,  "r");

   if(input_file_desc == 0)
   begin
      $swrite(input_filename,  "input%0d.dat", test_number);
      input_file_desc  = $fopen(input_filename,  "r");
   end

   if(input_file_desc != 0)
   begin
      couldnt_find_vector_set = 0;

      // Write a file indicating that the test has started
      $swrite(progress_indication_filename, "test%0d.STARTED", test_number);
      progress_indication_desc = $fopen(progress_indication_filename, "w");
      if(progress_indication_desc != 0)
      begin
         $fclose(progress_indication_desc);
      end

      // Exercise inputs
      $display("\nApplying vector set %0d\n=======================\n", test_number);

      repeat(16)
      begin
         @(posedge cpu_clk);
      end
      $display("\info:drive_in_data \n");
      run_input_rate_monitor = 0;
      run_output_rate_monitor = 0;
     // run_ram_monitor = 1;
      if (!payload_in_ready) $display("\nWaiting for design initialisation to complete...\n");
      while(!payload_in_ready)
      begin
         payload_in_valid <= 1'b0;
         @(posedge payload_clk);
      end

      while(!input_done)
      begin
         drive_in_data(input_file_desc, input_packet_count, input_done);
         input_packet_count = input_packet_count + 1;
      end
      
      $fclose(input_file_desc);

      run_input_rate_monitor = 0;
      run_output_rate_monitor = 0;
     // run_ram_monitor = 0;
      #10000;

      if (`MAX_INPUT_RATE!=0)
        $display("-- Input data rate = %0.3f Mbps (constrained by testbench)", input_rate);
      else
        $display("-- Input data rate = %0.3f Mbps", input_rate);
      $display("-- Output data rate = %0.3f Mbps\n", output_rate);

      no_output = 1;
      
      if(output_count != 0)
      begin
        no_output = 0;
      end
      
      if(no_output)
      begin
         $display("ERROR: No output was detected for test number %d", test_number);
         fail = 1;
      end

      #100000000;

      if(fail || test_failed)
      begin
         $swrite(progress_indication_filename, "test%0d.FAILED", test_number);
         progress_indication_desc = $fopen(progress_indication_filename, "w");
         if(progress_indication_desc != 0)
         begin
            $fclose(progress_indication_desc);
         end
      end
      else
      begin
         $swrite(progress_indication_filename, "test%0d.PASSED", test_number);
         progress_indication_desc = $fopen(progress_indication_filename, "w");
         if(progress_indication_desc != 0)
         begin
            $fclose(progress_indication_desc);
         end
      end
   end
end
endtask
//--------------------------------------------------------------------------------------------------
// Test program
//--------------------------------------------------------------------------------------------------

// Drive in the input packets
reg [31:0] number_of_channels;
//reg enable_event_fifo_monitor = 1'b0;
//reg enable_message_monitor = 1'b0;
real rate;
integer c;
initial
begin
   $timeformat(-9, 0, "ns", 0);
   $display("\nRX File test\n================\n");
   @(posedge reset_n);
   #(`INITIAL_WAIT);
   @(posedge cpu_clk);

   //avalon_read(`TS_RX_BASE + (23*4), number_of_channels);
//   if (number_of_channels<`CHANNEL_COUNT) begin
//      $display("ERROR: DUT does not support %0d channels.", `CHANNEL_COUNT);
//      test_failed = 1;
//   end

   `ifdef BYPASS_MODE
    $display("\nBYPASS_MODE is defined - switching to bypass mode because \n");
    for (c=0; c<`CHANNEL_COUNT; c=c+1) begin
       avalon_write(`TS_RX_BASE + (0*4), c);
       avalon_write(`TS_RX_BASE + (21*4), 3);
     end
   `endif

   couldnt_find_vectors = 0;

   if (~test_failed) begin

     `ifdef USE_THESE_VECTORS
        vector_set_number = `USE_THESE_VECTORS;
        apply_test_vectors(vector_set_number, couldnt_find_vectors, fail);
        if (fail) test_failed = 1;

        // Set vector set number to look correct for subsequent checks
        vector_set_number = couldnt_find_vectors ? 0 : 1;
     `else
        vector_set_number = 0;
        while(!couldnt_find_vectors)
        begin
        	$display("INFO: ENTER IN apply_test_vectors ");
           apply_test_vectors(vector_set_number, couldnt_find_vectors, fail);
           //test_failed = test_failed | fail;
           if (fail) test_failed = 1;
           if(!couldnt_find_vectors)
           begin
              vector_set_number = vector_set_number + 1;
           end
                      
          output_count = 0;
        end
     `endif

     if(vector_set_number == 0)
     begin
        $display("ERROR: No vector files were found.");
        test_failed = 1;
     end

     //enable_event_fifo_monitor = 1'b0;
    // enable_message_monitor = 1'b0;
     $display("\nSimulation Complete - %0d vector sets processed.\n", vector_set_number);

    // rate = (ram_access_count*(`SDRAM_DATA_WIDTH*2)*1000000/`DDR_CLK_PERIOD)/ram_clock_count;
    // $display("Frame buffer access rate = %0.1f Mbps (%0.1f %% of available bandwidth)", rate, (ram_access_count*100/ram_clock_count));
    // rate = (ram_active_count*(`SDRAM_DATA_WIDTH*2)*1000000/`DDR_CLK_PERIOD)/ram_clock_count;
    // $display("  Total active cycles = %0.1f Mbps (%0.1f %% utilization of total access cycles)", rate, (ram_active_count*100/ram_access_count));

   end

   if(test_failed)
   begin
      $display("\n*********************\n**** F A I L E D ****\n*********************");
   end
   else
   begin
      $display("\nPass");
   end

   $finish;
end


//--------------------------------------------------------------------------------------------------
// Output monitor
//--------------------------------------------------------------------------------------------------
/*
initial
begin : MONITOR
   @(posedge reset_n);
   forever
   begin
    // get_payload;
   end
end
*/
//--------------------------------------------------------------------------------------------------
// Instatiate the DUT, created by SOPC Builder
//--------------------------------------------------------------------------------------------------
wire                                      from_map_payload_out_req            ;
wire                                      to_map_payload_out_valid            ;
wire       [31:0]                         to_map_payload_out_data             ;
wire                                      to_map_payload_out_start            ;
wire                                      to_map_payload_out_end              ;

pid_filter_top DUT(
                                 
  .ts_clk                               (payload_clk       ),
  .ts_rst                               (~reset_n          ),
  .ts_in_valid                          (payload_in_valid  ),
  .ts_in_start                          (payload_in_start  ),
  .ts_in_end                            (payload_in_end    ),                                     
  .ts_in_data                           (payload_in_data   ),             
   
    //-----------businterface---------------------------------------------
  .bus_clk                              (cpu_clk           ),
  .bus_rst                              (~reset_n          ),
  .bus_address                          (cpu_address       ),
  .bus_read                             (cpu_read          ),
  .bus_write                            (cpu_write         ),
  .bus_writedata                        (cpu_writedata     ),
  .bus_readdata                         (cpu_readdata      )

 );
    
// dump fsdb file for debussy
initial
begin
  $fsdbDumpfile("tb_pid_filter.fsdb");
  $fsdbDumpvars;
end
endmodule
 
 
 
 
 
 