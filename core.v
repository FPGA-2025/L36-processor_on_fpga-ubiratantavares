module Core #(
    parameter BOOT_ADDRESS = 32'h00000000
) (   
    input wire clk,    // Control signal
    input wire rst_n,  // input wire halt,

    // Memory BUS
    // input  wire ack_i,
    output wire rd_en_o,
    output wire wr_en_i,
    
    // output wire [3:0]  byte_enable,
    input  wire [31:0] data_i,
    output wire [31:0] addr_o,
    output wire [31:0] data_o
);

    // Sinais de controle vindos da Control_Unit
    wire pc_write_w, ir_write_w, pc_source_w, reg_write_w, memory_read_w, 
    	 is_immediate_w, memory_write_w, pc_write_cond_w, lorD_w, memory_to_reg_w;
         
    wire [1:0] aluop_w, alu_src_a_w, alu_src_b_w;

    // Sinais internos do Datapath
    reg [31:0] pc_reg, instr_reg, alu_out_reg, memory_data_reg, a_reg, b_reg, pc_ant_reg;

    wire [31:0] pc_plus_4_w, pc_target_w, alu_in_a_w, alu_in_b_w, alu_result_w, 
                rs1_data_w, rs2_data_w, imm_w, data_w;

    wire alu_zero_w;

    wire [3:0] aluop_code_w;

    // Registradores internos para as saídas, para manter a porta como 'wire'
    reg rd_en_reg, wr_en_reg;
    reg [31:0] addr_reg, data_reg;

	// Módulos intermos

	// Unidade de Controle
	Control_Unit u_control_unit (
		.clk(clk),
		.rst_n(rst_n),
		.instruction_opcode(instr_reg[6:0]),
		.pc_write(pc_write_w),
		.ir_write(ir_write_w),
		.pc_source(pc_source_w),
		.reg_write(reg_write_w),
		.memory_read(memory_read_w),
		.is_immediate(is_immediate_w),
		.memory_write(memory_write_w),
		.pc_write_cond(pc_write_cond_w),
		.lorD(lorD_w),
		.memory_to_reg(memory_to_reg_w),
		.aluop(aluop_w),
		.alu_src_a(alu_src_a_w),
		.alu_src_b(alu_src_b_w)		
	);

	// gerador de imediato
	Immediate_Generator u_immediate_generator (
		.instr_i(instr_reg),
		.imm_o(imm_w)
	);

	// banco de registradores
	Registers u_registers(
		.clk(clk),
		.wr_en_i(reg_write_w),
		.RS1_ADDR_i(instr_reg[19:15]),
		.RS2_ADDR_i(instr_reg[24:20]),
		.RD_ADDR_i(instr_reg[11:7]),
		.data_i(data_w),
		.RS1_data_o(rs1_data_w),
		.RS2_data_o(rs2_data_w)
	);

	// Controle da ALU
	ALU_Control u_alu_control(
		.is_immediate_i(is_immediate_w),
		.ALU_CO_i(aluop_w),
		.FUNC7_i(instr_reg[31:25]),
		.FUNC3_i(instr_reg[14:12]),
		.ALU_OP_o(aluop_code_w)
	);

	// ALU
	Alu u_alu(
		.ALU_OP_i(aluop_code_w),
		.ALU_RS1_i(alu_in_a_w),
		.ALU_RS2_i(alu_in_b_w),
		.ALU_RD_o(alu_result_w),
		.ALU_ZR_o(alu_zero_w)
	);

	// Lógica do Datapath	
	// Registradores de Estado do Datapath (PC, IR, Registradores temporários)
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            pc_reg <= BOOT_ADDRESS;
            instr_reg <= 32'b0;
            alu_out_reg <= 32'b0;
            memory_data_reg <= 32'b0;
            a_reg <= 32'b0;
            b_reg <= 32'b0;
        end else begin
            if (pc_write_w || (pc_write_cond_w && alu_zero_w) ) 
            	pc_reg <= (pc_source_w == 1'b0) ? pc_plus_4_w :  pc_target_w;
            	
            if (ir_write_w) begin
                instr_reg <= data_i;
                pc_ant_reg <= pc_reg;
            end
            // Registradores temporários para o multiciclo
            a_reg <= rs1_data_w;
            b_reg <= rs2_data_w;
            alu_out_reg <= alu_result_w;
            memory_data_reg <= data_i;
        end
    end
	
    // Lógica do PC e multiplexadores
    assign pc_plus_4_w  = pc_reg + 4;

    assign pc_target_w  = pc_ant_reg + imm_w;

    assign alu_in_a_w = (alu_src_a_w == 2'b00) ? pc_reg :
                        (alu_src_a_w == 2'b01) ? a_reg :
                        (alu_src_a_w == 2'b10) ? pc_ant_reg : 32'b0;

    assign alu_in_b_w = (alu_src_b_w == 2'b00) ? b_reg :
                        (alu_src_b_w == 2'b01) ? 32'd4 :
                        (alu_src_b_w == 2'b10) ? imm_w : 32'b0;

    assign data_w = (memory_to_reg_w == 1'b1) ? memory_data_reg : alu_out_reg;

    assign addr_o  = (lorD_w == 0) ? pc_reg : alu_out_reg;

    assign rd_en_o = memory_read_w || (lorD_w == 1'b0); // ler instrução ou dado

    assign wr_en_i = memory_write_w;

    assign data_o  = b_reg;

    
	

endmodule
