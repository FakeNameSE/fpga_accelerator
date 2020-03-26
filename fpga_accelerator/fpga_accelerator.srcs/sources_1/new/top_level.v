`timescale 1ns / 1ps

module top_level(
    input clk,
    input RxD,
    input sw_reset,
    output TxD,
    output [15:0] led
);
    
    wire can_receive = 1'b1;
    wire done_reading;
    wire [7:0] data_byte;
    uart_rx recv(clk, sw_reset, can_receive, RxD, done_reading, data_byte);
    
    assign led[7:0] = data_byte;
    assign led[15] = sw_reset;
   
    // adds a clock of delay between when done_reading is set
    // this ensure synchronization as uart_rx changes done_reading
    reg can_transmit;
    reg [7:0] send_data = 0;
    always @(posedge clk)
        begin
        can_transmit <= done_reading;
        send_data <= data_byte;
        end
        
    uart_tx send(clk, sw_reset, can_transmit, send_data, , TxD, );
    
endmodule
