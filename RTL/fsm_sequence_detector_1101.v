module fsm_sequence_detector_1101 (
    input wire clk,
    input wire reset,
    input wire data_in,
    output reg detected
);

    // State encoding
    parameter IDLE = 3'b000;
    parameter S1   = 3'b001;  // detected first '1'
    parameter S11  = 3'b010;  // detected '11'
    parameter S110 = 3'b011;  // detected '110'

    reg [2:0] current_state, next_state;

    // State register
    always @(posedge clk or posedge reset) begin
        if (reset)
            current_state <= IDLE;
        else
            current_state <= next_state;
    end

    // Next state logic
    always @(*) begin
        case (current_state)
            IDLE: begin
                if (data_in == 1'b1)
                    next_state = S1;
                else
                    next_state = IDLE;
            end
            
            S1: begin
                if (data_in == 1'b1)
                    next_state = S11;
                else
                    next_state = IDLE;
            end
            
            S11: begin
                if (data_in == 1'b0)
                    next_state = S110;
                else
                    next_state = S11;  // stay in S11 for consecutive 1s
            end
            
            S110: begin
                if (data_in == 1'b1)
                    next_state = S1;   // sequence detected, start looking for new sequence
                else
                    next_state = IDLE;
            end
            
            default: next_state = IDLE;
        endcase
    end

    // Output logic - detect when we complete the sequence
    always @(posedge clk or posedge reset) begin
        if (reset)
            detected <= 1'b0;
        else if (current_state == S110 && data_in == 1'b1)
            detected <= 1'b1;
        else
            detected <= 1'b0;
    end

endmodule