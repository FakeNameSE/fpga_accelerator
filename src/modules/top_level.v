module top_level(
    input clk,
    input in_RxD,
    input sw_reset,
    output reg out_TxD,
    output reg [15:0] led
);

    localparam s_IDLE = 3'b000;
    localparam s_RX = 3'b001;
    localparam s_COMPUTE = 3'b010;
    localparam s_TX = 3'b011;
    localparam s_CLEANUP = 3'b100;
    
    // two bytes
    reg [7:0] byte_one = 0;
    reg [7:0] byte_two = 0;

    // current state
    reg [2:0] r_SM_Main = 0;
    reg cur_byte = 0;

    // reading wires and regs
    wire done_reading;
    wire [7:0] data_byte;
    reg r_done_reading = 0;

    // computing
    wire [7:0] operand_a, operand_b, result;
    wire result_done;
    reg r_result_done = 0;
    reg [7:0] r_result = 0;
    wire A = 0;
    wire B = 1;

    // transmit
    wire done_transmitting;
    reg r_done_transmitting = 0;
    reg r_transmit = 0;

    // reset flag
    wire reset = sw_reset || r_SM_Main == s_CLEANUP;

    reg RxD;
    wire TxD;

    reg rx_inter;
    reg tx_inter;
    
    reg done_tx_inter;

    always @(posedge clk) begin
        {RxD, rx_inter} <= { rx_inter, in_RxD };
        {out_TxD, tx_inter} <= { tx_inter, TxD };
        led[7:0] <= r_result;
        led[13:8] <= 0;
        {led[14], done_tx_inter} <= {done_tx_inter, done_transmitting};
        led[15] <= sw_reset;
    end

    // Purpose: Control RX state machine
    always @(posedge clk)
        begin
        if (reset)
            begin
            r_SM_Main <= s_IDLE;
            cur_byte <= 0;
            r_done_reading <= 0;
            end
        else 
            begin
            case (r_SM_Main)
                s_IDLE :
                begin
                    r_SM_Main <= s_RX;
                    cur_byte <= 0;
                    byte_one <= 0;
                    byte_two <= 0;
                    r_done_reading <= 0;
                    r_result <= 0;
                    r_result_done <= 0;
                    r_done_transmitting <= 0;
                    r_transmit <= 0;
                end

                s_RX :
                begin
                if (r_done_reading)
                    begin
                    r_done_reading <= 0;
                    if (cur_byte < 1)
                        begin
                        byte_one <= data_byte;
                        cur_byte <= cur_byte + 1;
                        end
                    else
                        begin
                        byte_two <= data_byte;
                        r_SM_Main <= s_COMPUTE;
                        end
                    end
                else
                    begin
                    r_done_reading <= done_reading;
                    end
                end

                s_COMPUTE :
                begin
                if (r_result_done)
                    begin
                    r_SM_Main <= s_TX;
                    r_result_done <= 0;
                    r_result <= result;
                    end
                else
                    begin
                    r_result_done <= result_done;
                    end
                end

                s_TX :
                    begin
                    if (r_done_transmitting)
                        begin
                        r_SM_Main <= s_CLEANUP;
                        r_transmit <= 0;
                        r_done_transmitting <= 0;
                        end
                    else
                        begin
                        r_transmit <= 1;
                        r_done_transmitting <= done_transmitting;
                        end
                end

                s_CLEANUP :
                begin
                    r_SM_Main <= s_IDLE;
                end

                default :
                    r_SM_Main <= s_IDLE;

            endcase
        end
        end

    uart_rx recv(clk, reset, 1'b1, RxD, done_reading, data_byte);

//    regfile received_data(
//      .rsData(operand_a), .rtData(operand_b), .rsNum(A), .rtNum(B), .rdNum(cur_byte),
//      .rdData(data_byte), .rdWriteEnable(1'b1), .clock(clk), .reset(reset)
//    );

    assign operand_a = byte_one;
    assign operand_b = byte_two;

    accelerator compute(.clk(clk), .A(operand_a), .B(operand_b), .result(result), .done(result_done));

    uart_tx transmitter(clk, reset, r_transmit, r_result, , TxD, done_transmitting);

endmodule
