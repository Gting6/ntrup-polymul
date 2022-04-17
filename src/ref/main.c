#include <stdint.h>

static int16_t mock_mod4591(int64_t i){
    i %= 4591;
    if(i>2295){
	i -= 4591;
    }
    else if(i<-2295){
    	i += 4591;
    }
    return (int16_t)i;
}

void new_impl(int16_t *res, const int16_t *big, const int16_t *small){
    int i;
    for(i=0;i<761;i++){
        int64_t temp = 0;
        for(int j=0;j<=i;j++){
            temp += big[j] * small[i-j];
        }
        res[i] = mock_mod4591(temp);
    }
    for(;i<1521;i++){
        int64_t temp = 0;
        for(int j=i-760;j<761;j++){
            temp += big[j] * small[i-j];
        }
        res[i-760] = mock_mod4591(temp + res[i-760]);
        res[i-761] = mock_mod4591(temp + res[i-761]);
    }
}
