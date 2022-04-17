#include <stdint.h>
#include "args_ntt_16760833_512_full.h"


extern void ntt512x3_512_256_128_64(uint32_t (*A)[3], const uint64_t *wW, const int MODP);
extern void ntt512x3_32_16_8_4_2(uint32_t (*A)[3], const uint64_t *wW, const int MODP);

void ntt512x3_mod16760833_ifft2(uint32_t (*a)[3]) {
  ntt512x3_512_256_128_64(a, args_w_Wh_16760833_512_11680345_512_256_128_64, 16760833);
  ntt512x3_32_16_8_4_2(a, args_w_Wh_16760833_512_11680345_32_16_8_4_2, 16760833);
}
void ntt512x3_mod16760833_ifft(uint32_t (*a)[3]) {
  ntt512x3_512_256_128_64(a, args_w_Wh_16760833_512_11680345_512_256_128_64, 16760833);
  ntt512x3_32_16_8_4_2(a, args_w_Wh_16760833_512_11680345_32_16_8_4_2, 16760833);
}
void ntt512x3_mod16760833_fft(uint32_t (*a)[3]) {
  ntt512x3_512_256_128_64(a, args_w_Wh_16760833_512_10843986_512_256_128_64, 16760833);
  ntt512x3_32_16_8_4_2(a, args_w_Wh_16760833_512_10843986_32_16_8_4_2, 16760833);
}