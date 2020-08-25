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
    input wire [11:0]  iDATA, // data input from MEM
    output wire [11:0] oDATA, // data output to MEM
    output wire [11:0] oADDR,
    output wire        oCSELn,
    output wire        oWR_ENn
    );

   wire _fetch, _decode, _exec, _wb;

   wire [11:0] _data_d;		   // delayed data from MEM
   wire [11:0] _inst;		   // instruction
   wire [3:0]  _alu_ctrl;	   // ALU control command
   wire [2:0]  _rsrc1;		   // source register 1 in register file
   wire [2:0]  _rsrc2;		   // source register 2 in register file
   wire [2:0]  _rdest;		   // destination register
   wire [11:0] _opsrc1, _opsrc1_d; // value in source register 1
   wire [11:0] _opsrc2, _opsrc2_d; // value in source register 2
   wire [11:0] _opsrc2_imm_d;	   // value src2 or literal
   wire [11:0] _imm, _imm_d;	   // literal and delayed literal
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

   wire [11:0] _st_addr;	// address to store data

   reg [11:0]  _pc;             // program counter
   reg [11:0]  _npc;		// next program counter
   wire [11:0]  _tpc;		// jump target address

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
		  (_exec) ? _st_addr : 12'ozzz; // note: high-impedance while wb is on
   assign oCSELn = ~(_fetch |(_exec & (_is_load | _is_store)));
   assign #`_HALF_CLK _decode_d = _decode;
   assign oWR_ENn = ~(_is_store & _exec);

   assign _inst = (_fetch) ? iDATA : 12'ozzz;
   assign _rd_gpr = _decode_d;
   assign _acc_alu = _exec & _is_alu; // TODO:

   D12 ddata(.iCLK(iCLK), .iBUS(iDATA), .oBUS(_data_d));
   assign _rdata = _is_alu ? _alu_result :
		   (_is_jump | _is_rdpc) ? _npc :
		   _data_d;

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

   // delay signals as long as half width of system clock
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
		  .iADD(~_is_abs), // TODO: not implemented
                  .iOP1(_npc),
                  .iOP2(_opsrc2_imm_d),
                  .oRES(_tpc)
		  );

endmodule // DOCITA
