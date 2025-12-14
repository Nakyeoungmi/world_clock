module watch(
    input clk,
    input rst,                 // active low
    input btn_mode_trig,
    input btn_up_trig,
    input btn_down_trig,
    input btn_1224_trig,
    input btn_world_trig,
    output [7:0] seg_data,
    output [7:0] seg_com,
    output ampm_led,
    output reg [2:0] world,
    output hour_chime_trig     // <<< 정각 신호 출력 추가!
);

    // 1초 발생기
    reg [9:0] h_cnt;
    reg tick_1s, blink_1s;

    // 시간 저장
    reg [5:0] sec, min;
    reg [4:0] hour_24;
    reg [1:0] set_mode;
    reg is_24h;

    // 세계시간
    reg [4:0] local_hour24;
    reg [4:0] disp_hour;
    wire is_pm;

    // 6자리 BCD
    reg [3:0] h_ten, h_one;
    reg [3:0] m_ten, m_one;
    reg [3:0] s_ten, s_one;

    wire [7:0] seg_h_ten, seg_h_one;
    wire [7:0] seg_m_ten, seg_m_one;
    wire [7:0] seg_s_ten, seg_s_one;

    // mux 확장
    reg [2:0] mux_cnt;
    reg [7:0] seg_data_r, seg_com_r;

    assign seg_data = seg_data_r;
    assign seg_com  = seg_com_r;

    assign is_pm    = (local_hour24 >= 5'd12);
    assign ampm_led = is_pm ? blink_1s : 1'b1;

    // 7-seg 디코더 6개
    seg_decoder U0(h_ten, seg_h_ten);
    seg_decoder U1(h_one, seg_h_one);
    seg_decoder U2(m_ten, seg_m_ten);
    seg_decoder U3(m_one, seg_m_one);
    seg_decoder U4(s_ten, seg_s_ten);
    seg_decoder U5(s_one, seg_s_one);

    // 1초 카운터
    always @(posedge clk or negedge rst) begin
        if (!rst) begin
            h_cnt    <= 0; 
            blink_1s <= 0; 
            tick_1s  <= 0;
        end else begin
            if (h_cnt >= 999) begin
                h_cnt    <= 0;
                blink_1s <= ~blink_1s;
                tick_1s  <= 1;
            end else begin
                h_cnt    <= h_cnt + 1;
                tick_1s  <= 0;
            end
        end
    end

    // 모드(NORMAL/HOUR/MIN/SEC)
    always @(posedge clk or negedge rst) begin
        if (!rst) set_mode <= 0;
        else if (btn_mode_trig) set_mode <= (set_mode==3)?0:set_mode+1;
    end

    // 시간 카운팅 및 설정
    always @(posedge clk or negedge rst) begin
        if (!rst) begin 
            sec <= 0; 
            min <= 0; 
            hour_24 <= 0; 
        end else begin
            if (set_mode == 0) begin
                if (tick_1s) begin
                    if (sec == 59) begin sec <= 0;
                        if (min == 59) begin min <= 0;
                            hour_24 <= (hour_24==23)?0:hour_24+1;
                        end else min <= min+1;
                    end else sec <= sec+1;
                end
            end

            case(set_mode)
                1: begin
                    if (btn_up_trig)   hour_24 <= (hour_24==23)?0:hour_24+1;
                    if (btn_down_trig) hour_24 <= (hour_24==0)?23:hour_24-1;
                end
                2: begin
                    if (btn_up_trig)   min <= (min==59)?0:min+1;
                    if (btn_down_trig) min <= (min==0)?59:min-1;
                end
                3: begin
                    if (btn_up_trig)   sec <= (sec==59)?0:sec+1;
                    if (btn_down_trig) sec <= (sec==0)?59:sec-1;
                end
            endcase
        end
    end

    // 12/24 토글
    always @(posedge clk or negedge rst) begin
        if (!rst) is_24h <= 1;
        else if (btn_1224_trig) is_24h <= ~is_24h;
    end

    // 세계도시 선택(0~4)
    always @(posedge clk or negedge rst) begin
        if (!rst) world <= 0;
        else if (btn_world_trig) world <= (world==4)?0:world+1;
    end

    // 시간대 계산
    always @(*) begin
        case(world)
            0,1: local_hour24 = hour_24;                                  // 서울/도쿄
            2:   local_hour24 = (hour_24==0)?23:hour_24-1;               // 베이징
            3:   local_hour24 = (hour_24>=9)?hour_24-9:hour_24+15;       // 런던
            4:   local_hour24 = (hour_24>=14)?hour_24-14:hour_24+10;     // 뉴욕
        endcase
    end

    // 12시간 변환
    always @(*) begin
        if (is_24h) disp_hour = local_hour24;
        else begin
            if (local_hour24 == 0) disp_hour = 12;
            else if (local_hour24 > 12) disp_hour = local_hour24 - 12;
            else disp_hour = local_hour24;
        end
    end

    // BCD 변환
    always @(*) begin
        h_ten = disp_hour / 10; h_one = disp_hour % 10;
        m_ten = min / 10;       m_one = min % 10;
        s_ten = sec / 10;       s_one = sec % 10;
    end

    // 6자리 MUX
    always @(posedge clk or negedge rst) begin
        if (!rst) mux_cnt <= 0;
        else mux_cnt <= mux_cnt + 1;
    end

    always @(posedge clk or negedge rst) begin
        if (!rst) begin 
            seg_com_r  <= 8'hFF; 
            seg_data_r <= 0; 
        end else begin
            case(mux_cnt)
                3'd0: begin seg_com_r <= 8'b1111_0111; seg_data_r <= seg_h_ten; end
                3'd1: begin seg_com_r <= 8'b1111_1011; seg_data_r <= seg_h_one; end
                3'd2: begin seg_com_r <= 8'b1111_1101; seg_data_r <= seg_m_ten; end
                3'd3: begin seg_com_r <= 8'b1111_1110; seg_data_r <= seg_m_one; end
                3'd4: begin seg_com_r <= 8'b1110_1111; seg_data_r <= seg_s_ten; end
                3'd5: begin seg_com_r <= 8'b1101_1111; seg_data_r <= seg_s_one; end
            endcase
        end
    end

    // ★ 정각 신호(00분 00초가 되고 tick_1s 발생 순간)
    assign hour_chime_trig = (min == 0 && sec == 0 && tick_1s);

endmodule
