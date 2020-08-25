# docita_emu.py
from consts import Consts, Opcode, OpcodeError, OperandError, InstError

# for debug
def trace(func):
    def wrapper(*args, **kwargs):
        print("> ", func.__name__)
        if (ll := len(args)) > 0:
            print("# ", "{0}".format(args[1:ll]))
        if len(kwargs) > 0:
            print("% ", kwargs)
        ret = func(*args, **kwargs)
        if ret is not None:
            print("$ ", ret)
        print("< ", func.__name__)
        return ret
    return wrapper


class Docita:
    # TODO:
    # Opcode.NOP
    # Opcode.CLR

    def __init__(self):
        self.reg = [0] * 11    # レジスタ
        self.reg[Consts.PC] = 0 # program counter
        self.reg[Consts.NPC] = 1 # next program counter
        self.ZERO = True
        self.GT_SIGNED = True
        self.GT_UNSIGNED = True
        self.mem = [0] * Consts.MEM_SIZE # main memory
        self.str = None

    def reset(self, start=0):
        self.reg[Consts.PC] = start

    def parse(self, inst):
        key = self.opcode_1(inst)
        if   key == 0b000:
            self.exec_000(inst)
        elif key == 0b001:
            self.exec_001(inst)
        elif key == 0b010:
            self.exec_010(inst)
        elif key == 0b011:
            self.exec_011(inst)
        elif key == 0b100:
            self.exec_100(inst)
        elif key == 0b101:
            self.exec_101(inst)
        elif key == 0b110:
            self.exec_110(inst)
        elif key == 0b111:
            self.exec_111(inst)
        else:
            raise InstError(bin(key), "illegal instruction")

    def exec_000(self, inst):
        rd = self.op_rd(inst)
        rs = self.op_rs(inst)
        svd = sign_ext(self.reg[rd])
        svs = sign_ext(self.reg[rs])
        uvd = w12(self.reg[rd])
        uvs = w12(self.reg[rs])
        if   self.opcode_2(inst) == Consts.OP2_ADD:
            op = Opcode.ADD
            self.reg[rd] = mod_word_size(svd + svs)
        elif self.opcode_2(inst) == Consts.OP2_SUB:
            op = Opcode.SUB
            self.reg[rd] = mod_word_size(svd - svs)
        elif self.opcode_2(inst) == Consts.OP2_CMP:
            op = Opcode.CMP
            self.ZERO = (uvd == uvs)
            self.GT_SIGNED = (svd > svs)
            self.GT_UNSIGNED = (uvd > uvs)
        elif self.opcode_2(inst) == Consts.OP2_AND:
            op = Opcode.AND
            self.reg[rd] = mod_word_size(self.reg[rd] & self.reg[rs])
        elif self.opcode_2(inst) == Consts.OP2_OR:
            op = Opcode.OR
            self.reg[rd] = mod_word_size(self.reg[rd] | self.reg[rs])
        elif self.opcode_2(inst) == Consts.OP2_XOR:
            op = Opcode.XOR
            self.reg[rd] = mod_word_size(self.reg[rd] ^ self.reg[rs])
        else:
            raise InstError(inst, "illegal instruction")
        self.str = '{0} %r{1}, %r{2}'.format(Consts.mnemonic[op], rd, rs)

    def exec_001(self, inst):
        rd = self.op_rd(inst)
        rs = self.op_rs(inst)
        if  self.opcode_2(inst) == Consts.OP2_SRL:
            op = Opcode.SRL
            self.reg[rd] = (self.reg[rs] >> 1) & 0b0111_1111_1111
        elif self.opcode_2(inst) == Consts.OP2_SRA:
            op = Opcode.SRA
            msb = self.reg[rs] & 0b1000_0000_0000
            self.reg[rd] = mod_word_size(self.reg[rs] >> 1) | msb
        elif self.opcode_2(inst) == Consts.OP2_SLL:
            op = Opcode.SLL
            self.reg[rd] = mod_word_size(self.reg[rs] << 1)
        elif self.opcode_2(inst) == Consts.OP2_NOT:
            op = Opcode.NOT
            self.reg[rd] = mod_word_size(self.reg[rs] ^ 0b1111_1111_1111)
        elif self.opcode_2(inst) == Consts.OP2_NEG:
            op = Opcode.NEG
            self.reg[rd] = mod_word_size(0b1_0000_0000_0000 - self.reg[rs])
        elif self.opcode_2(inst) == Consts.OP2_MOVE:
            op = Opcode.MOVE
            self.reg[rd] = mod_word_size(self.reg[rs])
        elif self.opcode_2(inst) == Consts.OP2_SEXT:
            op = Opcode.SEXT
            upper = 0b1111_1100_0000 if (self.reg[rs] & 0b10_0000) else 0
            self.reg[rd] = upper | ( self.reg[rs] & 0b11_1111)
        else:
            raise InstError(inst, "illegal instruction")
        self.str = '{0} %r{1}, %r{2}'.format(Consts.mnemonic[op], rd, rs)

    def exec_010(self, inst):
        tgt = self.op_rd(inst)
        idx = self.op_rs(inst)
        addr = None
        if   self.opcode_2(inst) == Consts.OP2_LDA:
            op = Opcode.LDA
            addr = self.reg[idx]
            self.reg[tgt] = self.mem[addr]
            self.str = '{0} %r{1}, [%r{2}]'.format(Consts.mnemonic[op], tgt, idx)
        elif self.opcode_2(inst) == Consts.OP2_LDP:
            op = Opcode.LDP
            addr = mod_word_size(self.reg[Consts.PC] + self.reg[idx])
            self.reg[tgt] = self.mem[addr]
            self.str = '{0} %r{1}, [%r{2}]'.format(Consts.mnemonic[op], tgt, idx)
        elif self.opcode_2(inst) == Consts.OP2_STA:
            op = Opcode.STA
            addr = self.reg[tgt]
            self.mem[addr] = self.reg[idx]
            self.str = '{0} [%r{1}], %r{2}'.format(Consts.mnemonic[op], tgt, idx)
        elif self.opcode_2(inst) == Consts.OP2_STP:
            op = Opcode.STP
            addr = mod_word_size(self.reg[Consts.PC] + self.reg[tgt])
            self.mem[addr] = self.reg[idx]
            self.str = '{0} [%r{1}], %r{2}'.format(Consts.mnemonic[op], tgt, idx)
        else:
            raise InstError(inst, "illegal instruction")
        # TODO: assembler の def lda_ 参照

    def exec_011(self, inst):
        rd = self.op_rd(inst)
        imm = self.uimm3(inst)
        if   self.opcode_2(inst) == Consts.OP2_INCR:
            op = Opcode.INCR
            self.reg[rd] = mod_word_size(self.reg[rd] + imm)
            self.str = '{0} %r{1}, {2}'.format(Consts.mnemonic[op], rd, imm)
        elif self.opcode_2(inst) == Consts.OP2_DECR:
            op = Opcode.DECR
            self.reg[rd] = mod_word_size(self.reg[rd] - imm)
            self.str = '{0} %r{1}, {2}'.format(Consts.mnemonic[op], rd, imm)
        elif self.opcode_2_6(inst) == Consts.OP2_RDPC:
            op = Opcode.RDPC
            self.reg[rd] = self.reg[Consts.PC]
            self.str = '{0} %r{1}'.format(Consts.mnemonic[op], rd)
        elif self.opcode_2_6(inst) == Consts.OP2_RET:
            op = Opcode.RET
            self.reg[Consts.NPC] = self.reg[rd]
            self.str = '{0} %r{1}'.format(Consts.mnemonic[op], rd)
        elif self.opcode_2_6(inst) == Consts.OP2_HALT:
            op = Opcode.HALT
            self.str = '{0}'.format(Consts.mnemonic[op])
            raise Halt()
        else:
            raise InstError(inst, "illegal instruction")

    def exec_100(self, inst):
        cond = self.cond(inst)
        imm = self.simm6(inst)
        npc = self.reg[Consts.NPC]
        taken = 'F'
        if   cond == Consts.COND_BAL:
            op = Opcode.BAL
            taken = 'T'
            self.reg[Consts.NPC] = mod_word_size(npc + imm)
        elif cond == Consts.COND_BZ:
            op = Opcode.BZ
            if self.ZERO:
                taken = 'T'
                self.reg[Consts.NPC] = mod_word_size(npc + imm)
        elif cond == Consts.COND_BNZ:
            op = Opcode.BNZ
            if not self.ZERO:
                taken = 'T'
                self.reg[Consts.NPC] = mod_word_size(npc + imm)
        elif cond == Consts.COND_BGT:
            op = Opcode.BGT
            if self.GT_SIGNED:
                taken = 'T'
                self.reg[Consts.NPC] = mod_word_size(npc + imm)
        elif cond == Consts.COND_BGE:
            op = Opcode.BGE
            if self.ZERO or self.GT_SIGNED:
                taken = 'T'
                self.reg[Consts.NPC] = mod_word_size(npc + imm)
        elif cond == Consts.COND_BGTU:
            op = Opcode.BGTU
            if self.GT_UNSIGNED:
                taken = 'T'
                self.reg[Consts.NPC] = mod_word_size(npc + imm)
        elif cond == Consts.COND_BGEU:
            op = Opcode.BGEU
            if self.ZERO or self.GT_UNSIGNED:
                taken = 'T'
                self.reg[Consts.NPC] = mod_word_size(npc + imm)
        else:
            raise InstError(inst, "illegal instruction")
        self.str = '{0} {1:#05x}: {2}'.format(Consts.mnemonic[op], imm, taken)

    def exec_101(self, inst):
        rd = self.op_rd(inst)
        rs = self.op_rs(inst)
        npc = self.reg[Consts.NPC]
        self.reg[rd] = npc  # return address
        if   self.opcode_2(inst) == Consts.OP2_JALA:
            op = Opcode.JALA
            self.reg[Consts.NPC] = self.reg[rs]
        elif self.opcode_2(inst) == Consts.OP2_JALP:
            op = Opcode.JALP
            self.reg[Consts.NPC] = mod_word_size(npc + self.reg[rs])
        else:
            raise InstError(inst, "illegal instruction")
        self.str = '{0} %r{1}, %r{2}'.format(Consts.mnemonic[op], rd, rs)

    def exec_110(self, inst):
        rd = self.op_rd(inst)
        simm = self.simm6(inst)
        uimm = self.uimm6(inst)
        op = Opcode.SILO
        self.reg[rd] = simm & 0xfff
        self.str = '{0} %r{1}, {2:#05x}'.format(Consts.mnemonic[op], rd, uimm)

    def exec_111(self, inst):
        rd = self.op_rd(inst)
        uimm = self.uimm6(inst) # 仕様上は signed
        lower = self.reg[rd] & 0b000000_111111
        op = Opcode.SIHI
        self.reg[rd] = (uimm << 6) | lower
        self.str = '{0} %r{1}, {2:#05x}'.format(Consts.mnemonic[op], rd, uimm)

    def opcode_1(self, inst):
        """get 3-bit primary opcode"""
        return (inst >> 9) & 0b111

    def opcode_2(self, inst):
        """get 3-bit extended opcode"""
        return (inst >> 3) & 0b111

    def opcode_2_6(self, inst):
        """get 6-bit extended opcode"""
        return inst & 0b111111

    def op_rs(self, inst):
        """source register"""
        return (inst >> 0) & 0b111

    def op_rd(self, inst):
        """destination register"""
        return (inst >> 6) & 0b111

    cond = op_rd

    def simm6(self, inst):
        """get 6-bit signed immediate from instruction"""
        imm = inst & 0b111111
        if (imm > 0b10_0000):
            return ( -1 * (0b100_0000 - imm)) & 0xfff # 12bitの範囲で符号拡張
        else:
            return imm

    def uimm6(self, inst):
        """get 6-bit unsigned immediate from instruction"""
        return inst & 0b111111

    def uimm3(self, inst):
        """get 3-bit unsigned immediate from instruction"""
        return inst & 0b111

    def show(self):
        print(" R0: {1:#05x}, R1: {2:#05x}, R2: {3:#05x}, R3: {4:#05x},"
              " R4: {5:#05x}, R5: {6:#05x}, R6: {7:#05x}, R7: {8:#05x}\n".\
              format(self.reg[Consts.PC],
                     self.reg[0], self.reg[1], self.reg[2], self.reg[3],
                     self.reg[4], self.reg[5], self.reg[6], self.reg[7])
        )

    def run(self, start=0):
        self.reset(start)
        try:
            while True:
                self.reg[Consts.NPC] = mod_word_size(self.reg[Consts.PC] + 1)
                pc, npc = self.reg[Consts.PC], self.reg[Consts.NPC]
                inst = self.mem[pc]
                print("PC: {0:#05x}, INST: {1:#05x}, ".format(pc, inst), end='')
                self.parse(inst)
                self.reg[Consts.PC] = self.reg[Consts.NPC]
                print('"{}"'.format(self.str))
                self.show()

        except Halt as e:
            print(self.str)
            print('>>HALT<<')
            return
        except InstError as e:
            raise
        except OpcodeError as e:
            raise
        except OperandError as e:
            raise
        else:
            return

    def disasm(self, pc=0, count=1):
        for i in range(pc, pc + count):
            inst = self.mem[i]
            print("PC: {0:#05x}".format(i), end='')
            self.parse(False, inst)

    def dump(self, addr=0, count=1):
        j = 0
        for i in range(addr, addr + count):
            v = self.mem[i]
            if j % 8 == 0:
                print("PC: {0:#05x}: ".format(i), end='')
            print(" {0:#05x}".format(v), end='')
            if j % 8 == 7:
                print("")
            j += 1

    def load_bin(self, list, start=0):
        self.mem[start:len(list)+start] = list

