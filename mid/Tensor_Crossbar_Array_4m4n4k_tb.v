//Version 1.0

/*
这是Tensor_Crossbar_Array_4m4n4k的testbench
测试4x4x4的张量计算单元
测试用例：简单的矩阵数据加载和输出
*/

/*
Example:

     2 -3  5  6               3 -2  1 -5             25  15 -19  11
    -1  4 -7  3       *      -6  4 -7  2     =      -74  43 -50  55
     6 -5  1 -2               5 -1  0 -3             61 -45  55 -57
    -7  7 -4  0              -4  6 -7  7            -83  46 -56  61

     25  15 -19  11           5 -4  4 -5             30  11 -15  6
    -74  43 -50  55    +     -5  3 -3  3     =      -79  46 -53  58
     61 -45  55 -57           4 -3  4 -4             65 -48  59 -61
    -83  46 -56  61          -5  3 -4  4            -88  49 -60  65



    0010  1101  0101  0110          0011  1110  0001  1011          0101  1100  0100  1011
    1111  0100  1001  0011          1010  0100  1001  0010          1011  0011  1101  0011
    0110  1011  0001  1110          0101  1111  0000  1101          0100  1101  0100  1100
    1001  0111  1100  0000          1100  0110  1001  0111          1011  0011  1100  0100

    2F69  D4B7  591C  63E0          3A5C  E4F6  1909  B2D7          5B4B  C3D3  4D4C  B3C4
                                    3E1B  A492  5F0D  C697          5C4B  B3D3  4D4C  B3C4


*/



`timescale 1ns/1ns

module Tensor_Crossbar_Array_4m4n4k_tb;

    parameter cycle = 2;

    // Testbench signals
    reg clk;
    reg rst;
    reg start;

    reg [15:0] cin_M_0, cin_M_1, cin_M_2, cin_M_3;
    reg [15:0] cin_N_0, cin_N_1, cin_N_2, cin_N_3;
    reg [15:0] cin_K_0, cin_K_1, cin_K_2, cin_K_3;

    wire [15:0] data_out_col_0;
    wire [15:0] data_out_col_1;
    wire [15:0] data_out_col_2;
    wire [15:0] data_out_col_3;


// Instantiate the tensor crossbar module
Tensor_Crossbar_Array_4m4n4k uut (
    .clk(clk),
    .rst(rst),
    .start(start),
    .cin_M_0(cin_M_0),
    .cin_M_1(cin_M_1),
    .cin_M_2(cin_M_2),
    .cin_M_3(cin_M_3),
    .cin_N_0(cin_N_0),
    .cin_N_1(cin_N_1),
    .cin_N_2(cin_N_2),
    .cin_N_3(cin_N_3),
    .cin_K_0(cin_K_0),
    .cin_K_1(cin_K_1),
    .cin_K_2(cin_K_2),
    .cin_K_3(cin_K_3),
    .data_out_col_0(data_out_col_0),
    .data_out_col_1(data_out_col_1),
    .data_out_col_2(data_out_col_2),
    .data_out_col_3(data_out_col_3)
);


// Initialize the signals
initial begin
    cin_M_0 <= 0; cin_M_1 <= 0; cin_M_2 <= 0; cin_M_3 <= 0;
    cin_N_0 <= 0; cin_N_1 <= 0; cin_N_2 <= 0; cin_N_3 <= 0;
    cin_K_0 <= 0; cin_K_1 <= 0; cin_K_2 <= 0; cin_K_3 <= 0;
    start <= 0;
end


// Clock generator
initial begin
    clk = 0;
    rst = 1;
    start = 0;

    forever begin
        #(cycle/2) clk = ~clk;
    end
end

    
// Test stimulus
initial begin
    // 测试数据加载和输出
    #10;
    rst = 0;
    
    // 设置输入数据

    // 3A5C  E4F6  1909  B2D7          5B4B  C3D3  4D4C  B3C4
    // 3E1B  A492  5F0D  C697          5C4B  B3D3  4D4C  B3C4

    // 第一行数据
    cin_M_0 = 16'h2F69;  
    cin_M_1 = 16'hD4B7;  
    cin_M_2 = 16'h591C;  
    cin_M_3 = 16'h63E0;  

    cin_N_0 = 16'h3A5C;  
    cin_N_1 = 16'hE4F6;  
    cin_N_2 = 16'h1909;  
    cin_N_3 = 16'hB2D7;  
    
    cin_K_0 = 16'h5B4B;  
    cin_K_1 = 16'hC3D3;  
    cin_K_2 = 16'h4D4C;  
    cin_K_3 = 16'hB3C4;  
    
    
    // 启动计算
    start = 1;
    
    
    #200;


    // 关闭计算
    #10;
    start = 0;
    rst = 1;
    
    #20;
    $display("All tests completed");
    $finish;
end

// Monitor signals
initial begin
    $monitor("Time: %t, Data_out_col_0: %h, Data_out_col_1: %h, Data_out_col_2: %h, Data_out_col_3: %h, Start: %b, Rst: %b", 
                $time, data_out_col_0, data_out_col_1, data_out_col_2, data_out_col_3, start, rst);
end
    
endmodule
