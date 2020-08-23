// alu.v
// add, sub, 
// srl, sra, sll,
// and, or, xor, not, neg

`include "const.h"

`default_nettype none

module ALU #(parameter _DELAY = 700)
  (
   input wire 	     iCLK,
   input wire 	     iENABLE,
   input wire [3:0]  iCTRL,
   input wire [11:0] iOP1, // 第1オペランド
   input wire [11:0] iOP2, // 第2オペランド
   output reg [11:0] oRES, // 演算結果
   output reg 	     oNEG, // 1なら結果は負
   output reg 	     oALL_ZEROn, // 0なら全てのビットが0
   output reg        oANY_POS	 // [11]が0で、[10:0]に1個以上1のビットがある
   );
   reg [12:0] 	     _op1_enh;
   reg [12:0] 	     _op2_enh;
   reg [12:0] 	     _res;

   initial begin
      oNEG <= 0;
      oALL_ZEROn <= 1;
      oANY_POS <= 0;
   end

   always @(iENABLE) #_DELAY begin
      if (iENABLE)
	case (iCTRL)
	  `ALU_ADD:  oRES <= iOP1 + iOP2;	  
	  `ALU_SUB: begin // CMPもここで行う
	     _op1_enh = {1'b1, iOP1[11:0]};
	     _op2_enh = {iOP2[11], iOP2[11:0]};
	     _res = _op1_enh - _op2_enh;
	     oRES = _res[11:0];
	     oNEG = _res[11];
	     oALL_ZEROn = |oRES;
	     oANY_POS = (~oRES[11]) & (|oRES[10:0]);
	  end
	  `ALU_AND:  oRES <= iOP1 & iOP2;
	  `ALU_OR:   oRES <= iOP1 | iOP2;
	  `ALU_XOR:  oRES <= iOP1 ^ iOP2;
	  `ALU_SRL:  oRES <= {1'b0, iOP2[11:1]};
	  `ALU_SRA:  oRES <= {iOP2[11], iOP2[11:1]};
	  `ALU_SLL:  oRES <= {iOP2[10:0], 1'b0};
	  `ALU_NOT:  oRES <= iOP2 ^ 12'o7777;
	  `ALU_NEG:  oRES <= 12'o0000 - iOP2;
	  `ALU_MOVE: oRES <= iOP2; // TODO: 無駄
	  `ALU_SILO: oRES <= iOP2;
	  `ALU_SIHI: oRES <= {iOP2[11:6], iOP1[5:0]};
	  `ALU_SEXT: oRES <= {{6{iOP2[5]}}, iOP2[5:0]};
	  default:   oRES <= 12'bzzzz_zzzz_zzzz;
	endcase // case (iCTRL)
      else begin
	 oRES <= 12'bzzzz_zzzz_zzzz;
	 oNEG <= 0;
	 oALL_ZEROn <= 1;
	 oANY_POS <= 0;
      end
   end
endmodule // exec

`default_nettype wire
