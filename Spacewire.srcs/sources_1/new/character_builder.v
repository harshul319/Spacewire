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

    input  wire [2:0]  char_type,
    input  wire [7:0]  data_byte,   

    output reg  [9:0] word,
    output reg  [3:0]  length
);

    // ------------------------------------------
    // Character Type Encoding
    // ------------------------------------------
    localparam DATA = 3'd0;
    localparam FCT  = 3'd1;
    localparam EOP  = 3'd2;
    localparam EEP  = 3'd3;
    localparam ESC  = 3'd4;
    
    reg parity;

    always @(*) begin

        // Default values
        word   = 14'd0;
        length = 4'd0;

        case (char_type)

            // ----------------------------------
            // DATA (N-Char)
            // ----------------------------------
            DATA: begin
                // Parity over data + control bit (0)
                parity = ^{1'b0, data_byte};

                word   = {data_byte, 1'b0, parity};
                length = 4'd10;
            end

            // ----------------------------------
            // FCT (L-Char)
            // ----------------------------------
            FCT: begin
                parity = ^3'b001;
                word   = {3'b001,parity};
                length = 4'd4;
            end

            // ----------------------------------
            // EOP
            // ----------------------------------
            EOP: begin
                parity = ^3'b101;
                word   = {3'b101,parity};
                length = 4'd4;
            end

            // ----------------------------------
            // EEP
            // ----------------------------------
            EEP: begin
                parity = ^3'b011;
                word   = {3'b011,parity};
                length = 4'd4;
            end

            // ----------------------------------
            // ESC
            // ----------------------------------
            ESC: begin
                parity = ^3'b111;
                word   = {3'b111,parity};
                length = 4'd4;
            end

            default: begin
                word   = 14'd0;
                length = 4'd0;
            end
        endcase
    end

endmodule

