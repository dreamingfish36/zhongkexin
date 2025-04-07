// TPU AXI4 Interface Testbench
// Version 1.0

`timescale 1ns/1ps

module tpu_axi4_interface_tb;

    // Clock period definition
    parameter CLOCK_PERIOD = 10;

    // Clock and Reset
    reg ACLK;
    reg ARESETn;

    // AXI4 Slave Interface Signals
    reg [31:0] S_AXI_AWADDR;
    reg [7:0] S_AXI_AWLEN;
    reg [2:0] S_AXI_AWSIZE;
    reg [1:0] S_AXI_AWBURST;
    reg S_AXI_AWVALID;
    wire S_AXI_AWREADY;
    reg [31:0] S_AXI_WDATA;
    reg [3:0] S_AXI_WSTRB;
    reg S_AXI_WLAST;
    reg S_AXI_WVALID;
    wire S_AXI_WREADY;
    wire [1:0] S_AXI_BRESP;
    wire S_AXI_BVALID;
    reg S_AXI_BREADY;
    reg [31:0] S_AXI_ARADDR;
    reg [7:0] S_AXI_ARLEN;
    reg [2:0] S_AXI_ARSIZE;
    reg [1:0] S_AXI_ARBURST;
    reg S_AXI_ARVALID;
    wire S_AXI_ARREADY;
    wire [31:0] S_AXI_RDATA;
    wire [1:0] S_AXI_RRESP;
    wire S_AXI_RLAST;
    wire S_AXI_RVALID;
    reg S_AXI_RREADY;

    // AXI4 Master Interface Signals
    wire [31:0] M_AXI_AWADDR;
    wire [7:0] M_AXI_AWLEN;
    wire [2:0] M_AXI_AWSIZE;
    wire [1:0] M_AXI_AWBURST;
    wire M_AXI_AWVALID;
    reg M_AXI_AWREADY;
    wire [31:0] M_AXI_WDATA;
    wire [3:0] M_AXI_WSTRB;
    wire M_AXI_WLAST;
    wire M_AXI_WVALID;
    reg M_AXI_WREADY;
    reg [1:0] M_AXI_BRESP;
    reg M_AXI_BVALID;
    wire M_AXI_BREADY;

    // APB Interface Signals
    reg PSEL;
    reg PENABLE;
    reg PWRITE;
    reg [31:0] PADDR;
    reg [31:0] PWDATA;
    wire [31:0] PRDATA;
    wire PREADY;

    // TPU Control Signals
    wire tpu_start;
    reg tpu_done;
    wire [31:0] matrix_size;
    wire [31:0] operation_type;

    // Test variables
    integer test_status;
    reg [31:0] expected_data;
    reg [31:0] read_data;

    // Clock generation
    initial begin
        ACLK = 0;
        forever #(CLOCK_PERIOD/2) ACLK = ~ACLK;
    end

    // Instantiate the DUT
    tpu_axi4_interface dut (
        .ACLK(ACLK),
        .ARESETn(ARESETn),
        .S_AXI_AWADDR(S_AXI_AWADDR),
        .S_AXI_AWLEN(S_AXI_AWLEN),
        .S_AXI_AWSIZE(S_AXI_AWSIZE),
        .S_AXI_AWBURST(S_AXI_AWBURST),
        .S_AXI_AWVALID(S_AXI_AWVALID),
        .S_AXI_AWREADY(S_AXI_AWREADY),
        .S_AXI_WDATA(S_AXI_WDATA),
        .S_AXI_WSTRB(S_AXI_WSTRB),
        .S_AXI_WLAST(S_AXI_WLAST),
        .S_AXI_WVALID(S_AXI_WVALID),
        .S_AXI_WREADY(S_AXI_WREADY),
        .S_AXI_BRESP(S_AXI_BRESP),
        .S_AXI_BVALID(S_AXI_BVALID),
        .S_AXI_BREADY(S_AXI_BREADY),
        .S_AXI_ARADDR(S_AXI_ARADDR),
        .S_AXI_ARLEN(S_AXI_ARLEN),
        .S_AXI_ARSIZE(S_AXI_ARSIZE),
        .S_AXI_ARBURST(S_AXI_ARBURST),
        .S_AXI_ARVALID(S_AXI_ARVALID),
        .S_AXI_ARREADY(S_AXI_ARREADY),
        .S_AXI_RDATA(S_AXI_RDATA),
        .S_AXI_RRESP(S_AXI_RRESP),
        .S_AXI_RLAST(S_AXI_RLAST),
        .S_AXI_RVALID(S_AXI_RVALID),
        .S_AXI_RREADY(S_AXI_RREADY),
        .M_AXI_AWADDR(M_AXI_AWADDR),
        .M_AXI_AWLEN(M_AXI_AWLEN),
        .M_AXI_AWSIZE(M_AXI_AWSIZE),
        .M_AXI_AWBURST(M_AXI_AWBURST),
        .M_AXI_AWVALID(M_AXI_AWVALID),
        .M_AXI_AWREADY(M_AXI_AWREADY),
        .M_AXI_WDATA(M_AXI_WDATA),
        .M_AXI_WSTRB(M_AXI_WSTRB),
        .M_AXI_WLAST(M_AXI_WLAST),
        .M_AXI_WVALID(M_AXI_WVALID),
        .M_AXI_WREADY(M_AXI_WREADY),
        .M_AXI_BRESP(M_AXI_BRESP),
        .M_AXI_BVALID(M_AXI_BVALID),
        .M_AXI_BREADY(M_AXI_BREADY),
        .PSEL(PSEL),
        .PENABLE(PENABLE),
        .PWRITE(PWRITE),
        .PADDR(PADDR),
        .PWDATA(PWDATA),
        .PRDATA(PRDATA),
        .PREADY(PREADY),
        .tpu_start(tpu_start),
        .tpu_done(tpu_done),
        .matrix_size(matrix_size),
        .operation_type(operation_type)
    );

    // Task for writing to AXI4 registers
    task write_axi4;
        input [31:0] addr;
        input [31:0] data;
        begin
            // Set write address
            @(posedge ACLK);
            S_AXI_AWADDR = addr;
            S_AXI_AWVALID = 1;
            S_AXI_WDATA = data;
            S_AXI_WVALID = 1;
            S_AXI_WSTRB = 4'hF;
            S_AXI_WLAST = 1;

            // Wait for ready
            while (!S_AXI_AWREADY || !S_AXI_WREADY) @(posedge ACLK);
            @(posedge ACLK);
            
            // Clear write signals
            S_AXI_AWVALID = 0;
            S_AXI_WVALID = 0;
            S_AXI_WLAST = 0;
            
            // Handle write response
            S_AXI_BREADY = 1;
            while (!S_AXI_BVALID) @(posedge ACLK);
            @(posedge ACLK);
            S_AXI_BREADY = 0;
        end
    endtask

    // Task for reading from AXI4 registers
    task read_axi4;
        input [31:0] addr;
        output [31:0] data;
        begin
            // Set read address
            @(posedge ACLK);
            S_AXI_ARADDR = addr;
            S_AXI_ARVALID = 1;
            S_AXI_RREADY = 1;

            // Wait for address ready
            while (!S_AXI_ARREADY) @(posedge ACLK);
            @(posedge ACLK);
            S_AXI_ARVALID = 0;

            // Wait for data valid
            while (!S_AXI_RVALID) @(posedge ACLK);
            data = S_AXI_RDATA;
            @(posedge ACLK);
            S_AXI_RREADY = 0;
        end
    endtask

    // Task for APB write
    task write_apb;
        input [31:0] addr;
        input [31:0] data;
        begin
            @(posedge ACLK);
            PSEL = 1;
            PWRITE = 1;
            PADDR = addr;
            PWDATA = data;
            @(posedge ACLK);
            PENABLE = 1;
            while (!PREADY) @(posedge ACLK);
            @(posedge ACLK);
            PSEL = 0;
            PENABLE = 0;
        end
    endtask

    // Task for APB read
    task read_apb;
        input [31:0] addr;
        output [31:0] data;
        begin
            @(posedge ACLK);
            PSEL = 1;
            PWRITE = 0;
            PADDR = addr;
            @(posedge ACLK);
            PENABLE = 1;
            while (!PREADY) @(posedge ACLK);
            data = PRDATA;
            @(posedge ACLK);
            PSEL = 0;
            PENABLE = 0;
        end
    endtask

    // Test stimulus
    initial begin
        // Initialize test status
        test_status = 0;

        // Initialize signals
        ARESETn = 1;
        S_AXI_AWADDR = 0;
        S_AXI_AWLEN = 0;
        S_AXI_AWSIZE = 0;
        S_AXI_AWBURST = 0;
        S_AXI_AWVALID = 0;
        S_AXI_WDATA = 0;
        S_AXI_WSTRB = 0;
        S_AXI_WLAST = 0;
        S_AXI_WVALID = 0;
        S_AXI_BREADY = 0;
        S_AXI_ARADDR = 0;
        S_AXI_ARLEN = 0;
        S_AXI_ARSIZE = 0;
        S_AXI_ARBURST = 0;
        S_AXI_ARVALID = 0;
        S_AXI_RREADY = 0;
        M_AXI_AWREADY = 1;
        M_AXI_WREADY = 1;
        M_AXI_BVALID = 1;
        M_AXI_BRESP = 2'b00;
        PSEL = 0;
        PENABLE = 0;
        PWRITE = 0;
        PADDR = 0;
        PWDATA = 0;
        tpu_done = 0;

        // Reset sequence
        #(CLOCK_PERIOD*2);
        ARESETn = 0;
        #(CLOCK_PERIOD*2);
        ARESETn = 1;
        #(CLOCK_PERIOD*2);

        // Test Case 1: Configure TPU through APB
        $display("Test Case 1: TPU Configuration");
        write_apb(8'h00, 32'd16);  // Set matrix size to 16
        write_apb(8'h04, 32'd1);   // Set operation type to matrix multiplication
        write_apb(8'h08, 32'd1);   // Start TPU

        // Test Case 2: Write Matrix A through AXI4
        $display("\nTest Case 2: Writing Matrix A");
        write_axi4(32'h000, 32'h1);
        write_axi4(32'h004, 32'h2);
        write_axi4(32'h008, 32'h3);
        write_axi4(32'h00C, 32'h4);

        // Test Case 3: Write Matrix B through AXI4
        $display("\nTest Case 3: Writing Matrix B");
        write_axi4(32'h400, 32'h5);
        write_axi4(32'h404, 32'h6);
        write_axi4(32'h408, 32'h7);
        write_axi4(32'h40C, 32'h8);

        // Test Case 4: Read Matrix A through AXI4
        $display("\nTest Case 4: Reading Matrix A");
        read_axi4(32'h000, read_data);
        if (read_data == 32'h1) begin
            $display("Matrix A[0] PASSED: Expected 1, got %h", read_data);
            test_status = test_status + 1;
        end else begin
            $display("Matrix A[0] FAILED: Expected 1, got %h", read_data);
        end

        // Test Case 5: Read Matrix B through AXI4
        $display("\nTest Case 5: Reading Matrix B");
        read_axi4(32'h400, read_data);
        if (read_data == 32'h5) begin
            $display("Matrix B[0] PASSED: Expected 5, got %h", read_data);
            test_status = test_status + 1;
        end else begin
            $display("Matrix B[0] FAILED: Expected 5, got %h", read_data);
        end

        // Test Case 6: Matrix Operation Completion
        $display("\nTest Case 6: Matrix Operation");
        #(CLOCK_PERIOD*10);
        tpu_done = 1;
        #(CLOCK_PERIOD*2);
        tpu_done = 0;

        // Final test results
        #(CLOCK_PERIOD*2);
        if (test_status == 2) begin
            $display("\nAll tests PASSED!");
        end else begin
            $display("\nSome tests FAILED! Passed %0d out of 2 tests", test_status);
        end
        
        $finish;
    end

    // Optional: Add waveform dumping
    initial begin
        $dumpfile("tpu_axi4_interface_test.vcd");
        $dumpvars(0, tpu_axi4_interface_tb);
    end

endmodule 