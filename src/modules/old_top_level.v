// `define A 1'b0
// `define B 1'b1

// module top_level(
//     input clk,
//     input RxD,
//     input sw_reset,
//     output TxD,
//     output [15:0] led
// );

//     wire can_receive = 1'b1;
//     wire done_reading;
//     wire done_transmitting;
//     wire [7:0] data_byte;
//     wire [7:0] byte_to_transmit;
//     wire [7:0] operand_a, operand_b;
//     wire result_done;
//     wire [7:0] result;
//     wire [1:0] num_bytes_received;
//     wire reset, sIdle, sIncrement_bytes_received, sWait_to_receive, sCompute, sTransmit;
//     wire sIdle_next, sIncrement_bytes_received_next, sWait_to_receive_next, sCompute_next, sTransmit_next;

//     // Receive the bytes.
//     uart_rx recv(clk, reset, can_receive, RxD, done_reading, data_byte);

//     register #(2, 2'b0) bytes_counter(
//       .q(num_bytes_received), .d(num_bytes_received + 1'b1),
//       .clk(clk), .enable(sIncrement_bytes_received), .reset(reset)
//     );

//     // Register file to store the bytes.
//     regfile received_data(
//       .rsData(operand_a), .rtData(operand_b), .rsNum(A), .rtNum(B), .rdNum(~num_bytes_received[0]),
//       .rdData(data_byte), .rdWriteEnable(sIncrement_bytes_received | sWait_to_receive), .clock(clk), .reset(reset | num_bytes_received == 0)
//     );

//     // Accelerator module.
//     accelerator compute(.clk(clk), .A(operand_a), .B(operand_b), .result(result), .result_done(result_done));

//     // Store the results of the computation.
//     register #(8, 8'b0) result_reg(.q(byte_to_transmit), .d(result), .clk(clk), .enable(result_done), .reset(reset));

//     uart_tx transmitter(clk, reset, sTransmit, byte_to_transmit, , TxD, done_transmitting);

//     // TODO Figure out reset.
//     assign reset = (sw_reset | sTransmit & done_transmitting);
//     assign sIdle_next = (sIdle & ~done_reading) | (sTransmit & done_transmitting) | reset;
//     assign sIncrement_bytes_received_next = (sIdle & done_reading) | (sWait_to_receive & done_reading);
//     assign sWait_to_receive_next = (sIncrement_bytes_received & num_bytes_received != 2'd2);
//     assign sCompute_next = (sCompute & ~result_done) | (sIncrement_bytes_received & num_bytes_received == 2'd2);
//     assign sTransmit_next = (sTransmit & ~done_transmitting) | (sCompute & result_done);

//     register #(1, 1'b1) idle_reg(
//       .q(sIdle), .d(sIdle_next),
//       .clk(clk), .enable(1'b1), .reset(reset)
//     );

//     register #(1, 1'b0) increment_bytes_received_reg(
//       .q(sIncrement_bytes_received), .d(sIncrement_bytes_received_next),
//       .clk(clk), .enable(1'b1), .reset(reset)
//     );

//     register #(1, 1'b0) wait_to_receive_reg(
//       .q(sWait_to_receive), .d(sWait_to_receive_next),
//       .clk(clk), .enable(1'b1), .reset(reset)
//     );

//     register #(1, 1'b0) compute_reg(
//       .q(sCompute), .d(sCompute_next),
//       .clk(clk), .enable(1'b1), .reset(reset)
//     );

//     register #(1, 1'b0) transmit_reg(
//       .q(sTransmit), .d(sTransmit_next),
//       .clk(clk), .enable(1'b1), .reset(reset)
//     );


//     assign led[15] = sw_reset;
//     assign led[7:0] = byte_to_transmit;

// endmodule
