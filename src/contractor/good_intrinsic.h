#include <arm_neon.h>
#include <stdint.h>
#define SNTRUP_N 761
#define asm __asm__
#define reg64(x) asm(x)
#define constexpr const

#ifndef __INTELLISENSE__

void ntt512x3_good_permutation_f3_centered_mul_invN(uint32_t (*A)[3], const int16_t a[SNTRUP_N]) {
  
  const int16_t *x = a, *y = (a + 512);
  register const uint32x4_t zero reg64("v0") = vdupq_n_u32(0);
  const int32_t onev = 16760833 - 16728097;
  register const int16x4_t one reg64("v31") = vdup_n_s16(onev);
  register constexpr uint8x16_t idx01_0 reg64("v1") = {
      0,      1,      255,   255,   8 + 8, 8 + 9, 8 + 10, 8 + 11,
      16 + 8, 16 + 9, 8 + 0, 8 + 1, 255,   255,   255,    255};
  register constexpr uint8x16_t idx01_1 reg64("v2") = {
      2,       3,       255,   255,   255,   255,   8 + 12, 8 + 13,
      16 + 10, 16 + 11, 8 + 2, 8 + 3, 8 + 4, 8 + 5, 255,    255};
  register constexpr uint8x16_t idx01_2 reg64("v3") = {
      4,       5,       6,       7,       255,   255,   8 + 14, 8 + 15,
      16 + 12, 16 + 13, 16 + 14, 16 + 15, 8 + 6, 8 + 7, 255,    255};
  register constexpr uint8x8_t idx2_0 reg64("v7") = {255, 255, 8, 9,
                                                     0,   1,   2, 3};
  register constexpr uint8x8_t idx2_1 reg64("v8") = {255, 255, 10, 11,
                                                     12,  13,  4,  5};
  register constexpr uint8x8_t idx2_2 reg64("v9") = {255, 255, 255, 255,
                                                     14,  15,  6,   7};
  
  for (int i = 0;; i += 12) {
    uint8x16x2_t v4_01;
    int16x8_t xval01 = vld1q_s16(&x[i]);
    int16x8_t yval01 = vld1q_s16(&y[i]);

    xval01 = vmulq_n_s16(xval01, -32736);
    yval01 = vmulq_n_s16(yval01, -32736);

    v4_01.val[0] = vreinterpretq_u8_s16(xval01);
    v4_01.val[1] = vreinterpretq_u8_s16(yval01);

    int16x8_t r01_0 = vreinterpretq_s16_u8(vqtbl2q_u8(v4_01, idx01_0));
    int16x8_t r01_1 = vreinterpretq_s16_u8(vqtbl2q_u8(v4_01, idx01_1));
    int16x8_t r01_2 = vreinterpretq_s16_u8(vqtbl2q_u8(v4_01, idx01_2));

    int32x4_t s0_0 = vmovl_s16(vget_low_s16(r01_0));
    int32x4_t s0_1 = vmovl_s16(vget_low_s16(r01_1));
    int32x4_t s0_2 = vmovl_s16(vget_low_s16(r01_2));
    int32x4_t s1_0 = vmovl_s16(vget_high_s16(r01_0));
    int32x4_t s1_1 = vmovl_s16(vget_high_s16(r01_1));
    int32x4_t s1_2 = vmovl_s16(vget_high_s16(r01_2));

    vst1q_u32(&A[i][0], vreinterpretq_u32_s32(s0_0));
    vst1q_u32(&A[i][4], vreinterpretq_u32_s32(s0_1));
    vst1q_u32(&A[i][8], vreinterpretq_u32_s32(s0_2));
    vst1q_u32(&A[i + 4][0], vreinterpretq_u32_s32(s1_0));
    vst1q_u32(&A[i + 4][4], vreinterpretq_u32_s32(s1_1));
    vst1q_u32(&A[i + 4][8], vreinterpretq_u32_s32(s1_2));

    if (i == 240) break;

    uint8x8x2_t v4_2;
    int16x4_t xval2 = vld1_s16(&x[i + 8]);
    int16x4_t yval2 = vld1_s16(&y[i + 8]);

    xval2 = vmul_n_s16(xval2, -32736);
    yval2 = vmul_n_s16(yval2, -32736);

    v4_2.val[0] = vreinterpret_u8_s16(xval2);
    v4_2.val[1] = vreinterpret_u8_s16(yval2);

    int16x4_t r2_0 = vreinterpret_s16_u8(vtbl2_u8(v4_2, idx2_0));
    int16x4_t r2_1 = vreinterpret_s16_u8(vtbl2_u8(v4_2, idx2_1));
    int16x4_t r2_2 = vreinterpret_s16_u8(vtbl2_u8(v4_2, idx2_2));

    int32x4_t s2_0 = vmovl_s16(r2_0);
    int32x4_t s2_1 = vmovl_s16(r2_1);
    int32x4_t s2_2 = vmovl_s16(r2_2);

    vst1q_u32(&A[i + 8][0], vreinterpretq_u32_s32(s2_0));
    vst1q_u32(&A[i + 8][4], vreinterpretq_u32_s32(s2_1));
    vst1q_u32(&A[i + 8][8], vreinterpretq_u32_s32(s2_2));
  }

  for (int i = 248; i < 512; i += 12) {

    uint32x4_t v4_0, v4_1, v4_2;
    int16x4_t xval2 = vld1_s16(&x[i]);
    xval2 = vmul_n_s16(xval2, -32736);
    v4_2 = vreinterpretq_u32_s32(vmovl_s16(xval2));

    uint32x4_t r2_0 = vsetq_lane_u32(vgetq_lane_u32(v4_2, 0), zero, 2);
    uint32x4_t r2_1 = vsetq_lane_u32(vgetq_lane_u32(v4_2, 2), zero, 3);
    uint32x4_t r2_2 = vsetq_lane_u32(vgetq_lane_u32(v4_2, 3), zero, 3);
    r2_0 = vsetq_lane_u32(vgetq_lane_u32(v4_2, 1), r2_0, 3);

    vst1q_u32(&A[i][0], r2_0);
    vst1q_u32(&A[i][4], r2_1);
    vst1q_u32(&A[i][8], r2_2);

    int16x4_t xval0 = vld1_s16(&x[i + 4]);

    xval0 = vmul_n_s16(xval0, -32736);

    v4_0 = vreinterpretq_u32_s32(vmovl_s16(xval0));

    uint32x4_t r0_0 = vsetq_lane_u32(vgetq_lane_u32(v4_0, 0), zero, 0);
    uint32x4_t r0_1 = vsetq_lane_u32(vgetq_lane_u32(v4_0, 1), zero, 0);
    uint32x4_t r0_2 = vsetq_lane_u32(vgetq_lane_u32(v4_0, 2), zero, 0);

    r0_2 = vsetq_lane_u32(vgetq_lane_u32(v4_0, 3), r0_2, 1);

    vst1q_u32(&A[i + 4][0], r0_0);
    vst1q_u32(&A[i + 4][4], r0_1);
    vst1q_u32(&A[i + 4][8], r0_2);

    int16x4_t xval1 = vld1_s16(&x[i + 8]);

    xval1 = vmul_n_s16(xval1, -32736);

    v4_1 = vreinterpretq_u32_s32(vmovl_s16(xval1));

    uint32x4_t r1_0 = vsetq_lane_u32(vgetq_lane_u32(v4_1, 0), zero, 1);
    uint32x4_t r1_1 = vsetq_lane_u32(vgetq_lane_u32(v4_1, 1), zero, 1);
    uint32x4_t r1_2 = vsetq_lane_u32(vgetq_lane_u32(v4_1, 3), zero, 2);
    r1_1 = vsetq_lane_u32(vgetq_lane_u32(v4_1, 2), r1_1, 2);

    vst1q_u32(&A[i + 8][0], r1_0);
    vst1q_u32(&A[i + 8][4], r1_1);
    vst1q_u32(&A[i + 8][8], r1_2);
  }

  A[248][1] = (((int32_t)x[760] & onev) - ((int32_t)(-x[760]) & onev));

}

