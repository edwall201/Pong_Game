module alu(data_operandA, data_operandB, ctrl_ALUopcode,
			ctrl_shiftamt, data_result, isEqualTo, isNotEqual, isLessThan, overflow);

	input [31:0] data_operandA, data_operandB;
	input [4:0] ctrl_ALUopcode, ctrl_shiftamt;
	output [31:0] data_result;
	output isEqualTo, isNotEqual, isLessThan, overflow;
	
	wire signed [31:0] A = data_operandA;
	wire signed [31:0] B = data_operandB;

	reg [31:0] R;
	reg ofl;
	
	assign data_result = R;
	
	assign isEqualTo = (A == B);
	assign isNotEqual = (A != B);
	assign isLessThan = (A < B);
	assign overflow = ofl;
	
	always @* begin
		ofl = 1'b0;    // default
		R   = A + B;   // default result

		case (ctrl_ALUopcode)
			5'd0: begin                     // ADD
				R   = A + B;
				ofl = (A[31] == B[31]) && (R[31] != A[31]);
			end
			5'd1: begin                     // SUB
				R   = A - B;
				ofl = (A[31] != B[31]) && (R[31] != A[31]);
			end
			5'd2: begin R = A & B; ofl = 1'b0; end
			5'd3: begin R = A | B; ofl = 1'b0; end
			5'd4: begin R = A <<  ctrl_shiftamt; ofl = 1'b0; end
			5'd5: begin R = A >>> ctrl_shiftamt; ofl = 1'b0; end
			default: begin R = 32'b0; ofl = 1'b0; end
		endcase
  end
	
endmodule
