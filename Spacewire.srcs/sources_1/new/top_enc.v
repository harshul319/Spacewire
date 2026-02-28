`timescale 1ns / 1ps

module top_enc (
    input  wire        clk,
    input  wire        rst,
    input  wire        bit_en,

    input  wire        load,
    input  wire [9:0] word,
    input  wire [3:0]  length,
    
    output wire        serial_bit,
    output wire        DATA,
    output wire        STROBE,
    output wire        busy
);
    // -----------------------------
    // bit_en
    // -----------------------------
    
    bit_en u_bit_en (
        .clk     (clk),
        .rst     (rst),
        .bit_en  (bit_en)
    );

    // -----------------------------
    // Serializer
    // -----------------------------
    serializer u_serializer (
        .clk     (clk),
        .rst     (rst),
        .load    (load),
        .word    (word),
        .length  (length),
        .bit_out (serial_bit),
        .busy    (busy),
        .bit_en  (bit_en)
    );

    // -----------------------------
    // Data-Strobe Encoder
    // -----------------------------
    ds_encoder u_ds_encoder (
        .clk    (clk),
        .rst    (rst),
        .busy   (busy),
        .bit_in (serial_bit),
        .DATA   (DATA),
        .STROBE (STROBE),
        .bit_en (bit_en)
    );

endmodule
