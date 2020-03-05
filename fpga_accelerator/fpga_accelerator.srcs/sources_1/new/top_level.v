`timescale 1ns / 1ps

module top_level(
    clk,
    led,
    JB
    );

    input clk;                    // 100Mhz onboard clock
    input[5:3] JB;
    output[15:0] led;
    
    wire rx_DV;
    wire tx_DV; 
    wire[7:0] rx_Byte;
    
    uart_rx #(87) rx(clk, JB[4], rx_DV, rx_Byte);
//    uart_tx tx(clk, , JB[4], rx_DV, rx_Byte);
    
    
//      (
//     input       i_Clock,
//     input       i_Tx_DV,
//     input [7:0] i_Tx_Byte, 
//     output      o_Tx_Active,
//     output reg  o_Tx_Serial,
//     output      o_Tx_Done
//     );

    assign led[7:0] = rx_Byte;
    assign led[15] = rx_DV;

endmodule