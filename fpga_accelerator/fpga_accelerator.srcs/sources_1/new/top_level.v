`timescale 1ns / 1ps

module top_level(
    input clk,
    input RxD,
//    input sw_reset,
    output TxD,
    output [15:0] led
);
    wire sw_reset = 1'b0;
    wire lock;
    wire uart_rx_done;
    wire [7:0] uart_rx_data;
    wire [7:0] led_byte;
    receiever jatin_rules(uart_rx_data, uart_rx_done, clk, sw_reset, RxD);

    register #(1) store_lock(lock, 1'b1, clk, uart_rx_done, sw_reset);
    register #(8) my_led_reg(led_byte, uart_rx_data, clk, ~lock, sw_reset);
            
    assign led[7:0] = led_byte;
    assign led[15] = sw_reset;
    assign TxD = 1'b1;
    
endmodule

