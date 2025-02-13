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
    logic [7:0] write_data;
    logic [7:0] read_data;
    enum logic [2:0] {START1, START2, WAIT, RECEIVE, TRANSMIT} state, next_state;

    // Logic for handling ownership of the databus signal
    assign databus = iorw ? 7'bz : write_data;
    assign read_data = databus;

    // State machine flip flop
    always_ff @(posedge clk, negedge rst_n) begin
        
    end

    // State machine combinational logic
    always_comb begin
        next_state = state;
        iorw = 0;

    end

endmodule
