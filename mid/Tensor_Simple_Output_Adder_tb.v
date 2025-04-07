// version 1.0

/*

This is the test bench file of Simple Adder

using the real example of [0][0][0]

6 + 18 +25 + -24

*/


module Tensor_Simple_Output_Adder_tb;

    parameter cycle = 2;

    reg clk;
    reg rst;
    reg start;

    reg [15:0] input_a;
    reg [15:0] input_b;
    reg [15:0] input_c;
    reg [15:0] input_d;
    reg [3:0] input_e;

    wire signed [15:0] result;

Tensor_Simple_Output_Adder adder_inst (

    .clk(clk),
    .rst(rst),
    .start(start),
    .ele_0(input_a),
    .ele_1(input_b),
    .ele_2(input_c),
    .ele_3(input_d),
    .ele_k(input_e),
    .result(result)
);

initial begin
    clk = 0;
    rst = 1;
    start = 0;

    forever begin
        
        #(cycle/2) clk = ~clk;
    end

end


initial begin

    input_a = 16'd6;
    input_b = 16'd18;
    input_c = 16'd25;
    input_d = -16'd24;
    input_e = 4'd5;
    
end


initial begin

    #10;

    rst = 0;
    start = 1;

    #100;

    $finish;

end


endmodule
