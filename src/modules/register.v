// register: A register which may be reset to an arbirary value
//
// q      (output) - Current value of register
// d      (input)  - Next value of register
// clk    (input)  - Clock (positive edge-sensitive)
// enable (input)  - Load new value? (yes = 1, no = 0)
// reset  (input)  - Synchronous reset    (reset = 1)
//
module register(q, d, clk, enable, reset);

   parameter
            width = 32,
            reset_value = 0;

   output [(width-1):0] q;
   reg    [(width-1):0] q;
   input  [(width-1):0] d;
   input                clk, enable, reset;

   always@(posedge clk)
     if (reset == 1'b1)
       q <= reset_value;
     else if (enable == 1'b1)
       q <= d;

endmodule // register
