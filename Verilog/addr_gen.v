// addr_gen.v

`include "const.h"

`default_nettype none

module ADDR_GEN #(parameter _DELAY = 700)
  (
   input wire 	     iENABLE,
   input wire        iADD, // 1: add iOP1 and iOP2, 0: iOP2 goes through
   input wire [11:0] iOP1, // operand 1
   input wire [11:0] iOP2, // operand 2
   output reg [11:0] oRES  // result of operation
   );

   initial begin
      oRES <= 12'ozzz;
   end

   always @(iENABLE) #_DELAY begin
      if (iENABLE) begin 
	 if (iADD) oRES <= iOP1 + iOP2; // relative address
	 else oRES <= iOP2;	// absolute address
      end
      else oRES <= 12'bzzzz_zzzz_zzzz;
   end
endmodule

`default_nettype wire
