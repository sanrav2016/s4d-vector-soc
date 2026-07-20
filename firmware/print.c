// This is free and unencumbered software released into the public domain.
//
// Anyone is free to copy, modify, publish, use, compile, sell, or
// distribute this software, either in source code form or as a compiled
// binary, for any purpose, commercial or non-commercial, and by any
// means.

#include <stdint.h>
#include "print.h"

#define OUTPORT 0x10000000

void print_chr(char ch)
{
	*((volatile uint32_t*)OUTPORT) = ch;
}

void print_str(const char *p)
{
	while (*p != 0)
		*((volatile uint32_t*)OUTPORT) = *(p++);
}

void print_int(unsigned int val)
{
	if (val == 0) {
        print_chr('0');
        return;
    }
    
    // Explicit two's complement conversion to avoid signed undefined behavior
    uint32_t uval = (val < 0) ? (~((uint32_t)val) + 1) : (uint32_t)val;
    if (val < 0) {
        print_chr('-');
    }

    int started = 0;
    uint32_t count;

    // Direct scalar macro: No arrays, no pointers, pure registers
    #define EXTRACT_DIGIT(DIVISOR) \
        count = 0; \
        while (uval >= DIVISOR) { \
            uval -= DIVISOR; \
            count++; \
        } \
        if (count > 0 || started) { \
            print_chr(count + '0'); \
            started = 1; \
        }

    // Step through each base-10 magnitude using immediate literals
    EXTRACT_DIGIT(1000000000)
    EXTRACT_DIGIT(100000000)
    EXTRACT_DIGIT(10000000)
    EXTRACT_DIGIT(1000000)
    EXTRACT_DIGIT(100000)
    EXTRACT_DIGIT(10000)
    EXTRACT_DIGIT(1000)
    EXTRACT_DIGIT(100)
    EXTRACT_DIGIT(10)

    #undef EXTRACT_DIGIT

    // The remaining value is strictly the final single digit (0-9)
    print_chr(uval + '0');
}


