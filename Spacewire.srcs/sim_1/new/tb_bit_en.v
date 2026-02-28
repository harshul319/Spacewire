`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 19.02.2026 04:37:19
// Design Name: 
// Module Name: tb_bit_en
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


module tb_bit_en;

    // Testbench signals
    reg clk;
    reg rst;
    wire bit_en;

    // Instantiate DUT
    bit_en dut (
        .clk    (clk),
        .rst    (rst),
        .bit_en (bit_en)
    );

    // ------------------------
    // Clock generation
    // ------------------------
    initial begin
        clk = 0;
        forever #5 clk = ~clk;   // 10 ns clock period
    end

    // ------------------------
    // Reset sequence
    // ------------------------
    initial begin
        rst = 1'b1;
        #20;            // hold reset for 2 clock cycles
        rst = 1'b0;
    end

    // ------------------------
    // Simulation control
    // ------------------------
    initial begin
        #200;           // run long enough to see multiple pulses
        $finish;
    end

    // ------------------------
    // Monitor signals
    // ------------------------
    initial begin
        $monitor("Time=%0t | rst=%b | bit_en=%b",
                  $time, rst, bit_en);
    end

endmodule

