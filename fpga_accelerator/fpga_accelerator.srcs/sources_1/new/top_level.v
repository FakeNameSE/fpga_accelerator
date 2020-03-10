`timescale 1ns / 1ps

module top_level(
    input clk,
    input JC_rx,
    output JC_tx,
    output [15:0] led
);
    wire rx_DV;
    wire tx_DV; 
    wire[7:0] rx_Byte;
    wire lock;
    wire [7:0] led_byte;
    
    uart_rx #(870) rx(clk, JB_rx, rx_DV, rx_Byte);
    
    // q      (output) - Current value of register
    // d      (input)  - Next value of register
    // clk    (input)  - Clock (positive edge-sensitive)
    // enable (input)  - Load new value? (yes = 1, no = 0)
    // reset  (input)  - Asynchronous reset    (reset = 1)
    //
    register #(1) store_rx_dv(lock, 1'b1, clk, rx_DV, 1'b0);
    register #(8) my_led_reg(led_byte, rx_Byte, clk, ~lock, 1'b0);
    // uart_tx tx(clk, , JB[4], rx_DV, rx_Byte);
    
    
//      (
//     input       i_Clock,
//     input       i_Tx_DV,
//     input [7:0] i_Tx_Byte, 
//     output      o_Tx_Active,
//     output reg  o_Tx_Serial,
//     output      o_Tx_Done
//     );

    assign led[7:0] = led_byte;
    assign led[15] = ~lock;
    assign JB_tx = 0;

endmodule

