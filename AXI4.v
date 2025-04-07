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




module axi_slave_module#
	(
		parameter                                   C_S_AXI_ID_WIDTH	    = 1,
		parameter                                   C_S_AXI_DATA_WIDTH	    = 32,
		parameter                                   C_S_AXI_ADDR_WIDTH	    = 6,
		parameter                                   C_S_AXI_AWUSER_WIDTH	= 0,
		parameter                                   C_S_AXI_ARUSER_WIDTH	= 0,
		parameter                                   C_S_AXI_WUSER_WIDTH	    = 0,
		parameter                                   C_S_AXI_RUSER_WIDTH	    = 0,
		parameter                                   C_S_AXI_BUSER_WIDTH	    = 0
	)
	(
		input wire                                  S_AXI_ACLK      ,
		input wire                                  S_AXI_ARESETN   ,

		input wire [C_S_AXI_ID_WIDTH-1 : 0]         S_AXI_AWID      ,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0]       S_AXI_AWADDR    ,
		input wire [7 : 0]                          S_AXI_AWLEN     ,
		input wire [2 : 0]                          S_AXI_AWSIZE    ,
		input wire [1 : 0]                          S_AXI_AWBURST   ,
		input wire                                  S_AXI_AWLOCK    ,
		input wire [3 : 0]                          S_AXI_AWCACHE   ,
		input wire [2 : 0]                          S_AXI_AWPROT    ,
		input wire [3 : 0]                          S_AXI_AWQOS     ,
		input wire [3 : 0]                          S_AXI_AWREGION  ,
		input wire [C_S_AXI_AWUSER_WIDTH-1 : 0]     S_AXI_AWUSER    ,
		input wire                                  S_AXI_AWVALID   ,
		output wire                                 S_AXI_AWREADY   ,

		input wire [C_S_AXI_DATA_WIDTH-1 : 0]       S_AXI_WDATA     ,
		input wire [(C_S_AXI_DATA_WIDTH/8)-1 : 0]   S_AXI_WSTRB     ,
		input wire                                  S_AXI_WLAST     ,
		input wire [C_S_AXI_WUSER_WIDTH-1 : 0]      S_AXI_WUSER     ,
		input wire                                  S_AXI_WVALID    ,
		output wire                                 S_AXI_WREADY    ,

		output wire [C_S_AXI_ID_WIDTH-1 : 0]        S_AXI_BID       ,
		output wire [1 : 0]                         S_AXI_BRESP     ,
		output wire [C_S_AXI_BUSER_WIDTH-1 : 0]     S_AXI_BUSER     ,
		output wire                                 S_AXI_BVALID    ,
		input wire                                  S_AXI_BREADY    ,

		input wire [C_S_AXI_ID_WIDTH-1 : 0]         S_AXI_ARID      ,
		input wire [C_S_AXI_ADDR_WIDTH-1 : 0]       S_AXI_ARADDR    ,
		input wire [7 : 0]                          S_AXI_ARLEN     ,
		input wire [2 : 0]                          S_AXI_ARSIZE    ,
		input wire [1 : 0]                          S_AXI_ARBURST   ,
		input wire                                  S_AXI_ARLOCK    ,
		input wire [3 : 0]                          S_AXI_ARCACHE   ,
		input wire [2 : 0]                          S_AXI_ARPROT    ,
		input wire [3 : 0]                          S_AXI_ARQOS     ,
		input wire [3 : 0]                          S_AXI_ARREGION  ,
		input wire [C_S_AXI_ARUSER_WIDTH-1 : 0]     S_AXI_ARUSER    ,
		input wire                                  S_AXI_ARVALID   ,
		output wire                                 S_AXI_ARREADY   ,

		output wire [C_S_AXI_ID_WIDTH-1 : 0]        S_AXI_RID       ,
		output wire [C_S_AXI_DATA_WIDTH-1 : 0]      S_AXI_RDATA     ,
		output wire [1 : 0]                         S_AXI_RRESP     ,
		output wire                                 S_AXI_RLAST     ,
		output wire [C_S_AXI_RUSER_WIDTH-1 : 0]     S_AXI_RUSER     ,
		output wire                                 S_AXI_RVALID    ,
		input wire                                  S_AXI_RREADY    
);
/******************************************************************/
//计算二进制位宽
    function integer clogb2(input integer number);
    begin
    for(clogb2 = 0 ; number > 0 ; clogb2 = clogb2 + 1 )
        number = number >> 1;
    end
