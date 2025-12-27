module my_dffe(
    output reg q,
    input d,
    input clk,
    input en,
    input clr
);
    always @(posedge clk or posedge clr) begin
        if (clr)      q <= 1'b0;
        else if (en)  q <= d;
    end
endmodule
