// version 1.0

/*

这是张量计算单元 模型，进行 4bit 的 4*4*4 张量计算
采用 忆阻器的 交叉阵列形式构建 矩阵张量计算单元

当前只完成 架构设计和 基础的输入和输出，输出形式是 一列列的输出

矩阵序列为：
[00] [01] [02] [03]
[10] [11] [12] [13]
[20] [21] [22] [23]
[30] [31] [32] [33] 

输入序列同样为列输入，即Cin_M_0加载至列向量：
M[00] 
M[01]
M[02]
M[03]

输出序列同样为列输出，即data_out_col_[?] 分别指定特定列输出

*/

// version1.0   完成矩阵 输入，输出。 当前状态为列输入输出，列存储，二段式状态机编写
// version1.01 完成矩阵乘法计算
// version1.02 完成矩阵乘法并加法计算出最后结果     （bug 未修复）
// version1.03 (Beta) 修复bug，完成矩阵乘法并加法计算出最后结果, 但目前 对于 输入的 N 和 K 是手动转置后的矩阵，同时，对于输出结果，莫名变成行输出，可能跟转置有关，但整体已经正确计算输出
// version1.04 (Beta) 修复首次输出的时序错误bug
// version1.05 修复转置矩阵bug，统一代码格式



module Tensor_Crossbar_Array_4m4n4k(

    input wire clk                          ,   // Clock
    input wire rst                          ,   // Reset
    input wire start                        ,   // Start

    input wire [15:0] cin_M_0               ,   // Array M column 0 Input
    input wire [15:0] cin_M_1               ,   // Array M column 1 Input
    input wire [15:0] cin_M_2               ,   // Array M column 2 Input
    input wire [15:0] cin_M_3               ,   // Array M column 3 Input

    input wire [15:0] cin_N_0               ,   // Array N column 0 Input
    input wire [15:0] cin_N_1               ,   // Array N column 1 Input
    input wire [15:0] cin_N_2               ,   // Array N column 2 Input
    input wire [15:0] cin_N_3               ,   // Array N column 3 Input

    input wire [15:0] cin_K_0               ,   // Array K column 0 Input
    input wire [15:0] cin_K_1               ,   // Array K column 1 Input
    input wire [15:0] cin_K_2               ,   // Array K column 2 Input
    input wire [15:0] cin_K_3               ,   // Array K column 3 Input

    output reg [15:0] data_out_col_0        ,   // Output Column 0
    output reg [15:0] data_out_col_1        ,   // Output Column 1
    output reg [15:0] data_out_col_2        ,   // Output Column 2
    output reg [15:0] data_out_col_3            // Output Column 3

);


integer i, j, k                             ;   // for loop
genvar a, b, c, d, e                        ;   // generate 



