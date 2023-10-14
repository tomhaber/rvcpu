// riscv64-linux-gnu-gcc deps.S  -o /tmp/test -march=rv32if -nostartfiles -static -nodefaultlibs -mcmodel=medany -mabi=ilp32f

  .section ".text.init"
  .globl _start
_start:
    addi x2, x0, 4
    addi x3, x0, 6
    add x4, x2, x3
    addi x5, x2, 4
    add x1, x4, x5
    wfi

other:
    addi x2, x0, 1
    addi x2, x2, 2
    addi x2, x2, 3
    addi x2, x2, 4
    addi x2, x2, 5
    addi x2, x2, 6
    wfi
