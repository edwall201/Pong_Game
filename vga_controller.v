module vga_controller(iRST_n,
                      iVGA_CLK,
                      oBLANK_n,
                      oHS,
                      oVS,
                      b_data,
                      g_data,
                      r_data,
							 ball_x,
							 ball_y,
							 paddleL_y,
							 paddleR_y);

	
input iRST_n;
input iVGA_CLK;
input [9:0] ball_x;
input [9:0] ball_y;
input[9:0] paddleL_y;
input [9:0] paddleR_y;
output reg oBLANK_n;
output reg oHS;
output reg oVS;
output [7:0] b_data;
output [7:0] g_data;  
output [7:0] r_data; 
                       
wire rst = ~iRST_n;
wire cBLANK_n, cHS, cVS;
wire [9:0] x, y;
wire [23:0] obj_color;
reg [23:0] final_color;

video_sync_generator LTM_ins (.vga_clk(iVGA_CLK),
                              .reset(rst),
                              .blank_n(cBLANK_n),
                              .HS(cHS),
                              .VS(cVS),
										.x(x),
										.y(y)
);


pong_renderer renderer (
    .x(x),
    .y(y),
    .ball_x(ball_x),
    .ball_y(ball_y),
    .paddleL_y(paddleL_y),
    .paddleR_y(paddleR_y),
    .out_color(obj_color)
);	

always @(*) begin
    if (cBLANK_n)
        final_color = obj_color;       // visible region → use pong rendering
    else
        final_color = 24'h000000;      // blanking → force black
end	

assign r_data = final_color[23:16];
assign g_data = final_color[15:8];
assign b_data = final_color[7:0]; 

always@(posedge iVGA_CLK)
begin
  oHS <= cHS;
  oVS <= cVS;
  oBLANK_n <= cBLANK_n;
end

endmodule
 	
