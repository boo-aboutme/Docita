// -*- mode:Verilog -*-
// 定数の定義のみを集める

//// Opcode 1
`define OP1_ALU1 3'b000
`define OP1_ALU2 3'b001
`define OP1_MEM  3'b010
`define OP1_SPCL 3'b011
`define OP1_BRCH 3'b100
`define OP1_JUMP 3'b101
`define OP1_SILO 3'b110
`define OP1_SIHI 3'b111

//// Opcode 2
// ALU1系
`define OP2_ADD 3'b000
`define OP2_SUB 3'b001
`define OP2_CMP 3'b010
`define OP2_AND 3'b011
`define OP2_OR  3'b100
`define OP2_XOR 3'b101

// ALU2系
`define OP2_SRL  3'b000
`define OP2_SRA  3'b001
`define OP2_SLL  3'b010
`define OP2_NOT  3'b100
`define OP2_NEG  3'b101
`define OP2_MOVE 3'b110
`define OP2_SEXT 3'b111

// MEM系
`define OP2_LDA  3'b000
`define OP2_LDP  3'b001
`define OP2_STA  3'b010
`define OP2_STP  3'b011

// SPCL系(A)
`define OP2_INCR 3'b000
`define OP2_DECR 3'b001

// SPCL系(B)
`define OP2_RDPC 6'b101
`define OP2_RET  6'b110
`define OP2_HALT 6'b111

// BRCH系
`define COND_BAL  3'b000
`define COND_BZ   3'b001
`define COND_BNZ  3'b010
`define COND_BGT  3'b011
`define COND_BGE  3'b100
`define COND_BGTU 3'b101
`define COND_BGEU 3'b110
//`define COND_BXX 3'b111

// JUMP系
`define OP2_JALA  3'b000
`define OP2_JALP  3'b001

// ALU内部のローカルコード
`define ALU_NOP  4'b0000
`define ALU_ADD  4'b0001
`define ALU_SUB	 4'b0010
`define ALU_AND	 4'b0011
`define ALU_OR	 4'b0100
`define ALU_XOR	 4'b0101
`define ALU_SRL	 4'b0110
`define ALU_SRA	 4'b0111
`define ALU_SLL	 4'b1000
`define ALU_NOT  4'b1001
`define ALU_NEG  4'b1010
`define ALU_MOVE 4'b1011
`define ALU_SILO 4'b1100
`define ALU_SIHI 4'b1101
`define ALU_SEXT 4'b1110
//`define ALU_XXXX 4'b1111

// end of file
