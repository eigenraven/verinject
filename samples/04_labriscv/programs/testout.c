
__attribute__((always_inline)) inline void write_led_port(int value)
{
    __asm__ volatile(
        "csrw 0x7C1, %0"
        :
        : "rK"(value)
        : "memory");
}

void _start()
{
    write_led_port(0);
    write_led_port(1);
    write_led_port(2);
    write_led_port(3);
    while (1)
    {
        __asm__ __volatile__(""
                             :
                             :
                             : "memory");
    }
}
