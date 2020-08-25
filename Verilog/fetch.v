// fetch.v

`default_nettype none

module FETCH#(parameter _DELAY = 10)
  (
   input wire 	     iCLK,
   input wire 	     iENABLE,
   input wire [11:0] iADDR,
   output reg [11:0] oADDR
   );
   always @(posedge iCLK) begin
      if (iENABLE) #_DELAY oADDR <= iADDR;
   end
   always @(posedge iCLK) begin
      if (!iENABLE) #_DELAY oADDR <= 12'bzzzz_zzzz_zzzz;
   end
   
endmodule // fetch

`default_nettype wire
