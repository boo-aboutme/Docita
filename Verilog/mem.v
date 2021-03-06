// mem.v
// iWR_ENがのHの時書きこむ
// 2114風

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
   
   // RAM内のアクセスタイム
   assign #_ACCTIME _csel_dn = iCSELn;
   
   // データ出力: chip select され、書き込みモードではない場合
   assign oDATA = (!_csel_dn && !iCSELn && iWR_ENn) ? _mem[iADDR] : 12'bz;

   // データ書き込み: chip select され、書き込みモードの場合
   always @(*) begin
      if (!_csel_dn && !iWR_ENn) _mem[iADDR] = iDATA;
   end
endmodule // MEM

`default_nettype wire
