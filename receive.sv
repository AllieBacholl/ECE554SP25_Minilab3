module receive (
   input logic          clk,
   input logic          rst_n,
   input logic          iocs,
   input logic          iorw,
   input logic          rxd,
   input logic          receive_en,
   output logic         rda,
   output logic   [7:0] recieve_read_line,
);

endmodule