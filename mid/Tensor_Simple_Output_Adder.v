// version 1.0

/*

这是简单加法器，将第一步交叉矩阵乘法后的结果, 再与 张量计算的最后一个矩阵加法得到 矩阵最终结果

*/



module Tensor_Simple_Output_Adder(

    input wire clk,
    input wire rst,
    input wire start,

    input signed [7:0] ele_0,
    input signed [7:0] ele_1,
    input signed [7:0] ele_2,
    input signed [7:0] ele_3,
    input signed [3:0] ele_k,


    output wire signed [15:0] result
);


reg signed [15:0] result_temp;
reg done;

assign result = result_temp;

initial begin
    result_temp <= 16'd0;
    done <= 0;
end

always @(posedge clk) begin

    if (rst) begin

        result_temp <= 16'd0;
    end

    else if (start && !done) begin

        result_temp <= ele_0 + ele_1 + ele_2 + ele_3 + ele_k;
        done <= 1;
    end
    
end

endmodule
