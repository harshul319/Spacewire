`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2026 00:26:54
// Design Name: 
// Module Name: Flow_Control_Tx
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


module Flow_Control_Tx(
    input wire clk,
    input wire rst,
    input wire SEND_FCT,
    input wire FCT_sent,
    
    output reg [7:0] FCT_pending
    );
    
    always @(posedge clk) begin
        if (rst)
            FCT_pending <= 0;
        else begin
            case ({SEND_FCT, FCT_sent})
                2'b10: FCT_pending <= FCT_pending + 1;
                2'b01: FCT_pending <= FCT_pending - 1;
                2'b11: FCT_pending <= FCT_pending;
            endcase
        end
    end
endmodule
