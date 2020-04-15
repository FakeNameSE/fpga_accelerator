// Set Parameter CLKS_PER_BIT as follows:
// CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
// Example: 10 MHz Clock, 115200 baud UART
// (10000000)/(115200) = 87

module uart_rx
  (
   input        i_Clock,
   input        reset,
   input        receive, // can we receive?
   input        i_Rx_Serial, // input serial
   output       o_Rx_DV, // done reading byte (raised for one cycle)
   output [7:0] o_Rx_Byte // buffered byte of data, only reset when a new start bit is detected
   );

  parameter CLKS_PER_BIT = 10416;
  parameter s_IDLE         = 3'b000;
  parameter s_CAN_RECV     = 3'b001;
  parameter s_RX_START_BIT = 3'b010;
  parameter s_RX_DATA_BITS = 3'b011;
  parameter s_RX_STOP_BIT  = 3'b100;
  parameter s_CLEANUP      = 3'b101;

  reg           r_Rx_Data_R = 1'b1;
  reg           r_Rx_Data   = 1'b1;

  reg [17:0]     r_Clock_Count = 0;
  reg [2:0]     r_Bit_Index   = 0; //8 bits total
  reg [7:0]     r_Rx_Byte     = 0;
  reg           r_Rx_DV       = 0;
  reg [2:0]     r_SM_Main     = 0;

  // Purpose: Double-register the incoming data.
  // This allows it to be used in the UART RX Clock Domain.
  // (It removes problems caused by metastability)
  always @(posedge i_Clock)
    begin
      r_Rx_Data_R <= i_Rx_Serial;
      r_Rx_Data   <= r_Rx_Data_R;
    end


  // Purpose: Control RX state machine
  always @(posedge i_Clock)
    begin

    if (reset)
        begin
        r_SM_Main <= s_IDLE;
        end

    else
      begin
      case (r_SM_Main)
        s_IDLE :
          begin
            if (receive)
                begin
                    r_SM_Main <= s_CAN_RECV;
                end
            else
              begin
                r_Rx_Data_R <= 0;
                r_Rx_Data <= 0;
                r_Clock_Count <= 0;
                r_Bit_Index <= 0;
                r_Rx_Byte <= 0;
                r_Rx_DV <= 0;
              end
          end

        s_CAN_RECV:
            begin
            r_Rx_DV       <= 1'b0;
            r_Clock_Count <= 0;
            r_Bit_Index   <= 0;

            if (r_Rx_Data == 1'b0)          // Start bit detected
              begin
              r_SM_Main <= s_RX_START_BIT;
              // r_Rx_Byte <= 0; // I could do this here, but I am going to do it in the s_RX_START_BIT stage as this could be random noise
              end
            else
              r_SM_Main <= s_CAN_RECV;
            end

        // Check middle of start bit to make sure it's still low
        s_RX_START_BIT :
            begin
            r_Bit_Index   <= 0;
            if (r_Clock_Count == (CLKS_PER_BIT-1)/2)
                begin
                if (r_Rx_Data == 1'b0)
                    begin
                    r_Clock_Count <= 0;  // reset counter, found the middle
                    r_SM_Main     <= s_RX_DATA_BITS;
                    end
                else
                    r_SM_Main <= s_CAN_RECV;
                end
            else
                begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_START_BIT;
                end
            end // case: s_RX_START_BIT


        // Wait CLKS_PER_BIT-1 clock cycles to sample serial data
        s_RX_DATA_BITS :
          begin
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_DATA_BITS;
                r_Rx_Byte[r_Bit_Index] <= r_Rx_Data;
              end
            else
              begin
                r_Clock_Count          <= 0;

                // Check if we have received all bits
                if (r_Bit_Index < 7)
                  begin
                    r_Bit_Index <= r_Bit_Index + 1;
                    r_SM_Main   <= s_RX_DATA_BITS;
                  end
                else
                  begin
                    r_Bit_Index <= 0;
                    r_SM_Main   <= s_RX_STOP_BIT;
                  end
              end
          end // case: s_RX_DATA_BITS


        // Receive Stop bit.  Stop bit = 1
        s_RX_STOP_BIT :
          begin
            // Wait CLKS_PER_BIT-1 clock cycles for Stop bit to finish
            if (r_Clock_Count < CLKS_PER_BIT-1)
              begin
                r_Clock_Count <= r_Clock_Count + 1;
                r_SM_Main     <= s_RX_STOP_BIT;
                r_Rx_DV       <= 1'b0;
              end
            else
              begin
                r_Rx_DV       <= 1'b1;
                r_Clock_Count <= 0;
                r_SM_Main     <= s_CLEANUP;
              end
          end // case: s_RX_STOP_BIT


        // Stay here 1 clock, unecessary and may cause clock lag as we spend 11 clocks when we should spend 10
        s_CLEANUP :
          begin
            r_SM_Main <= s_IDLE;
            r_Rx_DV   <= 1'b0;            
          end


        default :
          r_SM_Main <= s_IDLE;

      endcase
    end
    end

  assign o_Rx_DV = r_Rx_DV;
  assign o_Rx_Byte = r_Rx_Byte;

endmodule // uart_rx
