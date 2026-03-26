`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 05:22:48
// Design Name: 
// Module Name: Data_Strobe
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


module ds_encoder (
    input  wire clk,
    input  wire rst,
    input  wire bit_en,

    input  wire bit_in,

    output reg  DATA,
    output reg  STROBE
);

    reg prev_data;

    always @(posedge clk) begin
        if (rst) begin
            DATA      <= 1'b0;
            STROBE    <= 1'b0;
            prev_data <= 1'b0;
        end
        else if (bit_en) begin
            DATA <= bit_in;

            if (bit_in == prev_data)
                STROBE <= ~STROBE;

            prev_data <= bit_in;
        end
    end

endmodule


