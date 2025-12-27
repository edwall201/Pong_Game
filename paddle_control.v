module paddle_control(
    input clk,   
    input rst_n,
    input move_tick,
    input [7:0] scan_code,
    input scan_ready,
    output reg [9:0] paddleL_y,
    output reg [9:0] paddleR_y
);
	 localparam integer SCREEN_HEIGHT = 480;
    localparam integer PADDLE_HEIGHT = 60;
    localparam integer PADDLE_SPEED = 4;
    localparam integer PADDLEL_START_Y = (SCREEN_HEIGHT - PADDLE_HEIGHT) / 2;
    localparam integer PADDLER_START_Y = (SCREEN_HEIGHT - PADDLE_HEIGHT) / 2;
	 
    // PS/2 set 2 scan codes
    localparam [7:0] SC_W = 8'h1D; // W
    localparam [7:0] SC_S = 8'h1B; // S
    localparam [7:0] SC_I = 8'h43; // I
    localparam [7:0] SC_K = 8'h42; // K
    localparam [7:0] SC_F0 = 8'hF0;  // Used when a key is released

    // Checks if a key is currently held down
    reg w_down, s_down, i_down, k_down;
    reg break_flag;

    // Update key states
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            w_down <= 1'b0;
            s_down <= 1'b0;
            i_down <= 1'b0;
            k_down <= 1'b0;
            break_flag <= 1'b0;
        end else if (scan_ready) begin
            if (scan_code == SC_F0) begin
                break_flag <= 1'b1;
            end else begin
                if (break_flag) begin
                    case (scan_code)
                        SC_W: w_down <= 1'b0;
                        SC_S: s_down <= 1'b0;
                        SC_I: i_down <= 1'b0;
                        SC_K: k_down <= 1'b0;
                        default: ;
                    endcase
                    break_flag <= 1'b0;
                end else begin
						  // When key is pressed
                    case (scan_code)
                        SC_W: w_down <= 1'b1;
                        SC_S: s_down <= 1'b1;
                        SC_I: i_down <= 1'b1;
                        SC_K: k_down <= 1'b1;
                        default: ;
                    endcase
                end
            end
        end
    end

    // Move paddle
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            paddleL_y <= PADDLEL_START_Y[9:0];
            paddleR_y <= PADDLER_START_Y[9:0];
        end else if (move_tick) begin
            // Left paddle: W = up, S = down
            if (w_down && !s_down) begin
                if (paddleL_y >= PADDLE_SPEED)
                    paddleL_y <= paddleL_y - PADDLE_SPEED;
                else
                    paddleL_y <= 10'd0;
            end else if (s_down && !w_down) begin
                if (paddleL_y + PADDLE_HEIGHT + PADDLE_SPEED <= SCREEN_HEIGHT)
                    paddleL_y <= paddleL_y + PADDLE_SPEED;
                else
                    paddleL_y <= SCREEN_HEIGHT - PADDLE_HEIGHT;
            end

            // Right paddle: I = up, K = down
            if (i_down && !k_down) begin
                if (paddleR_y >= PADDLE_SPEED)
                    paddleR_y <= paddleR_y - PADDLE_SPEED;
                else
                    paddleR_y <= 10'd0;
            end else if (k_down && !i_down) begin
                if (paddleR_y + PADDLE_HEIGHT + PADDLE_SPEED <= SCREEN_HEIGHT)
                    paddleR_y <= paddleR_y + PADDLE_SPEED;
                else
                    paddleR_y <= SCREEN_HEIGHT - PADDLE_HEIGHT;
            end
        end
    end
endmodule
