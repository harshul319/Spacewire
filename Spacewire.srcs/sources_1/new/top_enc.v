`timescale 1ns / 1ps

module top_enc (
    input  wire        clk,
    input  wire        rst,

    input  wire        SEND_FCT,
    input  wire        SEND_BC,

    input  wire [8:0]  fifo_data,
    input  wire [7:0]  broadcast_code,
    input  wire        fifo_empty,

    output wire        DATA,
    output wire        STROBE,
    output wire        serial_busy,
    output wire        bit_en,
    output wire        data_sent
    
);

    // ---------------------------------------
    // Internal wires (connections)
    // ---------------------------------------

    wire tx_allowed;
    wire load;

    wire [2:0] char_type;
    wire [7:0] data_byte;
    wire read_en;

    wire [9:0] word_reg;
    wire [3:0] length_reg;

    wire serial_bit;
    wire token;

    // ---------------------------------------
    // Token (for now constant, no receiver)
    // ---------------------------------------
    assign token = 1'b1;

    // ---------------------------------------
    // bit_en generator
    // ---------------------------------------
    bit_en u_bit_en (
        .clk    (clk),
        .rst    (rst),
        .bit_en (bit_en)
    );

    // ---------------------------------------
    // Sequencer
    // ---------------------------------------
    Sequencer u_Sequencer (
        .clk            (clk),
        .rst            (rst),
        .serial_busy    (serial_busy),

        .SEND_FCT       (SEND_FCT),
        .SEND_BC        (SEND_BC),

        .tx_allowed     (tx_allowed),

        .broadcast_code (broadcast_code),
        .fifo_data      (fifo_data),
        .fifo_empty     (fifo_empty),

        .load           (load),
        .char_type      (char_type),
        .data_byte      (data_byte),

        .data_sent      (data_sent),
        .read_en        (read_en)
    );

    // ---------------------------------------
    // Flow Control
    // ---------------------------------------
    flow_control u_flow_control (
        .clk        (clk),
        .rst        (rst),
        .token      (token),
        .data_sent  (data_sent),
        .tx_allowed (tx_allowed)
    );

    // ---------------------------------------
    // Character Builder
    // ---------------------------------------
    character_builder u_character_builder (
        .clk        (clk),
        .char_type  (char_type),
        .data_byte  (data_byte),
        .word_reg       (word_reg),
        .length_reg     (length_reg)
    );

    // ---------------------------------------
    // Serializer
    // ---------------------------------------
    serializer u_serializer (
        .clk          (clk),
        .rst          (rst),
        .load         (load),
        .word_reg         (word_reg),
        .length_reg       (length_reg),
        .bit_out      (serial_bit),
        .serial_busy  (serial_busy),
        .bit_en       (bit_en)
    );

    // ---------------------------------------
    // Data-Strobe Encoder
    // ---------------------------------------
    ds_encoder u_ds_encoder (
        .clk          (clk),
        .rst          (rst),
        .serial_busy  (serial_busy),
        .bit_in       (serial_bit),
        .DATA         (DATA),
        .STROBE       (STROBE),
        .bit_en       (bit_en)
    );

endmodule