void ntt512x3_good_permutation_N(uint32_t (*A)[3], const int16_t a[SNTRUP_N]) {
  const int16_t *x = a, *y = (a + 512);

  register const uint32x4_t zero reg64("v0") = vdupq_n_u32(0);

  register constexpr uint8x16_t idx01_0 reg64("v1") = {
      0,      1,      255,   255,   8 + 8, 8 + 9, 8 + 10, 8 + 11,
      16 + 8, 16 + 9, 8 + 0, 8 + 1, 255,   255,   255,    255};
  register constexpr uint8x16_t idx01_1 reg64("v2") = {
      2,       3,       255,   255,   255,   255,   8 + 12, 8 + 13,
      16 + 10, 16 + 11, 8 + 2, 8 + 3, 8 + 4, 8 + 5, 255,    255};
  register constexpr uint8x16_t idx01_2 reg64("v3") = {
      4,       5,       6,       7,       255,   255,   8 + 14, 8 + 15,
      16 + 12, 16 + 13, 16 + 14, 16 + 15, 8 + 6, 8 + 7, 255,    255};
  register constexpr uint8x8_t idx2_0 reg64("v7") = {255, 255, 8, 9,
                                                     0,   1,   2, 3};
  register constexpr uint8x8_t idx2_1 reg64("v8") = {255, 255, 10, 11,
                                                     12,  13,  4,  5};
  register constexpr uint8x8_t idx2_2 reg64("v9") = {255, 255, 255, 255,
                                                     14,  15,  6,   7};
  for (int i = 0;; i += 12) {

    uint8x16x2_t v4_01;

    int16x8_t xval01 = vld1q_s16(&x[i]);
    int16x8_t yval01 = vld1q_s16(&y[i]);

    v4_01.val[0] = vreinterpretq_u8_s16(xval01);
    v4_01.val[1] = vreinterpretq_u8_s16(yval01);

    int16x8_t r01_0 = vreinterpretq_s16_u8(vqtbl2q_u8(v4_01, idx01_0));
    int16x8_t r01_1 = vreinterpretq_s16_u8(vqtbl2q_u8(v4_01, idx01_1));
    int16x8_t r01_2 = vreinterpretq_s16_u8(vqtbl2q_u8(v4_01, idx01_2));

    int32x4_t s0_0 = vmovl_s16(vget_low_s16(r01_0));
    int32x4_t s0_1 = vmovl_s16(vget_low_s16(r01_1));
    int32x4_t s0_2 = vmovl_s16(vget_low_s16(r01_2));
    int32x4_t s1_0 = vmovl_s16(vget_high_s16(r01_0));
    int32x4_t s1_1 = vmovl_s16(vget_high_s16(r01_1));
    int32x4_t s1_2 = vmovl_s16(vget_high_s16(r01_2));

    vst1q_u32(&A[i][0], vreinterpretq_u32_s32(s0_0));
    vst1q_u32(&A[i][4], vreinterpretq_u32_s32(s0_1));
    vst1q_u32(&A[i][8], vreinterpretq_u32_s32(s0_2));
    vst1q_u32(&A[i + 4][0], vreinterpretq_u32_s32(s1_0));
    vst1q_u32(&A[i + 4][4], vreinterpretq_u32_s32(s1_1));
    vst1q_u32(&A[i + 4][8], vreinterpretq_u32_s32(s1_2));

    if (i == 240) break;

    uint8x8x2_t v4_2;
    v4_2.val[0] = vreinterpret_u8_s16(vld1_s16(&x[i + 8]));
    v4_2.val[1] = vreinterpret_u8_s16(vld1_s16(&y[i + 8]));

    int16x4_t r2_0 = vreinterpret_s16_u8(vtbl2_u8(v4_2, idx2_0));
    int16x4_t r2_1 = vreinterpret_s16_u8(vtbl2_u8(v4_2, idx2_1));
    int16x4_t r2_2 = vreinterpret_s16_u8(vtbl2_u8(v4_2, idx2_2));

    vst1q_u32(&A[i + 8][0], vreinterpretq_u32_s32(vmovl_s16(r2_0)));
    vst1q_u32(&A[i + 8][4], vreinterpretq_u32_s32(vmovl_s16(r2_1)));
    vst1q_u32(&A[i + 8][8], vreinterpretq_u32_s32(vmovl_s16(r2_2)));
  }

  for (int i = 248; i < 512; i += 12) {

    uint32x4_t v4_0, v4_1, v4_2;

    v4_2 = vreinterpretq_u32_s32(vmovl_s16(vld1_s16(&x[i])));

    uint32x4_t r2_0 = vsetq_lane_u32(vgetq_lane_u32(v4_2, 0), zero, 2);
    uint32x4_t r2_1 = vsetq_lane_u32(vgetq_lane_u32(v4_2, 2), zero, 3);
    uint32x4_t r2_2 = vsetq_lane_u32(vgetq_lane_u32(v4_2, 3), zero, 3);
    r2_0 = vsetq_lane_u32(vgetq_lane_u32(v4_2, 1), r2_0, 3);

    vst1q_u32(&A[i][0], r2_0);
    vst1q_u32(&A[i][4], r2_1);
    vst1q_u32(&A[i][8], r2_2);

    v4_0 = vreinterpretq_u32_s32(vmovl_s16(vld1_s16(&x[i + 4])));

    uint32x4_t r0_0 = vsetq_lane_u32(vgetq_lane_u32(v4_0, 0), zero, 0);
    uint32x4_t r0_1 = vsetq_lane_u32(vgetq_lane_u32(v4_0, 1), zero, 0);
    uint32x4_t r0_2 = vsetq_lane_u32(vgetq_lane_u32(v4_0, 2), zero, 0);

    r0_2 = vsetq_lane_u32(vgetq_lane_u32(v4_0, 3), r0_2, 1);

    vst1q_u32(&A[i + 4][0], r0_0);
    vst1q_u32(&A[i + 4][4], r0_1);
    vst1q_u32(&A[i + 4][8], r0_2);

    v4_1 = vreinterpretq_u32_s32(vmovl_s16(vld1_s16(&x[i + 8])));

    uint32x4_t r1_0 = vsetq_lane_u32(vgetq_lane_u32(v4_1, 0), zero, 1);
    uint32x4_t r1_1 = vsetq_lane_u32(vgetq_lane_u32(v4_1, 1), zero, 1);
    uint32x4_t r1_2 = vsetq_lane_u32(vgetq_lane_u32(v4_1, 3), zero, 2);
    r1_1 = vsetq_lane_u32(vgetq_lane_u32(v4_1, 2), r1_1, 2);

    vst1q_u32(&A[i + 8][0], r1_0);
    vst1q_u32(&A[i + 8][4], r1_1);
    vst1q_u32(&A[i + 8][8], r1_2);
  }

  A[248][1] = x[760];

}

#endif