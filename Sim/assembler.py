from consts import Consts, OperandError, OpcodeError
import re

"""
TODO: 欲しい機能
- テキスト入力(pythonスクリプトじゃない)
- コメント (開始記号 ';')
- 疑似命令
  - ラベル
  - .org: .org アドレス ; 現在位置の絶対アドレスを指定する
  - .set: 識別子 .set 数値 ; 定数に名前を付ける (再定義可能)
　- .equ: 識別子 .equ 数値 ; 定数に名前を付ける (再定義不可)
"""

class Assembler():
    REGNUM = re.compile('\%r(?P<regnum>[0-7])') #  %r0 ～ %r7
    REGPC  = re.compile('\%pc')
    IMMEDIATE = re.compile(r"""
    (?P<hex_imm>^0[xX][a-fA-F0-9]+$) # hex immediate value (ex. 0xf00)
    |(?P<oct_imm>^0[oO][0-7]+$) # octal immediate value (ex. 0o77)
    |(?P<dec_imm>^[0-9]+$)      # decimal immediate value (ex. 1024)
    """, re.VERBOSE)
    ABS_ADDR = re.compile(r"""
    \[ *(?P<hex_abs_addr>0[xX][a-fA-F0-9]+) *\] # hex absolute address (ex. [0xf00])
    |\[ *(?P<dec_abs_addr>[0-9]+) *\] # decimal absolute address (ex. [1024])
    """, re.VERBOSE)
    IND_ADDR = re.compile(r"""
    \[ *\%r(?P<regnum>[0-7]) *\] # register indierct address (ex. [%r0])
    """, re.VERBOSE)

    def __init__(self):
        self.lines = []

    def is_reg(self, str):
        """strがレジスタ表記ならTrueとその番号を返す。でなければ Falseと0を返す"""
        if (r := re.match(self.REGNUM, str)) is None:
            return False, 0
        else:
            return True, int(r.group('regnum'))

    def is_sreg(self, str):
        """
        strが特殊レジスタ表記ならTrueと対応するレジスタ番号を返す。
        でなければ Falseと0を返す
        """
        if (r := re.match(self.REGPC, str)) is not None:
            return True, Consts.PC
        else:
            return False, 0

    def is_immediate(self, str):
        """strが即値ならTrueとその値を返す。でなければFalseと0を返す"""
        if (r := re.match(self.IMMEDIATE, str)) is None:
            return False, 0
        elif (v := r.group('hex_imm')) is not None:
            val = int(v, 16)
        elif (v := r.group('oct_imm')) is not None:
            val = int(v, 8)
        elif (v := r.group('dec_imm')) is not None:
            val = int(v)
        else:
            return False, 0
        return True, val

    def is_ind_addr(self, str):
        """
        strが間接アドレス表記ならTrueとそのレジスタ番号を返す。でなければFalseと0を返す
        """
        if (r := re.match(self.IND_ADDR, str)) is None:
            return False, 0
        elif (v := r.group('regnum')) is not None:
            regnum = int(v)
        else:
            assert False
        return True, regnum

    def _2reg_inst(self, op1, op2, dest, src):
        """
        レジスタオペランドを2個持つ形式の命令 (op1 = 0b000, 0b001, 0b010)
        """
        rd, rs = 0, 0           # レジスタ番号
        pd, ps = False, False   # オペランドがレジスタかどうか
        pd, rd = self.is_reg(dest)
        ps, rs = self.is_reg(src)
        if not pd:
            raise OperandError(dest, "destination register error")
        if not ps:
            raise OperandError(src, "source register error")
        word = ((op1 << 9) | (rd << 6) | (op2 << 3) | (rs << 0))
        self.append(word)

    def _load_inst(self, op1, op2, dest, src):
        """
        ロード命令 (lda/ldp, %rd, [%rs]) %rd <- mem[%rs]
        """
        rd, rs = 0, 0           # レジスタ番号
        pd, ps = False, False   # オペランドがレジスタかどうか
        pd, rd = self.is_reg(dest)
        ps, rs = self.is_ind_addr(src)
        if not pd:
            raise OperandError(dest, "destination register error")
        if not ps:
            raise OperandError(src, "source register error")
        word = ((op1 << 9) | (rd << 6) | (op2 << 3) | (rs << 0))
        self.append(word)

    def _store_inst(self, op1, op2, dest, src):
        """
        ストア命令 (sta/stp, [%rd], %rs) mem[%rd] <- %rs
        """
        rd, rs = 0, 0           # レジスタ番号
        pd, ps = False, False   # オペランドがレジスタかどうか
        pd, rd = self.is_ind_addr(dest)
        ps, rs = self.is_reg(src)
        if not pd:
            raise OperandError(dest, "destination register error")
        if not ps:
            raise OperandError(src, "source register error")
        word = ((op1 << 9) | (rd << 6) | (op2 << 3) | (rs << 0))
        self.append(word)

    def _1reg_uimm3_inst(self, op1, op2, reg, imm):
        """
        レジスタオペランド1個とリテラル(uimm3)1個持つ形式の命令
        (op1 = 0b011, op2, 0xx)
        """
        pd, rd = self.is_reg(reg)
        pv, val = self.is_immediate(imm)
        if not pd:
            raise OperandError(reg, "destination register error")
        if (not pv) or (val > 0b111):
            raise OperandError(imm, "immediate operand error")
        word = ((op1 << 9) | (rd << 6) | (op2 << 3) | (val << 0))
        self.append(word)

    def _1reg_inst(self, op1, op2, reg):
        """
        レジスタオペランド1個のみを持つ形式の命令 (op1 = 0b011, op2 = 0b1xxxxx)
        """
        ps, rs = self.is_reg(reg)
        if not ps:
            raise OperandError(reg, "destination register error")
        word = ((op1 << 9) | (op2 << 3) | (rs << 0))
        self.append(word)

    def _ret_inst(self, op1, op2, reg):
        """
        レジスタオペランド1個のみを持つ形式の命令 (op1 = 0b011, op2 = 0b1xxxxx)
        """
        pd, rd = self.is_reg(reg)
        if not pd:
            raise OperandError(reg, "destination register error")
        word = ((op1 << 9) | (rd << 6) | (op2 << 0))
        self.append(word)

    def _branch(self, op1, cond, disp):
        """
        条件分岐命令。分岐条件と相対分岐アドレス
        """
        pv, val = self.is_immediate(disp)
        if (not pv) or (val > 0b111111):
            raise OperandError(disp, "branch target address too far")
        word = ((op1 << 9) | (cond << 6) | (val << 0))
        self.append(word)

    def _1reg_simm6_inst(self, op1, reg, imm):
        """
        レジスタオペランド1個とリテラル(simm6)1個持つ形式の命令
        (op1 = 0b101, 0b110, 0b111)
        """
        pd, rd = self.is_reg(reg)
        pv, val = self.is_immediate(imm)
        if not pd:
            raise OperandError(reg, "destination register error")
        if (not pv) or (val > 0b111111):
            raise OperandError(imm, "immediate operand error")
        word = ((op1 << 9) | (rd << 6) | (val << 0))
        self.append(word)

    def add_(self, dest, src):
        self._2reg_inst(0b000, Consts.OP2_ADD, dest, src)

    def sub_(self, dest, src):
        self._2reg_inst(0b000, Consts.OP2_SUB, dest, src)

    def cmp_(self, dest, src):
        self._2reg_inst(0b000, Consts.OP2_CMP, dest, src)

    def and_(self, dest, src):
        self._2reg_inst(0b000, Consts.OP2_AND, dest, src)

    def or_(self, dest, src):
        self._2reg_inst(0b000, Consts.OP2_OR, dest, src)

    def xor_(self, dest, src):
        self._2reg_inst(0b000, Consts.OP2_XOR, dest, src)

    def srl_(self, dest, src):
        self._2reg_inst(0b001, Consts.OP2_SRL, dest, src)

    def sra_(self, dest, src):
        self._2reg_inst(0b001, Consts.OP2_SRA, dest, src)

    def sll_(self, dest, src):
        self._2reg_inst(0b001, Consts.OP2_SLL, dest, src)

    def not_(self, dest, src):
        self._2reg_inst(0b001, Consts.OP2_NOT, dest, src)

    def neg_(self, dest, src):
        self._2reg_inst(0b001, Consts.OP2_NEG, dest, src)

    def move_(self, dest, src):
        self._2reg_inst(0b001, Consts.OP2_MOVE, dest, src)

    def sext_(self, dest, src):
        self._2reg_inst(0b001, Consts.OP2_SEXT, dest, src)

    def lda_(self, dest, idx):
        self._load_inst(0b010, Consts.OP2_LDA, dest, idx)

    def ldp_(self, dest, idx):
        self._load_inst(0b010, Consts.OP2_LDP, dest, idx)

    def sta_(self, src, idx):
        self._store_inst(0b010, Consts.OP2_STA, src, idx)

    def stp_(self, src, idx):
        self._store_inst(0b010, Consts.OP2_STP, src, idx)

    def incr_(self, dest, imm):
        self._1reg_uimm3_inst(0b011, Consts.OP2_INCR, dest, imm)

    def decr_(self, dest, imm):
        self._1reg_uimm3_inst(0b011, Consts.OP2_DECR, dest, imm)

    def rdpc_(self, dest):
        self._1reg_inst(0b011, Consts.OP2_RDPC, dest)

    def ret_(self, ret_reg):    # TODO:
        self._1reg_inst(0b011, Consts.OP2_RET, ret_reg)

    def halt_(self):
        self._1reg_inst(0b011, Consts.OP2_HALT, '%r0')

    def bal_(self, imm):
        self._branch(0b100, Consts.COND_BAL, imm)

    def bz_(self, imm):
        self._branch(0b100, Consts.COND_BZ, imm)

    def bnz_(self, imm):
        self._branch(0b100, Consts.COND_BNZ, imm)

    def bgt_(self, imm):
        self._branch(0b100, Consts.COND_BGT, imm)

    def bge_(self, imm):
        self._branch(0b100, Consts.COND_BGE, imm)

    def bgtu_(self, imm):
        self._branch(0b100, Consts.COND_BGTU, imm)

    def bgeu_(self, imm):
        self._branch(0b100, Consts.COND_BGEU, imm)

    def jala_(self, link, tgt):
        self._2reg_inst(0b101, Consts.OP2_JALA, link, tgt)

    def jalp_(self, link, tgt):
        self._2reg_inst(0b101, Consts.OP2_JALP, link, tgt)

    def silo_(self, reg, imm):
        self._1reg_simm6_inst(0b110, reg, imm)

    def sihi_(self, reg, imm):
        self._1reg_simm6_inst(0b111, reg, imm)

    def nop_(self):
        self._2reg_inst(0b000, Consts.OP2_OR, '%r0', '%r0') # or %r0, %r0

    def clr_(self, reg):
        self._2reg_inst(0b000, Consts.OP2_XOR, reg, reg) # xor reg, reg

    # アセンブラ作成
    def append(self, word):
        self.lines += [word]

    def get_bin(self):
        return self.lines

    # test
    def test_000(self):
        self.silo_('%r0', '0x28')
        self.silo_('%r5', '0x02')
        self.add_('%r0', '%r5')
        self.sub_('%r0', '%r5')
        self.cmp_('%r0', '%r5')
        self.and_('%r0', '%r5')
        self.or_('%r0', '%r5')
        self.xor_('%r0', '%r5')
        self.nop_()
        self.halt_()

    def test_001(self):
        self.sihi_('%r0', '0x3f')
        self.silo_('%r0', '0x2a')
        self.sra_('%r1', '%r0')
        self.srl_('%r2', '%r0')
        self.sll_('%r3', '%r0')
        self.not_('%r4', '%r0')
        self.neg_('%r5', '%r0')
        self.move_('%r6', '%r4')
        self.sihi_('%r0', '0x0')
        self.silo_('%r0', '0x35')
        self.sext_('%r7', '%r0')
        self.halt_()

    def test_010(self):
        self.sihi_('%r0', '0x3f')
        self.silo_('%r0', '0x3f')
        self.sihi_('%r1', '0x15')
        self.silo_('%r1', '0x3a')
        self.sta_('[%r0]', '%r1')
        self.lda_('%r2', '[%r0]')
        self.halt_()

    def test_011(self):
        self.silo_('%r7', '0x15')
        self.incr_('%r7', '1')
        self.decr_('%r7', '3')
        self.rdpc_('%r1')
        self.silo_('%r2', '0x5')
        self.ret_('%r2')
        self.nop_()
        self.nop_()
        self.halt_()

    def test_100a(self):
        self.bal_('0x1')
        self.nop_()
        self.sihi_('%r1', '0x17') # 0b0101_1100_0000
        self.sihi_('%r2', '0x31') # 0b1100_0100_0000
        self.cmp_('%r1', '%r2')
        self.bnz_('0x1')
        self.nop_()
        self.cmp_('%r2', '%r1')
        self.bgtu_('0x1')
        self.nop_()
        self.cmp_('%r1', '%r2')
        self.bgt_('0x1')
        self.nop_()
        self.halt_()

    def test_100b(self):
        self.sihi_('%r1', '0x17') # 0b0101_1100_0000
        self.sihi_('%r2', '0x31') # 0b1100_0100_0000
        self.cmp_('%r1', '%r1')
        self.bz_('0x1')
        self.nop_()
        self.cmp_('%r2', '%r1')
        self.bgeu_('0x1')
        self.nop_()
        self.cmp_('%r1', '%r2')
        self.bge_('0x1')
        self.nop_()
        self.halt_()

    def test_101(self):
        self.silo_('%r2', '0x8') # absolute address for 'jalp'
        self.sihi_('%r2', '0x0')
        self.jala_('%r1', '%r2')
        self.nop_()
        self.nop_()
        self.nop_()
        self.nop_()
        self.nop_()
        self.jalp_('%r1', '%r2') # PC-relative address for 'halt'
        self.nop_()
        self.nop_()
        self.nop_()
        self.nop_()
        self.nop_()
        self.nop_()
        self.nop_()
        self.nop_()
        self.halt_()

    def test_arith1(self):
        self.add_('%r0',   '%r1')
        self.sta_('[%r7]', '%r0')
        self.sub_('%r1',   '%r2')
        self.sta_('[%r7]', '%r1')
        self.and_('%r3',   '%r4')
        self.sta_('[%r7]', '%r3')
        self.or_( '%r4',   '%r5')
        self.sta_('[%r7]', '%r4')
        self.xor_('%r5',   '%r6')
        self.sta_('[%r7]', '%r5')

    def test_arith2(self):
        self.sra_( '%r0',   '%r1')
        self.sta_( '[%r7]', '%r0')
        self.srl_( '%r0',   '%r1')
        self.sta_( '[%r7]', '%r0')
        self.sll_( '%r0',   '%r1')
        self.sta_( '[%r7]', '%r0')
        self.not_( '%r0',   '%r1')
        self.sta_( '[%r7]', '%r0')
        self.neg_( '%r0',   '%r1')
        self.sta_( '[%r7]', '%r0')
        self.move_('%r0',   '%r1')
        self.sta_( '[%r7]', '%r0')
        self.sext_('%r0',   '%r1')
        self.sta_( '[%r7]', '%r0')

    def test_branches(self):
        self.bal_('0x03')
        self.bal_('0x77')
        self.bge_('0x76')
        self.bgt_('0x76')
        self.bnz_('0x76')
        self.bz_('0x76')

    def test_misc(self):
        self.decr_('%r3', '1')
        self.halt_()
        self.incr_('%r3', '1')
        self.jala_('%r2', '%r1')
        self.lda_('%r2', '[%r1]')
        self.rdpc_('%r2')
        self.ret_('%r2')
        self.sihi_( '%r1', '0o73')
        self.silo_( '%r1', '0o73')
        self.sta_('[%r3]', '%r1')
        self.lda_('%r2', '[%r3]')

if __name__ == '__main__':
    asm = Assembler()
    #print("asm created")
    #asm.test_000()
    #asm.test_001()
    #asm.test_010()
    #asm.test_011()
    #asm.test_100a()
    #asm.test_100b()
    #asm.test_101()
    #asm.test_arith1()
    #asm.test_arith2()
    #asm.test_branches()
    asm.test_misc()
    lines = asm.get_bin()
    print(lines)
    for i, l in enumerate(lines):
        print("{0:4}  12'o{1:04o}".format(i,l)) # 4 Octal-digit in Verilog format

# end of file
