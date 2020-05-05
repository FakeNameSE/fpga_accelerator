`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/04/2020 07:43:38 PM
// Design Name: 
// Module Name: accelerator
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module accelerator(
    input clk,
    input [7:0] A,
    input [7:0] B,
    output [7:0] result,
    output done
    );

    // Right now this finishes in under a cycle, will change this if it becomes more complex.
    assign done = 1'b1;
    assign result = A ^ B;

endmodule
