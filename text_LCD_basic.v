`timescale 1ns / 1ps

module text_LCD_basic(
    input rst, clk,
    input [2:0] world_sel,
    output LCD_E,
    output reg LCD_RS,
    output reg LCD_RW,
    output reg [7:0] LCD_DATA,
    output reg [7:0] LED_out
);

assign LCD_E = clk;


reg [2:0] state;
integer cnt;

parameter DELAY        = 3'b000,
          FUNCTION_SET = 3'b001,
          ENTRY_MODE   = 3'b010,
          DISP_ONOFF   = 3'b011,
          LINE1        = 3'b100,
          LINE2        = 3'b101,
          DELAY_T      = 3'b110,
          CLEAR_DISP   = 3'b111;

always @(posedge clk or negedge rst) begin
    if (!rst) begin
        state   <= DELAY;
        cnt     <= 0;
        LED_out <= 8'b0000_0000;
    end 
    else begin
        case (state)
            DELAY: begin
                LED_out <= 8'b1000_0000;
                if (cnt >= 70) begin
                    cnt <= 0;
                    state <= FUNCTION_SET;
                end else cnt <= cnt + 1;
            end

            FUNCTION_SET: begin
                LED_out <= 8'b0100_0000;
                if (cnt >= 30) begin
                    cnt <= 0;
                    state <= DISP_ONOFF;
                end else cnt <= cnt + 1;
            end

            DISP_ONOFF: begin
                LED_out <= 8'b0010_0000;
                if (cnt >= 30) begin
                    cnt <= 0;
                    state <= ENTRY_MODE;
                end else cnt <= cnt + 1;
            end

            ENTRY_MODE: begin
                LED_out <= 8'b0001_0000;
                if (cnt >= 30) begin
                    cnt <= 0;
                    state <= LINE1;
                end else cnt <= cnt + 1;
            end

            LINE1: begin
                LED_out <= 8'b0000_1000;
                if (cnt >= 17) begin
                    cnt <= 0;
                    state <= LINE2;
                end else cnt <= cnt + 1;
            end

            LINE2: begin
                LED_out <= 8'b0000_0100;
                if (cnt >= 17) begin
                    cnt <= 0;
                    state <= DELAY_T;
                end else cnt <= cnt + 1;
            end

            DELAY_T: begin
                LED_out <= 8'b0000_0010;
                if (cnt >= 5) begin
                    cnt <= 0;
                    state <= CLEAR_DISP;
                end else cnt <= cnt + 1;
            end

            CLEAR_DISP: begin
                LED_out <= 8'b0000_0001;
                if (cnt >= 5) begin
                    cnt <= 0;
                    state <= LINE1;
                end else cnt <= cnt + 1;
            end
        endcase
    end
end

// LCD DATA 출력
always @(posedge clk or negedge rst) begin
    if (!rst) begin
        LCD_RS   <= 1'b1;
        LCD_RW   <= 1'b1;
        LCD_DATA <= 8'h00;
    end else begin
        case (state)

            FUNCTION_SET :  begin LCD_RS<=0; LCD_RW<=0; LCD_DATA <= 8'h38; end
            DISP_ONOFF   :  begin LCD_RS<=0; LCD_RW<=0; LCD_DATA <= 8'h0C; end
            ENTRY_MODE   :  begin LCD_RS<=0; LCD_RW<=0; LCD_DATA <= 8'h06; end

            // =============== LINE 1 : 도시 이름 ==================
            LINE1: begin
                LCD_RS <= (cnt==0)?0:1;
                LCD_RW <= 0;
                case (world_sel)
                    // ----- SEOUL -----
                    3'd0: case(cnt)
                        0: LCD_DATA<=8'h80;
                        5: LCD_DATA<="S";
                        6: LCD_DATA<="E";
                        7: LCD_DATA<="O";
                        8: LCD_DATA<="U";
                        9: LCD_DATA<="L";
                        default: LCD_DATA<=" ";
                    endcase

                    // ----- TOKYO -----
                    3'd1: case(cnt)
                        0: LCD_DATA<=8'h80;
                        5: LCD_DATA<="T";
                        6: LCD_DATA<="O";
                        7: LCD_DATA<="K";
                        8: LCD_DATA<="Y";
                        9: LCD_DATA<="O";
                        default: LCD_DATA<=" ";
                    endcase

                    // ----- BEIJING -----
                    3'd2: case(cnt)
                        0: LCD_DATA<=8'h80;
                        4: LCD_DATA<="B";
                        5: LCD_DATA<="E";
                        6: LCD_DATA<="I";
                        7: LCD_DATA<="J";
                        8: LCD_DATA<="I";
                        9: LCD_DATA<="N";
                        10:LCD_DATA<="G";
                        default: LCD_DATA<=" ";
                    endcase

                    // ----- LONDON -----
                    3'd3: case(cnt)
                        0: LCD_DATA<=8'h80;
                        5: LCD_DATA<="L";
                        6: LCD_DATA<="O";
                        7: LCD_DATA<="N";
                        8: LCD_DATA<="D";
                        9: LCD_DATA<="O";
                        10:LCD_DATA<="N";
                        default: LCD_DATA<=" ";
                    endcase

                    // ----- NEW YORK -----
                    3'd4: case(cnt)
                        0: LCD_DATA<=8'h80;
                        4: LCD_DATA<="N";
                        5: LCD_DATA<="E";
                        6: LCD_DATA<="W";
                        7: LCD_DATA<=" ";
                        8: LCD_DATA<="Y";
                        9: LCD_DATA<="O";
                        10:LCD_DATA<="R";
                        11:LCD_DATA<="K";
                        default: LCD_DATA<=" ";
                    endcase
                endcase
            end

            // =============== LINE 2 : 국가 이름 ==================
            LINE2: begin
                LCD_RS <= (cnt==0)?0:1;
                LCD_RW <= 0;
                case (world_sel)
                    // KOREA
                    3'd0: case(cnt)
                        0: LCD_DATA<=8'hC0;
                        5: LCD_DATA<="K";
                        6: LCD_DATA<="O";
                        7: LCD_DATA<="R";
                        8: LCD_DATA<="E";
                        9: LCD_DATA<="A";
                        default: LCD_DATA<=" ";
                    endcase
                    // JAPAN
                    3'd1: case(cnt)
                        0: LCD_DATA<=8'hC0;
                        5: LCD_DATA<="J";
                        6: LCD_DATA<="A";
                        7: LCD_DATA<="P";
                        8: LCD_DATA<="A";
                        9: LCD_DATA<="N";
                        default: LCD_DATA<=" ";
                    endcase
                    // CHINA
                    3'd2: case(cnt)
                        0: LCD_DATA<=8'hC0;
                        5: LCD_DATA<="C";
                        6: LCD_DATA<="H";
                        7: LCD_DATA<="I";
                        8: LCD_DATA<="N";
                        9: LCD_DATA<="A";
                        default: LCD_DATA<=" ";
                    endcase
                    // U.K.
                    3'd3: case(cnt)
                        0: LCD_DATA<=8'hC0;
                        5: LCD_DATA<="U";
                        6: LCD_DATA<=".";
                        7: LCD_DATA<="K";
                        8: LCD_DATA<=".";
                        default: LCD_DATA<=" ";
                    endcase
                    // U.S.A
                    3'd4: case(cnt)
                        0: LCD_DATA<=8'hC0;
                        5: LCD_DATA<="U";
                        6: LCD_DATA<=".";
                        7: LCD_DATA<="S";
                        8: LCD_DATA<=".";
                        9: LCD_DATA<="A";
                        default: LCD_DATA<=" ";
                    endcase
                endcase
            end

            DELAY_T:   begin LCD_RS<=0; LCD_RW<=0; LCD_DATA<=8'h02; end
            CLEAR_DISP:begin LCD_RS<=0; LCD_RW<=0; LCD_DATA<=8'h01; end
        endcase
    end
end

endmodule
