// clk_gen.v

`timescale 1ns/100ps
//`include "const.h"
`default_nettype none

module CLK_GEN#(
		parameter _HALF_CLK = 500, // システムクロック半周期
		parameter _FULL_CLK = _HALF_CLK * 2, // システムクロック周期
		parameter _RESET = 1050, // パワーオン・リセット完了までの時間
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
