module bus_interface (
   input logic          iocs,
   input logic          iorw,
   input logic          rda,
   input logic          tbr,
   input logic    [1:0] ioaddr;
   input logic    [7:0] recieve_read_line,
   output logic         recieve_read_en,
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
   assign databus = (ioaddr == 2'b01) ? status_reg : (iorw ? read_data : 8'bz);
   assign write_line = databus;

   always_comb begin
      recieve_read_en = 1'b0;
      transmit_write_en = 1'b0;
      baud_write_en = 1'b0;
      status_reg = 8'h00;
      // 0 is lower, 1 is upper 8 bits
      baud_write_location = 1'b0;

      case({ioaddr, iocs})
         3'b00: begin
            if (iorw) begin
               recieve_read_en = 1'b1;
            end
            else (iorw) begin
               transmit_write_en = 1'b1;
            end
         end

         3'b011: begin
            status_reg = {6'h00, tbr, rda};
         end

         3'b101: begin
            baud_write_en = 1'b1;
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