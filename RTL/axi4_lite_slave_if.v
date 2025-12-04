`timescale 1ns/1ps

module axi4_lite_slave_if #(
    parameter ADDR_WIDTH = 32,
    parameter DATA_WIDTH = 32
)(
    input  wire                     clk,
    input  wire                     rst_n,
    
    // AXI4-Lite Write Address Channel
    input  wire [ADDR_WIDTH-1:0]    awaddr,
    input  wire [2:0]               awprot,
    input  wire                     awvalid,
    output reg                      awready,
    
    // AXI4-Lite Write Data Channel
    input  wire [DATA_WIDTH-1:0]    wdata,
    input  wire [(DATA_WIDTH/8)-1:0] wstrb,
    input  wire                     wvalid,
    output reg                      wready,
    
    // AXI4-Lite Write Response Channel
    output reg  [1:0]               bresp,
    output reg                      bvalid,
    input  wire                     bready,
    
    // AXI4-Lite Read Address Channel
    input  wire [ADDR_WIDTH-1:0]    araddr,
    input  wire [2:0]               arprot,
    input  wire                     arvalid,
    output reg                      arready,
    
    // AXI4-Lite Read Data Channel
    output reg  [DATA_WIDTH-1:0]    rdata,
    output reg  [1:0]               rresp,
    output reg                      rvalid,
    input  wire                     rready,
    
    // Memory Interface
    output reg  [ADDR_WIDTH-1:0]    mem_addr,
    output reg  [DATA_WIDTH-1:0]    mem_wdata,
    output reg  [(DATA_WIDTH/8)-1:0] mem_wstrb,
    output reg                      mem_wen,
    output reg                      mem_ren,
    input  wire [DATA_WIDTH-1:0]    mem_rdata,
    input  wire                     mem_ready
);

    // State machine states
    localparam IDLE = 2'b00;
    localparam WRITE = 2'b01;
    localparam READ = 2'b10;
    localparam RESP = 2'b11;
    
    reg [1:0] state, next_state;
    reg [ADDR_WIDTH-1:0] addr_reg;
    reg write_pending, read_pending;
    
    // State machine
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end
    
    // Next state logic
    always @(*) begin
        next_state = state;
        case (state)
            IDLE: begin
                if (awvalid && wvalid) begin
                    next_state = WRITE;
                end else if (arvalid) begin
                    next_state = READ;
                end
            end
            WRITE: begin
                if (mem_ready) begin
                    next_state = RESP;
                end
            end
            READ: begin
                if (mem_ready && rready) begin
                    next_state = IDLE;
                end
            end
            RESP: begin
                if (bready) begin
                    next_state = IDLE;
                end
            end
        endcase
    end
    
    // Address capture
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            addr_reg <= 0;
        end else begin
            if (state == IDLE && awvalid && wvalid) begin
                addr_reg <= awaddr;
            end else if (state == IDLE && arvalid) begin
                addr_reg <= araddr;
            end
        end
    end
    
    // Write channel ready signals
    always @(*) begin
        awready = (state == IDLE) && wvalid;
        wready = (state == IDLE) && awvalid;
    end
    
    // Read address ready
    always @(*) begin
        arready = (state == IDLE) && !awvalid && !wvalid;
    end
    
    // Write response channel
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            bvalid <= 1'b0;
            bresp <= 2'b00;
        end else begin
            if (state == WRITE && mem_ready) begin
                bvalid <= 1'b1;
                bresp <= 2'b00; // OKAY
            end else if (bvalid && bready) begin
                bvalid <= 1'b0;
            end
        end
    end
    
    // Read data channel
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rvalid <= 1'b0;
            rdata <= 0;
            rresp <= 2'b00;
        end else begin
            if (state == READ && mem_ready) begin
                rvalid <= 1'b1;
                rdata <= mem_rdata;
                rresp <= 2'b00; // OKAY
            end else if (rvalid && rready) begin
                rvalid <= 1'b0;
            end
        end
    end
    
    // Memory interface
    always @(*) begin
        mem_addr = addr_reg;
        mem_wdata = wdata;
        mem_wstrb = wstrb;
        mem_wen = (state == WRITE);
        mem_ren = (state == READ);
    end

endmodule