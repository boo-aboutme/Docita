// decode.v

`include "const.h"
`default_nettype none

module CONTROL 
  #(parameter _SD = 50, parameter _LD = 350) // short/long delay
   (
    input wire 	      iCLK,
    input wire 	      iENABLE,
    input wire [11:0] iINST,
    input wire 	      iIS_ZEROn, // すべてのビットがオフ
    input wire 	      iIS_NEG, // ビット11がオン
    input wire 	      iIS_POS, // ビット11がオフで、それ以外のどれかがオン
    output reg 	      oFETCH,
    output reg 	      oDECODE,
    output reg 	      oEXEC,
    output reg 	      oWB,
    output reg [3:0]  oALU_CTRL,
    output reg [2:0]  oRS1,
    output reg [2:0]  oRS2,
    output reg [2:0]  oRD,	// TODO: CMP時に zzz にしたい
    output reg 	      oIS_ALU,
    output reg 	      oIS_LOAD,
    output reg 	      oIS_STORE,
    output reg 	      oIS_IMM,
    output reg [11:0] oIMM,	// 即値
    output reg 	      oIS_TAKEN, // 分岐成立
    output reg 	      oIS_JUMP,
    output reg 	      oIS_RDPC,
    output reg 	      oIS_ABS	// 絶対アドレス
    );
   reg [11:0] 	      _inst_loc; // 命令の保持用
   reg [2:0] 	      _rd;
   reg 		      _en_dest;	    // _rd を oRD に出力するか
   reg 		      _is_zero_loc; // 分岐条件のホールド
   reg 		      _is_neg_loc;  // 分岐条件のホールド
   reg 		      _is_pos_loc;  // 分岐条件のホールド
   reg 		      _is_halt;
   wire 	      _inst_test;
   reg 		      _decode_d;
   reg [3:0] 	      _debug;
   
   initial begin
      _inst_loc <= 12'bzzzz_zzzz_zzzz;
      _is_zero_loc <= 0;
      _is_neg_loc <= 0;
      _is_pos_loc <= 0;
      _is_halt <= 0;
      _decode_d <= 0;
      oFETCH <= 0;
      oDECODE <= 0;
      oEXEC <= 0;
      oALU_CTRL <= `ALU_NOP;
      oIS_ALU <= 0;
      oIS_LOAD <= 0;
      oIS_STORE <= 0;
      oIS_IMM <= 0;
      oWB <= 0;
      _en_dest <= 0;
      oRS1 <= 3'bzzz;
      oRS2 <= 3'bzzz;
      oRD <= 3'bzzz;
      oIMM <= 12'ozzzz;
      oIS_TAKEN <= 0;
      oIS_JUMP <= 0;
      oIS_ABS <= 0;
      oIS_RDPC <= 0;
      _debug <= 0;
   end

   
   // iINSTに有効なアドレスが来ているかどうか
   assign _inst_test = (iINST[0] !== 1'bz) ? 1 : 0;

   always @(posedge iCLK) begin
      if (iENABLE & ~oDECODE & ~oEXEC & ~_is_halt) #_SD begin
	 oWB <= 0;
	 _en_dest <= 0;
	 oIS_ALU <= 0;
	 oIS_IMM <= 0;
	 oIMM <= 12'bzzz;
	 oRD <= 3'bzzz;
	 oIS_TAKEN <= 0;
	 oIS_JUMP <= 0;
	 oIS_RDPC <= 0;
	 oFETCH <= 1;
      end
   end
   always @(posedge iCLK) begin
      if (_inst_test) #_SD begin
	 oFETCH <= 0;
	 oDECODE <= 1;
	 _inst_loc = iINST;
      end
      if (oDECODE) #_SD begin
	 oDECODE <= 0;
	 if (~_is_halt)
	   oEXEC <= 1;
      end
   end
   // 咬ませているディレイが異なるので上のalways文とはまとめない
   always @(posedge iCLK) begin
      if (oDECODE) #_LD begin
	 oRS1 <= 3'bzzz;
	 oRS2 <= 3'bzzz;
      end
   end

   always @(negedge iCLK) begin
      if (oDECODE) #_SD begin
	 _decode_d <= 1;
      end
      if (_decode_d) #_LD begin
	 _decode_d <= 0;
	 _is_zero_loc <= 0;
	 _is_neg_loc <= 0;
	 _is_pos_loc <= 0;
      end
   end

   always @(posedge iCLK) begin
      if (oEXEC) #_SD begin
	 oEXEC <= 0;
	 oIS_ABS <= 0;
	 if (oIS_ALU) begin
	    oALU_CTRL <= `ALU_NOP;
	    if (~oIS_TAKEN) oWB <= 1;
	    if (_en_dest) oRD <= _rd;
	 end
	 if (oIS_LOAD) begin
	    oIS_LOAD <= 0;
	    oWB <= 1;
	    oRD <= _rd;
	 end
	 if (oIS_STORE) begin
	    oIS_STORE <= 0;
	    oWB <= 1;
	 end
	 if (oIS_JUMP | oIS_RDPC) begin
	    if (_en_dest) begin
	       oRD <= _rd;
	       oWB <= 1;
	    end
	 end
      end
   end

   always @(posedge oWB) begin
      _is_zero_loc <= ~iIS_ZEROn;
      _is_neg_loc <= iIS_NEG;
      _is_pos_loc <= iIS_POS;
   end
   
   always @(oDECODE) begin
      // ALU pipeline FETCH/DECODE/EXEC/WB
      if (oDECODE) #_LD begin
	 case (_inst_loc[11:9])
	   `OP1_ALU1: begin
	      oRS1 <= _inst_loc[8:6];
	      oRS2 <= _inst_loc[2:0];
	      oIS_ALU <= 1;
	      _rd <= _inst_loc[8:6];
	      case (_inst_loc[5:3])
		`OP2_ADD:  begin
		   oALU_CTRL <= `ALU_ADD;
		   _en_dest <= 1;
		end
		`OP2_SUB:  begin
		   oALU_CTRL <= `ALU_SUB;
		   _en_dest <= 1;
		end
		`OP2_CMP:  begin
		   oALU_CTRL <= `ALU_SUB;
		   _en_dest <= 0; // 強調
		end
		`OP2_AND:  begin
		   oALU_CTRL <= `ALU_AND;
		   _en_dest <= 1;
		end
		`OP2_OR:   begin
		   oALU_CTRL <= `ALU_OR;
		   _en_dest <= 1;
		end
		`OP2_XOR:  begin
		   oALU_CTRL <= `ALU_XOR;
		   _en_dest <= 1;
		end
		default:  oALU_CTRL <= `ALU_NOP;
	      endcase // case (_inst_loc[5:3])
	   end
	   `OP1_ALU2: begin
	      oRS2 <= _inst_loc[2:0];
	      _rd <= _inst_loc[8:6];
	      _en_dest <= 1;
	      oIS_ALU <= 1;
	      case (_inst_loc[5:3])
		`OP2_SRL:  oALU_CTRL <= `ALU_SRL;
		`OP2_SRA:  oALU_CTRL <= `ALU_SRA;
		`OP2_SLL:  oALU_CTRL <= `ALU_SLL;
		`OP2_NOT:  oALU_CTRL <= `ALU_NOT;
		`OP2_NEG:  oALU_CTRL <= `ALU_NEG;
		`OP2_MOVE: oALU_CTRL <= `ALU_MOVE;
		`OP2_SEXT: oALU_CTRL <= `ALU_SEXT;
		default:   oALU_CTRL <= `ALU_NOP;
	      endcase // case (_inst_loc[5:3])
	   end
	   `OP1_MEM: begin		// load/store
	      oRS1 <= _inst_loc[2:0];	// TODO: oRS1で正しい？
	      oRS2 <= _inst_loc[8:6];	// contains mem address
	      _en_dest <= 1;
	      case (_inst_loc[5:3])
		`OP2_LDA: oIS_LOAD <= 1;
		`OP2_LDP: oIS_LOAD <= 1;
		`OP2_STA: oIS_STORE <= 1;
		`OP2_STP: oIS_STORE <= 1;
		default:  oIS_LOAD <= 1;
	      endcase // case (_inst_loc[5:3])
	   end
           `OP1_SPCL: begin
	      case (_inst_loc[5:3])
		`OP2_INCR: begin
		   oIS_ALU <= 1;
		   oALU_CTRL <= `ALU_ADD;
		   oRS1 <= _inst_loc[8:6];
		   _rd <= _inst_loc[8:6];
		   _en_dest <= 1;
		   oIS_IMM <= 1;
		   oIMM = {9'b000000000, _inst_loc[2:0]}; // unsigned
		end
		`OP2_DECR: begin
		   oIS_ALU <= 1;
		   oALU_CTRL <= `ALU_SUB;
		   oRS1 <= _inst_loc[8:6];
		   _rd <= _inst_loc[8:6];
		   _en_dest <= 1;
		   oIS_IMM <= 1;
		   oIMM = {9'b000000000, _inst_loc[2:0]}; // unsigned
		end
                `OP2_RDPC: begin 
		   oIS_RDPC <= 1;
		   _rd <= _inst_loc[8:6];
		   _en_dest <= 1;
		end
                `OP2_RET: begin 
		   oRS2 <= _inst_loc[2:0];
		   oIS_JUMP <= 1;
		   oIS_ABS <= 1;
		end
                `OP2_HALT: _is_halt <= 1;
	      endcase // case (_inst_loc[5:3])
	   end
           `OP1_BRCH: begin
	      oIS_IMM <= 1;
	      oIMM = {{6{_inst_loc[5]}}, _inst_loc[5:0]}; // sign extention
	      oIS_ABS <= 0;
	      case (_inst_loc[8:6])
		`COND_BAL: oIS_TAKEN = 1;
		`COND_BZ: oIS_TAKEN = _is_zero_loc;
		`COND_BNZ: oIS_TAKEN = ~_is_zero_loc;
		`COND_BGT: oIS_TAKEN = _is_pos_loc;
		`COND_BGE: oIS_TAKEN = _is_zero_loc | _is_pos_loc;
		//`COND_BGTU: // TODO:
		//`COND_BGEU: // TODO:
		default: oIS_TAKEN = 0;
	      endcase // case (_inst_loc[8:6])
	   end
           `OP1_JUMP: begin
	      oRS2 <= _inst_loc[2:0];
	      _rd <= _inst_loc[8:6];
	      _en_dest <= 1;
	      oIS_JUMP <= 1;
	      case (_inst_loc[5:3])
		`OP2_JALA: oIS_ABS <= 1;
		`OP2_JALP: oIS_ABS <= 0;
		default: begin end // 未定義動作
	      endcase // case (_inst_loc[5:3])
	   end
           `OP1_SILO: begin
	      oIS_IMM <= 1;
	      oIMM <= {{6{_inst_loc[5]}}, _inst_loc[5:0]}; // sign extention
	      oIS_ALU <= 1;
	      oALU_CTRL <= `ALU_SILO;
	      _rd <= _inst_loc[8:6];
	   end
           `OP1_SIHI: begin
	      oIS_IMM <= 1;
	      oIMM <= {_inst_loc[5:0], 6'b000000};
	      oIS_ALU <= 1;
	      oALU_CTRL <= `ALU_SIHI;
	      oRS1 <= _inst_loc[8:6];
	      _rd <= _inst_loc[8:6];
	   end
	   default: begin
	   end
	 endcase // case (_inst_loc[11:9])

      end
   end

endmodule // CONTROL

`default_nettype wire
