`timescale 1ns / 1ps
module oneshot_universal #(
    parameter WIDTH = 1        // 버튼 개수
)(
    input  wire                clk,
    input  wire                rst,        // active low
    input  wire [WIDTH-1:0]    btn,        // raw button input
    output reg  [WIDTH-1:0]    btn_trig    // one-shot pulse output
);

    reg [WIDTH-1:0] btn_reg;  // 이전 버튼 상태 저장

    // 버튼을 edge 감지 → rising edge 에서만 펄스 발생
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            btn_reg  <= {WIDTH{1'b0}};
            btn_trig <= {WIDTH{1'b0}};
        end
        else begin
            btn_trig <= btn & ~btn_reg; // 현재=1, 이전=0 → 트리거
            btn_reg  <= btn;            // 현재 상태 저장
        end
    end

endmodule
