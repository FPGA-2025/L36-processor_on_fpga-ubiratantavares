module Memory #(
    parameter MEMORY_FILE = "",
    parameter MEMORY_SIZE = 4096
)(
    input  wire clk,
    input  wire rd_en_i,           // habilita leitura
    input  wire wr_en_i,           // habilita escrita
    input  wire [31:0] addr_i,     // endereço
    input  wire [31:0] data_i,     // dados de entrada (para escrita)
    output wire [31:0] data_o,     // dados de saída (para leitura)
    output wire ack_o              // confirmação da transação
);

	// declaração do array de memória.
    reg [31:0] memory [0:(MEMORY_SIZE/4)-1]; // reg [31:0] memory [0:MEMORY_SIZE-1];    

    // inicialização da memória a partir de um arquivo, se fornecido.
    initial begin
        if (MEMORY_FILE != "") begin
            $readmemh(MEMORY_FILE, memory); // Lê o arquivo hexadecimal para a memória [47, 48]
        end 
    end

    // lógica de escrita e leitura assíncrona da memória.
    always @(posedge clk) begin
        if (wr_en_i) begin
            memory[addr_i[13:2]] <= data_i; // Atribuição não-bloqueante para síncrono. // memory[addr_i[11:0]] <= data_i;
        end
    end

    // atribuição da saída de dados e acknowledge.
    assign data_o = (rd_en_i) ? memory[addr_i[31:2]] : 32'b0; // Acesso à memória com endereçamento de palavra (4 bytes)

    // ack_o sinaliza que uma operação (leitura ou escrita) está ocorrendo ou foi completada.
    assign ack_o = rd_en_i || wr_en_i;
endmodule
