// test

`include "clk_gen.v"
`include "mem.v"
`include "docita.v"

module TOP();

`include "top.inc"

   initial begin
      $dumpfile("test_op_arith1.vcd");
      $dumpvars(0, TOP);
      #41000 $finish;
   end

   initial begin
      mem._mem[0] = 12'o0001; // add %r0, %r1
      mem._mem[1] = 12'o2720; // sta [%r7], %r0
      mem._mem[2] = 12'o0112; // sub %r1, %r2
      mem._mem[3] = 12'o2721; // sta [%r7], %r1
      mem._mem[4] = 12'o0334; // and %r3, %r4
      mem._mem[5] = 12'o2723; // sta [%r7], %r3
      mem._mem[6] = 12'o0445; // or  %r4, %r5
      mem._mem[7] = 12'o2724; // sta [%r7], %r4
      mem._mem[8] = 12'o0556; // xor %r5, %r6
      mem._mem[9] = 12'o2725; // sta [%r7], %r5
      proc.greg._r[0] = 12'o0770;
      proc.greg._r[1] = 12'o0071;
      proc.greg._r[2] = 12'o0702;
      proc.greg._r[3] = 12'o0003;
      proc.greg._r[4] = 12'o0074;
      proc.greg._r[5] = 12'o0705;
      proc.greg._r[6] = 12'o0006;
      proc.greg._r[7] = 10;          // 10進数
   end

endmodule
