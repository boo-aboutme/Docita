// decode.v

`include "const.h"
`default_nettype none

module DECODE(
	      input wire 	iCLK,
	      input wire 	iENABLE,
	      input wire [11:0] iINST,
	      output reg 	oALLOC,
	      output reg 	oEXEC,
	      output reg 	oWB,
	      output reg [3:0] 	oALU_CTRL,
	      output reg [2:0] 	oRS1,
	      output reg [2:0] 	oRS2,
	      output reg 	oEN_DEST, 
	      output reg [2:0] 	oRD,
	      output reg 	oIS_ALU,
	      output reg 	oIS_LOAD
	      );
   reg 				_p1;
   reg 				_p2;
   reg 				_p3;
   reg 				_p4;
   reg [11:0] 			_inst_src;
   
   initial begin
      _p1 <= 0;
      _p2 <= 0;
      _p3 <= 0;
      _p4 <= 0;
      _inst_src <= 12'bzzzz_zzzz_zzzz;
      oALLOC <= 0;
      oEXEC <= 0;
      oWB <= 0;
      oALU_CTRL <= 0;
      oIS_ALU <= 0;
      oIS_LOAD <= 0;
      oEN_DEST <= 0;
      oRS1 <= 0;
      oRS2 <= 0;
      oEN_DEST <= 0;
      oRD <= 0;
   end
   
   always @(posedge iCLK) begin
      if (iENABLE) begin
	 _p4 <= 0;
	 _p1 <= 1;
	 _inst_src <= iINST;
      end
      if (_p1) begin
	 _p2 <= 1;
      end
      if (_p2) begin
	 _p1 <= 0;
	 _p3 <= 1;
	 oIS_LOAD <= 0;
	 oALLOC <= 0;
      end
      if (_p3) begin
	 _p2 <= 0;
	 _p4 <= 1;
	 _inst_src <= 12'bzzzz_zzzz_zzzz;
	 oALU_CTRL <= `ALU_NOP;
	 oRS1 <= 3'bzzz;
	 oRS2 <= 3'bzzz;
	 oEXEC <= 0;
      end
      if (_p4) begin
	 _p3 <= 0;
	 oRD <= 3'bzzz;
	 oIS_ALU <= 0;
	 oWB <= 0;
      end
   end

   always @(negedge iCLK) begin
      // ALU pipeline FETCH/DECODE/ALLOC/EXEC/WB
      case (_inst_src[11:9])
	3'b000: begin		// arithmetic/logic
	   oALLOC <= _p1;
	   oEXEC <= _p1 & _p2;
	   oWB <= _p3;
	   oRS1 <= _inst_src[8:6];
	   oRS2 <= _inst_src[2:0];
	   oRD <= _inst_src[8:6];
	   oEN_DEST <= 1;
	   oIS_ALU <= 1;
	   case (_inst_src[5:3])
	     `OP2_ADD: oALU_CTRL <= `ALU_ADD;
	     `OP2_SUB: oALU_CTRL <= `ALU_SUB;
	     `OP2_CMP: oALU_CTRL <= `ALU_SUB;
	     `OP2_AND: oALU_CTRL <= `ALU_AND;
	     `OP2_OR:  oALU_CTRL <= `ALU_OR;
	     `OP2_XOR: oALU_CTRL <= `ALU_XOR;
	     default:  oALU_CTRL <= `ALU_NOP;
	   endcase // case (_inst_src[5:3])
	end
	//3'b001: begin		// shift/logic
	//end
	3'b010: begin		// load/store
	   oALLOC <= _p1;
	   oWB <= _p3;
	   oRS2 <= _inst_src[2:0];
	   oRD <= _inst_src[8:6];
	   oEN_DEST <= 1;
	   oIS_LOAD <= 1;
	end
	default: begin
	   oALLOC <= 0;
	end
      endcase // case (_inst_src[11:9])
   end
endmodule // DECODE

`default_nettype wire
