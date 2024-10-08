`timescale 1ns / 1ps
module lab2_tb;

  wire clk_50M, clk_11M0592;

  reg push_btn;   // BTN5 ��ť���أ���������·������ʱΪ 1
  reg reset_btn;  // BTN6 ��λ��ť����������·������ʱΪ 1

  reg [3:0] touch_btn; // BTN1~BTN4����ť���أ�����ʱΪ 1
  reg [31:0] dip_sw;   // 32 λ���뿪�أ�������ON��ʱΪ 1

  wire [15:0] leds;  // 16 λ LED�����ʱ 1 ����
  wire [7:0] dpy0;   // ����ܵ�λ�źţ�����С���㣬��� 1 ����
  wire [7:0] dpy1;   // ����ܸ�λ�źţ�����С���㣬��� 1 ����

  initial begin
    // ����������Զ�������������У����磺
    dip_sw = 32'h0;
    touch_btn = 0;
    reset_btn = 0;
    push_btn = 0;

    #100;
    reset_btn = 1;
    #100;
    reset_btn = 0;
    
    for (integer i = 0; i < 20; i = i + 1) begin
      #100;  // �ȴ� 100ns
      push_btn = 1;  // ���� push_btn ��ť
      #100;  // �ȴ� 100ns
      push_btn = 0;  // �ɿ� push_btn ��ť
    end

    #10000 $finish;
  end

  // �������û����
  lab2_top dut (
      .clk_50M(clk_50M),
      .clk_11M0592(clk_11M0592),
      .push_btn(push_btn),
      .reset_btn(reset_btn),
      .touch_btn(touch_btn),
      .dip_sw(dip_sw),
      .leds(leds),
      .dpy1(dpy1),
      .dpy0(dpy0),

      .txd(),
      .rxd(1'b1),
      .uart_rdn(),
      .uart_wrn(),
      .uart_dataready(1'b0),
      .uart_tbre(1'b0),
      .uart_tsre(1'b0),
      .base_ram_data(),
      .base_ram_addr(),
      .base_ram_ce_n(),
      .base_ram_oe_n(),
      .base_ram_we_n(),
      .base_ram_be_n(),
      .ext_ram_data(),
      .ext_ram_addr(),
      .ext_ram_ce_n(),
      .ext_ram_oe_n(),
      .ext_ram_we_n(),
      .ext_ram_be_n(),
      .flash_d(),
      .flash_a(),
      .flash_rp_n(),
      .flash_vpen(),
      .flash_oe_n(),
      .flash_ce_n(),
      .flash_byte_n(),
      .flash_we_n()
  );

  // ʱ��Դ
  clock osc (
      .clk_11M0592(clk_11M0592),
      .clk_50M    (clk_50M)
  );

endmodule
