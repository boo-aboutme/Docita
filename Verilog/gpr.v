// gpr.v
// general purpose register. 2 reads and 1 write

`default_nettype none

module GPR #(parameter _DELAY = 10)
   (
    input wire 	      iRD_EN,	// read enable
    input wire [2:0]  iRDREG0,	// read register 0
    input wire [2:0]  iRDREG1,	// read register 1
    input wire [2:0]  iWRREG,	// write register
    input wire 	      iWR_EN,	// write enable
    input wire [11:0] iDATA,	// data to be written
    output reg [11:0] oDATA0,	// output from read register 0
    output reg [11:0] oDATA1	// output from read register 1;
    );
   reg [11:0] 		      _r[0:7];
   always @(iRD_EN) #_DELAY begin
      oDATA0 <= _r[iRDREG0];
      oDATA1 <= _r[iRDREG1];
   end
   always @(iWR_EN) #_DELAY begin
      _r[iWRREG] <= iDATA;
   end

endmodule // gpr
