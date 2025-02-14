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

reg [7:0] databus_reg;
assign databus = databus_reg;

Minilab3 DUT (.CLOCK2_50(CLOCK2_50), .CLOCK3_50(CLOCK3_50), .CLOCK4_50(CLOCK4_50), .CLOCK_50(CLOCK_50), .HEX0(hex0), 
                    .HEX1(hex1), .HEX2(hex2), .HEX3(hex3), .HEX4(hex4), .HEX5(hex5), .LEDR(ledr), .KEY(key), .SW(sw), .GPIO(gpio));

spart iSPART (.clk(CLOCK_50), .rst_n(key[0]), .iocs(iocs), .iorw(iorw), .rda(rda), .tbr(tbr), .ioaddr(ioaddr), .databus(databus), .txd(gpio[5]), .rxd(gpio[3]));

 initial begin 

    CLOCK3_50 = 0;
    CLOCK4_50 = 0;
    CLOCK2_50 = 0;
    CLOCK_50 = 0; 

    key = '0;
    sw = '0;
    iorw = '1;
    ioaddr = '0;
    iocs = '0;
    databus_reg = 'z;

    repeat (2) @(posedge CLOCK_50);
    key[0] = 1;
    repeat (4) @(posedge CLOCK_50);
    key[0] = 0;

    // Baud rate set tp 4800 bps at 50 MHz
    iorw = 1'b0;
    ioaddr = 2'b10;
    iocs = 1'b1;
    databus_reg = 8'h8b;
    @(posedge CLOCK_50);

    ioaddr = 2'b11;
    databus_reg = 8'h02;
    @(posedge CLOCK_50);

    // Send data
    ioaddr = 2'b00;
    databus_reg = 8'hb4;
    iorw = 1'b0;

    @(posedge CLOCK_50);
    databus_reg = 'z;
    iorw = 1'b1;

    // Wait to receive data
    @(posedge rda)

    if (databus != 8'hb4) begin
        $display("Error: databus should be 8'hb4 but is %h", databus);
    end

    $display("End of tests");

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