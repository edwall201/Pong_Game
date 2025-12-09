module ball_motion (input clk,     // same as VGA_CLK
                    input rst_n,   // active-low reset (KEY[0])
                    output reg [9:0] ball_x,
                    output reg [9:0] ball_y);



// Screen and ball parameters
localparam SCREEN_W  = 640;
localparam SCREEN_H  = 480;
localparam BALL_SIZE = 10;

// Simple velocity (signed)
reg signed [9:0] vx;
reg signed [9:0] vy;

// Clock divider to slow down motion
reg [19:0] div_cnt;        // 20 bits → up to ~1,000,000 cycles
wire ball_tick = (div_cnt == 20'd0);

always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        div_cnt <= 20'd0;
    end else begin
        div_cnt <= div_cnt + 1;
    end
end

// Ball position + velocity update
always @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        // initial state
        ball_x <= SCREEN_W/2;
        ball_y <= SCREEN_H/2;
        vx     <= 10'sd2;   // move right
        vy     <= 10'sd1;   // move down
    end else if (ball_tick) begin
        integer next_x;
        integer next_y;

        // compute next position in *signed* integer space
        next_x = $signed({1'b0, ball_x}) + vx;
        next_y = $signed({1'b0, ball_y}) + vy;
        // --- LEFT / RIGHT walls ---
        if (next_x < 0) begin
            next_x = 0;
            vx     <= -vx;  // reflect horizontally
        end
        else if (next_x > SCREEN_W - BALL_SIZE) begin
            next_x = SCREEN_W - BALL_SIZE;
            vx     <= -vx;
        end

        // --- TOP / BOTTOM walls ---
        if (next_y < 0) begin
            next_y = 0;
            vy     <= -vy;  // reflect vertically
        end
        else if (next_y > SCREEN_H - BALL_SIZE) begin
            next_y = SCREEN_H - BALL_SIZE;
            vy     <= -vy;
        end

        // commit final, clamped positions
        ball_x <= next_x[9:0];
        ball_y <= next_y[9:0];
    end
end

endmodule
