// riscv64-linux-gnu-gcc prog.S  -o /tmp/test -march=rv32if -nostartfiles -static -nodefaultlibs -mcmodel=medany -mabi=ilp32f

  .section ".text.init"
  .globl _start
_start:
	li x2, 4
	li x3, 6
	add x1, x2, x3
	sub x4, x3, x2
	lw x7, 3(x1)
	and x7, x1, x6
	sll x5, x2, x1
	slt x5, x2, x1
	bne x2, x3, l1
	sltu x5, x2, x1
l1:
	xor x5, x2, x1
	srl x5, x2, x1
	sra x5, x2, x1
	jal x5, 2
	addi x5, x2, 1
	slti x5, x2, 3
	andi x5, x2, 5
	slli x5, x2, 2
	jalr x5, x2, 2
	wfi
