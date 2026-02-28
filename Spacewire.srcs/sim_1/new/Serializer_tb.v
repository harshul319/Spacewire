`timescale 1ns / 1ps

module tb_serializer;

    reg         clk;
    reg         rst;
    reg         load;
    reg [13:0]  word;
    reg [3:0]   length;

    wire        bit_out;
    wire        busy;

    // DUT
    serializer dut (
        .clk(clk),
        .rst(rst),
        .load(load),
        .word(word),
        .length(length),
        .bit_out(bit_out),
        .busy(busy)
    );

    // Clock: 10 ns period
    always #5 clk = ~clk;

    initial begin
        // Init
        clk    = 0;
        rst    = 1;
        load   = 0;
        word   = 0;
        length = 0;

        #20;
        rst = 0;

        // ----------------------------------
        // TEST 1: 4-bit control character
        // ----------------------------------
        @(posedge clk);
        word   = 14'b0000_0000_0001_101; // lower 4 bits = 1101
        length = 4;
        load   = 1;

        @(posedge clk);
        load = 0;

        wait (!busy);
        #20;

        // ----------------------------------
        // TEST 2: 10-bit data character
        // ----------------------------------
        @(posedge clk);
        word   = 14'b0000_11_10101010; // lower 10 bits valid
        length = 10;
        load   = 1;

        @(posedge clk);
        load = 0;

        wait (!busy);
        #20;

        // ----------------------------------
        // TEST 3: 14-bit time code
        // ----------------------------------
        @(posedge clk);
        word   = 14'b11_101011_01111_0; // example 14-bit pattern
        length = 14;
        load   = 1;

        @(posedge clk);
        load = 0;

        wait (!busy);
        #50;

        $finish;
    end

endmodule
