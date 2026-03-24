`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 02:15:21
// Design Name: 
// Module Name: character_builder
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


module character_builder (

    input wire clk,
    input  wire [2:0]  char_type,
    input  wire [7:0]  data_byte,   

    output reg  [9:0] word_reg,
    output reg  [3:0] length_reg
);

    // ------------------------------------------
    // Character Type Encoding
    // ------------------------------------------
    localparam DATA = 3'd0;
    localparam FCT  = 3'd1;
    localparam EOP  = 3'd2;
    localparam EEP  = 3'd3;
    localparam ESC  = 3'd4;

    reg [9:0] word_next;
    reg [3:0] length_next;
    reg parity;

    // -------------------------------
    // COMBINATIONAL LOGIC
    // -------------------------------
    always @(*) begin
        word_next   = 10'd0;
        length_next = 4'd0;

        case (char_type)

            DATA: begin
                parity = ~(^{1'b0, data_byte});
                word_next   = {data_byte, 1'b0, parity};
                length_next = 4'd10;
            end

            FCT: begin
                parity = ~(^3'b001);
                word_next   = {3'b001, parity};
                length_next = 4'd4;
            end

            EOP: begin
                parity = ~(^3'b101);
                word_next   = {3'b101, parity};
                length_next = 4'd4;
            end

            EEP: begin
                parity = ~(^3'b011);
                word_next   = {3'b011, parity};
                length_next = 4'd4;
            end

            ESC: begin
                parity = ~(^3'b111);
                word_next   = {3'b111, parity};
                length_next = 4'd4;
            end
        endcase
    end

    // -------------------------------
    // REGISTERED OUTPUT 
    // -------------------------------
    always @(posedge clk) begin
        word_reg   <= word_next;
        length_reg <= length_next;
    end

endmodule

