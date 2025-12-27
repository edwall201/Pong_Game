module cpu_clk_div(
    input wire clk,
    input wire reset,            
    output wire clk_out
);
	 localparam DIV = 700_000;
    reg [31:0] r_reg;
    wire [31:0] r_nxt;
    reg clk_track;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_reg     <= 32'd0;
            clk_track <= 1'b0;
        end else if (r_reg == DIV-1) begin
            r_reg <= 32'd0;
            clk_track <= ~clk_track; 
        end else begin
            r_reg <= r_nxt;
        end
    end

    assign r_nxt = r_reg + 1'b1;
    assign clk_out = clk_track;
endmodule
