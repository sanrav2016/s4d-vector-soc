.section .text
.global _start
_start:
    li sp, 0x00004000 // Set stack pointer to the top of 16KB memory
    call main
inf_loop:
    j inf_loop