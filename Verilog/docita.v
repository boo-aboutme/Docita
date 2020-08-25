// docita.v
// CPU

`include "gpr.v"
`include "alu.v"
`include "addr_gen.v"
`include "d12.v"
`include "control.v"
`timescale 1ns/100ps

`define _HALF_CLK 500

module DOCITA
  #(parameter _SD = 50, parameter _LD = 350) // short/long delay
   (
    input wire 	       iCLK,
    input wire 	       iRESETn,
    input wire [11:0]  iDATA, // MEMから受け取るデータ
    output wire [11:0] oDATA, // MEMに与えるデータ
    output wire [11:0] oADDR,
    output wire        oCSELn,
    output wire        oWR_ENn
    );				// TODO

   wire _fetch, _decode, _exec, _wb;

   wire [11:0] _data_d;		   // MEMが返したデータ(遅延)
   wire [11:0] _inst;		   // 命令
   wire [3:0]  _alu_ctrl;	   // ALU制御コマンド
   wire [2:0]  _rsrc1;		   // レジスタファイルの第1ソースレジスタ
   wire [2:0]  _rsrc2;		   // 第2ソースレジスタ
   wire [2:0]  _rdest;		   // ディスティネーションレジスタ
   wire [11:0] _opsrc1, _opsrc1_d; // 第1ソースレジスタの値/(遅延)
   wire [11:0] _opsrc2, _opsrc2_d; // 第2ソースレジスタの値/(遅延)
   wire [11:0] _opsrc2_imm_d;	   // 第2ソースの値/リテラル値
   wire [11:0] _imm, _imm_d;	   // リテラル値/(遅延)
   wire [11:0] _alu_result;
   wire        _en_dest;
   wire        _is_alu;
   wire        _is_imm;
   wire        _is_load;
   wire        _is_store;
   wire        _is_branch;
   wire        _is_jump;
   wire        _is_rdpc;
   wire        _neg;
   wire        _all_zero_n;
   wire        _any_pos;
   wire        _is_taken;
   wire        _is_abs;
   wire [11:0] _res;
   wire [11:0] _rdata;
   wire        _rd_gpr;

   wire [11:0] _st_addr;	// ストア先アドレス

   reg [11:0]  _pc;             // プログラムカウンタ
   reg [11:0]  _npc;		// ネクストプログラムカウンタ
   wire [11:0]  _tpc;		// ジャンプ先アドレス

   initial begin
      _pc  <= 12'o000;
      _npc <= 12'o001;
   end

   always @(negedge _exec) #_SD begin
      if (iRESETn) begin
	 if (_is_taken | _is_jump) begin
            _pc <= _tpc;
            _npc <= _tpc + 1;
	 end
	 else begin
	    _pc <= _npc;
	    _npc <= _npc + 1;
	 end
      end
   end

   CONTROL ctrl(
		.iCLK(iCLK),
                .iENABLE(iRESETn),
		.iINST(_inst),
		.iIS_ZEROn(_all_zero_n),
		.iIS_POS(_any_pos),
		.oFETCH(_fetch),
		.oDECODE(_decode),
		.oEXEC(_exec),
		.oWB(_wb),
		.oIS_ALU(_is_alu),
		.oIS_LOAD(_is_load),
		.oIS_STORE(_is_store),
		.oIS_IMM(_is_imm),
		.oALU_CTRL(_alu_ctrl),
		.oRS1(_rsrc1),
		.oRS2(_rsrc2),
		.oRD(_rdest),
		.oIMM(_imm),
		.oIS_TAKEN(_is_taken),
		.oIS_JUMP(_is_jump),
		.oIS_ABS(_is_abs),
		.oIS_RDPC(_is_rdpc)
		);

   assign oADDR = (_fetch | _decode) ? _pc :
		  (_exec) ? _st_addr : 12'ozzz; // wb のタイミングではハイインピーダンス
   assign oCSELn = ~(_fetch |(_exec & (_is_load | _is_store)));
   assign #`_HALF_CLK _decode_d = _decode;
   assign oWR_ENn = ~(_is_store & _exec);

   assign _inst = (_fetch) ? iDATA : 12'ozzz;
   assign _rd_gpr = _decode_d;
   assign _acc_alu = _exec & _is_alu; // TODO:

   D12 ddata(.iCLK(iCLK), .iBUS(iDATA), .oBUS(_data_d));
   assign _rdata = _is_alu ? _alu_result : // ALU出力
		   (_is_jump | _is_rdpc) ? _npc : // 次の命令のアドレス
		   _data_d;	     // ロードしたデータ

   GPR greg(
	    .iRD_EN(_rd_gpr),
	    .iRDREG0(_rsrc1),
	    .iRDREG1(_rsrc2),
	    .iWRREG(_rdest),
	    .iWR_EN(_wb),	// TODO: .iWR_EN(_wb & _en_dest), ?
	    .iDATA(_rdata),
	    .oDATA0(_opsrc1),
	    .oDATA1(_opsrc2)
	    );

   // クロック半周期分のディレイ
   D12 dsrc1(.iCLK(iCLK), .iBUS(_opsrc1), .oBUS(_opsrc1_d));
   D12 dsrc2(.iCLK(iCLK), .iBUS(_opsrc2), .oBUS(_opsrc2_d));
   D12 dsrci(.iCLK(iCLK), .iBUS(_imm), .oBUS(_imm_d));
   assign _opsrc2_imm_d = (_is_imm) ? _imm_d : _opsrc2_d;

   assign oDATA = _opsrc1;
   assign _st_addr = _opsrc2_imm_d;

   ALU alu(
	   .iCLK(iCLK),
	   .iENABLE(_exec),
	   .iCTRL(_alu_ctrl),
	   .iOP1(_opsrc1_d),
	   .iOP2(_opsrc2_imm_d),
	   .oRES(_alu_result),
	   .oNEG(_neg),
	   .oALL_ZEROn(_all_zero_n),
	   .oANY_POS(_any_pos)
	   );

   ADDR_GEN adgen(
                  .iENABLE(_is_taken | _is_jump),
		  .iADD(~_is_abs), // TODO:
                  .iOP1(_npc),
                  .iOP2(_opsrc2_imm_d),
                  .oRES(_tpc)
		  );

endmodule // DOCITA
