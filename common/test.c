#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "cpucycles.h"  // cycle count for A72
#include "sntrup761.h"  // parameter set

static int cmpfunc (const void * a, const void * b) {return ( *(int*)a - *(int*)b );}
extern void ref_impl(int16_t*, const int16_t*, const int16_t*);
extern void new_impl(int16_t*, const int16_t*, const int16_t*);

#ifndef REPS
#define REPS 1024
#endif

int main(void){
	int64_t fail[REPS], fail_total = 0, cc0, cc1, cc[REPS], cc_total = 0;

	int16_t f[SNTRUP_N], g[SNTRUP_N],h_new[SNTRUP_N], h_ref[SNTRUP_N];
	
	for (int round=0; round<REPS; round++) {
		
		/* Initialization */
		fail[round] = 0;
		for (int deg=0; deg<SNTRUP_N; deg++) {          // sample polynomial f, g
			f[deg] = (rand()%SNTRUP_M) - (SNTRUP_M/2);  // centered, [-2295, 2295]
			g[deg] = (rand()%3)-1;                      // small, [-1, 1]
#ifdef DEBUG_POLY
			f[deg] = 0;
			g[deg] = 0;
#endif
		}
#ifdef DEBUG_POLY
		f[0] = 4; g[0] = -1; f[1] = 3; g[1] = 1;
#endif

		/* Run implementation with benchmark */
		ref_impl(h_ref,f,g);
		cc0 = hal_get_time();
		new_impl(h_new,f,g);
		cc1 = hal_get_time();
		cc_total += (cc[round] = cc1-cc0);

		for (int deg=0; deg<SNTRUP_N; deg++) {
			if (h_new[deg] ^ h_ref[deg]) {
#ifdef DEBUG
				printf("Fail: h_ref[%3d] = %8d, h_new[%3d] = %8d. (In Test %d)\n", deg,h_ref[deg],deg,h_new[deg],round);
#endif
				fail[round] = 1;
#ifndef DEBUG
				break;
#endif
			}
		}
	fail_total += fail[round];
	}

	/* Report cyclecounts */
	qsort(cc, REPS, sizeof(int64_t), cmpfunc); // sort for the median
	printf("\n================ RESULT ================\n");
	printf("Rounds: %d, Success: %d, Fail: %d;\n", REPS, REPS-fail_total, fail_total);
	printf("Avg time = %d, Median = %d.\n",cc_total/REPS,cc[REPS>>1]);  // no need to multiply 64 on A72
}
