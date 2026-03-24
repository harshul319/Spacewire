`timescale 1ns / 1ps

module tb_top_enc;

    reg clk;
    reg rst;

    reg SEND_FCT;
    reg SEND_BC;

    reg [8:0] fifo_data;
    reg [7:0] broadcast_code;
    reg fifo_empty;

    wire DATA;
    wire STROBE;
    wire serial_busy;

    // DUT
    top_enc dut (
        .clk(clk),
        .rst(rst),
        .SEND_FCT(SEND_FCT),
        .SEND_BC(SEND_BC),
        .fifo_data(fifo_data),
        .broadcast_code(broadcast_code),
        .fifo_empty(fifo_empty),
        .DATA(DATA),
        .STROBE(STROBE),
        .serial_busy(serial_busy)
    );

    // -----------------------------
    // Clock (10ns)
    // -----------------------------
    always #5 clk = ~clk;

    // -----------------------------
    // Test sequence
    // -----------------------------
    initial begin
        clk = 0;
        rst = 1;

        SEND_FCT = 0;
        SEND_BC  = 0;

        fifo_empty = 1;
        fifo_data  = 9'd0;
        broadcast_code = 8'hA5;

        #20;
        rst = 0;

        // ---------------------------------
        // 1. Let NULL start
        // ---------------------------------
        #40;

      
        // BC arrives while NULL is in progress
        SEND_BC = 1;
        #10;
        SEND_BC = 0;

        // ---------------------------------
        // 2. Send normal DATA
        // ---------------------------------
        #200;

        fifo_empty = 0;
        fifo_data  = {1'b0, 8'h3C};   // normal data

        #100;

        fifo_data  = {1'b0, 8'h7E};   // next data

        #100;

        // ---------------------------------
        // 3. Last DATA (TLAST = 1 → EOP)
        // ---------------------------------
        fifo_data  = {1'b1, 8'h55};

        #100;

        // ---------------------------------
        // 4. Trigger FCT
        // ---------------------------------
        #100;

        SEND_FCT = 1;
        #10;
        SEND_FCT = 0;

        // ---------------------------------
        // Run more
        // ---------------------------------
        #2500;

    end

    // ---------------------------------
    // Monitor (basic)
    // ---------------------------------
    initial begin
        $display("Time\tBusy\tDATA\tSTROBE");
        $monitor("%0t\t%b\t%b\t%b",
            $time,
            serial_busy,
            DATA,
            STROBE
        );
    end

endmodule