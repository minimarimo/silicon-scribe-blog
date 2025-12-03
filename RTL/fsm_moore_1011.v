module sequence_detector_1011 (
    input wire clk,
    input wire reset,
    input wire data_in,
    output reg detected
);

    // State encoding
    parameter IDLE = 3'b000;
    parameter S1   = 3'b001;  // detected '1'
    parameter S10  = 3'b010;  // detected '10'
    parameter S101 = 3'b011;  // detected '101'
    parameter S1011= 3'b100;  // detected '1011'

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
                if (data_in)
                    next_state = S1;
                else
                    next_state = IDLE;
            end
            
            S1: begin
                if (data_in)
                    next_state = S1;  // stay in S1 for consecutive 1s
                else
                    next_state = S10;
            end
            
            S10: begin
                if (data_in)
                    next_state = S101;
                else
                    next_state = IDLE;
            end
            
            S101: begin
                if (data_in)
                    next_state = S1011;
                else
                    next_state = S10;  // Go to S10 for overlapping sequences
            end
            
            S1011: begin
                if (data_in)
                    next_state = S1;  // restart looking for sequence
                else
                    next_state = S10; // Go to S10 for overlapping sequences
            end
            
            default: next_state = IDLE;
        endcase
    end

    // Output logic (Moore FSM - output depends only on current state)
    always @(*) begin
        case (current_state)
            S1011: detected = 1'b1;
            default: detected = 1'b0;
        endcase
    end

endmodule