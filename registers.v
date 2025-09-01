module Registers (
    input  wire clk,
    input  wire wr_en_i,
    
    input  wire [4:0] RS1_ADDR_i,
    input  wire [4:0] RS2_ADDR_i,
    input  wire [4:0] RD_ADDR_i,

    input  wire [31:0] data_i,

    output wire [31:0] RS1_data_o,
    output wire [31:0] RS2_data_o
);

	// declaração do array de registradores
	reg [31:0] reg_array [0:31];

	// lógica de escrita para o banco de registradores
	always @(posedge clk) begin
		if (wr_en_i) begin
			if (RD_ADDR_i != 5'b00000) begin
				reg_array[RD_ADDR_i] <= data_i;
			end
		end
	end

	// lógica de leitura do primeiro porto
	assign RS1_data_o = (RS1_ADDR_i == 5'b00000) ? 32'b0 : reg_array[RS1_ADDR_i];

	// lógica de leitura do segundo porto 
	assign RS2_data_o = (RS2_ADDR_i == 5'b00000) ? 32'b0 : reg_array[RS2_ADDR_i];
endmodule
