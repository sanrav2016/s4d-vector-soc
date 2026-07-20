.section .text
.global _start

_start:
    # 0x00000000: Reset Vector (Jump past the trap vector area)
    j boot

    .balign 16
trap_vector:
    # 0x00000010: PicoRV32 hardware trap/exception vector
    j trap_vector

boot:
    # 1. Setup Stack Pointer at the top of your VALID 16KB memory space
    li sp, 0x00010000

    # 2. Clear the .bss section to 0 so your matrix states start clean
    la a0, _bss_start
    la a1, _bss_end
bss_loop:
    bge a0, a1, bss_done
    sw zero, 0(a0)
    addi a0, a0, 4
    j bss_loop

bss_done:
    # 3. Call your C main function safely
    jal main

# If main ever finishes, park the CPU core safely
end_loop:
    j end_loop