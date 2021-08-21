//
//  group.h
//
//  Copyright © 2020 by Blockchain Commons, LLC
//  Licensed under the "BSD-2-Clause Plus Patent License"
//

#ifndef GROUP_H
#define GROUP_H

#include <stdlib.h>
#include <stdint.h>

#if defined(__EMSCRIPTEN__)
#pragma pack(push, 1)
#endif

typedef struct sskr_group_descriptor_struct {
    uint8_t threshold;
    uint8_t count;
} sskr_group_descriptor;

#if defined(__EMSCRIPTEN__)
#pragma pack(pop)
#endif

#endif /* GROUP_H */
