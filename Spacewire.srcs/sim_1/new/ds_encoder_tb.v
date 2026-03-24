`timescale 1ns / 1ps

module tb_ds_encoder;

    // DUT inputs
    reg clk;
    reg rst;
    reg serial_busy;
    reg bit_in;

    // DUT outputs
    wire DATA;
    wire STROBE;

    // Instantiate DUT
    ds_encoder dut (
        .clk    (clk),
        .rst    (rst),
        .busy   (busy),
        .bit_in (bit_in),
        .DATA   (DATA),
        .STROBE (STROBE)
    );

    // Clock generation: 100 MHz (10 ns period)
    always #5 clk = ~clk;

    // Task to send one serialized bit
    task send_bit(input reg b);
        begin
            bit_in = b;
            serial_busy   = 1'b1;
            #10;                 // one clock cycle
        end
    endtask

    initial begin
        // Initial values
        clk    = 0;
        rst    = 1;
        serial_busy   = 0;
        bit_in = 0;

        // Reset pulse
        #20;
        rst = 0;

        // -----------------------------
        // Test sequence
        // -----------------------------

        // First bit (0)
        send_bit(0);

        // Same bit again → STROBE should toggle
        send_bit(0);

        // Change bit → STROBE should NOT toggle
        send_bit(1);

        // Same bit → STROBE toggles
        send_bit(1);

        // Change bit → no toggle
        send_bit(0);

        // Idle (busy low)
        serial_busy = 0;
        #20;

        // Resume transmission
        send_bit(0);
        send_bit(0);
        send_bit(1);

        // End simulation
        #20;
        $finish;
    end

endmodule
