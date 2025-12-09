module ps2_test(
    input        CLOCK_50,
    input        resetn,       // active low (KEY0)
    inout        ps2_clock,
    inout        ps2_data,
    output [7:0] leds
);

    wire [7:0] scan_code;
    wire       scan_ready;
    wire [7:0] ps2_out_unused;

    // EXACTLY the same ordering as your working skeleton
    PS2_Interface myps2(
        CLOCK_50,       // clock
        resetn,         // resetn (active low)
        ps2_clock,      // ps2_clock
        ps2_data,       // ps2_data
        scan_code,      // ps2_key_data
        scan_ready,     // ps2_key_pressed
        ps2_out_unused  // ps2_out
    );

    // Latch last scan code on each key event
    reg [7:0] last_scan;
    always @(posedge CLOCK_50 or negedge resetn) begin
        if (!resetn)
            last_scan <= 8'h00;
        else if (scan_ready)
            last_scan <= scan_code;
    end

    assign leds = last_scan;

endmodule
