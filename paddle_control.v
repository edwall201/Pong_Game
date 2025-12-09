module paddle_control #(
    parameter SCREEN_HEIGHT = 480,
    parameter PADDLE_HEIGHT = 60,
    parameter PADDLE_SPEED  = 4,
    parameter PADDLEL_START_Y = (480-60)/2,
    parameter PADDLER_START_Y = (480-60)/2
)(
    input        clk,
    input        rst_n,
    input  [7:0] scan_code,
    input        scan_ready,
    output reg [9:0] paddleL_y,
    output reg [9:0] paddleR_y
);

    // PS/2 set 2 scan codes
    localparam [7:0] SC_W = 8'h1D;
    localparam [7:0] SC_S = 8'h1B;
    localparam [7:0] SC_I = 8'h43;
    localparam [7:0] SC_K = 8'h42;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            paddleL_y <= PADDLEL_START_Y[9:0];
            paddleR_y <= PADDLER_START_Y[9:0];
        end else if (scan_ready) begin
            case (scan_code)
                // LEFT paddle: W up, S down
                SC_W: begin
                    if (paddleL_y >= PADDLE_SPEED)
                        paddleL_y <= paddleL_y - PADDLE_SPEED;
                    else
                        paddleL_y <= 10'd0;
                end
                SC_S: begin
                    if (paddleL_y + PADDLE_HEIGHT + PADDLE_SPEED <= SCREEN_HEIGHT)
                        paddleL_y <= paddleL_y + PADDLE_SPEED;
                    else
                        paddleL_y <= SCREEN_HEIGHT - PADDLE_HEIGHT;
                end

                // RIGHT paddle: I up, K down
                SC_I: begin
                    if (paddleR_y >= PADDLE_SPEED)
                        paddleR_y <= paddleR_y - PADDLE_SPEED;
                    else
                        paddleR_y <= 10'd0;
                end
                SC_K: begin
                    if (paddleR_y + PADDLE_HEIGHT + PADDLE_SPEED <= SCREEN_HEIGHT)
                        paddleR_y <= paddleR_y + PADDLE_SPEED;
                    else
                        paddleR_y <= SCREEN_HEIGHT - PADDLE_HEIGHT;
                end

                default: ; // ignore other keys
            endcase
        end
    end
endmodule
