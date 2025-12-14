`timescale 1us / 1ns
module piezo_chime(
    input        clk,      
    input        rst,     
    input  [7:0] btn,           // 기존 피아노 버튼
    input        hour_chime_trig, // 정각이면 1펄스 들어옴
    output reg   piezo          
);

    // 음계 주파수 동일
    localparam integer C_LO = 3830; 
    localparam integer D     = 3400; 
    localparam integer E     = 3038; 
    localparam integer F     = 2864; 
    localparam integer G     = 2550; 
    localparam integer A     = 2272; 
    localparam integer B     = 2028; 
    localparam integer C_HI  = 1912; 

    reg [15:0] cnt;
    reg [15:0] cnt_limit; 

    // === 정각 알람용 FSM ===
    reg [2:0] chime_state;
    reg [15:0] chime_cnt;
    reg chime_mode;  // 1이면 자동 모드(정각 알람 중)

    // 버튼 음 우선 → 아니면 정각 모드 → 아니면 OFF
    always @(*) begin
        if (chime_mode) begin
            cnt_limit = C_LO; // 뻐꾹 음은 저음 C
        end else begin
            casex (btn)
                8'b1xxxxxxx: cnt_limit = C_HI;
                8'b01xxxxxx: cnt_limit = B;    
                8'b001xxxxx: cnt_limit = A;   
                8'b0001xxxx: cnt_limit = G;   
                8'b00001xxx: cnt_limit = F;    
                8'b000001xx: cnt_limit = E;   
                8'b0000001x: cnt_limit = D;    
                8'b00000001: cnt_limit = C_LO;
                default: cnt_limit = 16'd0;
            endcase
        end
    end

    // piezo PWM 생성
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            cnt   <= 16'd0;
            piezo <= 1'b0;
        end else if (cnt_limit == 16'd0) begin
            cnt   <= 16'd0;
            piezo <= 1'b0;
        end else begin
            if (cnt >= (cnt_limit >> 1) - 1) begin 
                cnt   <= 16'd0;
                piezo <= ~piezo;
            end else begin
                cnt <= cnt + 16'd1;
            end
        end
    end

    // === 정각 알람 FSM ===
    // 2번 "뻐꾸기"
    always @(posedge clk or posedge rst) begin
        if (rst) begin
            chime_mode  <= 1'b0;
            chime_state <= 3'd0;
            chime_cnt   <= 16'd0;
        end 
        else begin
            if (hour_chime_trig && !chime_mode) begin
                chime_mode  <= 1'b1; // 시작
                chime_state <= 3'd1;
                chime_cnt   <= 16'd0;
            end

            if (chime_mode) begin
                chime_cnt <= chime_cnt + 1;

                case (chime_state)
                    3'd1: if (chime_cnt > 100000) begin chime_cnt<=0; chime_state<=3'd2; end // "뻐"
                    3'd2: if (chime_cnt > 50000 ) begin chime_cnt<=0; chime_state<=3'd3; end // 쉬고
                    3'd3: if (chime_cnt > 100000) begin chime_cnt<=0; chime_state<=3'd4; end // "꾹"
                    3'd4: if (chime_cnt > 50000 ) begin chime_mode<=0; chime_state<=0; end   // 끝
                endcase
            end
        end
    end
endmodule
