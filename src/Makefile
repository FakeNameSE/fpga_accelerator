
all:
	@echo Choose an option from: tx, rx, top_level

tx : modules/uart_tx.v test/tx_tb.v
	iverilog -o out/ivo $^
	vvp out/ivo
	mv test_tx.vcd out/test_tx.vcd
	open out/test_tx.vcd

rx: modules/uart_rx.v modules/uart_tx.v test/rx_tb.v
	iverilog -o out/ivo $^
	vvp out/ivo
	mv test_rx.vcd out/test_rx.vcd
	open out/test_rx.vcd

top_level: modules/* test/top_level_tb.v
	iverilog -o out/ivo $^
	vvp out/ivo
	mv test_top_level.vcd out/test_top_level.vcd
	open out/test_top_level.vcd

clean:
	rm out/ivo out/*.vcd
