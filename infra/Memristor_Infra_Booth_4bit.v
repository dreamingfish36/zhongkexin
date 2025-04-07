//Version 1.01

/*

这是单个memristor模型，实现2bit Booth算法,testbench中给出了 计算INT4 bit 相乘
上下两极输入 0和1 进行对比，象征Booth算法中，相邻两位进行对比
00，11不执行操作，01，10分别执行 A=A+M A=A-M操作
M为Multiplicand，提前初始化传入
A为Accumulator，累乘加结果
进行判断后，更新φ左移一位，阻值自增 同时修正权重

两个signed 4bit 相乘，结果最多为8bit 无溢出

bottom 是前一位，top是最新位 -> {top,bottom}

*/

// 1.01 调整输出形式为 wire类型，便于后续传递与计算，reg 类型的话，外界无法进行操作


module Memristor_Infra_Booth_4bit (

    input wire clk                      , // clock line
    input wire rst                      , // reset line
    input wire start                    , // enable line

    input wire top                      , // Top bit input
    input wire bottom                   , // Bottom bit input
    input wire signed [3:0] delta_m     , // Δm multiplicant

    output wire signed [7:0] result        // Result output wire
);

// Internal register to temporarily store the result and resistence
reg signed [7:0] phi;

// Connect the outpur out to the result wire
assign result = phi;

// Define Execution code
`define Add_Shift_Execution phi <= $signed({( (phi[7:4] + delta_m)),phi[3:0]}) >>> 1     // A = A+M , A = A>>1
`define Sub_Shift_Execution phi <= $signed({( (phi[7:4] - delta_m)),phi[3:0]}) >>> 1     // A = A-M , A = A>>1
`define Equ_Shift_Execution phi <= phi >>> 1                                             // A = A >>1


// Initialize the phi value
initial begin

    phi <= 0                            ;
end


// main 

always @(posedge clk) begin

    if (rst) begin

        phi <= 0                        ;
    end

    else if (start) begin

        case({top,bottom})

            2'b00: `Equ_Shift_Execution  ;
            2'b11: `Equ_Shift_Execution  ;
            2'b10: `Sub_Shift_Execution  ;
            2'b01: `Add_Shift_Execution  ;

        endcase
    end

end


endmodule
