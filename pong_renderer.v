module pong_renderer(
    input [9:0] x,
    input [9:0] y,
    input [9:0] ball_x,
    input [9:0] ball_y,
    input [9:0] paddleL_y,
    input [9:0] paddleR_y,
    input [2:0] scoreL,
    input [2:0] scoreR,
    input game_over,
    input left_win,
    input right_win,
    output reg [23:0] out_color
);

    // Existing parameters
    localparam BALL_SIZE = 10;
    localparam PADDLE_WIDTH = 10;
    localparam PADDLE_HEIGHT = 60;
    localparam PADDLEL_X = 3;
    localparam PADDLER_X = 630;
    localparam MIDLINE_X = 320;  
    localparam MIDLINE_WIDTH = 4;

    // Screen + digit layout parameters
    localparam SCREEN_W = 640;
    localparam SCREEN_H = 480;

    localparam FONT_W = 3;
    localparam FONT_H = 5;
    localparam DIGIT_SCALE = 4;
    localparam DIGIT_W = FONT_W * DIGIT_SCALE;
    localparam DIGIT_H = FONT_H * DIGIT_SCALE;

    // Positions for score
    localparam SCORE_Y = (SCREEN_H/2) - (DIGIT_H/2) - 150;
    localparam SCOREL_X = (SCREEN_W/4)  - (DIGIT_W/2);
    localparam SCORER_X = (3*SCREEN_W/4) - (DIGIT_W/2);

    // Displaying score
    function digit_on;
        input [2:0] digit;
        input [1:0] dx;
        input [2:0] dy; 
        reg [14:0] pattern;
        integer idx;
    begin
        case (digit)
            3'd0: pattern = 15'b111_101_101_101_111;
            3'd1: pattern = 15'b001_001_001_001_001;
            3'd2: pattern = 15'b111_001_111_100_111;
            3'd3: pattern = 15'b111_001_111_001_111;
            3'd4: pattern = 15'b101_101_111_001_001;
            3'd5: pattern = 15'b111_100_111_001_111;
            3'd6: pattern = 15'b111_100_111_101_111;
            3'd7: pattern = 15'b111_001_001_001_001;
            default: pattern = 15'b000_000_000_000_000;
        endcase

        idx = dy * FONT_W + dx;
        digit_on = pattern[14-idx];
    end
    endfunction

    // Helpers for score drawing
    reg draw_scoreL, draw_scoreR;
    integer dx, dy;

    always @(*) begin
        // Default background = white
        out_color   = 24'hFFFFFF;
        draw_scoreL = 1'b0;
        draw_scoreR = 1'b0;

        // Win screen
        if (game_over) begin
            if (left_win)
                out_color = 24'hFFFFFF;  
            else if (right_win)
                out_color = 24'hFFFFFF;  
            else
                out_color = 24'hFFFFFF;

            // Left score area
            if (x >= SCOREL_X && x < SCOREL_X + DIGIT_W && y >= SCORE_Y  && y < SCORE_Y  + DIGIT_H) begin
                dx = (x - SCOREL_X) / DIGIT_SCALE;  
                dy = (y - SCORE_Y)  / DIGIT_SCALE;  
                if (digit_on(scoreL, dx[1:0], dy[2:0]))
                    out_color = 24'h000000;         // digit in black
            end

            // Right score area
            if (x >= SCORER_X && x < SCORER_X + DIGIT_W && y >= SCORE_Y  && y < SCORE_Y  + DIGIT_H) begin
                dx = (x - SCORER_X) / DIGIT_SCALE;
                dy = (y - SCORE_Y)  / DIGIT_SCALE;
                if (digit_on(scoreR, dx[1:0], dy[2:0]))
                    out_color = 24'h000000;
            end
        end
		  // Game rendering
        else begin
            // Left score area
            if (x >= SCOREL_X && x < SCOREL_X + DIGIT_W && y >= SCORE_Y  && y < SCORE_Y  + DIGIT_H) begin
                dx = (x - SCOREL_X) / DIGIT_SCALE;
                dy = (y - SCORE_Y)  / DIGIT_SCALE;
                if (digit_on(scoreL, dx[1:0], dy[2:0]))
                    draw_scoreL = 1'b1;
            end

            // Right score area
            if (x >= SCORER_X && x < SCORER_X + DIGIT_W && y >= SCORE_Y  && y < SCORE_Y  + DIGIT_H) begin
                dx = (x - SCORER_X) / DIGIT_SCALE;
                dy = (y - SCORE_Y)  / DIGIT_SCALE;
                if (digit_on(scoreR, dx[1:0], dy[2:0]))
                    draw_scoreR = 1'b1;
            end

            // Ball
            if (x >= ball_x && x < ball_x + BALL_SIZE && y >= ball_y && y < ball_y + BALL_SIZE) begin
                out_color = 24'h000000;
            end

            // Left paddle
            else if (x >= PADDLEL_X && x < PADDLEL_X + PADDLE_WIDTH && y >= paddleL_y && y < paddleL_y + PADDLE_HEIGHT) begin
                out_color = 24'h000000;
            end

            // Right paddle
            else if (x >= PADDLER_X && x < PADDLER_X + PADDLE_WIDTH && y >= paddleR_y && y < paddleR_y + PADDLE_HEIGHT) begin
                out_color = 24'h000000;
            end

            // Scores
            else if (draw_scoreL || draw_scoreR) begin
                out_color = 24'h000000;
            end

            // Center line 
            else if (x >= MIDLINE_X - (MIDLINE_WIDTH/2) && x < MIDLINE_X + (MIDLINE_WIDTH/2) && (y[4:0] < 5'd16)) begin
                out_color = 24'h000000;
            end
        end
    end
endmodule
