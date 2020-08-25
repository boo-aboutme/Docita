// clk_gen.v

`timescale 1ns/100ps
//`include "const.h"
`default_nettype none

module CLK_GEN#(
		parameter _HALF_CLK = 500, // half width of system clock
		parameter _FULL_CLK = _HALF_CLK * 2, // system clock width
		parameter _RESET = 1050, // from power-on to reset sequence completion
		parameter _delay = 10
		)
   (
    output reg oCLK,
    output reg oRESETn
    );
   initial begin
      oCLK <= 0;
      oRESETn <= 0;
      forever #_HALF_CLK oCLK = ~oCLK;
   end

   initial begin
      #_RESET oRESETn = 1;
   end
endmodule 

`default_nettype wire
