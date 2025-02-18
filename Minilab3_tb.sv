`timescale 1 ps / 1 ps

module Minilab3_tb;

logic CLOCK2_50, CLOCK3_50, CLOCK4_50, CLOCK_50;
logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
logic [9:0] ledr;
logic [3:0] key;
logic [9:0] sw;
wire [35:0] gpio;

logic iorw;
logic rda, tbr;
logic [1:0] ioaddr;
logic iocs;
wire [7:0] databus;

logic all_tests_passed;

logic [15:0] baud_rate;

logic [7:0] data_write;
assign databus = iocs ? (iorw ? 8'bz : data_write) : 8'bz;

// Set baud rate based on switch position
always_comb begin
   if (sw[9:8] == 2'b00)
      baud_rate = 651;
   else if (sw[9:8] == 2'b01)
      baud_rate = 326;
   else if (sw[9:8] == 2'b10)
      baud_rate = 163;
   else 
      baud_rate = 81;
end

// Instantiate both the paired spart and controller and our standalone spart
Minilab3 DUT (.CLOCK2_50(CLOCK2_50), .CLOCK3_50(CLOCK3_50), .CLOCK4_50(CLOCK4_50), .CLOCK_50(CLOCK_50), .HEX0(hex0), 
                    .HEX1(hex1), .HEX2(hex2), .HEX3(hex3), .HEX4(hex4), .HEX5(hex5), .LEDR(ledr), .KEY(key), .SW(sw), .GPIO(gpio));

spart iSPART (.clk(CLOCK_50), .rst_n(key[0]), .iocs(iocs), .iorw(iorw), .rda(rda), .tbr(tbr), .ioaddr(ioaddr), .databus(databus), .txd(gpio[5]), .rxd(gpio[3]));

// Run tests at all 4 baud rates
initial begin 

   CLOCK3_50 = 0;
   CLOCK4_50 = 0;
   CLOCK2_50 = 0;
   CLOCK_50 = 0; 

   key = 4'b0001;
   sw = 10'b0;
   iorw = 1'b1;
   ioaddr = 2'b0;
   iocs = 1'b0;
   data_write = 8'b0;

   all_tests_passed = 1;

   repeat (2) @(posedge CLOCK_50);
   key[0] = 0;
   repeat (4) @(posedge CLOCK_50);
   key[0] = 1;

   // Baud rate set t0 4800 bps at 50 MHz
   iorw = 1'b0;
   ioaddr = 2'b10;
   iocs = 1'b1;
   data_write = baud_rate[7:0];
   @(posedge CLOCK_50);

   ioaddr = 2'b11;
   data_write = baud_rate[15:8];
   @(posedge CLOCK_50);
   iocs = 0;

   $display("Test 1: try sending 0xb4 and check for loopback from DUT at a baud rate of 4800");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'hb4;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout1
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 1 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout1;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'hb4) begin
            $display("Test 1 Failed: databus should be 0xb4 but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 1 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout1;
      end
   join

   $display("Test 2: try sending 0xff and check for loopback from DUT at a baud rate of 4800");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'hff;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout2
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 2 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout2;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'hff) begin
            $display("Test 2 Failed: databus should be 0xff but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 2 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout2;
      end
   join

   $display("Test 3: try sending 0x01 and check for loopback from DUT at a baud rate of 4800");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'h01;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout3
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 3 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout3;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'h01) begin
            $display("Test 3 Failed: databus should be 0x01 but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 3 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout3;
      end
   join

   $display("Test 4: try sending 0x00 and check for loopback from DUT at a baud rate of 4800");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'h00;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout4
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 4 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout4;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'h00) begin
            $display("Test 4 Failed: databus should be 0x00 but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 4 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout4;
      end
   join

   // Baud rate set tp 9600 bps at 50 MHz
   @(posedge CLOCK_50)
   sw = {2'b01, 8'b0};
   @(posedge CLOCK_50)
   iorw = 1'b0;
   ioaddr = 2'b10;
   iocs = 1'b1;
   data_write = baud_rate[7:0];
   @(posedge CLOCK_50);

   ioaddr = 2'b11;
   data_write = baud_rate[15:8];
   @(posedge CLOCK_50);
   iocs = 0;

   $display("Test 5: try sending 0xbf and check for loopback from DUT at a baud rate of 9600");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'hbf;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout5
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 5 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout5;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'hbf) begin
            $display("Test 5 Failed: databus should be 0xbf but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 5 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout5;
      end
   join

   $display("Test 6: try sending 0xff and check for loopback from DUT at a baud rate of 9600");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'hff;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout6
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 6 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout6;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'hff) begin
            $display("Test 6 Failed: databus should be 0xff but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 6 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout6;
      end
   join

   $display("Test 7: try sending 0x01 and check for loopback from DUT at a baud rate of 9600");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'h01;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout7
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 7 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout7;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'h01) begin
            $display("Test 7 Failed: databus should be 0x01 but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 7 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout7;
      end
   join

   $display("Test 8: try sending 0x00 and check for loopback from DUT at a baud rate of 9600");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'h00;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout8
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 8 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout8;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'h00) begin
            $display("Test 8 Failed: databus should be 0x00 but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 8 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout8;
      end
   join

   // Baud rate set tp 19200 bps at 50 MHz
   @(posedge CLOCK_50)
   sw = {2'b10, 8'b0};
   @(posedge CLOCK_50)
   iorw = 1'b0;
   ioaddr = 2'b10;
   iocs = 1'b1;
   data_write = baud_rate[7:0];
   @(posedge CLOCK_50);

   ioaddr = 2'b11;
   data_write = baud_rate[15:8];
   @(posedge CLOCK_50);
   iocs = 0;

   $display("Test 9: try sending 0xbf and check for loopback from DUT at a baud rate of 19200");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'hbf;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout9
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 9 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout9;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'hbf) begin
            $display("Test 9 Failed: databus should be 0xbf but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 9 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout9;
      end
   join

   $display("Test 10: try sending 0xff and check for loopback from DUT at a baud rate of 19200");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'hff;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout10
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 10 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout10;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'hff) begin
            $display("Test 10 Failed: databus should be 0xff but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 10 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout10;
      end
   join

   $display("Test 11: try sending 0x01 and check for loopback from DUT at a baud rate of 19200");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'h01;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout11
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 11 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout11;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'h01) begin
            $display("Test 11 Failed: databus should be 0x01 but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 11 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout11;
      end
   join

   $display("Test 12: try sending 0x00 and check for loopback from DUT at a baud rate of 19200");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'h00;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout12
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 12 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout12;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'h00) begin
            $display("Test 12 Failed: databus should be 0x00 but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 12 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout12;
      end
   join

   // Baud rate set tp 38400 bps at 50 MHz
   @(posedge CLOCK_50)
   sw = {2'b11, 8'b0};
   @(posedge CLOCK_50)
   iorw = 1'b0;
   ioaddr = 2'b10;
   iocs = 1'b1;
   data_write = baud_rate[7:0];
   @(posedge CLOCK_50);

   ioaddr = 2'b11;
   data_write = baud_rate[15:8];
   @(posedge CLOCK_50);
   iocs = 0;

   $display("Test 13: try sending 0xbf and check for loopback from DUT at a baud rate of 38400");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'hbf;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout13
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 13 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout13;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'hbf) begin
            $display("Test 13 Failed: databus should be 0xbf but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 13 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout13;
      end
   join

   $display("Test 14: try sending 0xff and check for loopback from DUT at a baud rate of 38400");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'hff;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout14
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 14 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout14;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'hff) begin
            $display("Test 14 Failed: databus should be 0xff but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 14 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout14;
      end
   join

   $display("Test 15: try sending 0x01 and check for loopback from DUT at a baud rate of 38400");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'h01;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout15
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 15 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout15;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'h01) begin
            $display("Test 15 Failed: databus should be 0x01 but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 15 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout15;
      end
   join

   $display("Test 16: try sending 0x00 and check for loopback from DUT at a baud rate of 38400");
   // Send a byte of data
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'h00;
   iorw = 1'b0;
   // Disable reading and writing to testbench spart until we need to
   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   // Wait for data to loopback from DUT
   fork : timeout16
      begin
         // Timeout check
         repeat (100000) @(posedge CLOCK_50);
         $display("Test 16 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         all_tests_passed = 0;
         disable timeout16;
      end
      begin
         // Correctness check
         @(posedge rda);
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'h00) begin
            $display("Test 16 Failed: databus should be 0x00 but is 0x%h\n", databus);
            all_tests_passed = 0;
         end
         else begin
            $display("Test 16 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
         disable timeout16;
      end
   join

   if (all_tests_passed) begin
      $display("YAHOO!!! All tests passed!");
   end
   else begin
      $display("End of tests");
   end
   $stop();

    end

 always begin 
    //#5 CLOCK2_50 = ~CLOCK_50;
    //#5 CLOCK3_50 = ~CLOCK_50;
    //#5 CLOCK4_50 = ~CLOCK_50;
    #5 CLOCK_50 = ~CLOCK_50; // 10ns clock period
 end


endmodule