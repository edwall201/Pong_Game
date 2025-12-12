module dmem(
    input clock,
    input rst_n,
    input [11:0] address,
    input [31:0] data,
    input wren,
    output reg [31:0] q,
    input left_point,
    input right_point,
    output [2:0] playerL,
    output [2:0] playerR
);
    // Score addresses
    localparam EVENT_ADDR  = 12'd2046;
    localparam CLEAR_ADDR  = 12'd2047;
    localparam SCOREL_ADDR = 12'd2048;
    localparam SCORER_ADDR = 12'd2049;

	 // Used as a wrapper, prevents address from writing into RAM
    wire addr_is_mmio = (address == EVENT_ADDR) || (address == CLEAR_ADDR) || (address == SCOREL_ADDR) || (address == SCORER_ADDR);
    wire ram_wren = wren && !addr_is_mmio;

	 wire [31:0] ram_q;
    dmem_ram ram_inst (
        .address(address),
        .clock(clock),
        .data(data),
        .wren(ram_wren),
        .q(ram_q)
    );

    // MMIO registers for events + scores
    reg [2:0] scoreL_reg, scoreR_reg;
    reg left_pending, right_pending;
	 
	 reg [23:0] test_cnt;
    always @(posedge clock or negedge rst_n) begin
        if (!rst_n) begin
            test_cnt <= 24'd0;
				scoreL_reg   <= 4'd0;
            scoreR_reg   <= 4'd0;
            left_pending <= 1'b0;
            right_pending<= 1'b0;
        end else begin
            if (left_point)
                left_pending <= 1'b1;
            if (right_point)
                right_pending <= 1'b1;

            if (wren) begin
                case (address)
						  SCOREL_ADDR: scoreL_reg <= data[2:0];
                    SCORER_ADDR: scoreR_reg <= data[2:0];

                    CLEAR_ADDR: begin
                        if (data[0]) left_pending  <= 1'b0;
                        if (data[1]) right_pending <= 1'b0;
                    end
                endcase
            end
        end
    end

    // Read logic
    always @(*) begin
        case (address)
            EVENT_ADDR: q = {30'd0, right_pending, left_pending};
            SCOREL_ADDR: q = {29'd0, scoreL_reg};
            SCORER_ADDR: q = {29'd0, scoreR_reg};
            default: q = ram_q;
        endcase
    end

    // Outputs to VGA
    assign playerL = scoreL_reg;
    assign playerR = scoreR_reg;
endmodule
