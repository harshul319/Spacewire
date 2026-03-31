`timescale 1ns / 1ps

module top_enc (
    input  wire        clk,
    input  wire        rst,

    input  wire        SEND_FCT,
    input  wire        SEND_BC,

    input  wire [7:0]  TDATA,
    input  wire        TVALID, 
    input  wire        TLAST,
    input  wire [7:0]  broadcast_code,

    output wire        TREADY,
    output wire        DATA,
    output wire        STROBE
    
);

    // ---------------------------------------
    // Internal wires (connections)
    // ---------------------------------------
    wire tx_allowed;
    wire serial_busy;
    wire bit_en;
    wire data_sent;
    wire load;
    wire [2:0] char_type;
    wire [7:0] data_byte;
    wire rd_en;
    wire wr_en;
    wire [8:0] din;
    wire [8:0] dout;
    wire almost_full;
    wire full;
    wire empty;
    wire [9:0] word_reg;
    wire [3:0] length_reg;
    wire [7:0] FCT_pending;
    
    wire FCT_sent;
    wire serial_bit;
    wire token;

    // ---------------------------------------
    // Token (for now constant, no receiver)
    // ---------------------------------------
    assign token = 1'b1;
    
    // ---------------------------------------
    // AXI_SLAVE
    // ---------------------------------------
    
    axi_slave u_axi_slave (
        .clk        (clk),
        .rst        (rst),

        .TDATA      (TDATA),
        .TVALID     (TVALID),
        .TLAST      (TLAST),
        .TREADY     (TREADY),   

        .full  (full),
        .fifo_din   (din),
        .wr_en (wr_en)
    );
    
    FIFO u_fifo (
        .clk            (clk),                  // input wire clk
        .srst           (rst),                // input wire srst
        .din            (din),                  // input wire [8 : 0] din
        .wr_en          (wr_en),              // input wire wr_en
        .rd_en          (rd_en),              // input wire rd_en
        .dout           (dout),                // output wire [8 : 0] dout
        .full           (full),                // output wire full
        .almost_full    (almost_full),  // output wire almost_full
        .empty          (empty)              // output wire empty
);

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

        .SEND_BC        (SEND_BC),

        .tx_allowed     (tx_allowed),

        .broadcast_code (broadcast_code),
        .fifo_data      (dout),
        .fifo_empty     (empty),
        .FCT_pending    (FCT_pending),

        .load           (load),
        .char_type      (char_type),
        .data_byte      (data_byte),

        .data_sent      (data_sent),
        .FCT_sent       (FCT_sent),
        .rd_en          (rd_en)
    );

    // ---------------------------------------
    // Flow Control Tokens available
    // ---------------------------------------
    Flow_Control_Rx u_flow_control_rx (
        .clk        (clk),
        .rst        (rst),
        .token      (token),
        .data_sent  (data_sent),
        .tx_allowed (tx_allowed)
    );

    // ---------------------------------------
    // Flow Control To Be Send
    // ---------------------------------------
    Flow_Control_Tx u_flow_control_tx (
        .clk         (clk),
        .rst         (rst),
        .SEND_FCT    (SEND_FCT),
        .FCT_sent    (FCT_sent),
        .FCT_pending (FCT_pending)
    );

    // ---------------------------------------
    // Character Builder
    // ---------------------------------------
    character_builder u_character_builder (   
        .char_type  (char_type),
        .data_byte  (data_byte),
        .word_reg   (word_reg),
        .length_reg (length_reg)
    );

    // ---------------------------------------
    // Serializer
    // ---------------------------------------
    serializer u_serializer (
        .clk          (clk),
        .rst          (rst),
        .load         (load),
        .word_reg     (word_reg),
        .length_reg   (length_reg),
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
        .bit_in       (serial_bit),
        .DATA         (DATA),
        .STROBE       (STROBE),
        .bit_en       (bit_en)
    );

endmodule