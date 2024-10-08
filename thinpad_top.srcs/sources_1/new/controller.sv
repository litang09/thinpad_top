`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2024/10/07 15:11:04
// Design Name: 
// Module Name: controller
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


module controller (
    input wire clk,
    input wire reset,

    // 连接寄存器堆模块的信号
    output reg  [4:0]  rf_raddr_a,
    input  wire [15:0] rf_rdata_a,
    output reg  [4:0]  rf_raddr_b,
    input  wire [15:0] rf_rdata_b,
    output reg  [4:0]  rf_waddr,
    output reg  [15:0] rf_wdata,
    output reg  rf_we,

    // 连接 ALU 模块的信号
    output reg  [15:0] alu_a,
    output reg  [15:0] alu_b,
    output reg  [ 3:0] alu_op,
    input  wire [15:0] alu_y,

    // 控制信号
    input  wire        step,    // 用户按键状态脉冲
    input  wire [31:0] dip_sw,  // 32 位拨码开关状态
    output reg  [15:0] leds
);

  logic [31:0] inst_reg;  // 指令寄存器

  // 组合逻辑，解析指令中的常用部分，依赖于有效的 inst_reg 值
  logic is_rtype, is_itype, is_peek, is_poke;
  logic [15:0] imm;
  logic [4:0] rd, rs1, rs2;
  logic [3:0] opcode;

  always_comb begin
    is_rtype = (inst_reg[2:0] == 3'b001);       // R-Type 指令标识
    is_itype = (inst_reg[2:0] == 3'b010);       // I-Type 指令标识
    is_peek = is_itype && (inst_reg[6:3] == 4'b0010);  // PEEK 指令
    is_poke = is_itype && (inst_reg[6:3] == 4'b0001);  // POKE 指令

    imm = inst_reg[31:16];  // 提取立即数
    rd = inst_reg[11:7];    // 目标寄存器 rd
    rs1 = inst_reg[19:15];  // 源寄存器 rs1
    rs2 = inst_reg[24:20];  // 源寄存器 rs2
    opcode = inst_reg[6:3]; // 操作码（ALU 操作类型）
  end

  // 使用枚举定义状态列表，数据类型为 logic [3:0]
  typedef enum logic [3:0] {
    ST_INIT,
    ST_DECODE,
    ST_CALC,
    ST_READ_REG,
    ST_WRITE_REG
  } state_t;

  // 状态机当前状态寄存器
  state_t state;

  // 状态机逻辑
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // 复位各个输出信号
      state <= ST_INIT;
      rf_we <= 0;
      leds <= 16'b0;
      rf_raddr_a <= 5'b0;     // 清空寄存器堆地址 A
      rf_raddr_b <= 5'b0;     // 清空寄存器堆地址 B
      rf_waddr <= 5'b0;       // 清空寄存器堆写地址
      rf_wdata <= 16'b0;      // 清空寄存器堆写入数据
      alu_a <= 16'b0;         // 清空 ALU 输入 A
      alu_b <= 16'b0;         // 清空 ALU 输入 B
      alu_op <= 4'b0;         // 清空 ALU 操作码
    end else begin
      case (state)
        // 初始状态，等待 step 按键按下
        ST_INIT: begin
          if (step) begin
            inst_reg <= dip_sw;  // 从拨码开关读取指令
            state <= ST_DECODE;  // 进入解码状态
          end
        end

        // 解码状态，根据指令类型选择下一步操作
        ST_DECODE: begin
          if (is_rtype) begin
            // R-Type 指令，读取寄存器 rs1 和 rs2
            rf_raddr_a <= rs1;  // 从寄存器堆读取 rs1
            rf_raddr_b <= rs2;  // 从寄存器堆读取 rs2
            state <= ST_CALC;
          end else if (is_poke) begin
            // POKE 指令，直接写立即数到 rd 寄存器
            rf_waddr <= rd;
            rf_wdata <= imm;
            rf_we <= 1;  // 写使能信号置高
            state <= ST_WRITE_REG;
          end else if (is_peek) begin
            // PEEK 指令，读取寄存器 rd，并将其值显示在 LED 上
            rf_raddr_a <= rd;
            state <= ST_READ_REG;
          end else begin
            // 未知指令，回到初始状态
            state <= ST_INIT;
          end
        end

        // ALU 计算状态，将 rs1 和 rs2 的值交给 ALU
        ST_CALC: begin
          alu_a <= rf_rdata_a;  // ALU 输入 A 为寄存器 rs1 的值
          alu_b <= rf_rdata_b;  // ALU 输入 B 为寄存器 rs2 的值
          alu_op <= opcode;     // ALU 操作类型由指令的操作码决定
          state <= ST_WRITE_REG;
        end

        // 写寄存器状态，将计算结果或者立即数写入寄存器 rd
        ST_WRITE_REG: begin
          rf_waddr <= rd;       // 目标寄存器地址
          rf_wdata <= is_rtype ? alu_y : imm;  // 对于 R-Type，写 ALU 结果；对于 POKE，写立即数
          rf_we <= 1;           // 使能寄存器写
          state <= ST_INIT;     // 回到初始状态
        end

        // 读寄存器状态，将寄存器 rd 的值显示在 LED 上
        ST_READ_REG: begin
          leds <= rf_rdata_a;   // 将寄存器 rd 的数据放在 LED 上
          state <= ST_INIT;     // 回到初始状态
        end

        default: begin
          state <= ST_INIT;     // 异常处理，回到初始状态
        end
      endcase
    end
  end
endmodule
