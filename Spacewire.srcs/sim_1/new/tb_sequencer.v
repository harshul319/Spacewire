`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 21.03.2026 18:57:55
// Design Name: 
// Module Name: tb_sequencer
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


`timescale 1ns / 1ps

module tb_sequencer;

    reg clk;
    reg rst;
    reg serial_busy;

    reg SEND_FCT;
    reg SEND_BC;

    reg tx_allowed;
    reg [8:0] fifo_data;
    reg [7:0] broadcast_code;
    reg fifo_empty;

    wire load;
    wire [2:0] char_type;
    wire [7:0] data_byte;

    // DUT
    Sequencer dut (
        .clk(clk),
        .rst(rst),
        .serial_busy(serial_busy),
        .SEND_FCT(SEND_FCT),
        .SEND_BC(SEND_BC),
        .tx_allowed(tx_allowed),
        .fifo_data(fifo_data),
        .broadcast_code(broadcast_code),
        .fifo_empty(fifo_empty),
        .load(load),
        .char_type(char_type),
        .data_byte(data_byte)
    );

    // Clock (10ns period)
    always #5 clk = ~clk;

    // ---------------------------------------
    // Serializer model (very simple)
    // ---------------------------------------
    reg [3:0] busy_counter;

    always @(posedge clk) begin
        if (rst) begin
            serial_busy <= 0;
            busy_counter <= 0;
        end else begin
            if (load && !serial_busy) begin
                serial_busy <= 1;
                busy_counter <= 3;   // pretend 3 cycles per char
            end
            else if (serial_busy) begin
                if (busy_counter == 0)
                    serial_busy <= 0;
                else
                    busy_counter <= busy_counter - 1;
            end
        end
    end

    // ---------------------------------------
    // Test sequence
    // ---------------------------------------
    initial begin
        clk = 0;
        rst = 1;

        SEND_FCT = 0;
        SEND_BC  = 0;

        tx_allowed = 0;
        fifo_empty = 1;
        fifo_data  = 9'd0;
        broadcast_code = 8'hA5;

        #20;
        rst = 0;

        // Let NULL start (ESC will be sent first)
        #20;

        // 🔥 KEY EVENT:
        // Immediately after ESC is sent (while busy),
        // trigger broadcast
        @(posedge clk);
        SEND_BC = 1;

        @(posedge clk);
        SEND_BC = 0;

        // Run for some cycles
        #200;

        $finish;
    end

    // ---------------------------------------
    // Monitor
    // ---------------------------------------
    initial begin
        $display("Time\tState\tLoad\tCharType\tData");
        $monitor("%0t\t%b\t%b\t%0d\t\t%0h",
            $time,
            dut.state,
            load,
            char_type,
            data_byte
        );
    end

endmodule
