`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2020 11:35:44 AM
// Design Name: 
// Module Name: baud_rate_generator
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


module baud_rate_generator(
    input clk, enable,
    output tick // generate a tick at the specified baud rate * oversampling
);
    parameter ClkFrequency = 100000000; //100MHz
    parameter Baud = 115200;
    parameter Oversampling = 1;
    function integer log2(input integer v);
    begin log2=0;
    while(v>>log2)
    log2=log2+1;
    end
    endfunction
    localparam AccWidth = log2(ClkFrequency/Baud)+8; // +/- 2% max timing error over a byte
    reg [AccWidth:0] Acc = 0;
    localparam ShiftLimiter = log2(Baud*Oversampling >> (31-AccWidth));
    // this makes sure Inc calculation doesn't overflow
    localparam Inc = ((Baud*Oversampling << (AccWidth-ShiftLimiter))+
                    (ClkFrequency>>(ShiftLimiter+1)))/(ClkFrequency>>ShiftLimiter);
    
    always @(posedge clk)
        if(enable) Acc <= Acc[AccWidth-1:0] + Inc[AccWidth:0];
        else Acc <= Inc[AccWidth:0];
    assign tick = Acc[AccWidth];
    
endmodule
