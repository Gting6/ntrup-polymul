#include <stdint.h>
#include "good_intrinsic.h"
#include "polymod_intrinsic.h"
#include "ntt512x3.h"

extern void ntt512x3_bit_perm_with_reverse_good_2N_761(int32_t conv[], uint32_t (*const A)[3]);
extern void ntt512x3_bit_perm(uint32_t (*A)[3]);
extern void mul_conv3x3_mod16760833_512_aarch64_asm(uint32_t (*x)[3], const uint32_t (*y)[3]);

void new_impl(int16_t *res, const int16_t *big, const int16_t *small) {
  
  static uint32_t A[512][3], B[512][3];
  
  ntt512x3_good_permutation_N(A, big);
  ntt512x3_good_permutation_f3_centered_mul_invN(B, small);
  ntt512x3_mod16760833_ifft(A);
  ntt512x3_mod16760833_ifft2(B);
  mul_conv3x3_mod16760833_512_aarch64_asm(A, B);
  ntt512x3_bit_perm(A);
  ntt512x3_mod16760833_fft(A);
  ntt512x3_bit_perm_with_reverse_good_2N_761((int32_t*)B, A);
  mod16760833_xN_x_1_fM_center(res, (int32_t*)B);
}
