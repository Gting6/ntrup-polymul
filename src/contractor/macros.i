// not used
.macro transposition4x4_neon_ntt sh0, sh1, a0, a1, a2, a3, t0, t1, t2, t3
    /* inplace transposition, 4 temporary register needed
    ak = [a0[k], a1[k], a2[k], a3[k]] for k = 0, 1, 2, 3
    sh0: smaller shape, usually .4S
    sh1: larger shape, usually .2D
    */
    TRN1 \t0\sh0, \a0\sh0, \a1\sh0
    TRN2 \t1\sh0, \a0\sh0, \a1\sh0
    TRN1 \t2\sh0, \a2\sh0, \a3\sh0
    TRN2 \t3\sh0, \a2\sh0, \a3\sh0

    TRN1 \a0\sh1, \t0\sh1, \t2\sh1
    TRN2 \a2\sh1, \t0\sh1, \t2\sh1
    TRN1 \a1\sh1, \t1\sh1, \t3\sh1
    TRN2 \a3\sh1, \t1\sh1, \t3\sh1
.endm

.macro transposition4x4 sh0, sh1, a0, a1, a2, a3, tl, th
    /* inplace transposition, modify from Neon-NTT, but use 2 temporary SIMD register only
    ak = [a0[k], a1[k], a2[k], a3[k]] for k = 0, 1, 2, 3
    sh0: smaller shape, usually .4S
    sh1: larger shape, usually .2D
    */
    TRN1 \tl\sh0, \a0\sh0, \a1\sh0 // a00, a10, a02, a12
    TRN2 \a1\sh0, \a0\sh0, \a1\sh0 // a01, a11, a03, a13
    TRN2 \th\sh0, \a2\sh0, \a3\sh0 // a21, a31, a23, a33
    TRN1 \a2\sh0, \a2\sh0, \a3\sh0 // a20, a30, a22, a32

    TRN1 \a0\sh1, \tl\sh1, \a2\sh1 // a00, a10, a20, a30
    TRN2 \a2\sh1, \tl\sh1, \a2\sh1 // a02, a12, a22, a32
    TRN2 \a3\sh1, \a1\sh1, \th\sh1 // a03, a13, a23, a33
    TRN1 \a1\sh1, \a1\sh1, \th\sh1 // a01, a11, a21, a31
.endm

.macro triple_subadd sh, a0, a1, a2, b0, b1, b2, t0, t1, t2, bbsh
    /* inplace 2-NTT (a0[i], b0[i]), used in last 2 round
    ak[i] = ak[i] + bk[i]
    bk[i] = ak[i] - bk[i]
    for k = 0, 1, 2
    */
    SUB         \t0\sh, \a0\sh, \b0\sh
    SUB         \t1\sh, \a1\sh, \b1\sh
    SUB         \t2\sh, \a2\sh, \b2\sh
    ADD         \a0\sh, \a0\sh, \b0\sh
    ADD         \a1\sh, \a1\sh, \b1\sh
    ADD         \a2\sh, \a2\sh, \b2\sh
    MOV         \b0\bbsh, \t0\bbsh
    MOV         \b1\bbsh, \t1\bbsh
    MOV         \b2\bbsh, \t2\bbsh
.endm

.macro triple_GS_barrett sh, a0, a1, a2, b0, b1, b2, t0, t1, t2, zl, zh, pm
    /* inplace NTT (a0[i], b0[i]) with twiddle factor zl[i], prime modulus pm
    ak[i] =  ak[i] + bk[i]          mod pm
    bk[i] = (ak[i] - bk[i]) * zl[i] mod pm
    for k = 0, 1, 2
    */
    SUB         \t0\sh, \a0\sh, \b0\sh
    SUB         \t1\sh, \a1\sh, \b1\sh
    SUB         \t2\sh, \a2\sh, \b2\sh
    ADD         \a0\sh, \a0\sh, \b0\sh
    ADD         \a1\sh, \a1\sh, \b1\sh
    ADD         \a2\sh, \a2\sh, \b2\sh
    MUL         \b0\sh, \t0\sh, \zl
    MUL         \b1\sh, \t1\sh, \zl
    MUL         \b2\sh, \t2\sh, \zl
    SQRDMULH    \t0\sh, \t0\sh, \zh
    SQRDMULH    \t1\sh, \t1\sh, \zh
    SQRDMULH    \t2\sh, \t2\sh, \zh
    MLS         \b0\sh, \t0\sh, \pm
    MLS         \b1\sh, \t1\sh, \pm
    MLS         \b2\sh, \t2\sh, \pm
.endm

.macro single_GS_barrett sh, a0, b0, t0, zl, zh, pm
    /* inplace NTT, only used in the beginning of each 64-NTT because we are lack of ASIMD registers */
    SUB         \t0\sh, \a0\sh, \b0\sh
    ADD         \a0\sh, \a0\sh, \b0\sh
    MUL         \b0\sh, \t0\sh, \zl
    SQRDMULH    \t0\sh, \t0\sh, \zh
    MLS         \b0\sh, \t0\sh, \pm
.endm

.macro ABI_PUSH
    SUB sp, sp, #(16*9)
    STP x19, x20, [sp, #(16*0)]
    STP x21, x22, [sp, #(16*1)]
    STP x23, x24, [sp, #(16*2)]
    STP x25, x26, [sp, #(16*3)]
    STP x27, x28, [sp, #(16*4)]
    STP  d8,  d9, [sp, #(16*5)]
    STP d10, d11, [sp, #(16*6)]
    STP d12, d13, [sp, #(16*7)]
    STP d14, d15, [sp, #(16*8)]
.endm
.macro ABI_POP
    LDP x19, x20, [sp, #(16*0)]
    LDP x21, x22, [sp, #(16*1)]
    LDP x23, x24, [sp, #(16*2)]
    LDP x25, x26, [sp, #(16*3)]
    LDP x27, x28, [sp, #(16*4)]
    LDP  d8,  d9, [sp, #(16*5)]
    LDP d10, d11, [sp, #(16*6)]
    LDP d12, d13, [sp, #(16*7)]
    LDP d14, d15, [sp, #(16*8)]
    ADD	sp, sp, #(16*9)
.endm

