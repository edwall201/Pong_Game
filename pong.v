module pong(
    input CLOCK_50,
    input [3:0] KEY,
    inout PS2_CLK,
    inout PS2_DAT,
    output [7:0] VGA_R,
    output [7:0] VGA_G,
    output [7:0] VGA_B,
    output VGA_HS,
    output VGA_VS,
    output VGA_BLANK_N,
    output VGA_CLK,
    output [7:0] LEDR
);
    // Reset and clock
    wire rst_n = KEY[0];      
    wire reset = ~rst_n;
	 
    // 50 MHz → 25 MHz pixel clock
    reg pixel_clk_reg;
    always @(posedge CLOCK_50 or negedge rst_n) begin
        if (!rst_n)
            pixel_clk_reg <= 1'b0;
        else
            pixel_clk_reg <= ~pixel_clk_reg;
    end

    wire pixel_clk = pixel_clk_reg;
    assign VGA_CLK = pixel_clk;
	 
	 wire cpu_clk;
	 //cpu_clk_div cpu_clk0(CLOCK_50, reset, cpu_clk); Used for debugging instructions
	 assign cpu_clk = CLOCK_50;
	 
	 reg game_reset_pulse;
	 wire game_rst_n = rst_n & ~game_reset_pulse;

	 always @(posedge CLOCK_50 or negedge rst_n) begin
		  if (!rst_n) begin
			   game_reset_pulse <= 1'b0;
		  end else begin
			   if (ps2_key_pressed && ps2_key_data == 8'h2D) // 'R' key
					 game_reset_pulse <= 1'b1;
			   else
					 game_reset_pulse <= 1'b0;
		  end
	 end

    // Paddles, ball, scores
    wire [2:0] scoreL;
    wire [2:0] scoreR;
	 
	 wire [9:0] paddleL_y;
    wire [9:0] paddleR_y;

    wire [9:0] ball_x;
    wire [9:0] ball_y;

    // Scores from dmem → VGA
	 wire [2:0] playerL;
	 wire [2:0] playerR;
	 wire left_win = (scoreL == 3'd7);
	 wire right_win = (scoreR == 3'd7);
	 wire game_over = left_win | right_win;
	 
    // Score event pulses from ball_motion → dmem → CPU
    wire left_point;
    wire right_point;
	 
    // Game tick divider
    reg [19:0] game_div;
    wire game_tick = (game_div == 20'd0);

    always @(posedge CLOCK_50 or negedge rst_n) begin
        if (!rst_n)
            game_div <= 20'd0;
        else
            game_div <= game_div + 1'b1;
    end

    vga_controller u_vga(
        .iRST_n(rst_n),
        .iVGA_CLK(pixel_clk),
        .oBLANK_n(VGA_BLANK_N),
        .oHS(VGA_HS),
        .oVS(VGA_VS),
        .b_data(VGA_B),
        .g_data(VGA_G),
        .r_data(VGA_R),

        .ball_x(ball_x),
        .ball_y(ball_y),
        .paddleL_y(paddleL_y),
        .paddleR_y(paddleR_y),

        .scoreL(scoreL),
        .scoreR(scoreR),
		  .game_over(game_over),
		  .left_win(left_win),
		  .right_win(right_win)
    );

    wire [7:0] ps2_key_data;
    wire ps2_key_pressed;
    wire [7:0] ps2_out;

    PS2_Interface kbd (
        .inclock(CLOCK_50),
        .resetn(rst_n),
        .ps2_clock(PS2_CLK),
        .ps2_data(PS2_DAT),
        .ps2_key_data(ps2_key_data),
        .ps2_key_pressed(ps2_key_pressed),
        .last_data_received(ps2_out)
    );

    paddle_control paddles (
        .clk(CLOCK_50),
        .rst_n(game_rst_n),
        .move_tick(game_tick),
        .scan_code(ps2_key_data),
        .scan_ready(ps2_key_pressed),
        .paddleL_y(paddleL_y),
        .paddleR_y(paddleR_y)
    );

    ball_motion motion (
        .clk(VGA_CLK),
        .rst_n(game_rst_n),
		  .game_over(game_over),
        .paddleL_y(paddleL_y),
        .paddleR_y(paddleR_y),
        .ball_x(ball_x),
        .ball_y(ball_y),
        .left_point(left_point),
        .right_point(right_point),
		  .scoreL(scoreL),
		  .scoreR(scoreR)
    );

    // CPU + Imem + Dmem + Regfile 
    wire [11:0] imem_addr;
    wire [31:0] imem_q;

    wire [11:0] dmem_addr;
    wire [31:0] dmem_data;
    wire        dmem_wren;
    wire [31:0] dmem_q;

    wire rf_we;
    wire [4:0]  rf_waddr, rf_raddrA, rf_raddrB;
    wire [31:0] rf_wdata;
    wire [31:0] rf_rdataA, rf_rdataB;

    imem instr_mem (
        .address(imem_addr),
        .clock(cpu_clk),
        .q(imem_q)
    );

    dmem data_mem (
        .clock(cpu_clk),
        .rst_n(rst_n),
        .address(dmem_addr),
        .data(dmem_data),
        .wren(dmem_wren),
        .q(dmem_q),
        .left_point (left_point),
        .right_point(right_point),
        .playerL(playerL),
        .playerR(playerR)
    );

    regfile regfile_inst (
        .clock (cpu_clk),
        .ctrl_writeEnable(rf_we),
        .ctrl_reset(reset),
        .ctrl_writeReg(rf_waddr),
        .ctrl_readRegA(rf_raddrA),
        .ctrl_readRegB(rf_raddrB),
        .data_writeReg(rf_wdata),
        .data_readRegA(rf_rdataA),
        .data_readRegB(rf_rdataB)
    );

    processor cpu_inst (
        .clock(cpu_clk),
        .reset(reset),
        .address_imem(imem_addr),
        .q_imem(imem_q),
        .address_dmem(dmem_addr),
        .data(dmem_data),
        .wren(dmem_wren),
        .q_dmem(dmem_q),
        .ctrl_writeEnable(rf_we),
        .ctrl_writeReg(rf_waddr),
        .ctrl_readRegA(rf_raddrA),
        .ctrl_readRegB(rf_raddrB),
        .data_writeReg(rf_wdata),
        .data_readRegA(rf_rdataA),
        .data_readRegB(rf_rdataB)
    ); 

    // LED for debugging
    assign LEDR[3:0] = scoreL;
    assign LEDR[7:4] = scoreR;
endmodule
