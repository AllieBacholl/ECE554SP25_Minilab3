module bus_interface (
   input logic          iocs,
   input logic          iorw,
   input logic          rda,
   input logic          tbr,
   input logic    [7:0] recieve_read_line,
   output logic         recieve_read_en,
   output logic   [7:0] write_line,
   output logic         transmit_write_en,
   output logic         baud_write_en,
   output logic         baud_write_location,
   inout logic    [7:0] databus,
   );

   logic [7:0] write_data;
   logic [7:0] read_data;

   assign databus = iorw ? read_data : 7'bz;
   assign write_data = databus;

endmodule