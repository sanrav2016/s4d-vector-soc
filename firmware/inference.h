/** 
    @file inference.h
    @brief Inference test for SSM accelerator

    @author Sanjay Ravishankar
*/

#pragma once

#include <stdint.h>

#define D_MODEL 16
#define D_STATE 8

#define ACCELERATION    
#define ACCEL_BRAM_BASE_ADDR 0x40000000

/*
Per channel:
Input dimensions 1x1 (input vector)
A dimensions D_STATE^2 (state transition matrix)
B dimensions D_STATEx1 (input to state matrix)
C dimensions 1xD_STATE (state to output matrix)
D dimensions 1x1 (skip connection)
Output dimensions 1x1 (output vector)

There are D_MODEL channels
*/


typedef struct {
    int16_t real[D_MODEL][D_STATE];
    int16_t imag[D_MODEL][D_STATE];
} ssm_matrix_t;

typedef struct {
    ssm_matrix_t A;
    ssm_matrix_t C;
    // B is implicitly 1.0 (4096), completely omitted from storage
} ssm_weights_t;

typedef struct {
    int16_t real[D_MODEL][D_STATE];
    int16_t imag[D_MODEL][D_STATE];
} ssm_state_t;

void ssm_init_state(ssm_state_t *state);

void ssm_step_sw(const ssm_weights_t *weights, ssm_state_t *state, 
                 const int16_t *input_u, int16_t *output_y);

void ssm_step_hw(const int16_t *input_u, int16_t *output_y);