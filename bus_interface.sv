module bus_interface (
   input logic          iocs,
   input logic          iorw,
   input logic          rda,
   input logic          tbr,
   input logic    [1:0] ioaddr;
   input logic    [7:0] receive_read_line,
   output logic         receive_read_en,
   output logic   [7:0] write_line,
   output logic         transmit_write_en,
   output logic         baud_write_en,
   output logic         baud_write_location,
   inout logic    [7:0] databus,
   );

   // Intermediate signals
   logic [7:0] read_data;
   logic [7:0] status_reg;

   // Logic for handling ownership of the databus signal
   assign databus = iorw ? read_data : 7'bz;
   assign read_data = io_addr[0] ? {6'h00, tbr, rda} : receive_read_line;
   assign write_line = databus;

   always_comb begin
      receive_read_en = 1'b0;
      transmit_write_en = 1'b0;
      baud_write_en = 1'b0;
      status_reg = 8'h00;
      // 0 is lower, 1 is upper 8 bits
      baud_write_location = 1'b0;

      case({ioaddr, iocs})
         3'b001: begin
            if (iorw) begin
               receive_read_en = 1'b1;
            end
            else (iorw) begin
               transmit_write_en = 1'b1;
            end
         end

         3'b011: begin
            // Nothing to enable
         end

         3'b101: begin
            baud_write_en = 1'b1;
            baud_write_location = 1'b0;
         end

         3'b111: begin
            baud_write_en = 1'b1;
            baud_write_location = 1'b1;
         end

         default: begin
            // Default do nothing since CS is low
         end
      endcase
   end


endmodule