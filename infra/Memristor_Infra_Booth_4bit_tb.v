//version 1.0

/*
这是Memristor_Infra_Booth_2bit的testbench，
计算0111 * 0011 7*3 = 21

*/

// version 1.01 修正输出形式为wire 类型
// version 1.02 添加负数计算验证，已经确认逻辑正确，包括 -7*-3, -7*3

`timescale 1ns/1ns

module Memristor_Infra_Booth_4bit_tb;

    parameter cycle = 2         ;

    // Testbench signals
    reg clk                     ;
    reg rst                     ;
    reg start                   ;
    reg top                     ;
    reg bottom                  ;
    reg signed [3:0] delta_m    ;
    wire signed [7:0] result    ;
    


// Instantiate the memristor simulation module
Memristor_Infra_Booth_4bit uut (
    
    .clk(clk)                   ,
    .rst(rst)                   ,
    .start(start)               ,
    .top(top)                   ,
    .bottom(bottom)             ,
    .delta_m(delta_m)           ,
    .result(result)
);


// Initialize the signals
initial begin

    top <=0                     ;
    bottom <= 0                 ;
    delta_m <= 0                ;
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

    //0111 * 0011

    #10                         ;
    rst = 0                     ;
    start = 1                   ;

    delta_m = 4'b0111           ;


    //0011 
    //0110

    top <= 1                    ;
    bottom <= 0                 ;

    #2                          ;

    top <= 1                    ;
    bottom <= 1                 ;

    #2                          ;

    top <= 0                    ;
    bottom <= 1                 ;

    #2                          ;

    top <= 0                    ;
    bottom <= 0                 ;

    #50                         ;

    start <= 0                  ;
    rst   <= 1                  ;




    // 测试计算 -7 * -3 = 21
    #10                         ;
    rst = 0                     ;   
    start = 1                   ;

    delta_m = 4'b1001           ;   

    //1101
    //1010

    top <= 1                    ;
    bottom <= 0                 ;       

    #2                          ;

    top <= 0                    ;
    bottom <= 1                 ;   

    #2                          ;

    top <= 1                    ;
    bottom <= 0                 ;   

    #2                          ;

    top <= 1                    ;
    bottom <= 1                 ;      
    
    #10                         ;


    $finish;

end

// Monitor signals
initial begin
    $monitor("Time: %t, Top: %b, Bottom: %b, Result: %d", 
                $time, top, bottom, result);
end
    
endmodule
