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
    input  wire [15:0] a,       // ������ A
    input  wire [15:0] b,       // ������ B
    input  wire [3:0] op,       // �����룬���� ALU ����������
    output wire [15:0] y        // ������ 
);
    
    reg[15:0] result;
    
    assign y = result;
    

    always_comb begin
        case (op)
            4'b0001: begin // ADD
                result = a + b; // ����Ͳ�����λ
            end
            4'b0010: begin // SUB
                result = a - b; // ��������λ
            end
            4'b0011: begin // AND
                result = a & b; // λ������
            end
            4'b0100: begin // OR
                result = a | b; // λ������
            end
            4'b0101: begin // XOR
                result = a ^ b; // �������
            end
            4'b0110: begin // NOT
                result = ~a; // ȡ�����㣬���� A ����
            end
            4'b0111: begin // SLL
                result = a << (b % 16); // �߼�����
            end
            4'b1000: begin // SRL
                result = a >> (b % 16); // �߼�����
            end
            4'b1001: begin // SRA
                result = $signed(a) >>> (b % 16); // ��������
            end
            4'b1010: begin // ROL
                result = (a << (b % 16)) | (a >> (16 - (b % 16))); // ѭ������
            end
            default: begin // Ĭ�����
                result = 16'b0; // ��� 0
            end
        endcase
        
    end

endmodule
