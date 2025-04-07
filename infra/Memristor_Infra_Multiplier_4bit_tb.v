//Version 1.0

/*
这是Memristor_Infra_multiplier_4bit的testbench
测试计算两个4bit有符号数相乘
测试用例：7 * 3 = 21
*/

`timescale 1ns/1ns

module Memristor_Infra_Multiplier_4bit_tb;

    parameter cycle = 2         ;

    // Testbench signals
    reg clk                     ;
    reg rst                     ;
    reg start                   ;
    reg signed [3:0] multiplier ;
    reg signed [3:0] multiplicand;
    wire signed [7:0] result    ;
    wire done                   ;
    

// Instantiate the multiplier module
Memristor_Infra_multiplier_4bit uut (
    
    .clk(clk)                   ,
    .rst(rst)                   ,
    .start(start)               ,
    .multiplier(multiplier)     ,
    .multiplicand(multiplicand) ,
    .result(result)             ,
    .done(done)
);


// Initialize the signals
initial begin

    multiplier <= 0             ;
    multiplicand <= 0           ;
    start <= 0                  ;

end

// Clock generator
initial begin


    clk = 0                     ;
    rst = 1                     ;
    start = 0                   ;

    forever begin
        #(cycle/2) clk = ~clk   ;
    end

end
    
// Test stimulus
initial begin

    // 测试 7 * 3 = 21

    #10                         ;
    rst = 0                     ;
    
    // 设置输入值
    multiplier = 4'b0011        ; // 3
    multiplicand = 4'b0111      ; // 7
    
    // 启动计算
    start = 1                   ;
    
    // 等待计算完成
    wait(done)                  ;
    #2                          ;
    
    // 验证结果
    if(result == 8'd21) begin
        $display("Test PASSED! 7 * 3 = %d", result);
    end else begin
        $display("Test FAILED! Expected 21, got %d", result);
    end
    




    // 测试负数乘法: -3 * 5 = -15
    #10                         ;
    rst  = 1                    ; // 重置内部乘法单元
    start = 0                   ; // 复位开始信号
    #2                          ;
    rst = 0                     ;    
    
    multiplier = 4'b1101        ; // -3 (二进制补码)
    multiplicand = 4'b0101      ; // 5
    
    start = 1                   ;
    
    wait(done)                  ;
    #2                          ;
    
    if(result == -15) begin
        $display("Test PASSED! -3 * 5 = %d", result);
    end else begin
        $display("Test FAILED! Expected -15, got %d", result);
    end
    



    // -7 * -7 = 49 
    #10                         ;
    rst = 1                     ;
    start = 0                   ;
    #2                          ;
    rst = 0                     ;
    
    multiplier = 4'b1001        ; // -7
    multiplicand = 4'b1001      ; // -7
    
    start = 1                   ;
    
    wait(done)                  ;
    #2                          ;
    

    if(result == 49) begin
        $display("Test PASSED! -7 * -7 = %d", result);
    end else begin
        $display("Test FAILED! Expected 49, got %d", result);
    end



    // 关闭计算
    #10                         ;
    start = 0                   ;
    rst = 1                     ;
    
    #20                         ;
    $display("All tests completed");
    $finish                     ;

end


// Monitor signals
initial begin
    $monitor("Time: %t, Multiplier: %d, Multiplicand: %d, Result: %d, Done: %b", 
                $time, multiplier, multiplicand, result, done);
end
    
endmodule