`define STATE_IDLE      0
`define STATE_LOAD      1
`define STATE_MULT      2
`define STATE_ADD       3
`define STATE_OUTPUT    4



reg [3:0]   STATE                           ;   // State code
reg [3:0]   Array_M [0:3] [0:3]             ;   // Multiplicand Array
reg [3:0]   Array_N [0:3] [0:3]             ;   // Multiplier Array
reg [3:0]   Array_K [0:3] [0:3]             ;   // Plus Array
reg [2:0]   FLAG_OUTPUT                     ;   // Flag for output state machine to output the result



// Multiplier Array Control Signals
reg rst_mul                                 ;   // Multiplier Array rst signal
reg start_mul                               ;   // Start signal for multiplier
reg done_mul                                ;   // Done signal for multiplier
wire done_signal [0:3][0:3][0:3]            ;   // Done signal for multiplier
wire [7:0] multiplier_out [0:3][0:3][0:3]   ;   // Multiplier output



// Adder Array Control Signals
reg rst_adder                               ;   // Adder Array rst signal
reg start_adder                             ;   // Start signal for adder
wire [15:0] Adder_Result [0:3] [0:3]        ;   // Result Array, receiving the result from the adder



// Multiplier and Adder Instance

generate    // Adder Instance
    
    for(d = 0; d < 4; d = d + 1) begin: floor
        for(e = 0; e < 4; e = e + 1) begin: row

            Tensor_Simple_Output_Adder adder_inst (

                .clk(clk)                           ,
                .rst(rst_adder)                     ,
                .start(start_adder)                 ,

                .ele_0(multiplier_out[d][e][0])     ,
                .ele_1(multiplier_out[d][e][1])     ,
                .ele_2(multiplier_out[d][e][2])     ,
                .ele_3(multiplier_out[d][e][3])     ,
                .ele_k(Array_K[d][e])               ,

                .result(Adder_Result[d][e])
            );
        end
    end
endgenerate 


generate    // Multiplier Instance

    for(a = 0; a < 4; a = a + 1) begin: floor_mul
        for(b = 0; b < 4; b = b + 1) begin: column_mul
            for(c = 0; c < 4; c = c + 1) begin: row_mul

                Memristor_Infra_multiplier_4bit multiplier_inst (

                    .clk(clk)                                   ,
                    .rst(rst_mul)                               ,
                    .start(start_mul)                           ,

                    .multiplier(Array_N[a][c])                  ,   // floor column input
                    .multiplicand(Array_M[b][c])                ,   // column row input

                    .result(multiplier_out[a][b][c])            ,   // floor row output
                    .done(done_signal[a][b][c])
                );
            end
        end
    end
endgenerate




//Initialize All Units

initial begin
    
    // Reset Array M,N,K
    for(i = 0; i < 4; i = i + 1) begin
        for(j = 0; j < 4; j = j + 1) begin
            Array_M[i][j] <= 4'b0           ;
            Array_N[i][j] <= 4'b0           ;
            Array_K[i][j] <= 4'b0           ;
        end
    end

    // Initialize State
    STATE <= `STATE_IDLE                    ;

    FLAG_OUTPUT <= 'd0                      ;
    rst_mul <= 'd1                          ;
    start_mul <= 'd0                        ;


    data_out_col_0 <= 'd0                   ;
    data_out_col_1 <= 'd0                   ;
    data_out_col_2 <= 'd0                   ;
    data_out_col_3 <= 'd0                   ;

    rst_adder <= 'd1                        ;
    start_adder <= 'd0                      ;

end



// Combine all the done wire of multiplier unit into one logic and gate, in order to recognize the implementation of multiply Array

reg temp_done;

always@(*) begin

    temp_done = 1'b1;
    
    for(i = 0; i < 4; i = i + 1) begin
        for(j = 0; j < 4; j = j + 1) begin
            for(k = 0; k < 4; k = k + 1) begin

                temp_done = temp_done & done_signal[i][j][k];
            end
        end
    end
end

always@(posedge clk) begin

    done_mul <= temp_done;
end



// State Machine Definition

