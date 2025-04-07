// TPU AXI4 Interface Module
// Version 1.0
   // AXI4-Full Master Interface for Matrix Output
module tpu_axi4_interface (
    parameter C_M_TARGET_SLAVE_BASE_ADDR = 32'h40000000,
    parameter integer C_M_AXI_DATA_WIDTH = 32,
    parameter integer C_M_AXI_ADDR_WIDTH = 32,
    parameter integer C_M_AXI_BURST_LEN = 16,
    parameter integer C_M_AXI_ID_WIDTH = 1,
    parameter integer C_M_AXI_AWUSER =0,
    parameter integer C_M_AXI_AWUSER_WIDTH = 0,
    parameter integer C_M_AXI_ARUSER_WIDTH = 0,
    parameter integer C_M_AXI_WUSER_WIDTH = 0,
    parameter integer C_M_AXI_RUSER_WIDTH = 0,
    parameter integer C_M_AXI_BUSER_WIDTH = 0,
    parameter MAX_MATRIX_SIZE = 16,  //最大支持16*16
    // Clock and Reset


)( 
    input wire ACLK,
    input wire ARESETn,  
    
    // Write Address Channel
    output wire [C_M_AXI_ID_WIDTH-1 : 0]            M_AXI_AWID,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0]          M_AXI_AWADDR,
    output wire [7:0]                               M_AXI_AWLEN,
    output wire [2:0]                               M_AXI_AWSIZE,
    output wire [1:0]                               M_AXI_AWBURST,
    output wire                                     M_AXI_AWLOCK,
    output wire [3:0]                               M_AXI_AWCACHE,
    output wire [2:0]                               M_AXI_AWPORT,
    output wire [3:0]                               M_AXI_AWQOS,
    output wire [C_M_AWUSER_WIDTH/8-1 : 0]          M_AXI_AWUSER
    output wire                                     M_AXI_AWVALID,
    input wire                                      M_AXI_AWREADY,
    
    // Write Data Channel
    output wire [C_M_AXI_DATA_WIDTH-1 : 0]          M_AXI_WDATE,
    output wire [C_M_AXI_DATA_WIDTH/8-1 : 0]        M_AXI_WSTRB,
    output wire M_AXI_WLAST,
    output wire [C_M_AXI_WUSER_WIDTH-1 : 0]         M_AXI_WUSER,
    output wire                                     M_AXI_WVALID,
    input wire                                      M_AXI_WREADY,

    // Write Response Channel
    input wire [C_M_AXI_ID_WIDTH-1 : 0]             M_AXI_BID,
    input wrie [1 : 0]                              M_AXI_BRESP
    input wire [C_M_AXI_BUSER_WIDTH-1 : 0]          M_AXI_BUSER,
    input wire                                      M_AXI_BVALID,
    output wire                                     M_AXI_BVALID,

    
    // Read Address Channel
    output wire [C_M_AXI_ID_WIDTH-1 : 0]            M_AXI_ARID,
    output wire [C_M_AXI_ADDR_WIDTH-1 : 0]          M_AXI_ARADDR,
    output wire [7:0]                               M_AXI_ARLEN,
    output wire [2:0]                               M_AXI_ARSIZE,
    output wire [1 : 0]                             M_AXI_ARBURST,
    output wire                                     M_AXI_ARLOCK,
    output wire [3:0]                               M_AXI_ARCACHE,
    output wire [2:0]                               M_AXI_ARPORT,
    output wire [3:0]                               M_AXI_ARQOS,
    output wire [C_M_AXI_ARUSER_WIDTH-1:0]          M_AXI_USER,
    output wire                                     M_AXI_ARVALID,
    input wire                                      M_AXI_ARREADY,

    
    // Read Data Channel
    input wire [C_M_AXI_ID_WIDTH-1:0]               M_AXI_RID,
    input wire [C_M_AXI_DATA_WIDTH-1:0]             M_AXI_RDATA,
    input wire [1:0]                                M_AXI_RRESP,
    input wire                                      M_AXI_RLAST,
    input wire [C_M_AXI_RUSER_WIDTH-1:0]            M_AXI_RUSER,
    input wire                                      M_AXI_RVALID,
    output wire                                     M_AXI_RREADY,
);
/******************************************************************/


    
    
    
    
    // AXI4-Full Slave Interface for Matrix Input
    // Write Address Channel
    output wire [31:0] M_AXI_AWADDR,
    output wire [7:0] M_AXI_AWLEN,
    output wire [2:0] M_AXI_AWSIZE,
    output wire [1:0] M_AXI_AWBURST,
    output wire M_AXI_AWVALID,
    input wire M_AXI_AWREADY,

    
    // Write Data Channel
    output wire [31:0] M_AXI_WDATA,
    output wire [3:0] M_AXI_WSTRB,
    output wire M_AXI_WLAST,
    output wire M_AXI_WVALID,
    input wire M_AXI_WREADY,
    
    // Write Response Channel
    input wire [1:0] M_AXI_BRESP,
    input wire M_AXI_BVALID,
    output wire M_AXI_BREADY,
    
    // APB Interface for Configuration
    input wire PSEL,
    input wire PENABLE,
    input wire PWRITE,
    input wire [31:0] PADDR,
    input wire [31:0] PWDATA,
    output wire [31:0] PRDATA,
    output wire PREADY,
    
    // TPU Control Signals
    output wire tpu_start,
    input wire tpu_done,
    output wire [31:0] matrix_size,
    output wire [31:0] operation_type
);

    // Internal Registers
    reg [31:0] matrix_a_addr;
    reg [31:0] matrix_b_addr;
    reg [31:0] matrix_c_addr;
    reg [31:0] matrix_size_reg;
    reg [31:0] operation_type_reg;
    reg tpu_start_reg;
    
    // Matrix Buffer Registers
    reg [31:0] matrix_a_buffer [0:1023];  // 4KB buffer for matrix A
    reg [31:0] matrix_b_buffer [0:1023];  // 4KB buffer for matrix B
    reg [31:0] matrix_c_buffer [0:1023];  // 4KB buffer for matrix C
    
    // AXI4 Slave State Machine
    localparam IDLE = 3'b000;
    localparam WRITE_ADDR = 3'b001;
    localparam WRITE_DATA = 3'b010;
    localparam WRITE_RESP = 3'b011;
    localparam READ_ADDR = 3'b100;
    localparam READ_DATA = 3'b101;
    
    reg [2:0] slave_state;
    reg [2:0] next_slave_state;
    
    // AXI4 Master State Machine
    localparam M_IDLE = 3'b000;
    localparam M_WRITE_ADDR = 3'b001;
    localparam M_WRITE_DATA = 3'b010;
    localparam M_WRITE_RESP = 3'b011;
    
    reg [2:0] master_state;
    reg [2:0] next_master_state;
    
    // APB State Machine
    localparam P_IDLE = 2'b00;
    localparam P_SETUP = 2'b01;
    localparam P_ACCESS = 2'b10;
    
    reg [1:0] apb_state;
    reg [1:0] next_apb_state;
    
    // Counter for burst transfers
    reg [7:0] burst_counter;
    reg [7:0] next_burst_counter;
    
    // AXI4 Slave Interface Logic
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            slave_state <= IDLE;
            S_AXI_AWREADY <= 1'b0;
            S_AXI_WREADY <= 1'b0;
            S_AXI_BVALID <= 1'b0;
            S_AXI_ARREADY <= 1'b0;
            S_AXI_RVALID <= 1'b0;
            S_AXI_RLAST <= 1'b0;
            burst_counter <= 8'd0;
        end else begin
            case (slave_state)
                IDLE: begin
                    if (S_AXI_AWVALID) begin
                        slave_state <= WRITE_ADDR;
                        S_AXI_AWREADY <= 1'b1;
                    end else if (S_AXI_ARVALID) begin
                        slave_state <= READ_ADDR;
                        S_AXI_ARREADY <= 1'b1;
                    end
                end
                
                WRITE_ADDR: begin
                    S_AXI_AWREADY <= 1'b0;
                    if (S_AXI_WVALID) begin
                        slave_state <= WRITE_DATA;
                        S_AXI_WREADY <= 1'b1;
                    end
                end
                
                WRITE_DATA: begin
                    if (S_AXI_WLAST) begin
                        S_AXI_WREADY <= 1'b0;
                        slave_state <= WRITE_RESP;
                        S_AXI_BVALID <= 1'b1;
                    end
                end
                
                WRITE_RESP: begin
                    if (S_AXI_BREADY) begin
                        S_AXI_BVALID <= 1'b0;
                        slave_state <= IDLE;
                    end
                end
                
                READ_ADDR: begin
                    S_AXI_ARREADY <= 1'b0;
                    slave_state <= READ_DATA;
                    S_AXI_RVALID <= 1'b1;
                end
                
                READ_DATA: begin
                    if (S_AXI_RREADY) begin
                        if (burst_counter == S_AXI_ARLEN) begin
                            S_AXI_RLAST <= 1'b1;
                            slave_state <= IDLE;
                        end else begin
                            burst_counter <= burst_counter + 1;
                        end
                    end
                end
            endcase
        end
    end
    
    // AXI4 Master Interface Logic
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            master_state <= M_IDLE;
            M_AXI_AWVALID <= 1'b0;
            M_AXI_WVALID <= 1'b0;
            M_AXI_BREADY <= 1'b0;
            burst_counter <= 8'd0;
        end else begin
            case (master_state)
                M_IDLE: begin
                    if (tpu_done) begin
                        master_state <= M_WRITE_ADDR;
                        M_AXI_AWVALID <= 1'b1;
                    end
                end
                
                M_WRITE_ADDR: begin
                    if (M_AXI_AWREADY) begin
                        M_AXI_AWVALID <= 1'b0;
                        master_state <= M_WRITE_DATA;
                        M_AXI_WVALID <= 1'b1;
                    end
                end
                
                M_WRITE_DATA: begin
                    if (M_AXI_WREADY) begin
                        if (burst_counter == matrix_size_reg) begin
                            M_AXI_WLAST <= 1'b1;
                            master_state <= M_WRITE_RESP;
                            M_AXI_BREADY <= 1'b1;
                        end else begin
                            burst_counter <= burst_counter + 1;
                        end
                    end
                end
                
                M_WRITE_RESP: begin
                    if (M_AXI_BVALID) begin
                        M_AXI_BREADY <= 1'b0;
                        master_state <= M_IDLE;
                    end
                end
            endcase
        end
    end
    
    // APB Interface Logic
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            apb_state <= P_IDLE;
            PREADY <= 1'b0;
            matrix_size_reg <= 32'd0;
            operation_type_reg <= 32'd0;
            tpu_start_reg <= 1'b0;
        end else begin
            case (apb_state)
                P_IDLE: begin
                    if (PSEL && !PENABLE) begin
                        apb_state <= P_SETUP;
                    end
                end
                
                P_SETUP: begin
                    if (PSEL && PENABLE) begin
                        apb_state <= P_ACCESS;
                        if (PWRITE) begin
                            case (PADDR[7:0])
                                8'h00: matrix_size_reg <= PWDATA;
                                8'h04: operation_type_reg <= PWDATA;
                                8'h08: tpu_start_reg <= PWDATA[0];
                            endcase
                        end
                        PREADY <= 1'b1;
                    end
                end
                
                P_ACCESS: begin
                    PREADY <= 1'b0;
                    apb_state <= P_IDLE;
                end
            endcase
        end
    end
    
    // Output Assignments
    assign tpu_start = tpu_start_reg;
    assign matrix_size = matrix_size_reg;
    assign operation_type = operation_type_reg;
    
    // Data Path Logic
    always @(posedge ACLK) begin
        if (S_AXI_WVALID && S_AXI_WREADY) begin
            case (S_AXI_AWADDR[11:0])
                12'h000: matrix_a_buffer[S_AXI_AWADDR[11:2]] <= S_AXI_WDATA;
                12'h400: matrix_b_buffer[S_AXI_AWADDR[11:2]] <= S_AXI_WDATA;
                12'h800: matrix_c_buffer[S_AXI_AWADDR[11:2]] <= S_AXI_WDATA;
            endcase
        end
    end
    
    // Read Data Assignment
    always @(posedge ACLK) begin
        if (S_AXI_ARVALID && S_AXI_ARREADY) begin
            case (S_AXI_ARADDR[11:0])
                12'h000: S_AXI_RDATA <= matrix_a_buffer[S_AXI_ARADDR[11:2]];
                12'h400: S_AXI_RDATA <= matrix_b_buffer[S_AXI_ARADDR[11:2]];
                12'h800: S_AXI_RDATA <= matrix_c_buffer[S_AXI_ARADDR[11:2]];
            endcase
        end
    end
    
    // Write Data Assignment
    always @(posedge ACLK) begin
        if (M_AXI_WVALID && M_AXI_WREADY) begin
            M_AXI_WDATA <= matrix_c_buffer[burst_counter];
        end
    end

endmodule 