

// 
// Module: test_rx
// 
// Notes:
// - rx simulation testbench.
// - Uses a working tx to test

// module uart_rx 
// (
//    input        i_Clock,
//    input        reset,
//    input        receive,
//    input        i_Rx_Serial,
//    output       o_Rx_DV,
//    output [7:0] o_Rx_Byte
//    );

module test_rx;
    
  reg        clk      = 0; // Top level system clock input.
  reg        reset   = 1;
  reg        can_receive = 0; // enable sending

  wire       uart_rxd  ; // UART receive pin.
  wire       uart_rx_done; // done receiving byte
  wire [7:0] uart_rx_byte; // full byte received
  
  reg uart_tx_en = 0;
  reg [7:0] uart_tx_data; // full data to be sent, the letter 'a'
  wire uart_txd; // UART transmit pin

  assign uart_rxd = uart_txd;

  // Period and frequency of the system clock.
  always #1 clk = !clk;

  initial begin
          $dumpfile("test_rx.vcd");
          $dumpvars(0, test_rx);
          # 2  reset = 0;      // stop reseting the register 

          # 2
            // send 'a'
            uart_tx_en = 1;
            uart_tx_data = 8'b01100001;
            can_receive = 1;

          #200000 // send and receive 'a'

          // send 'b'
            uart_tx_data = 8'b01100010;
            uart_tx_en = 1;
          
          #200000 // send and receive 'b'
          $finish;
  end

  uart_tx i_uart_tx(clk, reset, uart_tx_en, uart_tx_data, , uart_txd, );
  uart_rx i_uart_rx(clk, reset, can_receive, uart_rxd, uart_rx_done, uart_rx_byte);

endmodule
