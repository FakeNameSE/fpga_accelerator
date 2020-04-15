

// 
// Module: 
// 
// Notes:
// - tx level simulation testbench.
//

// module uart_tx 
//   (
//    input       i_Clock,
//    input        reset,
//    input       i_Tx_DV, // can we send?
//    input [7:0] i_Tx_Byte, // what to send
//    output      o_Tx_Active, // are we sending?
//    output reg  o_Tx_Serial, // output bit by bit
//    output      o_Tx_Done // are we done sending a bit?
//    );

module test_tx;
    
  reg        clk      = 0; // Top level system clock input.
  reg        reset   = 1;
  reg        uart_tx_en = 0; // enable sending
  reg  [7:0] uart_tx_data; // The recieved data.

  wire       uart_txd  ; // UART transmit pin.
  wire       uart_tx_active; // module sending
  wire       uart_tx_done; // done sending byte

  // Period and frequency of the system clock.
  always #1 clk = !clk;

  initial begin
          $dumpfile("test_tx.vcd");
          $dumpvars(0, test_tx);
          #2  reset = 0;      // stop reseting the register 

          #2
            // send 'a'
            uart_tx_data = 8'b01100001;
            uart_tx_en = 1;

          #104160
          $finish;
  end

  uart_tx i_uart_tx( clk, reset, uart_tx_en, uart_tx_data, uart_tx_active, uart_txd, uart_tx_done);

endmodule