endfunction



/*******************************参数*******************************/
// 基础AXI参数
parameter AXI_DATA_WIDTH  = 64;    // AXI数据位宽
parameter AXI_ADDR_WIDTH  = 32;    // AXI地址位宽
parameter AXI_ID_WIDTH    = 4;     // AXI ID位宽
parameter BURST_LEN       = 8;     // 默认突发长度

// 矩阵专用参数
parameter MAX_ROWS        = 1024;  // 最大行数
parameter MAX_COLS        = 1024;  // 最大列数
parameter ELEM_WIDTH      = 32;    // 矩阵元素位宽

// 状态编码
parameter ST_IDLE         = 3'd0;
parameter ST_READ_ADDR    = 3'd1;
parameter ST_READ_DATA    = 3'd2;
parameter ST_WRITE_ADDR   = 3'd3;
parameter ST_WRITE_DATA   = 3'd4;
parameter ST_USER_MODE    = 3'd5;  // 扩展模式预留

// 地址模式
parameter LINEAR_MODE     = 1'b0;
parameter TILED_MODE      = 1'b1;
/******************************状态机******************************/
// 状态定义
localparam IDLE = 0;
localparam READ_ADDR = 1;


// 状态寄存器
reg [2:0] state;
reg [2:0] next_state;

// 状态转移逻辑
// 主状态寄存器
reg [2:0] current_state;
reg [2:0] next_state;

// 矩阵行列计数器
reg [15:0] row_cnt;
reg [15:0] col_cnt;

// 状态转移逻辑
always @(*) begin
    case(current_state)
        ST_IDLE: 
            next_state = (start_op) ? 
                (op_type ? ST_WRITE_ADDR : ST_READ_ADDR) : ST_IDLE;
                
        ST_READ_ADDR:
            next_state = (axi_arready) ? ST_READ_DATA : ST_READ_ADDR;
            
        ST_READ_DATA:
            next_state = (axi_rlast) ? 
                ((row_cnt == rows-1) ? ST_IDLE : ST_READ_ADDR) : ST_READ_DATA;
        
        // ...其他状态转移...
        
        ST_USER_MODE:  // 用户扩展状态
            next_state = user_next_state;
    endcase
end


/*************************************寄存器*********************/
reg  [C_M_AXI_ADDR_WIDTH - 1 : 0] r_m_axi_awaddr        ;
reg                               r_m_axi_awvalid       ;
reg  [C_M_AXI_DATA_WIDTH - 1 : 0] r_m_axi_wdata         ;
reg                               r_m_axi_wlast         ;
reg                               r_m_axi_wvalid        ;
reg  [C_M_AXI_ADDR_WIDTH - 1 : 0] r_m_axi_araddr        ;
reg                               r_m_axi_arvalid       ;
reg                               r_m_axi_rready        ;
reg                               r_write_start         ;
reg                               r_read_start          ;
reg [7:0]                         r_burst_cnt           ;
reg [C_M_AXI_DATA_WIDTH - 1 : 0]  r_axi_read_data       ;

// 寄存器写入逻辑
always @(posedge clk) begin
    if (axi_awready && axi_wready) begin
        case (axi_awaddr[7:0])
            REG_CTRL: reg_ctrl <= s_axi_wdata;
        endcase
    end
end

/***********************************网表型***********************/
wire   w_system_rst                                     ;
wire   w_write_last                                     ;
// AXI接口连接
assign M_AXI_AWADDR  = base_addr + addr_offset;
assign M_AXI_ARADDR  = base_addr + addr_offset;
assign M_AXI_WDATA   = fifo_out_data;

