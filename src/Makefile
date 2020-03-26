
all:
	@echo Choose an option from: tx, rx

tx : rtl/uart_tx.v test/tx_tb.v
	iverilog -o out/ivo $^
	vvp out/ivo
	mv test_tx.vcd out/test_tx.vcd
	open out/test_tx.vcd

rx: rtl/uart_rx.v rtl/uart_tx.v test/rx_tb.v
	iverilog -o out/ivo $^
	vvp out/ivo
	mv test_rx.vcd out/test_rx.vcd
	open out/test_rx.vcd

clean:
	rm out/ivo out/*.vcd
