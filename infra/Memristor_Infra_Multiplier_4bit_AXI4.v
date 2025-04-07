// version 1.0
/*
This module implements an AXI4 interface for the 4-bit multiplier
*/

module Memristor_Infra_Multiplier_4bit_AXI4 (
    // Clock and Reset
    input wire ACLK,
    input wire ARESETn,

    // Write Address Channel
    input wire [31:0] AWADDR,
    input wire [2:0] AWPROT,
    input wire AWVALID,
    output wire AWREADY,

    // Write Data Channel
    input wire [31:0] WDATA,
    input wire [3:0] WSTRB,
    input wire WVALID,
    output wire WREADY,

    // Write Response Channel
    output wire [1:0] BRESP,
    output wire BVALID,
    input wire BREADY,

    // Read Address Channel
    input wire [31:0] ARADDR,
    input wire [2:0] ARPROT,
    input wire ARVALID,
    output wire ARREADY,

    // Read Data Channel
    output wire [31:0] RDATA,
    output wire [1:0] RRESP,
    output wire RVALID,
    input wire RREADY
);

    // Internal registers
    reg [31:0] control_reg;      // Control register
    reg [31:0] status_reg;       // Status register
    reg [31:0] multiplier_reg;   // Multiplier register
    reg [31:0] multiplicand_reg; // Multiplicand register
    reg [31:0] result_reg;       // Result register

    // Internal signals
    wire start;
    wire done;
    wire signed [7:0] result;

    // AXI4 write state machine
    reg write_state;
    reg write_done;
    localparam WRITE_IDLE = 1'b0;
    localparam WRITE_DATA = 1'b1;

    // AXI4 read state machine
    reg read_state;
    reg read_done;
    localparam READ_IDLE = 1'b0;
    localparam READ_DATA = 1'b1;

    // AXI4 handshake signals
    reg awready_reg;
    reg wready_reg;
    reg [1:0] bresp_reg;
    reg bvalid_reg;
    reg arready_reg;
    reg [31:0] rdata_reg;
    reg [1:0] rresp_reg;
    reg rvalid_reg;

    // Address mapping
    localparam ADDR_CONTROL = 8'h00;
    localparam ADDR_STATUS = 8'h04;
    localparam ADDR_MULTIPLIER = 8'h08;
    localparam ADDR_MULTIPLICAND = 8'h0C;
    localparam ADDR_RESULT = 8'h10;

    // Control register bits
    localparam CTRL_START = 0;
    localparam CTRL_RESET = 1;

    // Status register bits
    localparam STAT_DONE = 0;

    // Initial values
    initial begin
        control_reg = 32'h0;
        status_reg = 32'h0;
        multiplier_reg = 32'h0;
        multiplicand_reg = 32'h0;
        result_reg = 32'h0;
        write_state = WRITE_IDLE;
        write_done = 1'b0;
        read_state = READ_IDLE;
        read_done = 1'b0;
        awready_reg = 1'b1;
        wready_reg = 1'b1;
        bresp_reg = 2'b00;
        bvalid_reg = 1'b0;
        arready_reg = 1'b1;
        rdata_reg = 32'h0;
        rresp_reg = 2'b00;
        rvalid_reg = 1'b0;
    end

    // Instantiate the multiplier
    Memristor_Infra_multiplier_4bit multiplier_inst (
        .clk(ACLK),
        .rst(~ARESETn),
        .start(start),
        .multiplier(multiplier_reg[3:0]),
        .multiplicand(multiplicand_reg[3:0]),
        .result(result),
        .done(done)
    );

    // Control signals
    assign start = control_reg[CTRL_START];

    // Status register update
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            status_reg <= 32'h0;
        end else begin
            status_reg[STAT_DONE] <= done;
        end
    end

    // AXI4 Write Channel Logic
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            write_state <= WRITE_IDLE;
            write_done <= 1'b0;
            control_reg <= 32'h0;
            multiplier_reg <= 32'h0;
            multiplicand_reg <= 32'h0;
            awready_reg <= 1'b1;
            wready_reg <= 1'b1;
            bvalid_reg <= 1'b0;
            bresp_reg <= 2'b00;
        end else begin
            case (write_state)
                WRITE_IDLE: begin
                    if (AWVALID && WVALID) begin
                        write_state <= WRITE_DATA;
                        awready_reg <= 1'b0;
                        wready_reg <= 1'b0;
                        bvalid_reg <= 1'b1;
                        case (AWADDR[7:0])
                            ADDR_CONTROL: control_reg <= WDATA;
                            ADDR_MULTIPLIER: multiplier_reg <= WDATA;
                            ADDR_MULTIPLICAND: multiplicand_reg <= WDATA;
                            default: begin end
                        endcase
                    end
                end
                WRITE_DATA: begin
                    if (BREADY) begin
                        write_state <= WRITE_IDLE;
                        write_done <= 1'b1;
                        awready_reg <= 1'b1;
                        wready_reg <= 1'b1;
                        bvalid_reg <= 1'b0;
                    end
                end
            endcase
        end
    end

    // AXI4 Read Channel Logic
    always @(posedge ACLK or negedge ARESETn) begin
        if (!ARESETn) begin
            read_state <= READ_IDLE;
            read_done <= 1'b0;
            arready_reg <= 1'b1;
            rvalid_reg <= 1'b0;
            rresp_reg <= 2'b00;
            rdata_reg <= 32'h0;
        end else begin
            case (read_state)
                READ_IDLE: begin
                    if (ARVALID) begin
                        read_state <= READ_DATA;
                        arready_reg <= 1'b0;
                        rvalid_reg <= 1'b1;
                        case (ARADDR[7:0])
                            ADDR_CONTROL: rdata_reg <= control_reg;
                            ADDR_STATUS: rdata_reg <= status_reg;
                            ADDR_MULTIPLIER: rdata_reg <= multiplier_reg;
                            ADDR_MULTIPLICAND: rdata_reg <= multiplicand_reg;
                            ADDR_RESULT: rdata_reg <= {24'h0, result};
                            default: rdata_reg <= 32'h0;
                        endcase
                    end
                end
                READ_DATA: begin
                    if (RREADY) begin
                        read_state <= READ_IDLE;
                        read_done <= 1'b1;
                        arready_reg <= 1'b1;
                        rvalid_reg <= 1'b0;
                    end
                end
            endcase
        end
    end

    // Connect output signals
    assign AWREADY = awready_reg;
    assign WREADY = wready_reg;
    assign BRESP = bresp_reg;
    assign BVALID = bvalid_reg;
    assign ARREADY = arready_reg;
    assign RDATA = rdata_reg;
    assign RRESP = rresp_reg;
    assign RVALID = rvalid_reg;

endmodule 