`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 06.02.2026 04:23:23
// Design Name: 
// Module Name: Serializer
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


module serializer (
    input  wire        clk,
    input  wire        bit_en,
    input  wire        rst,
    input  wire        load,
    input  wire [9:0] word_reg,
    input  wire [3:0]  length_reg,

    output reg         bit_out,
    output reg         serial_busy
);

    reg [9:0] shift_reg;
    reg [3:0]  bit_cnt;
    reg [3:0]  len_reg;

    always @(posedge clk) begin
        if (rst) begin
            shift_reg <= 10'd0;
            bit_cnt   <= 4'd0;
            len_reg   <= 4'd0;
            bit_out   <= 1'b0;
            serial_busy      <= 1'b0;
        end
        else begin
            // LOAD PHASE
            if (load && !serial_busy) begin
                shift_reg <= word_reg;     
                len_reg   <= length_reg;   // latch length
                bit_cnt   <= 4'd0;
                serial_busy      <= 1'b1;
            end

            // SHIFT PHASE
            else if (serial_busy && bit_en) begin
                bit_out   <= shift_reg[0];
                shift_reg <= shift_reg >> 1;

                if (bit_cnt == len_reg - 1) begin
                    serial_busy    <= 1'b0;   // last bit sent
                end

                bit_cnt <= bit_cnt + 1'b1;
            end
        end
    end

endmodule


