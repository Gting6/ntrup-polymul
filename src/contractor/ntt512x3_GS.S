#include "macros.i"

	.arch armv8-a+crc
	.text
	.align	2
	.p2align 4,,15
    .globl  ntt512x3_512_256_128_64
	.type	ntt512x3_512_256_128_64, %function
    .globl  ntt512x3_32_16_8_4_2
	.type	ntt512x3_32_16_8_4_2, %function

ntt512x3_512_256_128_64:
/*  DATA STRUCTURE

    register:       v0.4S = { A[0][0], A[1][0], A[2][0], A[3][0] }      v1.4S = { A[0][1], A[1][1], A[2][1], A[3][1] }
                    v2.4S = { A[0][2], A[1][2], A[2][2], A[3][2] }      v12 - v14 = {0x100, 0x101, 0x102, 0x103}
                    v3 - v5  = {0x040, 0x041, 0x042, 0x043}             v15 - v17 = {0x140, 0x141, 0x142, 0x143}
                    v6 - v8  = {0x080, 0x081, 0x082, 0x083}             v18 - v20 = {0x180, 0x181, 0x182, 0x183}
                    v9 - v11 = {0x0c0, 0x0c1, 0x0c2, 0x0c3}             v21 - v23 = {0x1c0, 0x1c1, 0x1c2, 0x1c3}

                    v24.4S = { w[0], w[1], w[2], w[3] }                 v26.4S = { w[4], w[5], w[6], w[7] }
                    v25.4S = { W[0], W[1], W[2], W[3] }                 v27.4S = { W[4], W[5], W[6], W[7] }
                    
                    v28.4S = { MODP, MODP, MODP, MODP }
                    v29 - v31   : temporary registers
                    
                    x0 = [ptr] A -> polynomial coefficients
                    x1 = [ptr] 512_256_128-NTT twiddle factors
                    x2 = [int] loop count, 0 - 63
                    x3 = [ptr] 64-NTT twiddle factors
                    
                    x4 - x7     : temporary [ptr] registers when performing 64-NTT

                    x9  = [ptr] A + 64 * 1 -> v3 - v5
                    x10 = [ptr] A + 64 * 2 -> v6 - v8
                    x11 = [ptr] A + 64 * 3 -> v9 - v11
                    x12 = [ptr] A + 64 * 4 -> v12 - v14
                    x13 = [ptr] A + 64 * 5 -> v15 - v17
                    x14 = [ptr] A + 64 * 6 -> v18 - v20
                    x15 = [ptr] A + 64 * 7 -> v21 - v23
                    

    PARAMETER
    void ntt512x3_512_256_128_64(uint32_t (*A)[3], const uint64_t *wW, const int MODP);

    ALGORITHM
    twisted NTT; 512_256_128 NTT done naturally, then we have modified 64 NTT before storing the coefficients
    
*/
    ABI_PUSH
    DUP v28.4S, w2
    MOV x2, #0              // loop count

    ADD x9 , x0,  #768*1
    ADD x10, x0,  #768*2
    ADD x11, x0,  #768*3

    ADD x12, x0,  #768*4
    ADD x13, x9,  #768*4
    ADD x14, x10, #768*4
    ADD x15, x11, #768*4

    ADD x3, x1,  #512*7     // x1 + 0x1c0 * uint64_t
