// mem.v
// write when iWR_EN is 1
// 2114-like memory unit

`include "const.h"
`default_nettype none

module MEM #(parameter _ACCTIME = 350)
   (
    input wire [11:0]  iADDR, // address bus
    input wire [11:0]  iDATA, // data-in bus
    input wire 	       iCSELn, // chip select (neg)
    input wire 	       iWR_ENn, // write enable (neg)
    output wire [11:0] oDATA   // data-out bus
    );
   reg [11:0] 	       _mem[4095:0];	// 4K word
   wire 	       _csel_dn;	// delayed chip select (neg)
   
   // access time within memory
   assign #_ACCTIME _csel_dn = iCSELn;
   
   // data read is enable when the chip is selected and not write mode
   assign oDATA = (!_csel_dn && !iCSELn && iWR_ENn) ? _mem[iADDR] : 12'bz;

   // data write is enanle when the chip is selected and write mode
   always @(*) begin
      if (!_csel_dn && !iWR_ENn) _mem[iADDR] = iDATA;
   end
endmodule // MEM

`default_nettype wire
