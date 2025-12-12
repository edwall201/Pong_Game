module cpu_clk_div #(
    parameter DIV = 700_000    // clk_out toggles every DIV cycles
)(
    input  wire clk,
    input  wire reset,            // active-high, like freq_div_4
    output wire clk_out
);
    // Choose a width large enough for DIV-1
    // 25M < 2^25, so 25 bits is enough; 32 is safe and simple.
    reg  [31:0] r_reg;
    wire [31:0] r_nxt;
    reg         clk_track;

    always @(posedge clk or posedge reset) begin
        if (reset) begin
            r_reg     <= 32'd0;
            clk_track <= 1'b0;
        end else if (r_reg == DIV-1) begin
            r_reg     <= 32'd0;
            clk_track <= ~clk_track;   // toggle when we hit DIV-1
        end else begin
            r_reg <= r_nxt;
        end
    end

    assign r_nxt   = r_reg + 1'b1;
    assign clk_out = clk_track;
endmodule