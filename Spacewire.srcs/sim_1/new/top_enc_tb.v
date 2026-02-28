`timescale 1ns / 1ps

module tb_top_enc;

    reg         clk;
    reg         rst;
    reg         load;
    reg [9:0]  word;
    reg [3:0]   length;
    wire         bit_en;
    wire        DATA;
    wire        STROBE;
    wire        busy;
    wire        serial_bit;

    // -----------------------------
    // DUT
    // -----------------------------
    top_enc dut (
        .clk        (clk),
        .rst        (rst),
        .load       (load),
        .word       (word),
        .length     (length),
        .DATA       (DATA),
        .STROBE     (STROBE),
        .busy       (busy),
        .bit_en     (bit_en),
        .serial_bit (serial_bit)
    );

    // -----------------------------
    // Clock: 100 MHz (10 ns period)
    // -----------------------------
    always #5 clk = ~clk;

    // -----------------------------
    // Stimulus
    // -----------------------------
    initial begin
        clk    = 0;
        rst    = 1;
        load   = 0;
        word   = 10'd0;
        length = 4'd0;

        // Reset
        #20;
        rst = 0;

        // -------------------------
        // First word (10 bits)
        // -------------------------
        #20;
        word   = 10'b1011_0011_11; // LSB first
        length = 4'd10;
        load   = 1;

        #10;
        load = 0;

        wait (busy == 0);

        // -------------------------
        // Second word (4 bits)
        // -------------------------
        #20;
        word   = 10'b0000_0010_01; // pad to 10 bits
        length = 4'd4;
        load   = 1;

        #10;
        load = 0;

        wait (busy == 0);

        #10000;
        $finish;
    end

endmodule
