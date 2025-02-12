module baud_generator(
    input       clk,
    input       rst_n,
    input       baud_write_en,
    input       baud_write_location,
    input [7:0] baud_generator_write_line,
    output      transmit_baud,
    output      receive_baud,
    );

logic [15:0] down_cnt;

// divisor = (clock frequency/(2^n × baud rate) − 1)
// Assume clock frequency is 50 MHz and n = 4
// Supported baud rates are 4800, 9600, 19200, 38400
// Divisor values are 651, 326, 163, 81

always_ff@ (posedge clk, negedge rst_n) begin
    if (rst_n) begin
        transmit_baud <= 1'b0;
        receive_baud <= 1'b0;
    end
    else begin
        case (ioaddr)
            // Set DB(Low)
            2'b10: begin
                down_cnt[7:0] <= db_value;
            end
            // Set DB(High)
            2'b11: begin
                down_cnt[15:8] <= db_value;
            end
            // Calculate enable signals
            default: begin

            end

        endcase
    end
end


endmodule
