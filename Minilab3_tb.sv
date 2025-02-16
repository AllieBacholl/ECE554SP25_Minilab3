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

logic [7:0] data_write;
assign databus = iocs ? (iorw ? 8'bz : data_write) : 8'bz;

Minilab3 DUT (.CLOCK2_50(CLOCK2_50), .CLOCK3_50(CLOCK3_50), .CLOCK4_50(CLOCK4_50), .CLOCK_50(CLOCK_50), .HEX0(hex0), 
                    .HEX1(hex1), .HEX2(hex2), .HEX3(hex3), .HEX4(hex4), .HEX5(hex5), .LEDR(ledr), .KEY(key), .SW(sw), .GPIO(gpio));

spart iSPART (.clk(CLOCK_50), .rst_n(~key[0]), .iocs(iocs), .iorw(iorw), .rda(rda), .tbr(tbr), .ioaddr(ioaddr), .databus(databus), .txd(gpio[5]), .rxd(gpio[3]));

 initial begin 

   CLOCK3_50 = 0;
   CLOCK4_50 = 0;
   CLOCK2_50 = 0;
   CLOCK_50 = 0; 

   key = 4'b0;
   sw = 10'b0;
   iorw = 1'b1;
   ioaddr = 2'b0;
   iocs = 1'b0;
   data_write = 8'b0;

   repeat (2) @(posedge CLOCK_50);
   key[0] = 1;
   repeat (4) @(posedge CLOCK_50);
   key[0] = 0;

   // Baud rate set tp 4800 bps at 50 MHz
   iorw = 1'b0;
   ioaddr = 2'b10;
   iocs = 1'b1;
   data_write = 8'h8b;
   @(posedge CLOCK_50);

   ioaddr = 2'b11;
   data_write = 8'h02;
   @(posedge CLOCK_50);

   $display("Test 1: try sending 0xb4 and check for loopback from DUT at a baud rate of 4800");
   @(posedge CLOCK_50);
   iocs = 1;
   ioaddr = 2'b00;
   data_write = 8'hb4;
   iorw = 1'b0;

   @(posedge CLOCK_50);
   iocs = 0;
   iorw = 1'b1;
   fork : timeout
      begin
         // Timeout check
         repeat (10000) @(posedge CLOCK_50);
         $display("Test 1 Failed: timed out waiting for data ready signal from the test bench receiver\n");
         disable timeout;
      end
      begin
         // Correctness check
         @(posedge rda);
         disable timeout;
         iocs = 1;
         @(posedge CLOCK_50);
         if (databus !== 8'hb4) begin
            $display("Test 1 Failed: databus should be 0xb4 but is 0x%h\n", databus);
         end
         else begin
            $display("Test 1 Passed\n");
         end
         @(posedge CLOCK_50);
         iocs = 0;
      end
   join

   $display("End of tests");
   $stop();

    end

 always begin 
    //#5 CLOCK2_50 = ~CLOCK_50;
    //#5 CLOCK3_50 = ~CLOCK_50;
    //#5 CLOCK4_50 = ~CLOCK_50;
    #5 CLOCK_50 = ~CLOCK_50; // 10ns clock period
 end


endmodule