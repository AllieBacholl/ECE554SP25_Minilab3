module baud_generator(
    input       clk,
    input       rst_n,
    input       baud_write_en,
    input       baud_write_location,
    input [7:0] baud_generator_write_line,
    output reg  transmit_baud,
    output reg  receive_baud
    );

logic [15:0] db;
logic [15:0] down_cnt;

// divisor = (clock frequency/(2^n × baud rate) − 1)
// Assume clock frequency is 50 MHz and n = 4
// Supported baud rates are 4800, 9600, 19200, 38400
// Divisor values are 651, 326, 163, 81

always_ff@ (posedge clk, negedge rst_n) begin
    if (!rst_n) begin
        transmit_baud <= 1'b0;
        receive_baud <= 1'b0;
        down_cnt <= 16'h0000;
        // Default to 50 MHz at 9600 bps
        db <= 16'd326;
    end
    else begin
        // Set DB(Low)
        if (baud_write_en && !baud_write_location) begin
            db[7:0] <= baud_generator_write_line;
        end
        // Set DB(High)
        else if (baud_write_en && baud_write_location) begin
            db[15:8] <= baud_generator_write_line;
        end
        // Calculate enable signals
        else begin
            if (down_cnt == 16'h0000) begin
                down_cnt <= db;
                transmit_baud <= 1'b1;
                receive_baud <= 1'b1;
            end else begin
                down_cnt <= down_cnt - 1'b1;
                transmit_baud <= 1'b0;
                receive_baud <= 1'b0;
            end
        end
    end
end


endmodule
