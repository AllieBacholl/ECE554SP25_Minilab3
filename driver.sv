//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    
// Design Name: 
// Module Name:    driver 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module driver(
    input logic             clk,
    input logic             rst,
    input logic     [1:0]   br_cfg,
    output logic            iocs,
    output logic            iorw,
    input logic             rda,
    input logic             tbr,
    output logic    [1:0]   ioaddr,
    inout logic     [7:0]   databus,
    );

    // Intermediate signals
            logic   [1:0]   br_cfg_ff;
            logic   [7:0]   write_data;
            logic   [7:0]   read_data, read_data_next;
            logic   [15:0]  baud_rate;
    enum    logic   [2:0]   {START_WAIT1, START1, START_WAIT2, START2, WAIT, RECEIVE, TRANSMIT_WAIT, TRANSMIT} state, next_state;

    // Logic for handling ownership of the databus signal
    assign databus = iorw ? 7'bz : write_data;

    // Logic for determining the right baud rate
    always_comb begin
        if (br_cfg == 2'b00)
            baud_rate = 651;
        if (br_cfg == 2'b01)
            baud_rate = 326;
        if (br_cfg == 2'b10)
            baud_rate = 163;
        if (br_cfg == 2'b11)
            baud_rate = 81;
    end

    // State machine flip flop
    always_ff @(posedge clk, negedge rst_n) begin
        if (!rst_n) begin
            state = START_WAIT1;
            br_cfg_ff = 0;
        end
        else begin
            state = next_state;
            read_data = read_data_next;
            br_cfg_ff = br_cfg;
        end
    end

    // State machine combinational logic
    always_comb begin
        next_state = state;
        read_data_next = read_data;
        iorw = 0;
        ioaddr = 2'b00;
        iocs = 0;
        case(state)
            START_WAIT1:
                iocs = 0;
                if (tbr):
                    next_state = START1;
            START1:
                iocs = 1;
                iorw = 0;
                ioaddr = 2'b10;
                write_data = baud_rate[7:0];
                next_state = START_WAIT2;
            START_WAIT2:
                iocs = 0;
                if (br_cfg != br_cfg_ff)
                    next_state = StART_WAIT1;
                if (tbr):
                    next_state = START2;
            START2:
                iocs = 1;
                iorw = 0;
                ioaddr = 2'b11;
                write_data = baud_rate[15:8];
                if (br_cfg != br_cfg_ff)
                    next_state = StART_WAIT1;
                else
                    next_state = WAIT;
            WAIT:
                iocs = 0;
                if (br_cfg != br_cfg_ff)
                    next_state = StART_WAIT1;
                if(rda)
                    next_state = RECEIVE
            RECEIVE:
                iocs = 1;
                iorw = 1;
                ioaddr = 2'b00;
                next_state = TRANSMIT_WAIT
            TRANSMIT_WAIT:
            iocs = 0;
                if (tbr):
                    next_state = TRANSMIT;
            TRANSMIT:
                iocs = 1;
                iorw = 0;
                ioaddr = 2'b00;
                next_state = WAIT;

        endcase
    end

endmodule
