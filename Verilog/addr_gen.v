// addr_gen.v

`include "const.h"

`default_nettype none

module ADDR_GEN #(parameter _DELAY = 700)
  (
   input wire 	     iENABLE,
   input wire        iADD, // 1ならiOP1とiOP2の和。0ならiOP2をそのまま出力
   input wire [11:0] iOP1, // 第1オペランド
   input wire [11:0] iOP2, // 第2オペランド
   output reg [11:0] oRES  // 演算結果
   );

   initial begin
      oRES <= 12'ozzz;
   end

   always @(iENABLE) #_DELAY begin
      if (iENABLE) begin 
	 if (iADD) oRES <= iOP1 + iOP2;
	 else oRES <= iOP2;	// 絶対アドレス
      end
      else oRES <= 12'bzzzz_zzzz_zzzz;
   end
endmodule

`default_nettype wire