ntt512x3_512_256_128_64_LOOP:
    LD3 {v0.4S,  v1.4S,  v2.4S }, [x0 ]
    LD3 {v3.4S,  v4.4S,  v5.4S }, [x9 ]
    LD3 {v6.4S,  v7.4S,  v8.4S }, [x10]
    LD3 {v9.4S,  v10.4S, v11.4S}, [x11]
    LD3 {v12.4S, v13.4S, v14.4S}, [x12]
    LD3 {v15.4S, v16.4S, v17.4S}, [x13]
    LD3 {v18.4S, v19.4S, v20.4S}, [x14]
    LD3 {v21.4S, v22.4S, v23.4S}, [x15]

    // 512-NTT
    LD2 {v24.4S, v25.4S}, [x1], #32    // 0, 1, 2, 3
    LD2 {v26.4S, v27.4S}, [x1], #32    // 64, 65, 66, 67
    triple_GS_barrett .4S,  v0 , v1 , v2 ,  v12, v13, v14,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v3 , v4 , v5 ,  v15, v16, v17,  v29, v30, v31,  v26.4S, v27.4S, v28.S[0]
    LD2 {v24.4S, v25.4S}, [x1], #32    // 128, 129, 130, 131
    LD2 {v26.4S, v27.4S}, [x1], #32    // 192, 193, 194, 195
    triple_GS_barrett .4S,  v6 , v7 , v8 ,  v18, v19, v20,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v9 , v10, v11,  v21, v22, v23,  v29, v30, v31,  v26.4S, v27.4S, v28.S[0]
    // 256-NTT
    LD2 {v24.4S, v25.4S}, [x1], #32    // 0, 2, 4, 6
    LD2 {v26.4S, v27.4S}, [x1], #32    // 128, 130, 132, 134
    triple_GS_barrett .4S,  v0 , v1 , v2 ,  v6 , v7 , v8 ,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v12, v13, v14,  v18, v19, v20,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v3 , v4 , v5 ,  v9 , v10, v11,  v29, v30, v31,  v26.4S, v27.4S, v28.S[0]
    triple_GS_barrett .4S,  v15, v16, v17,  v21, v22, v23,  v29, v30, v31,  v26.4S, v27.4S, v28.S[0]
    // 128-NTT
    LD2 {v24.4S, v25.4S}, [x1], #32    // 0, 4, 8, 12
    triple_GS_barrett .4S,  v0 , v1 , v2 ,  v3 , v4 , v5 ,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v6 , v7 , v8 ,  v9 , v10, v11,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v12, v13, v14,  v15, v16, v17,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v18, v19, v20,  v21, v22, v23,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]

    TBZ     x2, #5, SAVE        // upperhalf of the 64 elements, no need to do 64-NTT

