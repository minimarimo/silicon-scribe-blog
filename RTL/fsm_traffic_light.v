module traffic_light_controller (
    input wire clk,
    input wire reset,
    input wire emergency,
    output reg [1:0] ns_light,  // North-South: 00=Red, 01=Yellow, 10=Green
    output reg [1:0] ew_light   // East-West: 00=Red, 01=Yellow, 10=Green
);

    // State encoding
    parameter NS_GREEN = 3'b000;
    parameter NS_YELLOW = 3'b001;
    parameter EW_GREEN = 3'b010;
    parameter EW_YELLOW = 3'b011;
    parameter EMERGENCY = 3'b100;

    // Light encoding
    parameter RED = 2'b00;
    parameter YELLOW = 2'b01;
    parameter GREEN = 2'b10;

    // Timer parameters (in clock cycles)
    parameter GREEN_TIME = 8;
    parameter YELLOW_TIME = 2;
    parameter EMERGENCY_TIME = 4;

    reg [2:0] current_state;
    reg [3:0] timer;

    // State register and timer
    always @(posedge clk or posedge reset) begin
        if (reset) begin
            current_state <= NS_GREEN;
            timer <= 0;
        end else begin
            // Emergency has highest priority
            if (emergency && current_state != EMERGENCY) begin
                current_state <= EMERGENCY;
                timer <= 0;
            end else begin
                case (current_state)
                    NS_GREEN: begin
                        if (timer >= GREEN_TIME - 1) begin
                            current_state <= NS_YELLOW;
                            timer <= 0;
                        end else begin
                            timer <= timer + 1;
                        end
                    end
                    
                    NS_YELLOW: begin
                        if (timer >= YELLOW_TIME - 1) begin
                            current_state <= EW_GREEN;
                            timer <= 0;
                        end else begin
                            timer <= timer + 1;
                        end
                    end
                    
                    EW_GREEN: begin
                        if (timer >= GREEN_TIME - 1) begin
                            current_state <= EW_YELLOW;
                            timer <= 0;
                        end else begin
                            timer <= timer + 1;
                        end
                    end
                    
                    EW_YELLOW: begin
                        if (timer >= YELLOW_TIME - 1) begin
                            current_state <= NS_GREEN;
                            timer <= 0;
                        end else begin
                            timer <= timer + 1;
                        end
                    end
                    
                    EMERGENCY: begin
                        if (timer >= EMERGENCY_TIME - 1 && !emergency) begin
                            current_state <= NS_GREEN;
                            timer <= 0;
                        end else begin
                            timer <= timer + 1;
                        end
                    end
                    
                    default: begin
                        current_state <= NS_GREEN;
                        timer <= 0;
                    end
                endcase
            end
        end
    end

    // Output logic
    always @(*) begin
        case (current_state)
            NS_GREEN: begin
                ns_light = GREEN;
                ew_light = RED;
            end
            
            NS_YELLOW: begin
                ns_light = YELLOW;
                ew_light = RED;
            end
            
            EW_GREEN: begin
                ns_light = RED;
                ew_light = GREEN;
            end
            
            EW_YELLOW: begin
                ns_light = RED;
                ew_light = YELLOW;
            end
            
            EMERGENCY: begin
                ns_light = RED;
                ew_light = RED;
            end
            
            default: begin
                ns_light = RED;
                ew_light = RED;
            end
        endcase
    end

endmodule