//
//  shamir.h
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef SHAMIR_H
#define SHAMIR_H

#include <stdint.h>
#include "shamir-errors.h"

#define MAX_SHARD_COUNT 16
#define SECRET_INDEX 255
#define DIGEST_INDEX 254

/**
 * creates a digest used to help valididate secret reconstruction (see slip-39 docs)
 *
 * returns: a pointer to the resulting 4-byte digest
 * inputs: random_data: array of data to create a digest for
 *         rdlen: length of random_data array
 *         shared_secret: bytes to use as the key for the hmac when generating digest
 *         sslen: length of the shared secret array
 *         result: a pointer to a block of 4 bytes to store the resulting digest
 */
uint8_t* create_digest(
    const uint8_t *random_data,
    uint32_t rdlen,
    const uint8_t *shared_secret,
    uint32_t sslen,
    uint8_t *result
);

//////////////////////////////////////////////////
// slip39 shamir sharing

/**
 * used slip39's version of shamir sharing to split a secret up into
 * shard_count shares such that threshold of them must be presented
 * to recover the secret.
 *
 * returns: the number of shards created
 *
 * inputs: threshold: number of shards required to recover secret
 *         shard_count: number of shards to generate
 *         secret: array of bytes representing the secret
 *         secret_length: length of the secret array. must be >= 16, <= 32 and even.
 *         result: place to store the resulting shares. Must be able to hold
 *                 share_count * secret_length bytes.
 *         ctx: user-defined context to be passed to the random_generator function.
 */
int32_t split_secret(
    uint8_t threshold,
    uint8_t shard_count,
    const uint8_t *secret,
    uint32_t secret_length,
    uint8_t *result,
    void* ctx,
    void (*random_generator)(uint8_t *, size_t, void*)
);

/**
 * recover a secret from shards
 *
 * returns: the number of bytes written to the secret array, or a negative value if there was an error
 *
 * inputs: threshold: number of shards required
 *         x: array of x values  (length threshold)
 *         shards: array (length threshold) of pointers to y value arrays
 *         shard_length: number of bytes in each y value array
 *         secret: array for writing results (must be at least shard_length long)
 */
int32_t recover_secret(
    uint8_t threshold,
    const uint8_t *x,
    const uint8_t **shards,
    uint32_t shard_length,
    uint8_t *secret
);

#endif /* SHAMIR_H */
