`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 27.03.2026 06:47:08
// Design Name: 
// Module Name: AXI_slave
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


module axi_slave (
    input  wire        clk,
    input  wire        rst,

    input  wire [7:0]  TDATA,
    input  wire        TVALID,
    input  wire        TLAST,
    input  wire        full,

    
    output reg         TREADY,
    output reg  [8:0]  fifo_din,
    output reg         wr_en
);

always @(posedge clk) begin
    if (rst) begin
        TREADY     <= 0;
        wr_en <= 0;
    end else begin
        TREADY     <= !full;
        wr_en <= 0;

        if (TVALID && TREADY) begin
            wr_en <= 1;
            fifo_din   <= {TLAST,TDATA};
        end
    end
end

endmodule