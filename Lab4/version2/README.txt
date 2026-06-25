Lab 4 RGB2YUV Version 2 (3 multipliers + 3 adders/subtractors)

Fixed schedule:
  Pick 1: t1, t2, t6
  Pick 2: t7, t8, t12, t4
  Pick 3: t13, t14, t3, t9, t10
  Pick 4: t15, t16, Y
  Pick 5: U, V

Important correction:
  The mathematically correct U expression is U = t10 - t9,
  because U = 128 + 0.5B - 0.169R - 0.331G.

RTL simulation on the course server:
  vcs -f file_v2.f -debug_access+all +v2k -R -full64

Design Compiler synthesis:
  dc_shell -f ./RGB2YUV_V2_dc.tcl

Expected structural resources:
  Mul instances:    MUL1, MUL2, MUL3
  AddSub instances: ALU1, ALU2, ALU3
