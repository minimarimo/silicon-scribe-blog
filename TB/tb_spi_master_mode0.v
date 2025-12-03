module tb_spi_master_mode0;

    reg clk;
    reg rst_n;
    reg start;
    reg [7:0] tx_data;
    wire [7:0] rx_data;
    wire busy;
    wire done;
    wire sclk;
    wire mosi;
    reg miso;
    wire cs_n;
    
    // Test variables
    reg [7:0] expected_rx_data;
    reg [7:0] test_miso_data;
    integer bit_counter;
    reg test_passed;
    reg prev_sclk;
    
    // Instantiate the SPI master
    spi_master_mode0 uut (
        .clk(clk),
        .rst_n(rst_n),
        .start(start),
        .tx_data(tx_data),
        .rx_data(rx_data),
        .busy(busy),
        .done(done),
        .sclk(sclk),
        .mosi(mosi),
        .miso(miso),
        .cs_n(cs_n)
    );
    
    // Clock generation
    always #5 clk = ~clk;
    
    // MISO data simulation (slave response)
    always @(posedge clk) begin
        prev_sclk <= sclk;
        
        if (cs_n) begin
            bit_counter <= 0;
            miso <= 1'b0;
        end else if (!prev_sclk && sclk) begin // Rising edge of sclk
            miso <= test_miso_data[7 - bit_counter];
            if (bit_counter < 7)
                bit_counter <= bit_counter + 1;
        end
    end
    
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 0;
        start = 0;
        tx_data = 8'h00;
        miso = 0;
        test_passed = 1;
        bit_counter = 0;
        prev_sclk = 0;
        
        // Reset sequence
        #20;
        rst_n = 1;
        #20;
        
        // Test Case 1: Basic SPI transaction
        tx_data = 8'hA5;
        test_miso_data = 8'h3C;
        expected_rx_data = 8'h3C;
        
        start = 1;
        #10;
        start = 0;
        
        // Wait for transaction to complete
        wait(done);
        #10;
        
        if (rx_data !== expected_rx_data) begin
            test_passed = 0;
        end
        
        #100;
        
        // Test Case 2: Different data pattern
        tx_data = 8'h55;
        test_miso_data = 8'hAA;
        expected_rx_data = 8'hAA;
        
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        #10;
        
        if (rx_data !== expected_rx_data) begin
            test_passed = 0;
        end
        
        #100;
        
        // Test Case 3: All zeros
        tx_data = 8'h00;
        test_miso_data = 8'h00;
        expected_rx_data = 8'h00;
        
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        #10;
        
        if (rx_data !== expected_rx_data) begin
            test_passed = 0;
        end
        
        #100;
        
        // Test Case 4: All ones
        tx_data = 8'hFF;
        test_miso_data = 8'hFF;
        expected_rx_data = 8'hFF;
        
        start = 1;
        #10;
        start = 0;
        
        wait(done);
        #10;
        
        if (rx_data !== expected_rx_data) begin
            test_passed = 0;
        end
        
        #100;
        
        // Final result
        if (test_passed) begin
            $display("TEST PASSED");
        end else begin
            $display("TEST FAILED");
        end
        
        $finish;
    end

endmodule