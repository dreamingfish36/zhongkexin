//version 1.1 - 修复位处理逻辑

/*

这是对 Memristor_Infra_Booth_4bit.v的封装，封装为输入两个 4-bit整数，输出结果 的整数乘法器

这个封装乘法器 里面只有一个乘法单元

*/

module Memristor_Infra_multiplier_4bit (
    input wire clk                          , // clock line
    input wire rst                          , // reset line
    input wire start                        , // enable line

    input wire signed [3:0] multiplier      , // Multiplier input wire
    input wire signed [3:0] multiplicand    , // Multiplicand input wire

    output wire signed [7:0] result         , // Result output wire
    output wire done                          // Calculation done flag
);



// Internal Connection
wire top, bottom                            ; // Booth algorithm bit inputs

reg enable                                  ; // Enable signal for booth module
reg [2:0] bit_counter                       ; // Counter for bit processing (增加到3位，可以计数到4)
reg [3:0] multiplier_reg                    ; // Register to store multiplier
reg [3:0] multiplicand_reg                  ; // Multiplicand register
reg done_reg                                ; // Done flag register



// Initialize the registers
initial begin

    enable <= 1'b0                          ;
    bit_counter <= 3'd0                     ;
    multiplier_reg <= 4'd0                  ;
    multiplicand_reg <= 4'd0                ;
    done_reg <= 1'b0                        ;
end


// Connect done reg with output signal
assign done = done_reg                      ;


// Detect the adjacent bit of multiplier
assign bottom = (bit_counter == 0) ? 1'b0 : multiplier_reg[bit_counter-1];
assign top = (bit_counter >= 4) ? 1'b0 : multiplier_reg[bit_counter]     ; 


// Instance
Memristor_Infra_Booth_4bit booth_instance (
    .clk(clk)                                                           ,
    .rst(rst)                                                           ,
    .start(enable)                                                      ,
    .top(top)                                                           ,
    .bottom(bottom)                                                     ,
    .delta_m(multiplicand_reg)                                          ,
    .result(result)
)                                                                       ;


// main
always @(posedge clk) begin

    if (rst) begin

        // reset all register
        enable <= 1'b0                                                  ;
        bit_counter <= 3'd0                                             ;
        multiplier_reg <= 4'd0                                          ;
        multiplicand_reg <= 4'd0                                        ;
        done_reg <= 1'b0                                                ;
    end

    else if (start) begin

        if (!done_reg) begin 

            if (bit_counter == 3'd0 && !enable) begin

                // Load the multiplier and multiplicand
                multiplier_reg   <= multiplier                          ;
                multiplicand_reg <= multiplicand                        ;
                enable <= 1'b1                                          ;
                bit_counter <= 3'd0                                     ; 
            end

            else if (bit_counter < 3'd3) begin
                
                //bit add
                bit_counter <= bit_counter + 1'b1                       ;
            end

            else if (bit_counter == 3'd3) begin  // final bit
                
                enable <= 1'b0                                          ;
                bit_counter <= 3'd0                                     ;
                done_reg <= 1'b1                                        ;  
            end
        end
    end

end

endmodule
