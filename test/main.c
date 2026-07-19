// Define magic memory addresses for simulation control
#define MMIO_PRINT 0x10000000
#define MMIO_EXIT  0x20000000

void print_chr(char c) {
    *(volatile int *)MMIO_PRINT = c;
}

int main() {
    char *msg = "Hello from PicoRV32!\n";
    while (*msg) {
        print_chr(*msg++);
    }
    *(volatile int *)MMIO_EXIT = 1;
    return 0;
}