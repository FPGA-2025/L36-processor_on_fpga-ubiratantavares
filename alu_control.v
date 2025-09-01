module ALU_Control (
    input wire is_immediate_i,
    input wire [1:0] ALU_CO_i,
    input wire [6:0] FUNC7_i,
    input wire [2:0] FUNC3_i,
    output reg [3:0] ALU_OP_o
);

	always @(*) begin
		case (ALU_CO_i)
			2'b00: ALU_OP_o = 4'b0010; // LOAD/STORE -> sempre soma

			2'b01: begin // BRANCH
				case (FUNC3_i)
					3'b000: ALU_OP_o = 4'b1010; // SUB (BEQ)
					3'b001: ALU_OP_o = 4'b0011; // EQUAL (BNE)
					3'b010: ALU_OP_o = 4'b1010; // BLT (equivalente ao SUB)
					3'b011: ALU_OP_o = 4'b1010; // BGE (equivalente ao SUB)
					3'b100: ALU_OP_o = 4'b1100; // GE (BLT)
					3'b101: ALU_OP_o = 4'b1110; // SLT (BLTU)
					3'b110: ALU_OP_o = 4'b1101; // GEU (BLTU)
					3'b111: ALU_OP_o = 4'b1111; // SLTU (BGEU)
					default: ALU_OP_o = 4'b0000;
				endcase
			end

			2'b10: begin // ALU
				case (FUNC3_i)
					3'b000: ALU_OP_o = (is_immediate_i || FUNC7_i != 7'b0100000) ? 4'b0010 : 4'b1010; // ADDI ou ADD/SUB
					3'b001: ALU_OP_o = 4'b0100; // SLL
					3'b010: ALU_OP_o = 4'b1110; // SLT
					3'b011: ALU_OP_o = 4'b1111; // SLTU
					3'b100: ALU_OP_o = 4'b1000; // XOR
					3'b101: ALU_OP_o = (FUNC7_i == 7'b0100000) ? 4'b0111 : 4'b0101; // SRA / SRL
					3'b110: ALU_OP_o = 4'b0001; // OR
					3'b111: ALU_OP_o = 4'b0000; // AND
					default: ALU_OP_o = 4'b0000;
					
				endcase
			end

			default: ALU_OP_o = 4'b0000; // caso inválido

		endcase	
	end

endmodule
