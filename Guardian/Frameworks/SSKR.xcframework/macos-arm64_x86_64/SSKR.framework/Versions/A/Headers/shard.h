//
//  shard.h
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef SHARD_H
#define SHARD_H

#include <stdint.h>
#include <stdlib.h>

typedef struct sskr_shard_struct {
    uint16_t identifier;
    size_t group_index;
    size_t group_threshold;
    size_t group_count;
    size_t member_index;
    size_t member_threshold;
    size_t value_len;
    uint8_t value[32];
} sskr_shard;

#endif /* SHARD_H */
