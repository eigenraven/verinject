
__attribute__((always_inline)) inline void write_led_port(int value)
{
    __asm__ volatile(
        "csrw 0x7C1, %0"
        :
        : "r"(value)
        : "memory");
}

void _start()
{
    for (int i = 0; i < 16; i++)
    {
        write_led_port(i);
    }
    while (1)
    {
        __asm__ __volatile__(""
                             :
                             :
                             : "memory");
    }
}
