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