.global _boot
.section .text
_boot:
    lui t0, 0x80000       # Endereço base do periférico de LEDs
    #i t1, 0b00001111     # Valor a ser escrito nos LEDs (acende os 4 primeiros LEDs)
	addi t1, x0, 0b00001111
    sw t1, 0(t0)          # Escreve o valor de t1 no registrador de LEDs
loop:
    j loop                # Loop infinito para encerrar o programa
