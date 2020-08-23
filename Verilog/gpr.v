// gpr.v
// 汎用レジスタファイル 2read1write

`default_nettype none

module GPR #(parameter _DELAY = 10)
   (
    input wire 	      iRD_EN, // read enable
    input wire [2:0]  iRDREG0, // 読み出しレジスタ番号0
    input wire [2:0]  iRDREG1, // 読み出しレジスタ番号1
    input wire [2:0]  iWRREG, // 書きこみレジスタ番号
    input wire 	      iWR_EN, // write enable
    input wire [11:0] iDATA, // 書きこみデータ
    output reg [11:0] oDATA0, // 読み出しレジスタ番号0の出力
    output reg [11:0] oDATA1 // 読み出しレジスタ番号1の出力
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
