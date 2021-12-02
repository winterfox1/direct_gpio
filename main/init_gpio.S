.global init_gpio_out
.global set_gpio

.global printstr

	# a0	GPIO
	# a1	GPIO_Value
	# a2	RA of calling function
	# t0	0x15, then GPIO_BASE_ADDRESS
	# t1	bitset_gpio
	# t2	0x80 = output
	# t3	GPIO_FUNCn_OUT_SEL_CFG_REG_BASE
	# t4	GPIO_FUNCn_OUT_SEL_CFG_REG
	# x1	RA register

.data
printstr:	.string	"--- user defined core dump ---\nt1: %8p\nt3: %8p\tt4: %8p\nt5: %8p\tt6: %8p\na0: %8p\ta1: %8p\n-----------------------\n\n\n"

.text
init_gpio_out:
	# save return address and jump to init
	mv	a2, x1 
	jal	x1, init
	mv	x1, a2

	# enable gpio
	sw	t1, 0x24(t0)		# store gpio bitmask to GPIO_ENABLE_W1TS_REG
	
	# set gpio as output
	mul 	t5, a0, t4		# multiply gpio * 4
	add	t6, t5, t3		# add offset to CFG_REG_BASE

	mv	a2, x1	############# DEBUG
	jal	x1, init
	mv	x1, a2
	
	sw	t2, 0(t6)		# store 0x80 to CFG_REG

	ret

set_gpio:
	# save return address and jump to init
	mv	a2, x1 
	jal	x1, debug_printf
	mv	x1, a2

	# gpio set or reset
	beq	a1, x0, reset_gpio
	sw	t1, 0x8(t0)
	
	ret
	
reset_gpio:
	sw	t1, 0xc(t0)
	ret

init:
	# set baseaddress and check if (0 <= gpio <= 21)
	li	t0, 0x15
	bgt	a0, t0, init_fail
	blt	a0, x0, init_fail
	li	t0, 0x60004000
	li	t1, 0x1			# 0x1 = GPIO 0
	sll	t2, t1, a0		# shift 0x1 to bit position according to gpio
	mv	t2, t1
	li	t2, 0x80		# 0x80 = output
	addi	t3, t0, 0x554		# base + 0x554
	li	t4, 0x4			# 0x4 will be multiplied by gpio
	ret

init_fail:
	# reset return address and exit
	mv	x1, a2
	ret

debug_printf:
	addi	sp, sp, -64
	sw	x1, 0(sp)
	sw	t0, 0x4(sp)
	sw	t1, 0x8(sp)
	sw	t2, 0xc(sp)
	sw	t3, 0x10(sp)
	sw	t4, 0x14(sp)
	sw	t5, 0x18(sp)
	sw	t6, 0x1c(sp)
	sw	a0, 0x20(sp)
	sw	a1, 0x24(sp)
	sw	a2, 0x28(sp)

	mv	a2, t3		# t3
	mv	a3, t4		# t4
	mv	a4, t5		# t5
	mv	a5, t6		# t6
	mv	a6, a0		# a0
	mv	a7, a1		# a1
	mv	a1, t1 		# t1
	la	a0, printstr
	call	printf

	lw	x1, 0(sp)
	lw	t0, 0x4(sp)
	lw	t1, 0x8(sp)
	lw	t2, 0xc(sp)
	lw	t3, 0x10(sp)
	lw	t4, 0x14(sp)
	lw	t5, 0x18(sp)
	lw	t6, 0x1c(sp)
	lw	a0, 0x20(sp)
	lw	a1, 0x24(sp)
	lw	a2, 0x28(sp)
	addi	sp, sp, 64
	
	ret
