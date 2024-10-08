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
    input wire        clk,        // 时钟信号
    input wire        reset,      // 复位信号

    // 写端口
    input wire  [4:0] waddr,      // 写寄存器编号
    input wire [15:0] wdata,      // 写入数据
    input wire        we,         // 写使能

    // 读端口 A
    input wire  [4:0] raddr_a,    // 读寄存器 A 编号
    output wire [15:0] rdata_a,   // 读寄存器 A 数据

    // 读端口 B
    input wire  [4:0] raddr_b,    // 读寄存器 B 编号
    output wire [15:0] rdata_b    // 读寄存器 B 数据
);

  // 32 个 16 位寄存器
  reg [15:0] regs [31:0];

  // 初始化复位
  integer i;
  always @(posedge clk or posedge reset) begin
    if (reset) begin
      for (i = 0; i < 32; i = i + 1) begin
        regs[i] <= 16'b0;
      end
    end else if (we && waddr != 5'd0) begin
      // 写入数据，忽略写入 0 号寄存器
      regs[waddr] <= wdata;
    end
  end

  // 读端口 A 和 B 的组合逻辑输出
  // 如果地址为 0，输出 0，否则读取寄存器
  assign rdata_a = (raddr_a == 5'd0) ? 16'd0 : regs[raddr_a];
  assign rdata_b = (raddr_b == 5'd0) ? 16'd0 : regs[raddr_b];
  

endmodule