// 矩阵接口连接
assign matrix_data   = (data_layout == 2'b00) ? axi_data[ELEM_WIDTH-1:0] : 
                       {axi_data[2*ELEM_WIDTH-1:ELEM_WIDTH], axi_data[ELEM_WIDTH-1:0]};

// 用户扩展接口
assign user_status   = {operation_done, error_flag, user_reg[0][15:0]};

/*************************组合逻辑*************************/
assign M_AXI_AWID    = 'd0                              ;
assign M_AXI_AWLEN   =  C_M_AXI_BURST_LEN               ;
assign M_AXI_AWSIZE  =  clogb2(C_M_AXI_DATA_WIDTH/8 -1) ;
assign M_AXI_AWBURST =  2'b01                           ;
assign M_AXI_AWLOCK  =  'd0                             ;
assign M_AXI_AWCACHE =  4'b0010                         ;
assign M_AXI_AWPROT  =  'd0                             ;
assign M_AXI_AWQOS   =  'd0                             ;
assign M_AXI_AWUSER  =  'd0                             ;
assign M_AXI_AWADDR  = r_m_axi_awaddr + C_M_TARGET_SLAVE_BASE_ADDR ;
assign M_AXI_AWVALID = r_m_axi_awvalid                  ;

assign M_AXI_WSTRB   = {C_M_AXI_DATA_WIDTH{1'b1}}       ;
assign M_AXI_WUSER   = 'd0                              ;
assign M_AXI_WDATA   = r_m_axi_wdata                    ; 

assign M_AXI_WLAST   = (C_M_AXI_BURST_LEN == 1) ? w_write_last : r_m_axi_wlast ; 

assign M_AXI_WVALID  = r_m_axi_wvalid                   ;

assign M_AXI_BREADY  = 1'b1                             ; 

assign M_AXI_ARID    = 'd0                              ;
assign M_AXI_ARADDR  = r_m_axi_araddr + C_M_TARGET_SLAVE_BASE_ADDR;
assign M_AXI_ARLEN   = C_M_AXI_BURST_LEN                ;
assign M_AXI_ARSIZE  = clogb2(C_M_AXI_DATA_WIDTH/8 -1)  ;
assign M_AXI_ARBURST = 2'b01                            ;
assign M_AXI_ARLOCK  = 'd0                              ;
assign M_AXI_ARCACHE = 4'b0010                          ;
assign M_AXI_ARPROT  = 'd0                              ;
assign M_AXI_ARQOS   = 'd0                              ;
assign M_AXI_ARUSER  = 'd0                              ;
assign M_AXI_ARVALID = r_m_axi_arvalid                  ;

assign M_AXI_RREADY  = r_m_axi_rready                   ;

assign w_system_rst  = ~M_AXI_ARESETN                   ;
assign w_write_last  = M_AXI_WVALID && M_AXI_WREADY     ;

// 地址生成逻辑
always @(*) begin
    if (data_layout == LINEAR_MODE) begin
        addr_offset = (row_cnt * stride + col_cnt) * (AXI_DATA_WIDTH/8);
    end else begin // TILED_MODE
        addr_offset = ((row_cnt/8)*stride + (col_cnt/8)*64 + 
                      (row_cnt%8)*8 + col_cnt%8) * (AXI_DATA_WIDTH/8);
    end
end

// 突发长度计算
assign burst_len = (cols - col_cnt > BURST_LEN) ? BURST_LEN : cols - col_cnt;

// 数据有效信号
assign data_valid = (current_state == ST_READ_DATA) && axi_rvalid;

/**********************进程***************************/
always@(posedge M_AXI_ACLK)
    if(w_system_rst ||M_AXI_AWVALID && M_AXI_AWREADY)
        r_m_axi_awvalid <= 'd0;
    else if(r_write_start)
        r_m_axi_awvalid <= 'd1; 
    else 
        r_m_axi_awvalid <= r_m_axi_awvalid;

always@(posedge M_AXI_ACLK)
    if(r_write_start)
        r_m_axi_awaddr <= 'd0;
    else 
        r_m_axi_awaddr <= 'd0;

always@(posedge M_AXI_ACLK)
    if(w_system_rst ||M_AXI_WLAST )
        r_m_axi_wvalid <= 'd0;
    else if(M_AXI_AWVALID && M_AXI_AWREADY)
        r_m_axi_wvalid <= 'd1;
    else 
        r_m_axi_wvalid <= r_m_axi_wvalid;

always@(posedge M_AXI_ACLK)
    if(w_system_rst || M_AXI_WLAST)
        r_m_axi_wdata <= 'd1;
    else if(M_AXI_WVALID && M_AXI_WREADY)
        r_m_axi_wdata <= r_m_axi_wdata + 1;
    else 
        r_m_axi_wdata <= r_m_axi_wdata;

always@(posedge M_AXI_ACLK)
    //burst len > 2
    if(C_M_AXI_BURST_LEN == 1)
        r_m_axi_wlast <= 0;
    else if(C_M_AXI_BURST_LEN == 2 && (M_AXI_WVALID && M_AXI_WREADY && !r_m_axi_wlast))
        r_m_axi_wlast <= M_AXI_WVALID  & M_AXI_WREADY;
    else if(C_M_AXI_BURST_LEN > 2 && r_burst_cnt == C_M_AXI_BURST_LEN - 2)
        r_m_axi_wlast <= 'd1;
    else
        r_m_axi_wlast <= 'd0;

always@(posedge M_AXI_ACLK)
    if(w_system_rst || M_AXI_WLAST)
        r_burst_cnt <= 'd0;
    else if(M_AXI_WVALID && M_AXI_WREADY)
        r_burst_cnt <= r_burst_cnt + 1;
    else
        r_burst_cnt <= r_burst_cnt;

/*---------------------------------------------------*/
always@(posedge M_AXI_ACLK)
    if(w_system_rst || (M_AXI_ARVALID && M_AXI_ARREADY))
        r_m_axi_arvalid <= 'd0;
    else if(r_read_start)
        r_m_axi_arvalid <= 'd1;
    else
        r_m_axi_arvalid <= r_m_axi_arvalid;
    

always@(posedge M_AXI_ACLK)
    if(r_read_start)
        r_m_axi_araddr <= 'd0;
    else
        r_m_axi_araddr <= 'd0;
    
always@(posedge M_AXI_ACLK)
    if(w_system_rst || M_AXI_RLAST)
        r_m_axi_rready <= 'd0;
    else if(M_AXI_ARVALID && M_AXI_ARREADY)
        r_m_axi_rready <= 'd1;
    else
        r_m_axi_rready <= r_m_axi_rready;

always@(posedge M_AXI_ACLK)
    if(M_AXI_RVALID && M_AXI_RREADY)
        r_axi_read_data <= M_AXI_RDATA;
    else
        r_axi_read_data <= r_axi_read_data;

/*--------------------------------*/
always@(posedge M_AXI_ACLK)
    if(w_system_rst)
        r_st_current_write <= P_ST_IDLE         ;
    else 
        r_st_current_write <= r_st_next_write   ;

always@(*)
    case(r_st_current_write)
        P_ST_IDLE        : r_st_next_write = P_ST_WRITE_START ;
        P_ST_WRITE_START : r_st_next_write = r_write_start ? P_ST_WRITE_TRANS : P_ST_WRITE_START ;
        P_ST_WRITE_TRANS : r_st_next_write = M_AXI_WLAST   ? P_ST_WRITE_END   : P_ST_WRITE_TRANS ;
        P_ST_WRITE_END   : r_st_next_write = (r_st_current_read == P_ST_READ_END) ? P_ST_IDLE : P_ST_WRITE_END;
        default          : r_st_next_write = P_ST_IDLE ;
    endcase
    
always@(posedge M_AXI_ACLK)
    if(r_st_current_write == P_ST_WRITE_START)
        r_write_start <= 'd1;
    else 
        r_write_start <= 'd0;

/*--------------------------------*/
always@(posedge M_AXI_ACLK)
    if(w_system_rst)
        r_st_current_read <= P_ST_IDLE         ;
    else 
        r_st_current_read <= r_st_next_read   ;

always@(*)
    case(r_st_current_read)
        P_ST_IDLE        : r_st_next_read = (r_st_current_write == P_ST_WRITE_END) ? P_ST_READ_START  : P_ST_IDLE;
        P_ST_READ_START  : r_st_next_read = r_read_start ? P_ST_READ_TRANS : P_ST_READ_START;
        P_ST_READ_TRANS  : r_st_next_read = M_AXI_RLAST  ? P_ST_READ_END   : P_ST_READ_TRANS ;
        P_ST_READ_END    : r_st_next_read = P_ST_IDLE ;
        default          : r_st_next_read = P_ST_IDLE ;
    endcase

always@(posedge M_AXI_ACLK)
    if(r_st_current_read == P_ST_READ_START)
        r_read_start <= 'd1;
    else 
        r_read_start <= 'd0;
    

endmodule