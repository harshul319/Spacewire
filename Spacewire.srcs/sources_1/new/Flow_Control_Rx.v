`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 15.03.2026 15:20:27
// Design Name: 
// Module Name: Flow_Control_Rx
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


module Flow_Control_Rx(
    input clk,
    input rst,
    input token,       // received FCT
    input data_sent,

    output tx_allowed
);

reg [5:0] credit;

always @(posedge clk or posedge rst) begin
    if (rst)
        credit <= 0;
    else begin
        if (token)
            credit <= credit + 8;

        if (data_sent && credit > 0)
            credit <= credit - 1;
    end
end

assign tx_allowed = (credit > 0);

endmodule
