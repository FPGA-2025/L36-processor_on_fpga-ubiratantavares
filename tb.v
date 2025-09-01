`timescale 1ns/1ps

module tb();

reg clk = 0;
reg rst_n;
wire [7:0] leds;

reg [7:0] file_data [0:0];
reg [7:0] expected_leds;

always #1 clk = ~clk; // Clock generation

core_top #(
    .MEMORY_FILE("programa.txt") // Specify the memory file
) t (
    .clk(clk),
    .rst_n(rst_n),
    .leds(leds)
);

integer i;
reg [7:0] counter = 0;

initial begin
    $dumpfile("saida.vcd");
    $dumpvars(0, tb);

    $readmemh("teste.txt", file_data); // Read the memory file

    expected_leds = file_data[0];

    //$display("Test case: %b, Expected LEDs: %b, Expected Memory: %h", test_case, expected_leds, expected_memory);

    rst_n = 0; // Reset the system
    #5;
    rst_n = 1; // Release reset

    #50; // wait for the end of the program

    $display("Teste de escrita nos LEDS...");
    if (leds !== expected_leds) begin
        $display("=== ERRO Escrita nos LEDS falhou: esperava %h, obtive %h", expected_leds, leds);
    end else begin
        $display("=== OK Escrita nos LEDS passou: obtive %h", leds);
    end

    $finish; // End simulation
end

endmodule
