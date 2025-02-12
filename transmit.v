module transmit (
   input logic          clk,
   input logic          rst_n,
   input logic          iocs,
   input logic          iorw,
   input logic          transmit_en,
   input logic    [7:0] transmit_write_line,
   output logic         txd,
   output logic         tbr,
   );

endmodule