NTT_64:
    SUB x4, x0, #384
    SUB x5, x9, #384
    SUB x6, x10, #384
    SUB x7, x11, #384
    LD2 {v24.4S, v25.4S}, [x3], #32

    LD3 {v29.4S, v30.4S, v31.4S}, [x4]      // x4 = x0 - 32 * (12 bytes)
    single_GS_barrett .4S, v29, v0, v26, v24.4S, v25.4S, v28.S[0] 
    single_GS_barrett .4S, v30, v1, v26, v24.4S, v25.4S, v28.S[0] 
    single_GS_barrett .4S, v31, v2, v26, v24.4S, v25.4S, v28.S[0] 
    ST3 {v29.4S, v30.4S, v31.4S}, [x4]
    ST3 {v0.4S,  v1.4S,  v2.4S }, [x0], #48

    LD3 {v0.4S,  v1.4S,  v2.4S }, [x5]      // x5 = x9 - 32 * (12 bytes)
    triple_GS_barrett .4S, v0, v1, v2, v3, v4, v5, v29, v30, v31, v24.4S, v25.4S, v28.S[0]
    ST3 {v0.4S,  v1.4S,  v2.4S }, [x5]
    ST3 {v3.4S,  v4.4S,  v5.4S }, [x9], #48

    LD3 {v0.4S,  v1.4S,  v2.4S }, [x6]
    LD3 {v3.4S,  v4.4S,  v5.4S }, [x7]
    triple_GS_barrett .4S, v0, v1, v2, v6, v7 , v8 , v29, v30, v31, v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S, v3, v4, v5, v9, v10, v11, v29, v30, v31, v24.4S, v25.4S, v28.S[0]
    ST3 {v0.4S,  v1.4S,  v2.4S }, [x6]
    ST3 {v3.4S,  v4.4S,  v5.4S }, [x7]
    ST3 {v6.4S,  v7.4S,  v8.4S }, [x10], #48
    ST3 {v9.4S,  v10.4S, v11.4S}, [x11], #48

    SUB x4, x12, #384
    SUB x5, x13, #384
    SUB x6, x14, #384
    SUB x7, x15, #384
    LD3 {v0.4S,  v1.4S,  v2.4S }, [x4]
    LD3 {v3.4S,  v4.4S,  v5.4S }, [x5]
    LD3 {v6.4S,  v7.4S,  v8.4S }, [x6]
    LD3 {v9.4S,  v10.4S, v11.4S}, [x7]
    triple_GS_barrett .4S,      v0, v1, v2,    v12, v13, v14,    v29, v30, v31, v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,      v3, v4, v5,    v15, v16, v17,    v29, v30, v31, v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,      v6, v7, v8,    v18, v19, v20,    v29, v30, v31, v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,      v9, v10, v11,  v21, v22, v23,    v29, v30, v31, v24.4S, v25.4S, v28.S[0]
    ST3 {v0.4S,  v1.4S,  v2.4S }, [x4]
    ST3 {v3.4S,  v4.4S,  v5.4S }, [x5]
    ST3 {v6.4S,  v7.4S,  v8.4S }, [x6]
    ST3 {v9.4S,  v10.4S, v11.4S}, [x7]
    ST3 {v12.4S, v13.4S, v14.4S}, [x12], #48
    ST3 {v15.4S, v16.4S, v17.4S}, [x13], #48
    ST3 {v18.4S, v19.4S, v20.4S}, [x14], #48
    ST3 {v21.4S, v22.4S, v23.4S}, [x15], #48

    B   END
SAVE:
    ST3 {v0.4S,  v1.4S,  v2.4S }, [x0 ], #48
    ST3 {v3.4S,  v4.4S,  v5.4S }, [x9 ], #48
    ST3 {v6.4S,  v7.4S,  v8.4S }, [x10], #48
    ST3 {v9.4S,  v10.4S, v11.4S}, [x11], #48
    ST3 {v12.4S, v13.4S, v14.4S}, [x12], #48
    ST3 {v15.4S, v16.4S, v17.4S}, [x13], #48
    ST3 {v18.4S, v19.4S, v20.4S}, [x14], #48
    ST3 {v21.4S, v22.4S, v23.4S}, [x15], #48
END:
    ADD x2, x2, #4
    TBZ x2, #6, ntt512x3_512_256_128_64_LOOP

    ABI_POP
    RET


ntt512x3_32_16_8_4_2:
/*  DATA STRUCTURE

    register:       v0.4S = { A[0][0], A[1][0], A[2][0], A[3][0] }      v1.4S = { A[0][1], A[1][1], A[2][1], A[3][1] }
                    v2.4S = { A[0][2], A[1][2], A[2][2], A[3][2] }      v12 - v14 = {0x10, 0x11, 0x12, 0x13}
                    v3 - v5  = {0x4, 0x5, 0x6, 0x7}                     v15 - v17 = {0x14, 0x15, 0x16, 0x17}
                    v6 - v8  = {0x8, 0x9, 0xa, 0xb}                     v18 - v20 = {0x18, 0x19, 0x1a, 0x1b}
                    v9 - v11 = {0xc, 0xd, 0xe, 0xf}                     v21 - v23 = {0x1c, 0x1d, 0x1e, 0x1f}

                    v24.4S = { w[0], w[1], w[2], w[3] }                 v26.4S = { w[4], w[5], w[6], w[7] }
                    v25.4S = { W[0], W[1], W[2], W[3] }                 v27.4S = { W[4], W[5], W[6], W[7] }
                    
                    v28.4S = { MODP, MODP, MODP, MODP }
                    v29 - v31   : temporary registers
                    
                    x0 = [ptr] A[512][3] coefficients, for loading
                    x1 = [ptr] 32-NTT twiddle factors
                    x2 = [ptr] A[512][3] coefficients, for storing
                    x3 = [ptr] 16-NTT twiddle factors
                    x4 = [ptr] end loop when x3 == x4

    PARAMETER
    void ntt512x3_32_16_8_4_2(uint32_t (*A)[3], const uint64_t *wW, const int MODP);

    ALGORITHM
    twisted NTT; 32_16_8 NTT done naturally, then we have modified 4_2 NTT after 4x4 transposition
    
*/
    ABI_PUSH
    DUP v28.4S, w2
    MOV x2, x0  // backup for storing process
    MOV x3, x1
    MOV x4, #0

