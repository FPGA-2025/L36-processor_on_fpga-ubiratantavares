module led_peripheral(
    input  wire clk,
    input  wire rst_n,
    //ligação com o processador
    input wire rd_en_i,
    input wire wr_en_i,
    input wire [31:0] addr_i,
    input  wire [31:0] data_i,
    output wire [31:0] data_o,
    // ligação com o mundo externo
    output wire [7:0] leds_o
);

	// registrador interno de 8 bits para armazenar o estado dos LEDs
	reg[7:0] led_reg;

	// define os offsets de endereço
	localparam LED_WRITE_ADDR_OFFSET = 4'h0; // 0x00: escrita
	localparam LED_READ_ADDR_OFFSET  = 4'h4; // 0x04: leitura

	// apenas os 4 bits menos significativos são usados
	wire[3:0] effective_address;

	assign effective_address = addr_i[3:0];

	// lógica sequencial
	always @(posedge clk or negedge rst_n) begin
		if (!rst_n) begin
			led_reg <= 8'b0; // LEDs desligados no reset
		end else begin
			if (wr_en_i && (effective_address == LED_WRITE_ADDR_OFFSET)) begin
				led_reg <= data_i[7:0]; // escreve somente 8 bits
			end
		end
	end

	// lógica combininacional para leitura
	assign data_o = (rd_en_i && (effective_address == LED_READ_ADDR_OFFSET)) ? {24'b0, led_reg} : 32'b0;

	// saída dos LEDs
	assign leds_o = led_reg;

endmodule

