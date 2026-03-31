module Sequencer(
    input clk,
    input rst,
    input serial_busy,

    input SEND_BC,

    input tx_allowed,
    input [8:0] fifo_data,
    input [7:0] broadcast_code,
    input fifo_empty,
    input [7:0] FCT_pending,

    output reg load,
    output reg [2:0] char_type,
    output reg [7:0] data_byte,
    output reg data_sent,
    output reg rd_en,
    output reg FCT_sent
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
    reg       BC_pending;
    reg       eop_pending;
    reg       state_req;
    reg       data_sent_next;
    reg       FCT_sent_next;


    // ---------------------------------------
    // Pending BC accumulation
    // ---------------------------------------
    always @(posedge clk) begin
        if (rst) 
            BC_pending  <= 1'b0;
        else begin
            if (SEND_BC)
                    BC_pending <= 1'b1;
                    
            else if (state == S_BC_DATA)
                BC_pending <= 1'b0;
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
            next_state = S_NULL_FCT;
        end

    endcase
    end
    
    // ---------------------------------------
    // TRANSITION 
    // ---------------------------------------
    
    always @(posedge clk) begin
        if (rst) begin
            state <= S_NULL_ESC;
            state_req <= 1'b0;
            end
            
        else if(state_req && serial_busy) begin
            state <= next_state; 
            state_req <= 1'b0;  
        end
        
        else if(!serial_busy) begin
            state_req <= 1'b1;  
        end
        
    end
    
    // ---------------------------------------
    // OUTPUT 
    // ---------------------------------------
    always @(posedge clk) begin 
        if(rst) begin
            char_type <= ESC;
            data_byte <= 1'b0;
            data_sent <= 1'b0;
            FCT_sent <= 1'b0;
            FCT_sent_next <= 1'b0;
            data_sent_next <= 1'b0;        
            rd_en   <= 1'b0;
            eop_pending <= 1'b0;
            load <= 1'b0;
        end
        else begin
            data_sent <= 1'b0;
            FCT_sent <= 1'b0;
            FCT_sent_next <= 1'b0;
            data_sent_next <= 1'b0;
            rd_en <= 1'b0;
            load <= 1'b0;

            if (!serial_busy) begin
                
                load <= 1'b1;
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
                        eop_pending <= fifo_data[8];
                        data_sent_next <= 1'b1;
                        data_sent <= data_sent_next;
                        rd_en   <= data_sent_next;
                    end

                // -------------------------
                    S_EOP: begin
                        char_type <= EOP;
                        eop_pending <= 1'b0;
                    end

                // -------------------------
                   S_FCT: begin
                       char_type <= FCT;
                        FCT_sent_next <= 1'b1;
                        FCT_sent <= FCT_sent_next;                    
                   end

                // -------------------------
                  S_BC_ESC: begin
                      char_type <= ESC;
                  end

                // -------------------------
                  S_BC_DATA: begin
                      char_type <= DATA;
                      data_byte <= broadcast_code;
                  end
                  
                endcase
            end
        end
    end

endmodule