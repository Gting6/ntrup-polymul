#include <arm_neon.h>
#include <stdint.h>
#define SNTRUP_N 761
#define SNTRUP_M 4591
#define asm __asm__
#define reg64(x) asm(x)
#define constexpr const

__attribute__((optimize("unroll-loops"))) static inline void
mod16760833_xN_x_1_fM_center(int16_t *hr, int32_t *res) {
  int32_t res0 = res[0];
  res[0] -= res[SNTRUP_N - 1];
  const int32_t NTTM = 16760833;
  const int32_t NTRUM = SNTRUP_M;
  const int16x4_t Mx4 = vdup_n_s16(SNTRUP_M);
  const int16x4_t MHx4 = vdup_n_s16(SNTRUP_M / 2);

#if SNTRUP_M == 4591
  const int32_t INVNTRUM = 467759;
#elif SNTRUP_M == 4621
  const int32_t INVNTRUM = 464722;
#elif SNTRUP_M == 5167
  const int32_t INVNTRUM = 415615;
#elif SNTRUP_M == 6343
  const int32_t INVNTRUM = 338559;
#elif SNTRUP_M == 7177
  const int32_t INVNTRUM = 299217;
#elif SNTRUP_M == 7879
  const int32_t INVNTRUM = 272557;
#else
  for (;;)
    ;
#endif

  for (int i = 0;; i += 12) {
    int32x4_t Ai0 = vld1q_s32(&res[i]);
    int32x4_t Ai1 = vld1q_s32(&res[i + 4]);
    int32x4_t Ai2 = vld1q_s32(&res[i + 8]);
    int32x4_t Aj0 = vld1q_s32(&res[i + SNTRUP_N - 1]);
    int32x4_t Aj1 = vld1q_s32(&res[i + SNTRUP_N - 1 + 4]);
    int32x4_t Aj2 = vld1q_s32(&res[i + SNTRUP_N - 1 + 8]);
    int32x4_t Ak0 = vextq_s32(Aj0, Aj1, 1);
    int32x4_t Ak1 = vextq_s32(Aj1, Aj2, 1);
    int32x4_t Ak2 = vld1q_s32(&res[i + SNTRUP_N + 8]);
    Ai0 += Aj0 + Ak0;
    Ai1 += Aj1 + Ak1;
    Ai2 += Aj2 + Ak2;
    Ai0 = vmlsq_n_s32(Ai0, vrshrq_n_s32(Ai0, 24), NTTM);
    Ai1 = vmlsq_n_s32(Ai1, vrshrq_n_s32(Ai1, 24), NTTM);
    Ai2 = vmlsq_n_s32(Ai2, vrshrq_n_s32(Ai2, 24), NTTM);
    Ai0 = vmlsq_n_s32(Ai0, vqdmulhq_n_s32(Ai0, INVNTRUM), NTRUM);
    Ai1 = vmlsq_n_s32(Ai1, vqdmulhq_n_s32(Ai1, INVNTRUM), NTRUM);
    Ai2 = vmlsq_n_s32(Ai2, vqdmulhq_n_s32(Ai2, INVNTRUM), NTRUM);
    int16x4_t B0 = vmovn_s32(Ai0);
    int16x4_t B1 = vmovn_s32(Ai1);
    int16x4_t B2 = vmovn_s32(Ai2);
    B0 -= vreinterpret_s16_u16(vcgt_s16(vabs_s16(B0), MHx4) & Mx4);
    B1 -= vreinterpret_s16_u16(vcgt_s16(vabs_s16(B1), MHx4) & Mx4);
    B2 -= vreinterpret_s16_u16(vcgt_s16(vabs_s16(B2), MHx4) & Mx4);
    vst1_s16(&hr[i], B0);
    if (i == SNTRUP_N - 5) {
      hr[i + 4] = vget_lane_s16(B1, 0);
      break;
    }
    vst1_s16(&hr[i + 4], B1);
    vst1_s16(&hr[i + 8], B2);
  }
  res[0] = res0;
}
