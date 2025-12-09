module pong_renderer(x,
				y,
				ball_x,
				ball_y,
				paddleL_y,
				paddleR_y,
				out_color);

input [9:0] x;
input [9:0] y;
input [9:0] ball_x;
input [9:0] ball_y;
input [9:0] paddleL_y;
input [9:0] paddleR_y;
output reg [23:0] out_color;
	
localparam BALL_X = 320;
localparam BALL_Y = 240;
localparam BALL_SIZE = 10;
localparam PADDLE_WIDTH = 10;
localparam PADDLE_HEIGHT = 60;
localparam PADDLEL_X = 3;
localparam PADDLER_X = 630;
localparam PADDLEL_Y = 210;
localparam PADDLER_Y = 210;
localparam MIDLINE_X = 320;  
localparam MIDLINE_WIDTH = 4;

always @(*) begin
	// default background = black
	out_color = 24'hFFFFFF;

	// ball
	if (x >= ball_x && x < ball_x + BALL_SIZE &&
		y >= ball_y && y < ball_y + BALL_SIZE)
		out_color = 24'h000000;

	// left paddle
	else if (x >= PADDLEL_X && x < PADDLEL_X + PADDLE_WIDTH &&
		y >= paddleL_y && y < paddleL_y + PADDLE_HEIGHT)
		out_color = 24'h000000;

	// right paddle
	else if (x >= PADDLER_X && x < PADDLER_X + PADDLE_WIDTH &&
      y >= paddleR_y && y < paddleR_y + PADDLE_HEIGHT)
      out_color = 24'h000000;
	// center dashed line
    else if (x >= MIDLINE_X - (MIDLINE_WIDTH/2) &&
      x <  MIDLINE_X + (MIDLINE_WIDTH/2) &&
      // make it dashed: draw for part of every 32-pixel vertical block
      (y[4:0] < 5'd16)) begin
      // y[4:0] is y % 32; this draws 16 pixels on, 16 off
      out_color = 24'h000000;
	 end
end

endmodule
