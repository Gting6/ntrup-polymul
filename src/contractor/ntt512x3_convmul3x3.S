#ifdef __aarch64__
	.arch armv8-a+crc
	.file	"mul_conv3x3_mod16760833_512_aarch64.s"
	.text
	.section	.text.hot.mul_conv3x3_mod16760833_512_aarch64_asm,"ax",@progbits
	.align	2
	.p2align 4,,15
    .globl  mul_conv3x3_mod16760833_512_aarch64_asm
	.type	mul_conv3x3_mod16760833_512_aarch64_asm, %function
mul_conv3x3_mod16760833_512_aarch64_asm:
.FUNC_SIZE:
	.cfi_startproc
	mov	w3, 961
	movk	w3, 0x4010, lsl 16
	fmov	s20, w3
	mov	w3, 128
	movk	w3, 0x7fe0, lsl 16
	mov	x2, 6144
	fmov	s19, w3
	mov	w3, 49153
	movk	w3, 0xff, lsl 16
	add	x2, x0, x2
	fmov	s7, w3
	.p2align 6
.SIMDLOOP:
	ld3	{v16.4s - v18.4s}, [x1], 48
	ld3	{v4.4s - v6.4s}, [x0]
	smull2 v21.2d,v4.4s,v16.4s
	dup	d23, v16.d[0]
	smlal2 v21.2d,v5.4s,v18.4s
	dup	d25, v17.d[0]
	smlal2 v21.2d,v6.4s,v17.4s
	dup	d26, v18.d[0]
	srshr	v31.2d, v21.2d, 30
	dup	d1, v4.d[0]
	smull2 v3.2d,v4.4s,v17.4s
	dup	d24, v5.d[0]
	smlal2 v3.2d,v5.4s,v16.4s
	dup	d22, v6.d[0]
	smlal2 v3.2d,v6.4s,v18.4s
	smull v0.2d, v1.2s, v23.2s
	smlal v0.2d,v24.2s,v26.2s
	smlal v0.2d,v22.2s,v25.2s
	srshr	v27.2d, v0.2d, 30
	uzp1	v28.4s, v0.4s, v21.4s
	smull v2.2d, v1.2s, v25.2s
	smlal v2.2d,v24.2s,v23.2s
	smlal v2.2d,v22.2s,v26.2s
	uzp1	v21.4s, v27.4s, v31.4s
	sqrdmulh v21.4s,v21.4s,v20.s[0]
	mls v28.4s, v21.4s, v19.s[0]
	srshr	v27.2d, v3.2d, 30
	srshr	v21.4s, v28.4s, 24
	mls v28.4s, v21.4s, v7.s[0]
	srshr	v21.2d, v2.2d, 30
	uzp1	v29.4s, v2.4s, v3.4s
	smull v1.2d, v1.2s, v26.2s
	smull2 v0.2d,v4.4s,v18.4s
	smlal v1.2d,v24.2s,v25.2s
	uzp1	v3.4s, v21.4s, v27.4s
	sqrdmulh v3.4s,v3.4s,v20.s[0]
	mls v29.4s, v3.4s, v19.s[0]
	srshr	v3.4s, v29.4s, 24
	smlal v1.2d,v22.2s,v23.2s
	smlal2 v0.2d,v5.4s,v17.4s
	srshr	v2.2d, v1.2d, 30
	smlal2 v0.2d,v6.4s,v16.4s
	mls v29.4s, v3.4s, v7.s[0]
	srshr	v3.2d, v0.2d, 30
	uzp1	v30.4s, v1.4s, v0.4s
	uzp1	v1.4s, v2.4s, v3.4s
	sqrdmulh v1.4s,v1.4s,v20.s[0]
	mls v30.4s, v1.4s, v19.s[0]
	srshr	v1.4s, v30.4s, 24
	mls v30.4s, v1.4s, v7.s[0]
	st3	{v28.4s - v30.4s}, [x0], 48
	cmp	x0, x2
	bne	.SIMDLOOP
	ret
	.cfi_endproc
.FUNC_SIZE_END:
	.size	mul_conv3x3_mod16760833_512_aarch64_asm, .-mul_conv3x3_mod16760833_512_aarch64_asm
#endif
