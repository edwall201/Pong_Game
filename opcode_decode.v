module opcode_decode(opcode, is_R, is_addi, is_sw, is_lw, is_bne, is_blt, is_j, is_jal, is_jr, is_bex, is_setx, is_beq);
	input [4:0] opcode;
	output is_R, is_addi, is_sw, is_lw, is_bne, is_blt, is_j, is_jal, is_jr, is_bex, is_setx, is_beq;
	
	wire [4:0] opcode;
	wire is_R, is_addi, is_sw, is_lw, is_bne, is_blt, is_j, is_jal, is_jr, is_bex, is_setx, is_beq;
	
	assign is_R = (~opcode[4]) & (~opcode[3]) & (~opcode[2]) & (~opcode[1]) & (~opcode[0]);
	assign is_addi = (~opcode[4]) & (~opcode[3]) & opcode[2] & (~opcode[1]) & opcode[0];
	assign is_sw = (~opcode[4]) & (~opcode[3]) & opcode[2] & opcode[1] & opcode[0];
	assign is_lw = (~opcode[4]) & opcode[3] & (~opcode[2]) & (~opcode[1]) & (~opcode[0]);
	assign is_bne = (~opcode[4]) & (~opcode[3]) & (~opcode[2]) & opcode[1] & (~opcode[0]);
	assign is_blt = (~opcode[4]) & (~opcode[3]) & opcode[2] & opcode[1] & (~opcode[0]);
	assign is_j = (~opcode[4]) & (~opcode[3]) & (~opcode[2]) & (~opcode[1]) & opcode[0];
	assign is_jal = (~opcode[4]) & (~opcode[3]) & (~opcode[2]) & opcode[1] & opcode[0];
	assign is_jr = (~opcode[4]) & (~opcode[3]) & opcode[2] & (~opcode[1]) & (~opcode[0]);
	assign is_bex = opcode[4] & (~opcode[3]) & opcode[2] & opcode[1] & (~opcode[0]);
	assign is_setx = opcode[4] & (~opcode[3]) & opcode[2] & (~opcode[1]) & opcode[0];
	assign is_beq = (~opcode[4]) & opcode[3] & (~opcode[2]) & (~opcode[1]) & opcode[0];
endmodule
