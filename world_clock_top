`timescale 1ns / 1ps
module world_clock_top(
    input clk,
    input rst,            // active low
    input btn_mode,       // NORMAL/HOUR/MIN/SEC 변경
    input btn_up,         // +1
    input btn_down,       // -1
    input btn_1224,       // 12/24 토글
    input btn_world,      // 세계 도시 변경
    output [7:0] seg_data,
    output [7:0] seg_com,
    output ampm_led,
    output LCD_E,
    output LCD_RS,
    output LCD_RW,
    output [7:0] LCD_DATA,
    output piezo          // 뻐꾸기 소리
);

   
    wire [4:0] btn_vec;
    wire [4:0] btn_trig;

    assign btn_vec = {btn_world, btn_1224, btn_down, btn_up, btn_mode};

    oneshot_universal #(.WIDTH(5)) U_OS(
        .clk(clk),
        .rst(rst),
        .btn(btn_vec),
        .btn_trig(btn_trig)
    );

    wire btn_mode_trig  = btn_trig[0];
    wire btn_up_trig    = btn_trig[1];
    wire btn_down_trig  = btn_trig[2];
    wire btn_1224_trig  = btn_trig[3];
    wire btn_world_trig = btn_trig[4];

 
    wire [2:0] world_sel;
    wire hour_chime_trig;     // <<< 정각 신호를 받는 라인 추가

    watch U_WATCH(
        .clk(clk),
        .rst(rst),
        .btn_mode_trig(btn_mode_trig),
        .btn_up_trig(btn_up_trig),
        .btn_down_trig(btn_down_trig),
        .btn_1224_trig(btn_1224_trig),
        .btn_world_trig(btn_world_trig),
        .seg_data(seg_data),
        .seg_com(seg_com),
        .ampm_led(ampm_led),
        .world(world_sel),
        .hour_chime_trig(hour_chime_trig)  // <<< 여기서 정각 신호 출력
    );

    text_LCD_basic U_LCD(
        .rst(rst),
        .clk(clk),
        .world_sel(world_sel),
        .LCD_E(LCD_E),
        .LCD_RS(LCD_RS),
        .LCD_RW(LCD_RW),
        .LCD_DATA(LCD_DATA),
        .LED_out()
    );

  
    piezo_chime U_PIEZO(
        .clk(clk),
        .rst(rst),
        .btn(8'b00000000),     // 버튼 피아노 기능 필요 없으면 0으로 고정
        .hour_chime_trig(hour_chime_trig),
        .piezo(piezo)
    );

endmodule
