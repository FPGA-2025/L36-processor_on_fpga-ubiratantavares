module Immediate_Generator (
    input wire [31:0] instr_i,  // Entrada: Instrução
    output reg [31:0] imm_o     // Saída: Imediato extraído da instrução
);

	// definição dos opcodes RISC-V relevantes
	localparam LW_OPCODE        = 7'b0000011;
	localparam SW_OPCODE        = 7'b0100011;
	localparam JAL_OPCODE       = 7'b1101111;
	localparam LUI_OPCODE       = 7'b0110111;
	localparam JALR_OPCODE      = 7'b1100111;
	localparam AUIPC_OPCODE     = 7'b0010111;
	localparam BRANCH_OPCODE    = 7'b1100011;
	localparam IMMEDIATE_OPCODE = 7'b0010011;

	// extração dos campos de instrução que serão usados para identificar o tipo de imediato
	wire [6:0] opcode = instr_i[6:0];  // opcode principal
	wire [2:0] funct3 = instr_i[14:12]; // campo funct3
    wire [6:0] funct7 = instr_i[31:25];

    // lógica combinacional
	always @(*) begin
		imm_o = 32'bx;

		case (opcode)
			IMMEDIATE_OPCODE, LW_OPCODE, JALR_OPCODE: begin
				// Shift instructions
				if ((funct3 == 3'b001 && funct7 == 7'b0000000) || // SLLI
					(funct3 == 3'b101 && (funct7 == 7'b0000000 || funct7 == 7'b0100000))) begin
					imm_o = {27'b0, instr_i[24:20]}; // Zero-extend shamt
				end else begin
					imm_o = {{20{instr_i[31]}}, instr_i[31:20]}; // Sign-extend 12-bit immediate
				end
			end

			SW_OPCODE: begin
				imm_o = {{20{instr_i[31]}}, instr_i[31:25], instr_i[11:7]}; // S-type immediate
			end

			BRANCH_OPCODE: begin
				imm_o = {{19{instr_i[31]}}, instr_i[31], instr_i[7], instr_i[30:25], instr_i[11:8], 1'b0}; // B-type immediate
			end

			LUI_OPCODE, AUIPC_OPCODE: begin
				imm_o = {instr_i[31:12], 12'b0}; // U-type immediate
			end

			JAL_OPCODE: begin
				imm_o = {{11{instr_i[31]}}, instr_i[31], instr_i[19:12], instr_i[20], instr_i[30:21], 1'b0}; // J-type immediate
			end

			default: begin
				imm_o = 32'bx;
			end
		endcase
	end


endmodule
