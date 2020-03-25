`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 03/24/2020 08:17:00 PM
// Design Name: 
// Module Name: receiver
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


module receiver(
    output reg [7:0] rx_byte, // byte received
    output reg rx_done, // byte done being sent
    
    input clk, //UART input clock
    input reset, // reset signal
    input RxD
    );
    
    //internal variables
    reg [3:0] bitcounter; //4 bits counter to count up to 9 (1 start bit + 8 bits of data)
    reg [13:0] counter; //14 bits counter to count the baud rate, counter = clock / baud rate = 
    reg state, nextstate; // initial & next state variable
    // 9 bits data needed to be shifted out during transmission.
    reg [8:0] leftshiftreg;
    reg shift; //shift signal to start bit shifting in UART
    reg clear; //clear signal to start reset the bitcounter for UART transmission


    //UART transmission logic
    always @ (posedge clk) 
    begin 
        if (reset) 
           begin // reset is asserted (reset = 1)
            state <=0; // state is idle (state = 0)
            counter <=0; // counter for baud rate is reset to 0 
            bitcounter <=0; //counter for bit transmission is reset to 0
           end
        else begin
             counter <= counter + 1; //counter for baud rate generator start counting 
                if (counter >= 10415) //if count to 10416 (from 0 to 10415)
                   begin 
                      state <= nextstate; //previous state change to next state
                      counter <=0; // reset couter to 0
                      if (clear)
                        bitcounter <=0; // reset the bitcounter if clear is asserted
                      if (shift) 
                         begin // if shift is asserted
                            leftshiftreg <= leftshiftreg << 1; //left shift the data as we transmit the data from lsb
                            bitcounter <= bitcounter + 1; //count the bitcounter
                         end
                   end
             end
    end
    
    //state machine

    always @ (posedge clk) //trigger by positive edge of clock, 
    //always @ (state or bitcounter or transmit)
    begin
    shift <=0; // set shift equal to 0 at the beginning
    clear <=0; // set clear equal to 0 at the beginning
    rx_done <= 0;
    case (state)
        0: begin // idle state
             if (~RxD && ~reset) // start bit: rxd low and reset is off
             begin
                 nextstate <= 1; // Move to receiving state
                 shift <=0; // set shift to 0 so no shift ready yet
                 clear <=0; // set clear to 0 to avoid clear any counter
             end 
             else begin
                nextstate <= 0; // next state is back to idle state
             end
           end
        1: begin  // receive state
             if (bitcounter >=9) // check if receive is complete or not. If complete
                begin
                nextstate <= 0; // set nextstate back to 0 to idle state
                clear <=1; // set clear to 1 to clear all counters
                rx_done <= 1;
                rx_byte <= leftshiftreg[7:0];
                end 
		     else // if receive is not complete 
		        begin
                nextstate <= 1; // set nextstate to 1 to stay in transmit state
                leftshiftreg[0] <= RxD; // merge the bit into the receieve reg
                shift <=1; // set shift to 1 to continue shifting the data
                end
              end
         default: nextstate <= 0;                      
    endcase
    end

endmodule
