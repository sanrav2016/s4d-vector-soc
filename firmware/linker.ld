MEMORY {

    /* Testbench total memory is 16KB. */

    mem : ORIGIN = 0x00000000, LENGTH = 0x00010000

}



SECTIONS {

    /* 1. Executable Code */

    .text : ALIGN(4) {

        *(.text)

        *(.text.*)

    } > mem



    /* 2. Read-Only Constants (Your weights and input streams) */

    .rodata : ALIGN(4) {

        *(.rodata)

        *(.rodata.*)

    } > mem



    /* 3. Initialized Mutable Variables */

    .data : ALIGN(4) {

        *(.data)

        *(.data.*)

    } > mem



    /* 4. Uninitialized Variables (Your SSM state) */

    .bss : ALIGN(4) {

        _bss_start = .;

        *(.bss)

        *(.bss.*)

        *(COMMON)

        _bss_end = .;

    } > mem



    _end = .;

} 