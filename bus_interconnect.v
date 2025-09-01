module bus_interconnect (
    // sinais vindos do processador
    input   wire proc_rd_en_i,
    input   wire proc_wr_en_i,
    output  wire [31:0] proc_data_o,
    input   wire [31:0] proc_addr_i,
    input   wire [31:0] proc_data_i,
    
    //sinais que vão para a memória
    output   wire mem_rd_en_o,
    output   wire mem_wr_en_o,
    input    wire [31:0] mem_data_i,
    output   wire [31:0] mem_addr_o,
    output   wire [31:0] mem_data_o,

    //sinais que vão para o periférico
    output   wire periph_rd_en_o,
    output   wire periph_wr_en_o,
    input    wire [31:0] periph_data_i,
    output   wire [31:0] periph_addr_o,
    output   wire [31:0] periph_data_o
);

	// decodificacao de endereço: MSB define memória (0) ou periférico (1)
	wire is_peripheral_access = proc_addr_i[31];
	wire is_memory_access     = ~proc_addr_i[31];

	// roteamento para memória
	assign mem_rd_en_o = proc_rd_en_i & is_memory_access;
	assign mem_wr_en_o = proc_wr_en_i & is_memory_access;
	assign mem_addr_o  = proc_addr_i;
	assign mem_data_o  = proc_data_i;

	// roteamento para o periférico
	assign periph_rd_en_o = proc_rd_en_i & is_peripheral_access;
	assign periph_wr_en_o = proc_wr_en_i & is_peripheral_access;
	assign periph_addr_o  = proc_addr_i[3:0]; // apenas os bits menos significativos
	assign periph_data_o  = proc_data_i;

	// multiplexação de dados de retorno
	assign proc_data_o = (proc_rd_en_i & is_peripheral_access) ? periph_data_i : (proc_rd_en_i & is_memory_access) ? mem_data_i : 32'b0;

endmodule
