module tb_updown_counter_4bit;

reg clk;
reg reset_n;
reg load;
reg up_down;
reg [3:0] load_data;
wire [3:0] count;

// Instantiate the counter
updown_counter_4bit uut (
    .clk(clk),
    .reset_n(reset_n),
    .load(load),
    .up_down(up_down),
    .load_data(load_data),
    .count(count)
);

// Clock generation
initial begin
    clk = 0;
    forever #5 clk = ~clk;
end

// Test sequence
initial begin
    // Initialize signals
    reset_n = 0;
    load = 0;
    up_down = 1;
    load_data = 4'b0000;
    
    // Wait for reset to take effect
    @(posedge clk);
    @(posedge clk);
    
    // Release reset
    reset_n = 1;
    
    // Test reset functionality
    if (count !== 4'b0000) begin
        $display("TEST FAILED");
        $finish;
    end
    
    // Test up counting
    up_down = 1;
    @(posedge clk);
    if (count !== 4'b0001) begin
        $display("TEST FAILED");
        $finish;
    end
    
    @(posedge clk);
    if (count !== 4'b0010) begin
        $display("TEST FAILED");
        $finish;
    end
    
    @(posedge clk);
    if (count !== 4'b0011) begin
        $display("TEST FAILED");
        $finish;
    end
    
    // Test load functionality
    load_data = 4'b1010;
    load = 1;
    @(posedge clk);
    if (count !== 4'b1010) begin
        $display("TEST FAILED");
        $finish;
    end
    
    load = 0;
    @(posedge clk);
    if (count !== 4'b1011) begin
        $display("TEST FAILED");
        $finish;
    end
    
    // Test down counting
    up_down = 0;
    @(posedge clk);
    if (count !== 4'b1010) begin
        $display("TEST FAILED");
        $finish;
    end
    
    @(posedge clk);
    if (count !== 4'b1001) begin
        $display("TEST FAILED");
        $finish;
    end
    
    // Test overflow (up counting from 15)
    load_data = 4'b1111;
    load = 1;
    up_down = 1;
    @(posedge clk);
    load = 0;
    @(posedge clk);
    if (count !== 4'b0000) begin
        $display("TEST FAILED");
        $finish;
    end
    
    // Test underflow (down counting from 0)
    load_data = 4'b0000;
    load = 1;
    up_down = 0;
    @(posedge clk);
    load = 0;
    @(posedge clk);
    if (count !== 4'b1111) begin
        $display("TEST FAILED");
        $finish;
    end
    
    // Test reset during operation
    reset_n = 0;
    @(posedge clk);
    if (count !== 4'b0000) begin
        $display("TEST FAILED");
        $finish;
    end
    
    $display("TEST PASSED");
    $finish;
end

endmodule