def mod_word_size(x):
    """modulo by 2 ** 12"""
    return x & Consts.WORD_MASK

def w12(x):
    """12bit unsigned int"""
    return 0b1111_1111_1111 & x

def sign_ext(x):
    """12bit signed int を符号拡張する"""
    return -1 * (0b1_0000_0000_0000 - x) if (x > 0b1000_0000_0000) else x


class Halt(Exception):
    def __init__(self):
        pass


def testrun():
    docita = Docita()
    # test 000
    #docita.load_bin([3112, 3394, 5, 13, 21, 29, 37, 45, 32, 1592])
    # test 001
    #docita.load_bin([3647, 3114, 584, 640, 720, 800, 872, 948,
    #                 3125, 3584, 1016, 1592])
    # test 010
    #docita.load_bin([3647, 3135, 3669, 3194, 1041, 1152, 1592])
    # test 011
    #docita.load_bin([3541, 1985, 1995, 1640, 3208, 1712, 32, 32, 1592])
    # test 100a
    #docita.load_bin([2049, 32, 3671, 3761, 82, 2177, 32, 145, 2369, 32, 82, 2241, 32, 1592])
    # test 100b
    #docita.load_bin([3671, 3761, 81, 2113, 32, 145, 2497, 32, 82, 2305, 32, 1592])
    # test 101
    docita.load_bin([3208, 3712, 2626, 32, 32, 32, 32, 32, 2634, 32, 32, 32, 32, 32, 32, 32, 32, 1592])
    docita.run()
    docita.dump(0xfff, 1)

if __name__ == '__main__':
    testrun()
