`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 20:34:07
// Design Name: 
// Module Name: FIFO_controller
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module FIFO_controller(
    input clk,
    input rst,
    input [8:0] dout,
    input empty,
    input sequencer_busy,
    
    output reg read_en,
    output reg [7:0] data_char,
    output reg t_last
    );
    
    always @(posedge clk) begin
        if (rst) begin 
        data_char <= 8'd0;
        read_en <= 1'd0;
        t_last <= 1'd0;
        end
    
    end
endmodule
