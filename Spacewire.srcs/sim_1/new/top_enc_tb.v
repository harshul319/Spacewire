`timescale 1ns / 1ps

module tb_top_enc;

    reg clk;
    reg rst;

    reg SEND_FCT;
    reg SEND_BC;

    reg [7:0] TDATA;
    reg [7:0] broadcast_code;
    reg TLAST;
    reg TVALID;

    wire TREADY;
    wire DATA;
    wire STROBE;

    // DUT
    top_enc dut (
        .clk(clk),
        .rst(rst),
        .SEND_FCT(SEND_FCT),
        .SEND_BC(SEND_BC),
        .TDATA(TDATA),
        .broadcast_code(broadcast_code),
        .TLAST(TLAST),
        .TVALID(TVALID),
        .DATA(DATA),
        .STROBE(STROBE),
        .TREADY(TREADY)
    );

    // -----------------------------
    // CLOCK (10ns period)
    // -----------------------------
    always #5 clk = ~clk;

    // ============================================================
    // TASK: SEND AXI BYTE (with proper handshake)
    // ============================================================
    task send_axi_byte;
        input [7:0] data;
        input last;
    begin
        @(posedge clk);
        TDATA  <= data;
        TLAST  <= last;
        TVALID <= 1;

        // WAIT FOR READY
        wait (TREADY == 1);

        @(posedge clk);
        TVALID <= 0;
        TLAST  <= 0;
    end
    endtask

    // ============================================================
    // TASK: SEND PACKET (multiple bytes)
    // ============================================================
    task send_packet;
        input integer length;
        integer i;
    begin
        for (i = 0; i < length; i = i + 1) begin
            if (i == length - 1)
                send_axi_byte($random, 1);
            else
                send_axi_byte($random, 0);
        end
    end
    endtask

    // ============================================================
    // TASK: SEND FCT
    // ============================================================
    task send_fct;
    begin
        @(posedge clk);
        SEND_FCT <= 1;
        @(posedge clk);
        SEND_FCT <= 0;
    end
    endtask

    // ============================================================
    // TASK: SEND BROADCAST
    // ============================================================
    task send_bc;
        input [7:0] code;
    begin
        @(posedge clk);
        broadcast_code <= code;
        SEND_BC <= 1;

        @(posedge clk);
        SEND_BC <= 0;
    end
    endtask

    // ============================================================
    // INITIAL BLOCK
    // ============================================================
    initial begin
        // INIT
        clk = 0;
        rst = 1;

        SEND_FCT = 0;
        SEND_BC  = 0;
        TDATA = 0;
        broadcast_code = 0;
        TLAST = 0;
        TVALID = 0;

        // -----------------------------
        // RESET
        // -----------------------------
        #50;
        rst = 0;

        // -----------------------------
        // TEST 1: FCT ONLY
        // -----------------------------
        #20;
        send_fct();

        // -----------------------------
        // TEST 2: SIMPLE PACKET
        // -----------------------------
        #50;
        send_axi_byte(8'hA5, 0);
        send_axi_byte(8'h3C, 0);
        send_axi_byte(8'hF0, 1);

        // -----------------------------
        // TEST 3: BROADCAST
        // -----------------------------
        #50;
        send_bc(8'h55);

        // -----------------------------
        // TEST 4: MIXED TRAFFIC
        // -----------------------------
        #50;
        send_fct();
        send_packet(4);

        #20;
        send_bc(8'hAA);

        #20;
        send_packet(3);

        // -----------------------------
        // TEST 5: BACK-TO-BACK PACKETS
        // -----------------------------
        #50;
        send_packet(5);
        send_packet(2);

        // -----------------------------
        // TEST 6: RANDOM TRAFFIC
        // -----------------------------
        repeat (5) begin
            send_packet($urandom_range(1,5));

            if ($random % 2)
                send_fct();

            if ($random % 2)
                send_bc($random);

            #20;
        end

        // -----------------------------
        // END SIM
        // -----------------------------
        #200;
        $finish;
    end

endmodule