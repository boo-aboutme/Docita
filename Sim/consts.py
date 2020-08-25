from enum import IntEnum, auto


class Opcode(IntEnum):
    ADD  = auto()
    SUB  = auto()
    CMP  = auto()
    AND  = auto()
    OR   = auto()
    XOR  = auto()
    SRL  = auto()
    SRA  = auto()
    SLL  = auto()
    NOT  = auto()
    NEG  = auto()
    MOVE = auto()
    SEXT = auto()
    LDA  = auto()
    LDP  = auto()
    STA  = auto()
    STP  = auto()
    INCR = auto()
    DECR = auto()
    RDPC = auto()
    RET  = auto()
    HALT = auto()
    BAL  = auto()
    BZ   = auto()
    BNZ  = auto()
    BGT  = auto()
    BGE  = auto()
    BGTU = auto()
    BGEU = auto()
    JALA = auto()
    JALP = auto()
    SILO = auto()
    SIHI = auto()
    # pseudo instructions
    NOP  = auto()                # move %rd, %rd
    CLR  = auto()                # xor %rd, %rd


class Consts:
    # ワード幅
    WORD_SIZE = 12
    # 1ワードで表せる最大値 (unsigned/signed)
    UWORD_MAX = 2 ** WORD_SIZE - 1
    SWORD_MAX = 2 ** (WORD_SIZE - 1) - 1
    # ワード幅のマスク
    WORD_MASK = 0xfff           # UWORD_MAX と同じ
    # メモリの最大量
    MEM_SIZE = 2 ** WORD_SIZE
    # メモリの最大番地
    MEM_MAX = MEM_SIZE - 1


    R0  = 0
    R1  = 1
    R2  = 2
    R3  = 3
    R4  = 4
    R5  = 5
    R6  = 6
    R7  = 7
    # special registers
    PC  = 8
    NPC = 9

    # 000系
    OP2_ADD  = 0b000
    OP2_SUB  = 0b001
    OP2_CMP  = 0b010
    OP2_AND  = 0b011
    OP2_OR   = 0b100
    OP2_XOR  = 0b101
    # 001系
    OP2_SRL  = 0b000
    OP2_SRA  = 0b001
    OP2_SLL  = 0b010
    OP2_NOT  = 0b100
    OP2_NEG  = 0b101
    OP2_MOVE = 0b110
    OP2_SEXT = 0b111
    # 010系
    OP2_LDA  = 0b000
    OP2_LDP  = 0b001
    OP2_STA  = 0b010
    OP2_STP  = 0b011
    # 011系(A)
    OP2_INCR = 0b000
    OP2_DECR = 0b001
    # 011系(B)
    OP2_RDPC = 0b101000
    OP2_HALT = 0b111000
    # 011系(C)
    OP2_RET  = 0b000110
    # 100系
    COND_BAL  = 0b000
    COND_BZ   = 0b001
    COND_BNZ  = 0b010
    COND_BGT  = 0b011
    COND_BGE  = 0b100
    COND_BGTU = 0b101
    COND_BGEU = 0b111

    # 101系
    OP2_JALA  = 0b000
    OP2_JALP  = 0b001

    mnemonic = {Opcode.ADD  : 'add',
                Opcode.SUB  : 'sub',
                Opcode.CMP  : 'cmp',
                Opcode.AND  : 'and',
                Opcode.OR   : 'or',
                Opcode.XOR  : 'xor',
                Opcode.SRL  : 'srl',
                Opcode.SRA  : 'sra',
                Opcode.SLL  : 'sll',
                Opcode.NOT  : 'not',
                Opcode.NEG  : 'neg',
                Opcode.MOVE : 'move',
                Opcode.SEXT : 'sext',
                Opcode.LDA  : 'lda',
                Opcode.LDP  : 'ldp',
                Opcode.STA  : 'sta',
                Opcode.STP  : 'stp',
                Opcode.INCR : 'incr',
                Opcode.DECR : 'decr',
                Opcode.RDPC : 'rdpc',
                Opcode.RET  : 'ret',
                Opcode.HALT : 'halt',
                Opcode.BAL  : 'bal',
                Opcode.BZ   : 'bz',
                Opcode.BNZ  : 'bnz',
                Opcode.BGT  : 'bgt',
                Opcode.BGE  : 'bge',
                Opcode.BGTU : 'bgtu',
                Opcode.BGEU : 'bgeu',
                Opcode.JALA : 'jala',
                Opcode.JALP : 'jalp',
                Opcode.SILO : 'silo',
                Opcode.SIHI : 'sihi',
                Opcode.NOP  : 'nop',
                Opcode.CLR  : 'clr',
    }

class InstError(Exception):
    def __init__(self, expression, message):
        pass                    # TODO

class OpcodeError(Exception):
    def __init__(self, expression, message):
        pass                    # TODO

class OperandError(Exception):
    def __init__(self, expression, message):
        pass                    # TODO

if __name__ == '__main__':
    c = Consts()
