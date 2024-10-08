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

    // ���ӼĴ�����ģ����ź�
    output reg  [4:0]  rf_raddr_a,
    input  wire [15:0] rf_rdata_a,
    output reg  [4:0]  rf_raddr_b,
    input  wire [15:0] rf_rdata_b,
    output reg  [4:0]  rf_waddr,
    output reg  [15:0] rf_wdata,
    output reg  rf_we,

    // ���� ALU ģ����ź�
    output reg  [15:0] alu_a,
    output reg  [15:0] alu_b,
    output reg  [ 3:0] alu_op,
    input  wire [15:0] alu_y,

    // �����ź�
    input  wire        step,    // �û�����״̬����
    input  wire [31:0] dip_sw,  // 32 λ���뿪��״̬
    output reg  [15:0] leds
);

  logic [31:0] inst_reg;  // ָ��Ĵ���

  // ����߼�������ָ���еĳ��ò��֣���������Ч�� inst_reg ֵ
  logic is_rtype, is_itype, is_peek, is_poke;
  logic [15:0] imm;
  logic [4:0] rd, rs1, rs2;
  logic [3:0] opcode;

  always_comb begin
    is_rtype = (inst_reg[2:0] == 3'b001);       // R-Type ָ���ʶ
    is_itype = (inst_reg[2:0] == 3'b010);       // I-Type ָ���ʶ
    is_peek = is_itype && (inst_reg[6:3] == 4'b0010);  // PEEK ָ��
    is_poke = is_itype && (inst_reg[6:3] == 4'b0001);  // POKE ָ��

    imm = inst_reg[31:16];  // ��ȡ������
    rd = inst_reg[11:7];    // Ŀ��Ĵ��� rd
    rs1 = inst_reg[19:15];  // Դ�Ĵ��� rs1
    rs2 = inst_reg[24:20];  // Դ�Ĵ��� rs2
    opcode = inst_reg[6:3]; // �����루ALU �������ͣ�
  end

  // ʹ��ö�ٶ���״̬�б���������Ϊ logic [3:0]
  typedef enum logic [3:0] {
    ST_INIT,
    ST_DECODE,
    ST_CALC,
    ST_READ_REG,
    ST_WRITE_REG
  } state_t;

  // ״̬����ǰ״̬�Ĵ���
  state_t state;

  // ״̬���߼�
  always_ff @(posedge clk or posedge reset) begin
    if (reset) begin
      // ��λ��������ź�
      state <= ST_INIT;
      rf_we <= 0;
      leds <= 16'b0;
      rf_raddr_a <= 5'b0;     // ��ռĴ����ѵ�ַ A
      rf_raddr_b <= 5'b0;     // ��ռĴ����ѵ�ַ B
      rf_waddr <= 5'b0;       // ��ռĴ�����д��ַ
      rf_wdata <= 16'b0;      // ��ռĴ�����д������
      alu_a <= 16'b0;         // ��� ALU ���� A
      alu_b <= 16'b0;         // ��� ALU ���� B
      alu_op <= 4'b0;         // ��� ALU ������
    end else begin
      case (state)
        // ��ʼ״̬���ȴ� step ��������
        ST_INIT: begin
          if (step) begin
            inst_reg <= dip_sw;  // �Ӳ��뿪�ض�ȡָ��
            state <= ST_DECODE;  // �������״̬
          end
        end

        // ����״̬������ָ������ѡ����һ������
        ST_DECODE: begin
          if (is_rtype) begin
            // R-Type ָ���ȡ�Ĵ��� rs1 �� rs2
            rf_raddr_a <= rs1;  // �ӼĴ����Ѷ�ȡ rs1
            rf_raddr_b <= rs2;  // �ӼĴ����Ѷ�ȡ rs2
            state <= ST_CALC;
          end else if (is_poke) begin
            // POKE ָ�ֱ��д�������� rd �Ĵ���
            rf_waddr <= rd;
            rf_wdata <= imm;
            rf_we <= 1;  // дʹ���ź��ø�
            state <= ST_WRITE_REG;
          end else if (is_peek) begin
            // PEEK ָ���ȡ�Ĵ��� rd��������ֵ��ʾ�� LED ��
            rf_raddr_a <= rd;
            state <= ST_READ_REG;
          end else begin
            // δָ֪��ص���ʼ״̬
            state <= ST_INIT;
          end
        end

        // ALU ����״̬���� rs1 �� rs2 ��ֵ���� ALU
        ST_CALC: begin
          alu_a <= rf_rdata_a;  // ALU ���� A Ϊ�Ĵ��� rs1 ��ֵ
          alu_b <= rf_rdata_b;  // ALU ���� B Ϊ�Ĵ��� rs2 ��ֵ
          alu_op <= opcode;     // ALU ����������ָ��Ĳ��������
          state <= ST_WRITE_REG;
        end

        // д�Ĵ���״̬��������������������д��Ĵ��� rd
        ST_WRITE_REG: begin
          rf_waddr <= rd;       // Ŀ��Ĵ�����ַ
          rf_wdata <= is_rtype ? alu_y : imm;  // ���� R-Type��д ALU ��������� POKE��д������
          rf_we <= 1;           // ʹ�ܼĴ���д
          state <= ST_INIT;     // �ص���ʼ״̬
        end

        // ���Ĵ���״̬�����Ĵ��� rd ��ֵ��ʾ�� LED ��
        ST_READ_REG: begin
          leds <= rf_rdata_a;   // ���Ĵ��� rd �����ݷ��� LED ��
          state <= ST_INIT;     // �ص���ʼ״̬
        end

        default: begin
          state <= ST_INIT;     // �쳣�����ص���ʼ״̬
        end
      endcase
    end
  end
endmodule
