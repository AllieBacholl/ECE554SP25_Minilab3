`timescale 1 ps / 1 ps

module Minilab3_tb;

logic CLOCK2_50, CLOCK3_50, CLOCK4_50, CLOCK_50;
logic [6:0] hex0, hex1, hex2, hex3, hex4, hex5;
logic [9:0] ledr;
logic [3:0] key;
logic [9:0] sw;
logic [35:0] GPIO;

logic clr;

Minilab3 DUT (.CLOCK2_50(CLOCK2_50), .CLOCK3_50(CLOCK3_50), .CLOCK4_50(CLOCK4_50), .CLOCK_50(CLOCK_50), .HEX0(hex0), 
                    .HEX1(hex1), .HEX2(hex2), .HEX3(hex3), .HEX4(hex4), .HEX5(hex5), .LEDR(ledr), .KEY(key), .SW(sw), .GPIO(GPIO));


 initial begin 

    CLOCK3_50 = 0;
    CLOCK4_50 = 0;
    CLOCK2_50 = 0;
    CLOCK_50 = 0; 

    key = 4'b1111;
    sw = 10'h0;
    clr = 1'b0;

    repeat (2) @(posedge CLOCK_50);
    key[0] = 0;
    repeat (4) @(posedge CLOCK_50);
    key[0] = 1;

    // Set a new baud rate of 4800 bps at 50 MHz
    

 repeat (200) @(posedge CLOCK_50);
 $stop;

    end

 always begin 
    //#5 CLOCK2_50 = ~CLOCK_50;
    //#5 CLOCK3_50 = ~CLOCK_50;
    //#5 CLOCK4_50 = ~CLOCK_50;
    #5 CLOCK_50 = ~CLOCK_50; // 10ns clock period
 end


endmodule