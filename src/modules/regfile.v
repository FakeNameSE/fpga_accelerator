module regfile (rsData, rtData,
                rsNum, rtNum, rdNum, rdData,
                rdWriteEnable, clock, reset);

   output [7:0]         rsData, rtData;
   input                rsNum, rtNum, rdNum;
   input [7:0]          rdData;
   input                rdWriteEnable, clock, reset;

   reg [7:0]   r[0:7];
   integer              i;

   always@(reset)
     if(reset == 1'b1)
       begin
          for(i = 0; i <= 7; i = i + 1)
            r[i] <= 8'b0;
       end

   assign rsData = r[rsNum];
   assign rtData = r[rtNum];

   wire [7:0] internal_rdData = rdData;     // set up and hold time
   always@(posedge clock)
     begin
        if((reset == 1'b0) && (rdWriteEnable == 1'b1))
          r[rdNum] <= rdData;
     end

endmodule // regfile_3port
