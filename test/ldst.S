// riscv64-linux-gnu-gcc prog.S  -o /tmp/test -march=rv32if -nostartfiles -static -nodefaultlibs -mcmodel=medany -mabi=ilp32f

.section ".text.init"
.globl _start
_start:
	li x2, 4
	li x3, 6
	auipc x8, 0x1
	sw x2, 0(x8)
	sw x3, 4(x8)
	lw x7, 4(x8)
	bne x7, x3, l1
	lw x7, 0(x8)
	bne x7, x2, l1
	wfi
l1:
	jal l1
