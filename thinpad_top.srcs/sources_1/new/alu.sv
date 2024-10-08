`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/07 15:10:32
// Design Name: 
// Module Name: alu
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module alu (
    input  wire [15:0] a,       // 操作数 A
    input  wire [15:0] b,       // 操作数 B
    input  wire [3:0] op,       // 操作码，控制 ALU 的运算类型
    output wire [15:0] y        // 结果输出 
);
    
    reg[15:0] result;
    
    assign y = result;
    

    always_comb begin
        case (op)
            4'b0001: begin // ADD
                result = a + b; // 计算和并检测进位
            end
            4'b0010: begin // SUB
                result = a - b; // 计算差并检测借位
            end
            4'b0011: begin // AND
                result = a & b; // 位与运算
            end
            4'b0100: begin // OR
                result = a | b; // 位或运算
            end
            4'b0101: begin // XOR
                result = a ^ b; // 异或运算
            end
            4'b0110: begin // NOT
                result = ~a; // 取反运算，仅对 A 操作
            end
            4'b0111: begin // SLL
                result = a << (b % 16); // 逻辑左移
            end
            4'b1000: begin // SRL
                result = a >> (b % 16); // 逻辑右移
            end
            4'b1001: begin // SRA
                result = $signed(a) >>> (b % 16); // 算术右移
            end
            4'b1010: begin // ROL
                result = (a << (b % 16)) | (a >> (16 - (b % 16))); // 循环左移
            end
            default: begin // 默认情况
                result = 16'b0; // 输出 0
            end
        endcase
        
    end

endmodule
