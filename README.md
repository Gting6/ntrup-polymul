# NTRUP-POLYMUL

## Interface

```=c
new_implementation(int16_t* result, int16_t* big, int16_t* small);
```

where:
- `big` is a length-761 polynomial with coefficient in [-2295, 2295];
- `small` is a length-761 polynomial with coefficient in [-1, 1];
- `result` is the product of `big` and `small` in $\mathbb Z_{4591}[x]/\langle x^{761}-x-1\rangle$.

## Reference Implementation and Performance

- poor implementation: 1581k cycle counts;
- contractor's implementation (with my handcraft assembly NTT): 78k cycle counts.

