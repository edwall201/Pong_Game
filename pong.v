module pong(
    input        CLOCK_50,
    input  [3:0] KEY,
    inout        PS2_CLK,
    inout        PS2_DAT,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output       VGA_HS,
    output       VGA_VS,
    output       VGA_BLANK_N,
    output       VGA_CLK,
	 output [7:0] LEDR
);
		

wire rst_n = KEY[0];

reg pixel_clk_reg;

always @(posedge CLOCK_50 or negedge rst_n) begin
    if (!rst_n)
        pixel_clk_reg <= 1'b0;
    else
        pixel_clk_reg <= ~pixel_clk_reg;
end

wire pixel_clk = pixel_clk_reg;
assign VGA_CLK = pixel_clk;

wire [9:0] paddleL_y;
wire [9:0] paddleR_y;

wire [9:0] ball_x;
wire [9:0] ball_y;

reg [19:0] game_div;
wire       game_tick = (game_div == 20'd0);

always @(posedge CLOCK_50 or negedge rst_n) begin
    if (!rst_n)
        game_div <= 20'd0;
    else
        game_div <= game_div + 1'b1;
end


ball_motion motion(
			.clk(VGA_CLK),
			.rst_n(rst_n),
			.ball_x(ball_x),
			.ball_y(ball_y));

vga_controller u_vga(
        .iRST_n    (rst_n),
        .iVGA_CLK  (pixel_clk),
        .oBLANK_n  (VGA_BLANK_N),
        .oHS       (VGA_HS),
        .oVS       (VGA_VS),
        .b_data    (VGA_B),
        .g_data    (VGA_G),
        .r_data    (VGA_R),
        .ball_x    (ball_x),
        .ball_y    (ball_y),
        .paddleL_y (paddleL_y),
        .paddleR_y (paddleR_y));

wire [7:0] ps2_key_data;
wire ps2_key_pressed;
wire [7:0] ps2_out;

PS2_Interface kbd (
    .inclock          (CLOCK_50),
    .resetn           (rst_n),
    .ps2_clock        (PS2_CLK),
    .ps2_data         (PS2_DAT),
    .ps2_key_data     (ps2_key_data),   
    .ps2_key_pressed  (ps2_key_pressed),     
    .last_data_received(ps2_out) 
);


paddle_control paddles (
    .clk        (CLOCK_50),   // or game_tick
    .rst_n      (rst_n),
    .scan_code  (ps2_key_data),
    .scan_ready (ps2_key_pressed),
    .paddleL_y  (paddleL_y),
    .paddleR_y  (paddleR_y)
);

assign LEDR[7:0] = paddleL_y;

	 
endmodule
