module ball_motion (
    input clk,         
    input rst_n,       
    input game_over,   
    input [9:0] paddleL_y,
    input [9:0] paddleR_y,
    output reg [9:0] ball_x,
    output reg [9:0] ball_y,
    output reg left_point,   
    output reg right_point,  
    output reg [2:0] scoreL, 
    output reg [2:0] scoreR  
);

	// Screen and ball parameters
	localparam SCREEN_W = 640;
	localparam SCREEN_H = 480;
	localparam BALL_SIZE = 10;

	localparam PADDLE_W = 10;
	localparam PADDLE_H = 60;

	localparam PADDLEL_X = 3;
	localparam PADDLER_X = 630;

	// Velocity
	reg signed [9:0] vx;
	reg signed [9:0] vy;

	// Sequence index for vertical direction when reset
	reg [1:0] seq_idx;

	// Clock divider to slow down motion
	reg [17:0] div_cnt;
	wire ball_tick = (div_cnt == 18'd0);

	integer next_x;
	integer next_y;

	always @(posedge clk or negedge rst_n) begin
		 if (!rst_n) begin
			  div_cnt <= 18'd0;
		 end else begin
			  div_cnt <= div_cnt + 1;
		 end
	end

	// Ball position + velocity + scoring
	always @(posedge clk or negedge rst_n) begin
		 if (!rst_n) begin
			  // Initial ball state
			  ball_x <= SCREEN_W/2;   
			  ball_y <= SCREEN_H/2;   
			  vx <= 10'sd2;  
			  vy <= 10'sd1; 
			  seq_idx <= 2'd0;  
			  // scoring reset
			  scoreL <= 3'd0;
			  scoreR <= 3'd0;
			  left_point <= 1'b0;
			  right_point <= 1'b0;
			  
		 end else if (ball_tick) begin
			  left_point <= 1'b0;
			  right_point <= 1'b0;

			  // If game is over, freeze everything (no movement or scoring)
			  if (game_over) begin
					// Ball does not appear in the win screen
			  end else begin
					// compute next position
					next_x = $signed({1'b0, ball_x}) + vx;
					next_y = $signed({1'b0, ball_y}) + vy;
					// Goal detection + scoring
					if (next_x < 0) begin
						 right_point <= 1'b1;
						 if (scoreR != 3'd7)
							  scoreR <= scoreR + 3'd1;
							  
						 // Reset ball to center, moving right
						 ball_x <= SCREEN_W/2;       
						 ball_y <= SCREEN_H/2;       
						 vx <= 10'sd2;           
						 
						 case (seq_idx)
							  2'd0: vy <= 10'sd1;     
							  2'd1: vy <= -10'sd1;    
							  2'd2: vy <= 10'sd1;     
							  2'd3: vy <= -10'sd1;    
						 endcase
						 seq_idx <= seq_idx + 1;

					end else if (next_x > SCREEN_W - BALL_SIZE) begin
						 left_point <= 1'b1;
						 if (scoreL != 3'd7)
							  scoreL <= scoreL + 3'd1;
							  
						 // Reset ball to center, moving left
						 ball_x <= SCREEN_W/2;       
						 ball_y <= SCREEN_H/2;       
						 vx <= -10'sd2;          

						 case (seq_idx)
							  2'd0: vy <= 10'sd1;     
							  2'd1: vy <= -10'sd1;    
							  2'd2: vy <= -10'sd1;    
							  2'd3: vy <= 10'sd1;     
						 endcase
						 seq_idx <= seq_idx + 1;

					end else begin
						 // Collisions

						 // Top/Bottom Walls
						 if (next_y < 0) begin
							  next_y = 0;
							  vy <= -vy;
						 end
						 else if (next_y > SCREEN_H - BALL_SIZE) begin
							  next_y = SCREEN_H - BALL_SIZE;
							  vy <= -vy;
						 end

						 // Paddle
						 // Left paddle
						 if (vx < 0 && (next_x <= PADDLEL_X + PADDLE_W) && (next_x + BALL_SIZE >= PADDLEL_X) && (next_y + BALL_SIZE >  paddleL_y) && (next_y < paddleL_y + PADDLE_H)) begin
							  next_x = PADDLEL_X + PADDLE_W;
							  vx <= -vx;
						 end

						 // Right paddle
						 else if (vx > 0 && (next_x + BALL_SIZE >= PADDLER_X) && (next_x <= PADDLER_X + PADDLE_W) && (next_y + BALL_SIZE >  paddleR_y) && (next_y < paddleR_y + PADDLE_H)) begin
							  next_x = PADDLER_X - BALL_SIZE;
							  vx <= -vx;
						 end
						 
						 ball_x <= next_x[9:0];
						 ball_y <= next_y[9:0];
					end
			  end
		 end
	end
endmodule
