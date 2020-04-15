//
// Module: test_top_level
// 
// Notes:
// - Top level simulation testbench.
// - Uses a working tx to test

// module top_level(
//     input clk,
//     input RxD,
//     input sw_reset,
//     output TxD,
//     output [15:0] led
// );

module test_top_level;
    
  reg        clk      = 0; // Top level system clock input.
  reg        reset   = 1;
  
  reg uart_tx_en = 1'b0;
  reg [7:0] uart_tx_data;
  wire uart_tx_active;
  wire uart_tx_done;
  
  wire uart_bit;
  
  reg uart_rx_en = 1'b0;
  wire uart_rx_done;
  wire [7:0] uart_rx_data;
  
  reg [1:0] bytes_sent = 2'd0;
  
  reg [7:0] result_byte;
  
  wire [15:0] leds;

  wire fpga_bit;
  wire fpga_done;

  // Period and frequency of the system clock.
  always #1 clk = !clk;
  
  assign fpga_done = leds[14];

  initial begin
          #2 reset = 0;      // stop resseting the register 
          #2 ;
  end
  
  always @(posedge clk) begin
    if (reset == 0) begin
        if (uart_tx_done == 1'b1 && bytes_sent == 2) begin
            uart_tx_en = 1'b0;
            uart_rx_en = 1'b1;
        end
        else if (uart_tx_done == 1'b1 && bytes_sent == 1) begin
            uart_tx_data = 8'd7;
            bytes_sent = bytes_sent + 1;
        end
        else if(bytes_sent == 0) begin
            uart_tx_data = 8'd5;
            uart_tx_en = 1'b1;
            bytes_sent = bytes_sent + 1;
        end
        if (bytes_sent == 2 && uart_rx_done == 1) begin
            result_byte = uart_rx_data;
            #50 $finish;
        end
    end
  end
  
  uart_tx cpu_tx(clk, reset, uart_tx_en, uart_tx_data, uart_tx_active, uart_bit, uart_tx_done); // mimics cpu sending data to FPGA
  uart_rx cpu_rx(clk, reset, uart_rx_en, fpga_bit, uart_rx_done, uart_rx_data); // mimics cpu receiving data from FPGA
  top_level fpga(clk, uart_bit, reset, fpga_bit, leds);

endmodule
