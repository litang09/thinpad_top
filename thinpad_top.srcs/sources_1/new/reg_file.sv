`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/07 14:46:38
// Design Name: 
// Module Name: reg_file
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


module regfile (
    input wire        clk,        // ʱ���ź�
    input wire        reset,      // ��λ�ź�

    // д�˿�
    input wire  [4:0] waddr,      // д�Ĵ������
    input wire [15:0] wdata,      // д������
    input wire        we,         // дʹ��

    // ���˿� A
    input wire  [4:0] raddr_a,    // ���Ĵ��� A ���
    output wire [15:0] rdata_a,   // ���Ĵ��� A ����

    // ���˿� B
    input wire  [4:0] raddr_b,    // ���Ĵ��� B ���
    output wire [15:0] rdata_b    // ���Ĵ��� B ����
);

  // 32 �� 16 λ�Ĵ���
  reg [15:0] regs [31:0];

  // ��ʼ����λ
  integer i;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 32; i = i + 1) begin
        regs[i] <= 16'b0;
      end
    end else if (we && waddr != 5'd0) begin
      // д�����ݣ�����д�� 0 �żĴ���
      regs[waddr] <= wdata;
    end
  end

  // ���˿� A �� B ������߼����
  // �����ַΪ 0����� 0�������ȡ�Ĵ���
  assign rdata_a = (raddr_a == 5'd0) ? 16'd0 : regs[raddr_a];
  assign rdata_b = (raddr_b == 5'd0) ? 16'd0 : regs[raddr_b];
  

endmodule
