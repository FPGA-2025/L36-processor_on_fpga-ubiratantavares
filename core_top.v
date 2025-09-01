module core_top #(
    parameter MEMORY_FILE = "programa.txt"
)(
    input wire clk,
    input wire rst_n,
    output wire [7:0] leds  // saída para os LEDs externos
);

    // sinais internos para conectar o Core ao Bus Interconnect
    
    wire proc_rd_en;                // habilita leitura do processador
    wire proc_wr_en;                // habilita escrita do processador
    wire [31:0] proc_addr;          // endereço do processador
    wire [31:0] proc_data_to_bus;   // dados de escrita do processador
    wire [31:0] proc_data_from_bus; // dados de leitura para o processador

    // sinais internos para conectar o Bus Interconnect à Memória
    
    wire mem_rd_en;                 // habilita leitura para a memória
    wire mem_wr_en;                 // habilita escrita para a memória
    wire [31:0] mem_addr;           // endereço para a memória
    wire [31:0] mem_data_to_mem;    // dados de escrita para a memória
    wire [31:0] mem_data_from_mem;  // dados de leitura da memória

    // sinais internos para conectar o Bus Interconnect ao Periférico de LEDs
    
    wire periph_rd_en;                   // habilita leitura para o periférico
    wire periph_wr_en;                   // habilita escrita para o periférico
    wire [31:0] periph_addr;             // endereço para o periférico
    wire [31:0] periph_data_to_periph;   // dados de escrita para o periférico
    wire [31:0] periph_data_from_periph; // dados de leitura do periférico

    // sinais de saída do periférico de LEDs para o mundo externo
    wire [7:0] leds_from_periph;

    // Instanciação do módulo Core
    // O parâmetro BOOT_ADDRESS é configurado para iniciar o PC em 0
    Core #(
        .BOOT_ADDRESS(32'h00000000)
    ) u_core (
        .clk(clk),
        .rst_n(rst_n),
        .rd_en_o(proc_rd_en),          // saída do Core para o barramento (solicitação de leitura)
        .wr_en_i(proc_wr_en),          // saída do Core para o barramento (solicitação de escrita)
        .data_i(proc_data_from_bus),   // entrada do Core (dados lidos do barramento)
        .addr_o(proc_addr),            // saída do Core (endereço no barramento)
        .data_o(proc_data_to_bus)      // saída do Core (dados a serem escritos no barramento)
    );

    // Instanciação do módulo Bus Interconnect
    // Este módulo roteia as requisições do processador para memória ou periférico
    bus_interconnect u_bus_interconnect (
        // sinais vindos do processador
        .proc_rd_en_i(proc_rd_en),
        .proc_wr_en_i(proc_wr_en),
        .proc_data_o(proc_data_from_bus), // dados para o processador
        .proc_addr_i(proc_addr),
        .proc_data_i(proc_data_to_bus),

        // sinais que vão para a memória
        .mem_rd_en_o(mem_rd_en),
        .mem_wr_en_o(mem_wr_en),
        .mem_data_i(mem_data_from_mem), // dados vindos da memória
        .mem_addr_o(mem_addr),
        .mem_data_o(mem_data_to_mem),

        // sinais que vão para o periférico
        .periph_rd_en_o(periph_rd_en),
        .periph_wr_en_o(periph_wr_en),
        .periph_data_i(periph_data_from_periph), // dados vindos do periférico
        .periph_addr_o(periph_addr),
        .periph_data_o(periph_data_to_periph)
    );

    // Instanciação do módulo Memory
    // O nome da instância 'mem' é crucial para o testbench
    Memory #(
        .MEMORY_FILE(MEMORY_FILE)
    ) mem (
        .clk(clk),
        .rd_en_i(mem_rd_en),           // habilita leitura da interconexão
        .wr_en_i(mem_wr_en),           // habilita escrita da interconexão
        .addr_i(mem_addr),             // endereço da interconexão
        .data_i(mem_data_to_mem),      // dados de escrita da interconexão
        .data_o(mem_data_from_mem),    // dados lidos pela memória, para a interconexão
        .ack_o()                       // sinal de confirmação da memória (não usado neste design)
    );

    // Instanciação do módulo Periférico de LEDs
    // Conecta-se ao barramento e expõe os LEDs externos [L35]
    led_peripheral u_led_peripheral (
        .clk(clk),
        .rst_n(rst_n),
        .rd_en_i(periph_rd_en),          // habilita leitura da interconexão
        .wr_en_i(periph_wr_en),          // habilita de escrita da interconexão
        .addr_i(periph_addr),            // endereço da interconexão
        .data_i(periph_data_to_periph),  // dados de escrita da interconexão
        .data_o(periph_data_from_periph),// dados lidos do periférico, para a interconexão
        .leds_o(leds_from_periph)        // saída dos LEDs do periférico para o mundo externo
    );

    // Conexão da saída de LEDs do periférico para a saída do top-level module
    assign leds = leds_from_periph;

endmodule
