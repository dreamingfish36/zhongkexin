// version 1.0
/*
Testbench for the AXI4 interface of the 4-bit multiplier
*/

`timescale 1ns/1ps

module Memristor_Infra_Multiplier_4bit_AXI4_tb;

    // Clock period definition
    parameter CLOCK_PERIOD = 10;

    // Clock and Reset
    reg ACLK;
    reg ARESETn;

    // Write Address Channel
    reg [31:0] AWADDR;
    reg [2:0] AWPROT;
    reg AWVALID;
    wire AWREADY;

    // Write Data Channel
    reg [31:0] WDATA;
    reg [3:0] WSTRB;
    reg WVALID;
    wire WREADY;

    // Write Response Channel
    wire [1:0] BRESP;
    wire BVALID;
    reg BREADY;

    // Read Address Channel
    reg [31:0] ARADDR;
    reg [2:0] ARPROT;
    reg ARVALID;
    wire ARREADY;

    // Read Data Channel
    wire [31:0] RDATA;
    wire [1:0] RRESP;
    wire RVALID;
    reg RREADY;

    // Test status
    integer test_status;
    reg [31:0] expected_result;
    reg [31:0] status;
    reg done;

    // Clock generation
    initial begin
        ACLK = 0;
        forever #(CLOCK_PERIOD/2) ACLK = ~ACLK;
    end

    // Instantiate the AXI4 interface module
    Memristor_Infra_Multiplier_4bit_AXI4 uut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .AWADDR(AWADDR),
        .AWPROT(AWPROT),
        .AWVALID(AWVALID),
        .AWREADY(AWREADY),
        .WDATA(WDATA),
        .WSTRB(WSTRB),
        .WVALID(WVALID),
        .WREADY(WREADY),
        .BRESP(BRESP),
        .BVALID(BVALID),
        .BREADY(BREADY),
        .ARADDR(ARADDR),
        .ARPROT(ARPROT),
        .ARVALID(ARVALID),
        .ARREADY(ARREADY),
        .RDATA(RDATA),
        .RRESP(RRESP),
        .RVALID(RVALID),
        .RREADY(RREADY)
    );

    // Task for writing to AXI4 registers
    task write_register;
        input [31:0] addr;
        input [31:0] data;
        begin
            // Set write address
            @(posedge ACLK);
            AWADDR = addr;
            AWVALID = 1;
            WDATA = data;
            WVALID = 1;
            WSTRB = 4'hF;

            // Wait for ready
            while (!AWREADY || !WREADY) @(posedge ACLK);
            @(posedge ACLK);
            
            // Clear write signals
            AWVALID = 0;
            WVALID = 0;
            
            // Handle write response
            BREADY = 1;
            while (!BVALID) @(posedge ACLK);
            @(posedge ACLK);
            BREADY = 0;
        end
    endtask

    // Task for reading from AXI4 registers
    task read_register;
        input [31:0] addr;
        output [31:0] data;
        begin
            // Set read address
            @(posedge ACLK);
            ARADDR = addr;
            ARVALID = 1;
            RREADY = 1;

            // Wait for address ready
            while (!ARREADY) @(posedge ACLK);
            @(posedge ACLK);
            ARVALID = 0;

            // Wait for data valid
            while (!RVALID) @(posedge ACLK);
            data = RDATA;
            @(posedge ACLK);
            RREADY = 0;
        end
    endtask

    // Task for waiting for multiplication completion
    task wait_for_completion;
        begin
            done = 0;
            while (!done) begin
                read_register(8'h04, status); // Read status register
                done = status[0];
                #(CLOCK_PERIOD);
            end
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize test status
        test_status = 0;
        done = 0;

        // Initialize signals
        ARESETn = 1;
        AWADDR = 0;
        AWPROT = 0;
        AWVALID = 0;
        WDATA = 0;
        WSTRB = 0;
        WVALID = 0;
        BREADY = 0;
        ARADDR = 0;
        ARPROT = 0;
        ARVALID = 0;
        RREADY = 0;

        // Reset sequence
        #(CLOCK_PERIOD*2);
        ARESETn = 0;
        #(CLOCK_PERIOD*2);
        ARESETn = 1;
        #(CLOCK_PERIOD*2);

        // Test case 1: 3 * 7 = 21
        $display("Test Case 1: 3 * 7");
        write_register(8'h08, 32'h3);  // Write multiplier
        write_register(8'h0C, 32'h7);  // Write multiplicand
        write_register(8'h00, 32'h1);  // Start multiplication

        wait_for_completion();

        read_register(8'h10, expected_result);
        if (expected_result[7:0] == 8'd21) begin
            $display("Test Case 1 PASSED: 3 * 7 = %d", expected_result[7:0]);
            test_status = test_status + 1;
        end else begin
            $display("Test Case 1 FAILED: Expected 21, got %d", expected_result[7:0]);
        end

        // Test case 2: -3 * 5 = -15
        $display("\nTest Case 2: -3 * 5");
        write_register(8'h08, 32'hFFFFFFFD);  // Write multiplier (-3)
        write_register(8'h0C, 32'h5);         // Write multiplicand
        write_register(8'h00, 32'h1);         // Start multiplication

        wait_for_completion();

        read_register(8'h10, expected_result);
        if ($signed(expected_result[7:0]) == -8'd15) begin
            $display("Test Case 2 PASSED: -3 * 5 = %d", $signed(expected_result[7:0]));
            test_status = test_status + 1;
        end else begin
            $display("Test Case 2 FAILED: Expected -15, got %d", $signed(expected_result[7:0]));
        end

        // Test case 3: -7 * -3 = 21
        $display("\nTest Case 3: -7 * -3");
        write_register(8'h08, 32'hFFFFFFF9);  // Write multiplier (-7)
        write_register(8'h0C, 32'hFFFFFFFD);  // Write multiplicand (-3)
        write_register(8'h00, 32'h1);         // Start multiplication

        wait_for_completion();

        read_register(8'h10, expected_result);
        if (expected_result[7:0] == 8'd21) begin
            $display("Test Case 3 PASSED: -7 * -3 = %d", expected_result[7:0]);
            test_status = test_status + 1;
        end else begin
            $display("Test Case 3 FAILED: Expected 21, got %d", expected_result[7:0]);
        end

        // Final test results
        #(CLOCK_PERIOD*2);
        if (test_status == 3) begin
            $display("\nAll tests PASSED!");
        end else begin
            $display("\nSome tests FAILED! Passed %0d out of 3 tests", test_status);
        end
        
        $finish;
    end

    // Optional: Add waveform dumping
    initial begin
        $dumpfile("axi4_multiplier_test.vcd");
        $dumpvars(0, Memristor_Infra_Multiplier_4bit_AXI4_tb);
    end

endmodule 