always @(posedge clk) begin

    case(STATE)

        `STATE_IDLE: begin

        //doing nothing and reset the output array

        data_out_col_0 <= 'd0                                       ;
        data_out_col_1 <= 'd0                                       ;
        data_out_col_2 <= 'd0                                       ;
        data_out_col_3 <= 'd0                                       ;


        end


        `STATE_LOAD: begin

            // Load Input Array Data

            // M: Column Input

            for(j = 0; j < 4; j = j + 1) begin
                for(i = 0; i < 4; i = i + 1) begin
                    case(j)
                        0: Array_M[i][j] <= cin_M_0[15-4*i -: 4]    ;
                        1: Array_M[i][j] <= cin_M_1[15-4*i -: 4]    ;
                        2: Array_M[i][j] <= cin_M_2[15-4*i -: 4]    ;
                        3: Array_M[i][j] <= cin_M_3[15-4*i -: 4]    ;
                    endcase
                end
            end


            // N and K: Row Input

            for(i = 0; i < 4; i = i + 1) begin
                for(j = 0; j < 4; j = j + 1) begin

                    case(i)
                        0: Array_N[i][j] <= cin_N_0[15-4*j -: 4]    ; 
                        1: Array_N[i][j] <= cin_N_1[15-4*j -: 4]    ;
                        2: Array_N[i][j] <= cin_N_2[15-4*j -: 4]    ;
                        3: Array_N[i][j] <= cin_N_3[15-4*j -: 4]    ;
                    endcase

                    case(i)
                        0: Array_K[i][j] <= cin_K_0[15-4*j -: 4]    ;
                        1: Array_K[i][j] <= cin_K_1[15-4*j -: 4]    ;
                        2: Array_K[i][j] <= cin_K_2[15-4*j -: 4]    ;
                        3: Array_K[i][j] <= cin_K_3[15-4*j -: 4]    ;
                    endcase
                end
            end

        end



        `STATE_MULT: begin

            // Take down the rst and enable the start -> Start Computing
            rst_mul <= 0;   
            start_mul <= 1; 

        end


        `STATE_ADD: begin

            // Stop Multiplier
            start_mul <= 0;

            // Start Adder
            rst_adder <= 0;
            start_adder <= 1;

        end



        `STATE_OUTPUT: begin

            // Output Result in column

            case(FLAG_OUTPUT)

                1: begin

                    data_out_col_0 <= Adder_Result[0][0]            ;
                    data_out_col_1 <= Adder_Result[0][1]            ;
                    data_out_col_2 <= Adder_Result[0][2]            ;
                    data_out_col_3 <= Adder_Result[0][3]            ;

                end

                2: begin

                    data_out_col_0 <= Adder_Result[1][0]            ;
                    data_out_col_1 <= Adder_Result[1][1]            ;
                    data_out_col_2 <= Adder_Result[1][2]            ;
                    data_out_col_3 <= Adder_Result[1][3]            ;
                end 

                3: begin

                    data_out_col_0 <= Adder_Result[2][0]            ;  
                    data_out_col_1 <= Adder_Result[2][1]            ;
                    data_out_col_2 <= Adder_Result[2][2]            ;
                    data_out_col_3 <= Adder_Result[2][3]            ;
                end


                4: begin

                    data_out_col_0 <= Adder_Result[3][0]            ;
                    data_out_col_1 <= Adder_Result[3][1]            ;
                    data_out_col_2 <= Adder_Result[3][2]            ;
                    data_out_col_3 <= Adder_Result[3][3]            ;  
                end

            endcase

        end


        default: begin

            STATE <= `STATE_IDLE;
        end

    endcase
end


// State Machine Centeral Control Unit

always @(posedge clk) begin

    if(rst) begin

        // IDLE state and reset the output 
        STATE <= `STATE_IDLE;
    end 
    
    else if(start) begin

        case(STATE)


            `STATE_IDLE: begin

                STATE <= `STATE_LOAD;
            end



            `STATE_LOAD: begin

                STATE <= `STATE_MULT;
            end



            `STATE_MULT: begin

                if (~done_mul) begin

                    STATE <= `STATE_MULT;
                end


                else if(done_mul) begin 

                    STATE <= `STATE_ADD;

                end
            end


            `STATE_ADD: begin

                STATE <= `STATE_OUTPUT;

            end



            `STATE_OUTPUT: begin

                // Controller
                if(FLAG_OUTPUT < 'd4) begin
                    FLAG_OUTPUT  <= FLAG_OUTPUT + 1;
                    STATE <= `STATE_OUTPUT;
                end

                else if(FLAG_OUTPUT == 'd4) begin

                    FLAG_OUTPUT <= 'd0;
                    STATE <= `STATE_IDLE;   // Back to idle
                    start_adder <= 0;       // Stop Adder
                    rst_mul <= 1;           // reset multiplier array
                    rst_adder <= 1;         // reset adder array
                end
            
            end

        endcase
    end
end


endmodule