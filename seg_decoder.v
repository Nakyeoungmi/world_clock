`timescale 1ns / 1ps
module seg_decoder(
    input  [3:0] bcd,
    output reg [7:0] seg_data   // Common Anode ⇒ 0=ON, 1=OFF
);

    always @(*) begin
        case (bcd)
            4'd0: seg_data = 8'b00111111; // 0
            4'd1: seg_data = 8'b00000110; // 1
            4'd2: seg_data = 8'b01011011; // 2
            4'd3: seg_data = 8'b01001111; // 3
            4'd4: seg_data = 8'b01100110; // 4
            4'd5: seg_data = 8'b01101101; // 5
            4'd6: seg_data = 8'b01111101; // 6
            4'd7: seg_data = 8'b00000111; // 7
            4'd8: seg_data = 8'b01111111; // 8
            4'd9: seg_data = 8'b01101111; // 9

            // 선택: A~F 표시 필요하면 활성
            4'hA: seg_data = 8'b01110111; // A
            4'hB: seg_data = 8'b01111100; // b
            4'hC: seg_data = 8'b00111001; // C
            4'hD: seg_data = 8'b01011110; // d
            4'hE: seg_data = 8'b01111001; // E
            4'hF: seg_data = 8'b01110001; // F

            default: seg_data = 8'b11111111; // OFF
        endcase
    end
endmodule
