module Sequencer(
    input clk,
    input rst,
    input serial_busy,

    input SEND_FCT,
    input SEND_BC,

    input tx_allowed,
    input [8:0] fifo_data,
    input [7:0] broadcast_code,
    input fifo_empty,

    output reg load,
    output reg [2:0] char_type,
    output reg [7:0] data_byte,
    output reg data_sent,
    output reg read_en
);

    // ---------------------------------------
    // Character Types
    // ---------------------------------------
    localparam DATA = 3'd0;
    localparam FCT  = 3'd1;
    localparam EOP  = 3'd2;
    localparam EEP  = 3'd3;
    localparam ESC  = 3'd4;

    // ---------------------------------------
    // FSM States
    // ---------------------------------------
    localparam S_NULL_ESC = 3'd0;
    localparam S_NULL_FCT = 3'd1;
    localparam S_DATA     = 3'd2;
    localparam S_EOP      = 3'd3;
    localparam S_FCT      = 3'd4;
    localparam S_BC_ESC   = 3'd5;
    localparam S_BC_DATA  = 3'd6;

    reg [2:0] state;
    reg [2:0] next_state;
    // ---------------------------------------
    // Internal registers
    // ---------------------------------------
    reg [7:0] FCT_pending;
    reg       BC_pending;
    reg       eop_pending;
    reg       state_req;


    // ---------------------------------------
    // Pending accumulation
    // ---------------------------------------
    always @(posedge clk) begin
        if (rst) begin
            FCT_pending <= 0;
            BC_pending  <= 0;
        end else begin
            if (SEND_FCT) 
                FCT_pending <= FCT_pending + 1;
                
            else if ((!serial_busy) & load & (char_type==FCT))
                FCT_pending <= 0;
                
            if (SEND_BC)
                BC_pending <= 1;
        end
    end

    // ---------------------------------------
    // MAIN FSM 
    // ---------------------------------------
    always @(*) begin

    case (state)

        // -------------------------
        S_NULL_ESC: begin
            next_state = S_NULL_FCT;
        end

        // -------------------------
        S_NULL_FCT: begin
            if (BC_pending > 0)
                next_state = S_BC_ESC;
            else if (FCT_pending > 0)
                next_state = S_FCT;
            else if (eop_pending)
                next_state = S_EOP;
            else if (!fifo_empty && tx_allowed)
                next_state = S_DATA;
            else
                next_state = S_NULL_ESC;
        end

        // -------------------------
        S_DATA: begin
            if (BC_pending > 0)
                next_state = S_BC_ESC;
            else if (FCT_pending > 0)
                next_state = S_FCT;
            else if (eop_pending)
                next_state = S_EOP;
            else if (!fifo_empty && tx_allowed)
                next_state = S_DATA;
            else
                next_state = S_NULL_ESC;
        end

        // -------------------------
        S_EOP: begin
            if (BC_pending > 0)
                next_state = S_BC_ESC;
            else if (FCT_pending > 0)
                next_state = S_FCT;
            else if (!fifo_empty && tx_allowed)
                next_state = S_DATA;
            else
                next_state = S_NULL_ESC;
        end

        // -------------------------
        S_FCT: begin
            if (BC_pending > 0)
                next_state = S_BC_ESC;
            else if (FCT_pending > 1)
                next_state = S_FCT;
            else if (eop_pending)
                next_state = S_EOP;
            else if (!fifo_empty && tx_allowed)
                next_state = S_DATA;
            else
                next_state = S_NULL_ESC;
        end

        // -------------------------
        S_BC_ESC: begin
            next_state = S_BC_DATA;
        end

        // -------------------------
        S_BC_DATA: begin
            if (BC_pending > 1)
                next_state = S_BC_ESC;
            else if (FCT_pending > 0)
                next_state = S_FCT;
            else if (eop_pending)
                next_state = S_EOP;
            else if (!fifo_empty && tx_allowed)
                next_state = S_DATA;
            else
                next_state = S_NULL_ESC;
        end

        // -------------------------
        default: begin
            next_state = S_NULL_ESC;
        end

    endcase
    end
    
    // ---------------------------------------
    // TRANSITION 
    // ---------------------------------------
    
    always @(posedge clk) begin
        if (rst) begin
            state <= S_NULL_ESC;
            next_state <= S_NULL_FCT;
            state_req <= 0;
            load <= 0;
            end
        else if(state_req && serial_busy)
            state <= next_state; 
            state_req <= 0;  
    end
    
    // ---------------------------------------
    // OUTPUT 
    // ---------------------------------------
    always @(posedge clk) begin 
        if(rst) begin
            char_type <= 1'b0;
            data_byte <= 1'b0;
            data_sent <= 1'b0;
            read_en   <= 1'b0;
            state_req <= 1'b0;
        end
        else begin
            data_sent <= 1'b0;
            read_en <= 1'b0;
            load <= 1'b0;

            if (!serial_busy) begin
                
                load <= 1'b1;
                state_req <= 1'b1;
                case (state)

                // -------------------------
                    S_NULL_ESC: begin
                        char_type <= ESC;
                    end

                // -------------------------
                    S_NULL_FCT: begin
                        char_type <= FCT;
                    end

                // -------------------------
                    S_DATA: begin
                        char_type <= DATA;
                        data_byte <= fifo_data[7:0];
                        data_sent <= 1'b1;
                        read_en   <= 1'b1;
                    end

                // -------------------------
                    S_EOP: begin
                        char_type <= EOP;
                    end

                // -------------------------
                   S_FCT: begin
                       char_type <= FCT;
                   end

                // -------------------------
                  S_BC_ESC: begin
                      char_type <= ESC;
                  end

                // -------------------------
                  S_BC_DATA: begin
                      char_type <= DATA;
                      data_byte <= broadcast_code;
                      BC_pending <= 0;
                  end
                  
                endcase
            end
        end
    end

endmodule