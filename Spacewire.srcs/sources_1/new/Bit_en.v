`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 03:53:20
// Design Name: 
// Module Name: bit_en
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


module bit_en(
    input  wire clk,
    input  wire rst,
    output wire bit_en
);

    reg [3:0] COUNTER;

    always @(posedge clk) begin
        if (rst)
            COUNTER <= 4'd0;
        else if (COUNTER == 4'd9)
            COUNTER <= 4'd0;
        else
            COUNTER <= COUNTER + 1'b1;
    end

    assign bit_en = (COUNTER == 4'd9);

endmodule

