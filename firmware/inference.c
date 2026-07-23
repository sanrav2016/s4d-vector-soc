#include <stdint.h>
#include "print.h"
#include "inference.h"

// Define memset since libc isn't linked
void *memset(void *s, int c, unsigned int n)
{
    unsigned char *p = s;
    while (n--)
    {
        *p++ = (unsigned char)c;
    }
    return s;
}

void ssm_init_state(ssm_state_t *state)
{
    for (int h = 0; h < D_MODEL; h++)
    {
        for (int n = 0; n < D_STATE; n++)
        {
            state->real[h][n] = 0;
            state->imag[h][n] = 0;
        }
    }
}

void ssm_step_sw(const ssm_weights_t *weights, ssm_state_t *state,
                 const int16_t *input_u, int16_t *output_y)
{
    for (int h = 0; h < D_MODEL; h++)
    {
        print_str("\n--- Channel h = ");
        print_int(h);
        print_str(" ---\n");
        int32_t y_accumulator = 0;
        int16_t u_t = input_u[h]; // Input vector scalar entry for channel h
        for (int n = 0; n < D_STATE; n++)
        {
            // 1. Complex Multiplication: A_bar * state_{t-1}
            // Real component: (A_real * state_real) - (A_imag * state_imag)
            int32_t prod_real = ((int32_t)weights->A.real[h][n] * state->real[h][n]) -
                                ((int32_t)weights->A.imag[h][n] * state->imag[h][n]);

            // Imaginary component: (A_real * state_imag) + (A_imag * state_real)
            int32_t prod_imag = ((int32_t)weights->A.real[h][n] * state->imag[h][n]) +
                                ((int32_t)weights->A.imag[h][n] * state->real[h][n]);

            // 2. Rescale down from Q8.24 to Q4.12 via arithmetic shift right
            int16_t a_state_real = (int16_t)(prod_real >> 12);
            int16_t a_state_imag = (int16_t)(prod_imag >> 12);

            // 3. Complete state update. B = 1.0 (4096), so (B * u_t) >> 12 simplifies to u_t
            state->real[h][n] = a_state_real + u_t;
            state->imag[h][n] = a_state_imag; // B has no imaginary component

            // 4. Output projection accumulation: Re(C_bar * state_t)
            // Re(C * state) = (C_real * state_real) - (C_imag * state_imag)
            int32_t c_prod = ((int32_t)weights->C.real[h][n] * state->real[h][n]) -
                             ((int32_t)weights->C.imag[h][n] * state->imag[h][n]);

            y_accumulator += (c_prod >> 12);
            //print_int(y_accumulator);
            //print_chr(' ');
        }
        // Final output value for channel h
        output_y[h] = (int16_t)y_accumulator;
        //print_chr('\n');
    }
}

#define SSM_STEP_EXEC() __asm volatile (".word 0x00000000B\n\t")

void ssm_step_hw(const int16_t *input_u, int16_t *output_y) {
    volatile uint32_t *u_bram = (volatile uint32_t *)(ACCEL_BRAM_BASE_ADDR + 0x400);
    volatile uint32_t *y_bram = (volatile uint32_t *)(ACCEL_BRAM_BASE_ADDR + 0x420);

    const uint32_t *u_packed = (const uint32_t *)input_u;
    for (int i = 0; i < 8; i++) {
        u_bram[i] = u_packed[i];
    }

    // Custom instruction
    SSM_STEP_EXEC();

    uint32_t *y_packed = (uint32_t *)output_y;
    for (int i = 0; i < 8; i++) {
        y_packed[i] = y_bram[i];
    }
}