ntt512x3_32_16_8_4_2_LOOP:

    // 32x3 coefficients loading
    LD3 {v0.4S,  v1.4S,  v2.4S }, [x0], #48
    LD3 {v3.4S,  v4.4S,  v5.4S }, [x0], #48
    LD3 {v6.4S,  v7.4S,  v8.4S }, [x0], #48
    LD3 {v9.4S,  v10.4S, v11.4S}, [x0], #48
    LD3 {v12.4S, v13.4S, v14.4S}, [x0], #48
    LD3 {v15.4S, v16.4S, v17.4S}, [x0], #48
    LD3 {v18.4S, v19.4S, v20.4S}, [x0], #48
    LD3 {v21.4S, v22.4S, v23.4S}, [x0], #48

    /* triple_GS_barrett sh, a0, a1, a2, b0, b1, b2, t0, t1, t2, zl, zh, pm */
    // 32-NTT: 0-1-2-3 vs 10-11-12-13
    LD2 {v24.4S, v25.4S}, [x1], #32 // [w0, w1, w2, w3]
    LD2 {v26.4S, v27.4S}, [x1], #32 // [w4, w5, w6, w7]
    triple_GS_barrett .4S,  v0 , v1 , v2 ,  v12, v13, v14,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v3 , v4 , v5 ,  v15, v16, v17,  v29, v30, v31,  v26.4S, v27.4S, v28.S[0]

    LD2 {v24.4S, v25.4S}, [x1], #32 // [w8, w9, wa, wb]
    LD2 {v26.4S, v27.4S}, [x1], #32 // [wc, wd, we, wf]
    triple_GS_barrett .4S,  v6 , v7 , v8 ,  v18, v19, v20,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v9 , v10, v11,  v21, v22, v23,  v29, v30, v31,  v26.4S, v27.4S, v28.S[0]

    // 16-NTT: 0-1-2-3 vs 8-9-a-b
    LD2 {v24.4S, v25.4S}, [x1], #32 // [w0, w2, w4, w6]
    LD2 {v26.4S, v27.4S}, [x1], #32 // [w8, wa, wc, we]
    triple_GS_barrett .4S,  v0 , v1 , v2 ,  v6 , v7 , v8 ,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v12, v13, v14,  v18, v19, v20,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v3 , v4 , v5 ,  v9 , v10, v11,  v29, v30, v31,  v26.4S, v27.4S, v28.S[0]
    triple_GS_barrett .4S,  v15, v16, v17,  v21, v22, v23,  v29, v30, v31,  v26.4S, v27.4S, v28.S[0]

    // 8-NTT: 0-1-2-3 vs 4-5-6-7
    TRN1 v29.2D, v24.2D, v26.2D // [w0, w2, w8, wa]
    TRN2 v30.2D, v24.2D, v26.2D // [w4, w6, wc, we]
    TRN1 v24.4S, v29.4S, v30.4S // [w0, w4, w8, wc] <--- next layer of NTT
    TRN1 v29.2D, v25.2D, v27.2D // [W0, W2, W8, Wa]
    TRN2 v30.2D, v25.2D, v27.2D // [W4, W6, Wc, We]
    TRN1 v25.4S, v29.4S, v30.4S // [W0, W4, W8, Wc] <--- next layer of NTT
    triple_GS_barrett .4S,  v0 , v1 , v2 ,  v3 , v4 , v5 ,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v6 , v7 , v8 ,  v9 , v10, v11,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v12, v13, v14,  v15, v16, v17,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]
    triple_GS_barrett .4S,  v18, v19, v20,  v21, v22, v23,  v29, v30, v31,  v24.4S, v25.4S, v28.S[0]

    /* transposition4x4 sh0, sh1, a0, a1, a2, a3, tl, th */
    transposition4x4 .4S, .2D, v0 , v3 , v6 , v9 , v29, v30
    transposition4x4 .4S, .2D, v1 , v4 , v7 , v10, v29, v30
    transposition4x4 .4S, .2D, v2 , v5 , v8 , v11, v29, v30
    transposition4x4 .4S, .2D, v12, v15, v18, v21, v29, v30
    transposition4x4 .4S, .2D, v13, v16, v19, v22, v29, v30
    transposition4x4 .4S, .2D, v14, v17, v20, v23, v29, v30

    // 4-NTT
    triple_subadd .4S,  v0 , v1 , v2 ,  v6 , v7 , v8 ,  v29, v30, v31, .16B
    triple_subadd .4S,  v12, v13, v14,  v18, v19, v20,  v29, v30, v31, .16B
    triple_GS_barrett .4S,  v3 , v4 , v5 ,  v9 , v10, v11,  v29, v30, v31,  v24.S[2], v25.S[2], v28.S[0]
    triple_GS_barrett .4S,  v15, v16, v17,  v21, v22, v23,  v29, v30, v31,  v24.S[2], v25.S[2], v28.S[0]
    // 2-NTT
    triple_subadd .4S,  v0 , v1 , v2 ,  v3 , v4 , v5 ,  v29, v30, v31, .16B
    triple_subadd .4S,  v6 , v7 , v8 ,  v9 , v10, v11,  v29, v30, v31, .16B
    triple_subadd .4S,  v12, v13, v14,  v15, v16, v17,  v29, v30, v31, .16B
    triple_subadd .4S,  v18, v19, v20,  v21, v22, v23,  v29, v30, v31, .16B

    /* transposition4x4 sh0, sh1, a0, a1, a2, a3, tl, th */
    // however, we can do basemul without transposition back, if we pre-permutate the convolution factor carefully
    transposition4x4 .4S, .2D, v0 , v3 , v6 , v9 , v29, v30
    transposition4x4 .4S, .2D, v1 , v4 , v7 , v10, v29, v30
    transposition4x4 .4S, .2D, v2 , v5 , v8 , v11, v29, v30
    transposition4x4 .4S, .2D, v12, v15, v18, v21, v29, v30
    transposition4x4 .4S, .2D, v13, v16, v19, v22, v29, v30
    transposition4x4 .4S, .2D, v14, v17, v20, v23, v29, v30

    ST3 {v0.4S,  v1.4S,  v2.4S }, [x2], #48
    ST3 {v3.4S,  v4.4S,  v5.4S }, [x2], #48
    ST3 {v6.4S,  v7.4S,  v8.4S }, [x2], #48
    ST3 {v9.4S,  v10.4S, v11.4S}, [x2], #48
    ST3 {v12.4S, v13.4S, v14.4S}, [x2], #48
    ST3 {v15.4S, v16.4S, v17.4S}, [x2], #48
    ST3 {v18.4S, v19.4S, v20.4S}, [x2], #48
    ST3 {v21.4S, v22.4S, v23.4S}, [x2], #48

    MOV x1, x3  // restore pointer to twiddle factors
    ADD x4, x4, #1
    TBZ x4, #4, ntt512x3_32_16_8_4_2_LOOP    // x4 < 16

    ABI_POP
    RET