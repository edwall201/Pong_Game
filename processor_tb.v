`timescale 1ns/1ps

module processor_tb;

    reg         clock;
    reg  [11:0] address;
    wire [31:0] q;

    // DUT: your imem
    imem dut (
        .address(address),
        .clock(clock),
        .q(q)
    );

    // Generate clock: 10ns period
    initial begin
        clock = 0;
        forever #5 clock = ~clock;
    end

    // Drive address
    initial begin
        address = 12'd0;

        // Let things settle a bit
        #2;

        // Step through a few addresses
        repeat (10) begin
            @(posedge clock);
            address <= address + 1;
        end

        // Run a few extra cycles
        repeat (5) @(posedge clock);

        $finish;
    end

    // Monitor address and q each cycle
    reg [11:0] prev_addr;

    initial begin
        $display(" time | addr | prev_addr | q");
        $monitor("%4t | %4d | %9d | %h",
                 $time, address, prev_addr, q);
    end

    // Track previous address for easy comparison
    always @(posedge clock) begin
        prev_addr <= address;
    end

endmodule
