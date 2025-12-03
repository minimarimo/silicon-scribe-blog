module updown_counter_4bit (
    input wire clk,
    input wire reset_n,
    input wire load,
    input wire up_down,  // 1 for up, 0 for down
    input wire [3:0] load_data,
    output reg [3:0] count
);

always @(posedge clk or negedge reset_n) begin
    if (!reset_n) begin
        count <= 4'b0000;
    end else if (load) begin
        count <= load_data;
    end else if (up_down) begin
        count <= count + 1'b1;
    end else begin
        count <= count - 1'b1;
    end
end

endmodule