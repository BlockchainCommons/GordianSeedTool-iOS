/*
 * Low level API for Daan Sprenkels' Shamir secret sharing library
 * Copyright (c) 2017 Daan Sprenkels <hello@dsprenkels.com>
 *
 * Licensed under the "MIT License"
 *
 * Usage of this API is hazardous and is only reserved for beings with a
 * good understanding of the Shamir secret sharing scheme and who know how
 * crypto code is implemented. If you are unsure about this, use the
 * intermediate level API. You have been warned!
 */


#ifndef HAZMAT_H
#define HAZMAT_H

#include <inttypes.h>

void
bitslice(uint32_t r[8], const uint8_t x[32]);

void
unbitslice(uint8_t r[32], const uint32_t x[8]);

void
bitslice_setall(uint32_t r[8], const uint8_t x);

/*
 * Add (XOR) `r` with `x` and store the result in `r`.
 */
void
gf256_add(uint32_t r[8], const uint32_t x[8]);

/*
 * Safely multiply two bitsliced polynomials in GF(2^8) reduced by
 * x^8 + x^4 + x^3 + x + 1. `r` and `a` may overlap, but overlapping of `r`
 * and `b` will produce an incorrect result! If you need to square a polynomial
 * use `gf256_square` instead.
 */
void
gf256_mul(uint32_t r[8], const uint32_t a[8], const uint32_t b[8]);

/*
 * Square `x` in GF(2^8) and write the result to `r`. `r` and `x` may overlap.
 */
void
gf256_square(uint32_t r[8], const uint32_t x[8]);

/*
 * Invert `x` in GF(2^8) and write the result to `r`
 */
void
gf256_inv(uint32_t r[8], uint32_t x[8]);


#if 0

#define sss_KEYSHARE_LEN 33 /* 1 + 32 */

/*
 * One share of a cryptographic key which is shared using Shamir's
 * the `sss_create_keyshares` function.
 */
typedef uint8_t sss_Keyshare[sss_KEYSHARE_LEN];


/*
 * Share the secret given in `key` into `n` shares with a treshold value given
 * in `k`. The resulting shares are written to `out`.
 *
 * The share generation that is done in this function is only secure if the key
 * that is given is indeed a cryptographic key. This means that it should be
 * randomly and uniformly generated string of 32 bytes.
 *
 * Also, for performance reasons, this function assumes that both `n` and `k`
 * are *public* values.
 *
 * If you are looking for a function that *just* creates shares of arbitrary
 * data, you should use the `sss_create_shares` function in `sss.h`.
 */
void sss_create_keyshares(sss_Keyshare *out,
                          const uint8_t key[32],
                          uint8_t n,
                          uint8_t k);


/*
 * Combine the `k` shares provided in `shares` and write the resulting key to
 * `key`. The amount of shares used to restore a secret may be larger than the
 * threshold needed to restore them.
 *
 * This function does *not* do *any* checking for integrity. If any of the
 * shares not original, this will result in an invalid resored value.
 * All values written to `key` should be treated as secret. Even if some of the
 * shares that were provided as input were incorrect, the resulting key *still*
 * allows an attacker to gain information about the real key.
 *
 * This function treats `shares` and `key` as secret values. `k` is treated as
 * a public value (for performance reasons).
 *
 * If you are looking for a function that combines shares of arbitrary
 * data, you should use the `sss_combine_shares` function in `sss.h`.
 */
void sss_combine_keyshares(uint8_t key[32],
                           const sss_Keyshare *shares,
                           uint8_t k);
#endif

#endif /* HAZMAT_H */
